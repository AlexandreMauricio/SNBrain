# Usage (from the vault root):  powershell -ExecutionPolicy Bypass -File _meta/tools/test-queue.ps1
# Rebuilds _meta/Test Queue.md: everything the vault says is still unconfirmed, grouped by folder,
# so a contributor with an instance open can pick something to test.
# Sources: bullets under "## Open questions" / "## Open points" / "## Still open" (minus answered ones),
# and body lines saying "unconfirmed" or "not confirmed". Exercises, _meta and templates are skipped.

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$out = Join-Path $root "_meta\Test Queue.md"

function Clean([string]$s) {
    $s = [regex]::Replace($s, '\[\[([^\]\|]+)\|([^\]]+)\]\]', '$2')
    $s = [regex]::Replace($s, '\[\[([^\]]+)\]\]', '$1')
    $s = $s -replace '^\s*(\d+\.|-|\*)\s*', '' -replace '\s+', ' '
    $s = $s.Trim()
    if ($s.Length -gt 220) { $s = $s.Substring(0, 217) + '...' }
    return $s
}

$files = Get-ChildItem -Path $root -Recurse -Filter *.md | Where-Object {
    $_.FullName -notmatch '\\\.git\\|\\\.obsidian\\|\\Templates\\|\\_meta\\|\\09-Exercises\\' -and
    $_.Name -notin @('_index.md', 'README.md', 'CLAUDE.md')
}
# ServiceNow release families in order; extend the list when a new family ships
$families = @('Utah', 'Vancouver', 'Washington', 'Xanadu', 'Yokohama', 'Zurich', 'Australia', 'Brazil', 'Cairo', 'Dublin')
function Rank([string]$s) { $r = -1; for ($i = 0; $i -lt $families.Count; $i++) { if ($s -match ('(?i)\b' + $families[$i] + '\b')) { $r = $i } }; return $r }

$groups = @{}; $total = 0; $noteCount = 0
$oneInstance = New-Object System.Collections.Generic.List[string]
$waiting = New-Object System.Collections.Generic.List[string]
# Latest release family recorded for any instance (Release column of _meta/Instances.md, bold values)
$maxInstance = -1
$inst = [IO.File]::ReadAllText((Join-Path $root '_meta\Instances.md'), [Text.Encoding]::UTF8)
foreach ($row in ($inst -split '\r?\n' | Where-Object { $_ -match '^\| ' })) {
    $cells = $row -split '\|'
    if ($cells.Count -gt 3 -and $cells[3] -match '\*\*([^*]+)\*\*') { $b = Rank $Matches[1]; if ($b -gt $maxInstance) { $maxInstance = $b } }
}
foreach ($f in $files) {
    $c = [IO.File]::ReadAllText($f.FullName, [Text.Encoding]::UTF8)
    $status = ''; $observed = ''; $fm = ''
    $body = $c
    if ($c -match '(?s)^---\r?\n(.*?)\r?\n---\r?\n(.*)$') {
        $fm = $Matches[1]; $body = $Matches[2]
        if ($fm -match '(?m)^status:\s*(\S+)') { $status = $Matches[1] }
        if ($fm -match '(?m)^observed-in:\s*\[?([^\]\r\n]*)') { $observed = $Matches[1].Trim() }
    }
    $items = New-Object System.Collections.Generic.List[string]
    $inOpen = $false; $inCode = $false
    foreach ($line in ($body -split '\r?\n')) {
        if ($line -match '^```') { $inCode = -not $inCode; continue }
        if ($inCode) { continue }
        if ($line -match '^#{2,3} ') { $inOpen = ($line -match '(?i)^#{2,3} (open questions|open points|still open)'); continue }
        if ($inOpen) {
            if ($line -match '^\s*(-|\*|\d+\.)\s+\S' -and $line -notmatch '(?i)\(answered|~~|^\s*(-|\d+\.)\s*answered') { $items.Add('Open: ' + (Clean $line)) }
            elseif ($line -match '^[A-Za-z*]' -and $line -notmatch '(?i)answered') { $items.Add('Open: ' + (Clean $line)) }
            continue
        }
        if ($line -match '(?i)\(contradicted') { $items.Add('Contradicted: ' + (Clean $line)) }
        elseif ($line -match '(?i)\bunconfirmed\b|\bnot confirmed\b' -and $line -notmatch '^\s*(source|sn-release):') {
            $items.Add('Unconfirmed: ' + (Clean $line))
        }
        elseif ($line -match '(?i)\(inference\b|\(inferred\b|\binferred from\b|\(inference\)') { $items.Add('Inference: ' + (Clean $line)) }
    }
    $rel = $f.FullName.Substring($root.Length + 1)
    if ($status -eq 'verified' -and $rel -match '^(03-How-To|04-Scripts-Automation|06-Reporting|07-Troubleshooting)') {
        $n = @($observed -split ',' | Where-Object { $_.Trim() }).Count
        if ($n -lt 2) { $oneInstance.Add("- [[$($f.BaseName)]] (" + $(if ($observed) { "only $observed" } else { 'instance not recorded' }) + ')') }
    }
    if ($fm -and $fm -match '(?m)^sn-release:\s*(.+)$' -and $maxInstance -ge 0) {
        $top = Rank $Matches[1]
        if ($top -gt $maxInstance) { $waiting.Add("- [[$($f.BaseName)]] (written for $($families[$top]); $status)") }
    }
    if ($items.Count -eq 0) { continue }
    $parts = $rel -split '\\'
    $group = if ($parts.Count -ge 3 -and $parts[0] -eq '02-Concepts') { $parts[0] + '/' + $parts[1] } else { $parts[0] }
    if (-not $groups.ContainsKey($group)) { $groups[$group] = New-Object System.Collections.Generic.List[string] }
    $label = "[[$($f.BaseName)]] ($status"
    if ($observed) { $label += "; observed in $observed" }
    $label += ')'
    $groups[$group].Add("- $label")
    foreach ($i in ($items | Select-Object -Unique)) { $groups[$group].Add("    - $i"); $total++ }
    $noteCount++
}

