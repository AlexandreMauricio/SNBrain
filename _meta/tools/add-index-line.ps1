# Usage (from the vault root):
#   powershell -File _meta/tools/add-index-line.ps1 -Index 02-Concepts/_index.md -Section "Foundations" -Line "- [[Note]] - description (documented)"
# Inserts Line at the END of the section whose "## " heading starts with Section (e.g. "Assets" matches "## Assets (`Assets/`)").
# For an index with no sections, omit -Section and the line is appended at the end.
# Writes UTF-8 without BOM.
param(
    [Parameter(Mandatory = $true)][string]$Index,
    [Parameter(Mandatory = $true)][string]$Line,
    [string]$Section = ""
)

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$path = Join-Path $root $Index
$lines = [System.Collections.Generic.List[string]]([IO.File]::ReadAllLines($path))
$utf8 = New-Object Text.UTF8Encoding($false)

if (-not $Section) {
    $lines.Add($Line)
} else {
    $start = -1
    for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i] -like "## $Section*") { $start = $i; break } }
    if ($start -lt 0) { throw "Section '$Section' not found in $Index" }
    $end = $lines.Count
    for ($j = $start + 1; $j -lt $lines.Count; $j++) { if ($lines[$j] -like '## *') { $end = $j; break } }
    # insert after the last non-blank line of the section
    $ins = $end
    while ($ins -gt $start + 1 -and [string]::IsNullOrWhiteSpace($lines[$ins - 1])) { $ins-- }
    $lines.Insert($ins, $Line)
}
[IO.File]::WriteAllLines($path, $lines, $utf8)
"added to $Index" + $(if ($Section) { " under '$Section'" } else { "" })
