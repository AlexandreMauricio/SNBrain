# Usage (from the vault root):  powershell -File _meta/tools/audit.ps1
# Final step of the "check before you write" rule: structural checks after adding notes.
# Reports: missing frontmatter keys, tags not in _meta/Tag Vocabulary.md, broken [[wikilinks]],
# notes not listed in any _index.md, how-tos without an Example section, status counts.

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$vocabText = Get-Content (Join-Path $root "_meta\Tag Vocabulary.md") -Raw -Encoding utf8
$vocab = [regex]::Matches($vocabText, '`([a-z0-9\-]+)`') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique

$all = Get-ChildItem -Path $root -Recurse -Filter *.md | Where-Object { $_.FullName -notmatch '\\\.obsidian|\\Templates\\' }
$names = @{}; $all | ForEach-Object { $names[$_.BaseName] = $true }
$notes = $all | Where-Object { $_.Name -ne '_index.md' -and $_.FullName -notmatch 'Bem-vindo|README\.md|CLAUDE\.md' }

$indexText = ($all | Where-Object { $_.Name -eq '_index.md' } | ForEach-Object { Get-Content $_.FullName -Raw -Encoding utf8 }) -join "`n"

$missing = @(); $badTags = @(); $noExample = @(); $notIndexed = @(); $broken = @(); $status = @{}; $bom = @(); $staleRead = @()
foreach ($f in $all) {
    $b = [IO.File]::ReadAllBytes($f.FullName)
    if ($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF) { $bom += $f.BaseName }
}
foreach ($f in $notes) {
    $c = Get-Content $f.FullName -Raw -Encoding utf8
    if ($f.FullName -notmatch '_meta' -and $c -match '(?i)not read yet|not yet read|has not been read') { $staleRead += $f.BaseName }
}
foreach ($f in $notes) {
    $c = Get-Content $f.FullName -Raw -Encoding utf8
    if ($c -notmatch '(?s)^---\r?\n(.*?)\r?\n---') { $missing += "$($f.BaseName): no frontmatter"; continue }
    $fm = $Matches[1]
    foreach ($k in 'type', 'tags', 'status', 'source', 'updated') { if ($fm -notmatch "(?m)^$k\s*:") { $missing += "$($f.BaseName): missing $k" } }
    if ($fm -match '(?m)^tags:\s*\[(.*?)\]') { foreach ($t in ($Matches[1] -split ',')) { $t = $t.Trim(); if ($t -and ($vocab -notcontains $t)) { $badTags += "$($f.BaseName): $t" } } }
    if ($fm -match '(?m)^status:\s*(\S+)') { $status[$Matches[1]] = 1 + [int]$status[$Matches[1]] }
    if ($fm -match '(?m)^type:\s*how-to' -and $c -notmatch '(?i)## Example') { $noExample += $f.BaseName }
    if ($f.FullName -notmatch '_meta|09-Exercises' -and $indexText -notmatch [regex]::Escape("[[$($f.BaseName)]]")) { $notIndexed += $f.BaseName }
}
foreach ($f in $all) {
    $c = Get-Content $f.FullName -Raw -Encoding utf8
    foreach ($m in [regex]::Matches($c, '\[\[([^\]\|#]+)')) {
        $n = $m.Groups[1].Value.Trim(); if ($n -match '/') { $n = ($n -split '/')[-1] }
        if (-not $names.ContainsKey($n) -and $f.FullName -notmatch 'CLAUDE|Bem-vindo|_index' ) { $broken += "$($f.BaseName) -> $n" }
    }
}

"notes: $($notes.Count)   status: " + (($status.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ', ')
foreach ($pair in @(@('Missing frontmatter keys', $missing), @('Tags not in vocabulary', $badTags), @('Broken links', $broken), @('Not listed in any _index.md', $notIndexed), @('How-tos without an Example section', $noExample), @('Files starting with a BOM (strip them)', $bom), @('Notes saying "not read yet" (verify each is still true)', $staleRead))) {
    "{0}: {1}" -f $pair[0], $pair[1].Count
    $pair[1] | Sort-Object -Unique | Select-Object -First 15 | ForEach-Object { "   - $_" }
}
