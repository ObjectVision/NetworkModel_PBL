# WriteOutputBlocks.ps1: de uitvoerstap per herkomstblok in porties (sinds 2026-10-07), zoals WriteChainBlocks.ps1 de ketenstap.
#
# Vraagt eerst de lijst van de blokken op (NetworkSetup/ConfigurationPerBlock/Generate_Output/OutputBlocks_List, geschreven naar
# batch\log\output_blocks.txt; dat schrijft of controleert ook de handtekening van de uitvoermap en het langste pad) en rekent die
# dan in porties van BatchSize blokken per GeoDmsRun. Elke portie is een eigen proces, zodat het geheugen tussen de porties
# vrijkomt: in een opvraging voor alle blokken (NetworkSetup/Generate_Output) groeide het vastgelegde geheugen van de uitvoer van
# Auto voor Buurt2023 naar Buurt2023 (450 blokken, 779 miljoen autoroutes) met ongeveer 0,7 GB per blok tot 386 GB (2026-10-06/07).
# Daarna maakt batch\OdTellingen.py de tellingen (od_tellingen.csv, unieke_od_tellingen.csv) uit de csv's; in de ene opvraging deed
# het model dat zelf (OD_Tellingen), met dezelfde regels, maar dat vraagt de resultaten van alle blokken in hetzelfde proces.
# Is de lijst leeg (Component 'Samen'), dan een opvraging van NetworkSetup/Generate_Output: het samenvoegen van de componenten.
#
# Aanroep (door UpdateAll.cmd output): WriteOutputBlocks.ps1 -Exe <GeoDmsRun.exe> -Cfg <cfg\main.dms> -LogDir <batch\log> -OutDir <uitvoermap>
#   -BatchSize  blokken per GeoDmsRun (standaard 50). Elke portie betaalt de opstart opnieuw; tot het eerste blokbestand duurde die
#               voor Y2023, Buurt2023 naar Buurt2023, 2,5 min bij Auto, 5 bij Fiets en 6 bij Lopen.
#   -MaxBlocks  hooguit zoveel blokken (0 = alle; om te testen)
# Exitcode 0 als alle porties en de tellingen gelukt zijn, anders 1.
param(
	[Parameter(Mandatory=$true)][string]$Exe,
	[Parameter(Mandatory=$true)][string]$Cfg,
	[Parameter(Mandatory=$true)][string]$LogDir,
	[Parameter(Mandatory=$true)][string]$OutDir,
	[int]$BatchSize = 50,
	[int]$MaxBlocks = 0
)
$ErrorActionPreference = 'Stop'
$listFile = Join-Path $LogDir 'output_blocks.txt'
$listItem = '/NetworkSetup/ConfigurationPerBlock/Generate_Output/OutputBlocks_List'
function Say($m) { "{0} {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m }

if (Test-Path $listFile) { Remove-Item $listFile }
$p = Start-Process -FilePath $Exe -ArgumentList @("/L$LogDir\UpdateAll_output_blocks.log", $Cfg, '@statistics', $listItem) -PassThru -Wait -WindowStyle Hidden -RedirectStandardOutput "$LogDir\UpdateAll_output_blocks.txt"
if ($p.ExitCode -ne 0 -or -not (Test-Path $listFile)) { Say "MISLUKT: de lijst van de blokken is niet gemaakt (exit $($p.ExitCode)), zie $LogDir\UpdateAll_output_blocks.log"; exit 1 }
$blocks = @(Get-Content $listFile | Where-Object { $_.Trim() -ne '' })

if ($blocks.Count -eq 0) {
	Say 'uitvoer: geen blokken (Samen), een opvraging van /NetworkSetup/Generate_Output'
	$p = Start-Process -FilePath $Exe -ArgumentList @("/L$LogDir\UpdateAll_output.log", $Cfg, '@statistics', '/NetworkSetup/Generate_Output') -PassThru -Wait -WindowStyle Hidden -RedirectStandardOutput "$LogDir\UpdateAll_output.txt"
	Say "uitvoer: exit $($p.ExitCode)"
	if ($p.ExitCode -eq 0) { exit 0 } else { exit 1 }
}

Say ("uitvoer per blok: {0} blokken, porties van {1}" -f $blocks.Count, $BatchSize)
if ($MaxBlocks -gt 0 -and $blocks.Count -gt $MaxBlocks) { $blocks = $blocks[0..($MaxBlocks - 1)] }
$nb = [Math]::Ceiling($blocks.Count / [double]$BatchSize)
for ($b = 0; $b -lt $nb; $b++) {
	$part = $blocks[($b * $BatchSize)..([Math]::Min(($b + 1) * $BatchSize, $blocks.Count) - 1)]
	$items = @(); foreach ($it in $part) { $items += '@statistics'; $items += $it }
	$sw = [Diagnostics.Stopwatch]::StartNew()
	$out = Join-Path $LogDir ('UpdateAll_output_b{0:000}.txt' -f ($b + 1))
	$p = Start-Process -FilePath $Exe -ArgumentList (@("/L$LogDir\UpdateAll_output.log", $Cfg) + $items) -PassThru -Wait -WindowStyle Hidden -RedirectStandardOutput $out
	Say ("portie {0}/{1}: {2} blokken, exit {3}, {4:N0} s" -f ($b + 1), $nb, $part.Count, $p.ExitCode, $sw.Elapsed.TotalSeconds)
	if ($p.ExitCode -ne 0) { Say "MISLUKT, zie $out en $LogDir\UpdateAll_output.log"; exit 1 }
}

$py = Get-Command python -ErrorAction SilentlyContinue
if (-not $py) { Say 'MISLUKT: geen python voor de tellingen (batch\OdTellingen.py)'; exit 1 }
$o = & $py.Source (Join-Path $PSScriptRoot 'OdTellingen.py') $OutDir --force 2>&1
$rc = $LASTEXITCODE
Say ("tellingen (OdTellingen.py): exit {0}; {1}" -f $rc, (($o | ForEach-Object { "$_" }) -join ' | '))
if ($rc -eq 0) { exit 0 } else { exit 1 }
