# Usage (from the vault root):
#   powershell -ExecutionPolicy Bypass -File _meta/tools/impact.ps1 -Note "incident|Business Rules"
#   powershell -ExecutionPolicy Bypass -File _meta/tools/impact.ps1 -Range "17185ad~1..17185ad"   (-All also lists how-tos and other notes)
# Propagation step of the improvement loop (_meta/Procedures/Improvement Loop.md): lists every note that
# links the given notes (or the notes changed in a git range), grouped so exercises and recipes come first.
# Each exercise or recipe listed must be checked, and gets a dated "Since written" line when the change
# affects it.

param([string]$Note = '', [string]$Range = '', [switch]$All)

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$targets = @()
if ($Note) { $targets += ($Note -split '\|' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }
if ($Range) {
    $changed = git -C $root diff --name-only $Range -- '*.md'
    foreach ($p in $changed) {
        $name = [IO.Path]::GetFileNameWithoutExtension($p)
        if ($p -notmatch '^_meta/|^Templates/' -and $name -ne '_index' -and $name -ne 'README' -and $name -ne 'CLAUDE') { $targets += $name }
    }
}
$targets = $targets | Sort-Object -Unique
if (-not $targets) { 'Give -Note "A|B" or -Range "<git range>".'; exit 1 }

$files = Get-ChildItem -Path $root -Recurse -Filter *.md | Where-Object {
    $_.FullName -notmatch '\\\.git\\|\\\.obsidian\\|\\Templates\\|\\_meta\\' -and $_.Name -ne '_index.md'
}
$text = @{}
foreach ($f in $files) { $text[$f.FullName] = [IO.File]::ReadAllText($f.FullName, [Text.Encoding]::UTF8) }

"Changed or named notes: $($targets.Count)"
$targets | ForEach-Object { "  - $_" }
''
$order = @('09-Exercises', '04-Scripts-Automation', '03-How-To', '06-Reporting', 'other')
$hits = @{}; foreach ($o in $order) { $hits[$o] = @{} }
foreach ($f in $files) {
    if ($targets -contains $f.BaseName) { continue }
    $c = $text[$f.FullName]
    $via = @()
    foreach ($t in $targets) {
        if ($c -match ('\[\[' + [regex]::Escape($t) + '(\]\]|\||#)')) { $via += $t }
    }
    if (-not $via) { continue }
    $rel = $f.FullName.Substring($root.Length + 1)
    $g = 'other'; foreach ($o in $order) { if ($rel.StartsWith($o)) { $g = $o } }
    $hits[$g][$f.BaseName] = ($via -join ', ')
}
foreach ($o in $order) {
    $h = $hits[$o]
    $title = @{ '09-Exercises' = 'Exercises (check each; add a Since written line if affected)'; '04-Scripts-Automation' = 'Recipes (check each; add a Since written line if affected)'; '03-How-To' = 'How-tos'; '06-Reporting' = 'Reporting'; 'other' = 'Other notes' }[$o]
    "$title : $($h.Count)"
    if ($All -or $o -eq '09-Exercises' -or $o -eq '04-Scripts-Automation') { foreach ($k in ($h.Keys | Sort-Object)) { "  - [[$k]]  <- $($h[$k])" } }
}
