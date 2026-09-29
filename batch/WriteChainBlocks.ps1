# WriteChainBlocks.ps1: de ketenstap per haltenblok, met hervatten (sinds 2026-09-29).
#
# Vraagt eerst de lijst op van de blokken waarvan de store nog ontbreekt (PublicTransport_Prep/ChainStore_Blocks/ToDo_List,
# geschreven naar batch\log\chain_blocks_todo.txt; een blok telt als klaar als zijn 0Dictionary.dms bestaat, dat de MMD-writer
# als laatste schrijft) en rekent die dan in porties van BatchSize blokken per GeoDmsRun. Elke portie is een eigen proces,
# zodat het geheugen tussen de porties vrijkomt; een onderbroken of mislukte ketenstap gaat bij een volgende aanroep verder
# bij het eerste blok zonder store.
#
# Aanroep (door UpdateAll.cmd chains): WriteChainBlocks.ps1 -Exe <GeoDmsRun.exe> -Cfg <cfg\main.dms> -LogDir <batch\log>
#   -BatchSize  blokken per GeoDmsRun (standaard 40)
#   -MaxBlocks  hooguit zoveel blokken in deze aanroep (0 = alle; om te testen)
# Exitcode 0 als alle blokken een store hebben (of MaxBlocks bereikt is), anders 1.
param(
	[Parameter(Mandatory=$true)][string]$Exe,
	[Parameter(Mandatory=$true)][string]$Cfg,
	[Parameter(Mandatory=$true)][string]$LogDir,
	[int]$BatchSize = 40,
	[int]$MaxBlocks = 0
)
$ErrorActionPreference = 'Stop'
$todoFile = Join-Path $LogDir 'chain_blocks_todo.txt'
$todoItem = '/NetworkSetup/PublicTransport_Prep/ChainStore_Blocks/ToDo_List'
function Say($m) { "{0} {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m }

function Get-ToDo {
	if (Test-Path $todoFile) { Remove-Item $todoFile }
	$p = Start-Process -FilePath $Exe -ArgumentList @("/L$LogDir\UpdateAll_chains_todo.log", $Cfg, '@statistics', $todoItem) -PassThru -Wait -WindowStyle Hidden -RedirectStandardOutput "$LogDir\UpdateAll_chains_todo.txt"
	if ($p.ExitCode -ne 0 -or -not (Test-Path $todoFile)) { throw "de lijst van ontbrekende blokken is niet gemaakt (exit $($p.ExitCode)), zie $LogDir\UpdateAll_chains_todo.log" }
	return @(Get-Content $todoFile | Where-Object { $_.Trim() -ne '' })
}

$todo = Get-ToDo
Say ("ketenstap per blok: {0} blokken zonder store" -f $todo.Count)
if ($MaxBlocks -gt 0 -and $todo.Count -gt $MaxBlocks) { $todo = $todo[0..($MaxBlocks - 1)] }
$nb = [Math]::Ceiling($todo.Count / [double]$BatchSize)
for ($b = 0; $b -lt $nb; $b++) {
	$part = $todo[($b * $BatchSize)..([Math]::Min(($b + 1) * $BatchSize, $todo.Count) - 1)]
	$items = @(); foreach ($it in $part) { $items += '@statistics'; $items += $it }
	$sw = [Diagnostics.Stopwatch]::StartNew()
	$out = Join-Path $LogDir ('UpdateAll_chains_b{0:000}.txt' -f ($b + 1))
	$p = Start-Process -FilePath $Exe -ArgumentList (@("/L$LogDir\UpdateAll_chains.log", $Cfg) + $items) -PassThru -Wait -WindowStyle Hidden -RedirectStandardOutput $out
	Say ("portie {0}/{1}: {2} blokken, exit {3}, {4:N0} s" -f ($b + 1), $nb, $part.Count, $p.ExitCode, $sw.Elapsed.TotalSeconds)
	if ($p.ExitCode -ne 0) { Say "MISLUKT, zie $out en $LogDir\UpdateAll_chains.log"; exit 1 }
}
$rest = Get-ToDo
Say ("klaar: {0} blokken nog zonder store" -f $rest.Count)
if ($rest.Count -eq 0 -or $MaxBlocks -gt 0) { exit 0 } else { exit 1 }
