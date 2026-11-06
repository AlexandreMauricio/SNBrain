# Usage (from the vault root):  powershell -ExecutionPolicy Bypass -File _meta/tools/audit.ps1 [-Strict]
# Final step of the "check before you write" rule: structural checks after adding notes.
# Reports: missing frontmatter keys, tags not in _meta/Tag Vocabulary.md, broken [[wikilinks]],
# notes not listed in any _index.md, how-tos without an Example section, BOMs, empty or extensionless files,
# verified notes without verified-by, recipes without a Flow diagram, verified exercises that link
# no verified how-to or recipe, status counts. "Not read yet" notes are a warning only.
# -Strict exits with code 1 when any error list is non-empty (used by .github/workflows/audit.yml).
param([switch]$Strict)

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$vocabText = Get-Content (Join-Path $root "_meta\Tag Vocabulary.md") -Raw -Encoding utf8
$vocab = [regex]::Matches($vocabText, '`([a-z0-9\-]+)`') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique

# Every path test below uses the path relative to the vault root, so the folder the vault sits in
# (e.g. a temp folder whose path contains "claude") can never exclude notes by accident.
function Rel($item) { $item.FullName.Substring($root.Length + 1) }
$all = Get-ChildItem -Path $root -Recurse -Filter *.md | Where-Object { (Rel $_) -notmatch '^\.obsidian\\|^Templates\\|^\.git\\' }
$names = @{}; $all | ForEach-Object { $names[$_.BaseName] = $true }
# Attachments and other files can be embedded or linked by full file name (![[image.png]])
Get-ChildItem -Path $root -Recurse -File | Where-Object { (Rel $_) -notmatch '^\.git\\|^\.obsidian\\' -and $_.Extension -ne '.md' } | ForEach-Object { $names[$_.Name] = $true }
$notes = $all | Where-Object { $_.Name -notin @('_index.md', 'README.md', 'CLAUDE.md') -and $_.Name -notmatch 'Bem-vindo' }

$indexText = ($all | Where-Object { $_.Name -eq '_index.md' } | ForEach-Object { Get-Content $_.FullName -Raw -Encoding utf8 }) -join "`n"

$missing = @(); $badTags = @(); $noExample = @(); $notIndexed = @(); $broken = @(); $status = @{}; $bom = @(); $staleRead = @()
$oddFiles = @(); $noVerifiedBy = @(); $noFlow = @(); $noRecipe = @(); $noteStatus = @{}; $exercises = @()
Get-ChildItem -Path $root -Recurse -File -Force | Where-Object { (Rel $_) -notmatch '^\.git\\|^\.obsidian\\' -and $_.Name -notmatch '^\.git(keep|ignore|attributes)$' } | ForEach-Object {
    if ($_.Length -eq 0 -or $_.Name -notmatch '\.') { $oddFiles += $_.FullName.Substring($root.Length + 1) }
}
foreach ($f in $all) {
    $b = [IO.File]::ReadAllBytes($f.FullName)
    if ($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF) { $bom += $f.BaseName }
}
foreach ($f in $notes) {
    $c = Get-Content $f.FullName -Raw -Encoding utf8
    if ($f.Name -notin @('Test Queue.md', 'Findings Log.md', 'Docs vs Reality.md') -and $c -match '(?i)not read yet|not yet read|has not been read') { $staleRead += $f.BaseName }
}
foreach ($f in $notes) {
    $c = Get-Content $f.FullName -Raw -Encoding utf8
    if ($c -notmatch '(?s)^---\r?\n(.*?)\r?\n---') { $missing += "$($f.BaseName): no frontmatter"; continue }
    $fm = $Matches[1]
    foreach ($k in 'type', 'tags', 'status', 'source', 'updated') { if ($fm -notmatch "(?m)^$k\s*:") { $missing += "$($f.BaseName): missing $k" } }
    if ($fm -match '(?m)^tags:\s*\[(.*?)\]') { foreach ($t in ($Matches[1] -split ',')) { $t = $t.Trim(); if ($t -and ($vocab -notcontains $t)) { $badTags += "$($f.BaseName): $t" } } }
    $st = ''
    if ($fm -match '(?m)^status:\s*(\S+)') { $st = $Matches[1]; $status[$st] = 1 + [int]$status[$st] }
    $noteStatus[$f.BaseName] = @($st, $f.FullName)
    if ($st -eq 'verified' -and $fm -notmatch '(?m)^verified-by:[ \t]*\S') { $noVerifiedBy += $f.BaseName }
    $isRecipe = (Rel $f) -match '^04-Scripts-Automation\\'
    if ($isRecipe -and $c -notmatch '(?m)^## Flow') { $noFlow += $f.BaseName }
    if ($st -eq 'verified' -and $fm -match '(?m)^type:\s*exercise') { $exercises += , @($f.BaseName, $c) }
    if ($fm -match '(?m)^type:\s*how-to' -and $c -notmatch '(?i)## Example') { $noExample += $f.BaseName }
    if ((Rel $f) -notmatch '^(_meta|09-Exercises)\\' -and $indexText -notmatch [regex]::Escape("[[$($f.BaseName)]]")) { $notIndexed += $f.BaseName }
}
foreach ($f in $all) {
    $c = Get-Content $f.FullName -Raw -Encoding utf8
    foreach ($m in [regex]::Matches($c, '\[\[([^\]\|#]+)')) {
        $n = $m.Groups[1].Value.Trim(); if ($n -match '/') { $n = ($n -split '/')[-1] }
        if (-not $names.ContainsKey($n) -and $f.Name -notin @('CLAUDE.md', '_index.md') -and $f.Name -notmatch 'Bem-vindo') { $broken += "$($f.BaseName) -> $n" }
    }
}

foreach ($e in $exercises) {
    $ok = $false
    foreach ($m in [regex]::Matches($e[1], '\[\[([^\]\|#]+)')) {
        $n = $m.Groups[1].Value.Trim()
        if ($noteStatus.ContainsKey($n) -and $noteStatus[$n][0] -eq 'verified' -and $noteStatus[$n][1] -match '\\(03-How-To|04-Scripts-Automation|06-Reporting)\\') { $ok = $true; break }
    }
    if (-not $ok) { $noRecipe += $e[0] }
}

"notes: $($notes.Count)   status: " + (($status.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ', ')
foreach ($pair in @(@('Missing frontmatter keys', $missing), @('Tags not in vocabulary', $badTags), @('Broken links', $broken), @('Not listed in any _index.md', $notIndexed), @('How-tos without an Example section', $noExample), @('Files starting with a BOM (strip them)', $bom), @('Empty or extensionless files', $oddFiles), @('Verified notes without verified-by', $noVerifiedBy), @('Recipes without a ## Flow diagram', $noFlow), @('Verified exercises linking no verified how-to or recipe', $noRecipe), @('Notes saying "not read yet" (verify each is still true; warning only)', $staleRead))) {
    "{0}: {1}" -f $pair[0], $pair[1].Count
    $pair[1] | Sort-Object -Unique | Select-Object -First 15 | ForEach-Object { "   - $_" }
}

if ($Strict) {
    $errors = $missing.Count + $badTags.Count + $broken.Count + $notIndexed.Count + $noExample.Count + $bom.Count + $oddFiles.Count + $noVerifiedBy.Count + $noFlow.Count + $noRecipe.Count
    if ($errors -gt 0) { "AUDIT FAILED: $errors problem(s)"; exit 1 }
    "AUDIT PASSED"
}