$today = Get-Date -Format 'yyyy-MM-dd'
$sb = New-Object Text.StringBuilder
[void]$sb.AppendLine('---')
[void]$sb.AppendLine('type: meta')
[void]$sb.AppendLine('tags: [meta]')
[void]$sb.AppendLine('status: documented')
[void]$sb.AppendLine('source: generated by _meta/tools/test-queue.ps1, do not edit by hand')
[void]$sb.AppendLine("updated: $today")
[void]$sb.AppendLine('---')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('# Test queue')
[void]$sb.AppendLine('')
[void]$sb.AppendLine("**Generated ${today}: $total items in $noteCount notes.** Everything the vault still calls open or unconfirmed, grouped by folder. With an instance open, pick an item, test it, and record the result in the note ([[Recording Results and Inbox]]): answer the open question, add the instance to ``observed-in:``, or mark the note ``verified``. Then regenerate this page:")
[void]$sb.AppendLine('')
[void]$sb.AppendLine('`powershell -ExecutionPolicy Bypass -File _meta/tools/test-queue.ps1`')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('Exercise notes are left out: their open items live in each exercise (*Open with the requester*, *Still open*).')
foreach ($g in ($groups.Keys | Sort-Object)) {
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine("## $g")
    [void]$sb.AppendLine('')
    foreach ($l in $groups[$g]) { [void]$sb.AppendLine($l) }
}
[void]$sb.AppendLine('')
[void]$sb.AppendLine("## Confirm in a second instance ($($oneInstance.Count))")
[void]$sb.AppendLine('')
[void]$sb.AppendLine('Verified how-tos, recipes and fixes with fewer than two instances in `observed-in:`. Re-running one in another instance and adding its label makes the finding much stronger; a different result goes into the note as a second finding ([[Improvement Loop]]).')
[void]$sb.AppendLine('')
foreach ($l in ($oneInstance | Sort-Object)) { [void]$sb.AppendLine($l) }
[void]$sb.AppendLine('')
[void]$sb.AppendLine("## Waiting for a newer instance ($($waiting.Count))")
[void]$sb.AppendLine('')
[void]$sb.AppendLine("Notes written from a release family newer than any instance recorded in [[Instances]] (latest known: $(if ($maxInstance -ge 0) { $families[$maxInstance] } else { 'none recorded' })). Test these once an instance reaches that release, and record its release first.")
[void]$sb.AppendLine('')
foreach ($l in ($waiting | Sort-Object)) { [void]$sb.AppendLine($l) }
[IO.File]::WriteAllText($out, $sb.ToString().Replace("`r`n", "`n"), (New-Object Text.UTF8Encoding($false)))
"wrote $out : $total items in $noteCount notes"
