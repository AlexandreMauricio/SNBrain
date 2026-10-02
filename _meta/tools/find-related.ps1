# Usage (from the vault root):
#   powershell -File _meta/tools/find-related.ps1 -Terms "sla definition|task_sla|Retroactive start" -Doc "sla-definition"
# Separate several terms with | (a single string, so it works with -File).
# Step 1 of the "check before you write" rule in CLAUDE.md.
# Prints: (a) whether the docs page (any distinctive part of its URL or title) is already in the Docs Reading List,
#         (b) every note and line mentioning any of the terms, so you can read and merge instead of duplicating.
param(
    [Parameter(Mandatory = $true)][string]$Terms,
    [string]$Doc = ""
)
$TermList = $Terms -split '\|' | ForEach-Object { $_.Trim() } | Where-Object { $_ }

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$notes = Get-ChildItem -Path $root -Recurse -Filter *.md |
    Where-Object { $_.FullName -notmatch '\\\.obsidian|\\Templates\\' }

if ($Doc) {
    Write-Host "== Already processed? ($Doc) ==" -ForegroundColor Cyan
    $hit = Select-String -Path (Join-Path $root "_meta\Docs Reading List.md") -Pattern $Doc -SimpleMatch |
        Where-Object { $_.Line -like '|*' }
    if ($hit) { $hit | ForEach-Object { Write-Host "YES: $($_.Line.Substring(0, [Math]::Min(160, $_.Line.Length)))" } }
    else { Write-Host "No row matching '$Doc' in the reading list." }
}

Write-Host "`n== Existing notes mentioning the terms ==" -ForegroundColor Cyan
foreach ($t in $TermList) {
    Write-Host "-- '$t' --" -ForegroundColor Yellow
    $matches = $notes | Select-String -Pattern $t -SimpleMatch -CaseSensitive:$false
    if (-not $matches) { Write-Host "  (none)"; continue }
    $matches | Group-Object Path | ForEach-Object {
        $name = [IO.Path]::GetFileNameWithoutExtension($_.Name)
        Write-Host "  [[${name}]] ($($_.Count) hit(s))"
        $_.Group | Select-Object -First 3 | ForEach-Object {
            $l = $_.Line.Trim(); Write-Host ("      L{0}: {1}" -f $_.LineNumber, $l.Substring(0, [Math]::Min(140, $l.Length)))
        }
    }
}
