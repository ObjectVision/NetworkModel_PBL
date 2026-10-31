# WriteChainBlocks.ps1: the chain step per stop block, with resume.
#
# First requests the list of the blocks whose cache is still missing (PublicTransport_Prep/PT_Chains_Blocks/ToDo_List,
# written to batch\log\chain_blocks_todo.txt; a block counts as done when its <n>of<N>.done exists, which the model writes
# after the parquet of the block is complete) and then calculates them in portions of BatchSize blocks per GeoDmsRun. Each
# portion is a separate process, so that memory is freed between the portions; an interrupted or failed chain step continues
# at the next call with the first block without a cache.
#
# Call (by UpdateAll.cmd chains): WriteChainBlocks.ps1 -Exe <GeoDmsRun.exe> -Cfg <cfg\main.dms> -LogDir <batch\log>
#   -BatchSize  blocks per GeoDmsRun (default 20). The blocks of a portion share only the start-up of about half a
#               minute, so the size makes little difference to the calculation time. A few slow blocks need 150 to 200 GB
#               of live data and page on a machine with 128 GB, whatever the portion size.
#   -MaxBlocks  at most this many blocks in this call (0 = all; for testing)
#   -Tag        appended to the names of the log and console files (UpdateAll.cmd passes none: the chain cache is shared
#               by the public transport components, so its step carries no component)
#   -Status     a file to which every progress line is appended as well (UpdateAll.cmd: batch\log\UpdateAll_status.txt)
# Exit code 0 when all blocks have a cache (or MaxBlocks is reached), otherwise 1; a failed GeoDmsRun call also prints its
# error messages (ShowGeoDmsErrors.ps1).
param(
	[Parameter(Mandatory=$true)][string]$Exe,
	[Parameter(Mandatory=$true)][string]$Cfg,
	[Parameter(Mandatory=$true)][string]$LogDir,
	[int]$BatchSize = 20,
	[int]$MaxBlocks = 0,
	[string]$Tag = '',
	[string]$Status = ''
)
$ErrorActionPreference = 'Stop'
$todoFile = Join-Path $LogDir 'chain_blocks_todo.txt'
$todoItem = '/NetworkSetup/PublicTransport_Prep/PT_Chains_Blocks/ToDo_List'
$showErrors = Join-Path $PSScriptRoot 'ShowGeoDmsErrors.ps1'
function Say($m) { $l = "{0} {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m; if ($Status -ne '') { Add-Content -Path $Status -Value $l }; $l }

function Get-ToDo {
	if (Test-Path $todoFile) { Remove-Item $todoFile }
	$p = Start-Process -FilePath $Exe -ArgumentList @("/L$LogDir\UpdateAll_chains_todo$Tag.log", $Cfg, '@statistics', $todoItem) -PassThru -Wait -WindowStyle Hidden -RedirectStandardOutput "$LogDir\UpdateAll_chains_todo$Tag.txt"
	if ($p.ExitCode -ne 0 -or -not (Test-Path $todoFile)) {
		& $showErrors -Path "$LogDir\UpdateAll_chains_todo$Tag.txt" | Out-Host   # Out-Host: the output of a function would otherwise become part of its result
		throw "the list of missing blocks was not made (exit $($p.ExitCode)), see $LogDir\UpdateAll_chains_todo$Tag.log"
	}
	return @(Get-Content $todoFile | Where-Object { $_.Trim() -ne '' })
}

$todo = @(Get-ToDo)   # @(): otherwise a list with one line (the OD pair mode, #129) becomes a string, and $todo[0..0] its first character
Say ("chain step per block: {0} blocks without a cache" -f $todo.Count)
if ($MaxBlocks -gt 0 -and $todo.Count -gt $MaxBlocks) { $todo = $todo[0..($MaxBlocks - 1)] }
$nb = [Math]::Ceiling($todo.Count / [double]$BatchSize)
$total = [Diagnostics.Stopwatch]::StartNew()
for ($b = 0; $b -lt $nb; $b++) {
	$part = $todo[($b * $BatchSize)..([Math]::Min(($b + 1) * $BatchSize, $todo.Count) - 1)]
	$items = @(); foreach ($it in $part) { $items += '@statistics'; $items += $it }
	$sw = [Diagnostics.Stopwatch]::StartNew()
	$out = Join-Path $LogDir ('UpdateAll_chains{0}_b{1:000}.txt' -f $Tag, ($b + 1))
	$p = Start-Process -FilePath $Exe -ArgumentList (@("/L$LogDir\UpdateAll_chains$Tag.log", $Cfg) + $items) -PassThru -Wait -WindowStyle Hidden -RedirectStandardOutput $out
	# the expected remaining time: the mean time of the portions so far times the portions still to go
	$left = [TimeSpan]::FromSeconds($total.Elapsed.TotalSeconds / ($b + 1) * ($nb - $b - 1))
	Say ("portion {0}/{1}: {2} blocks, exit {3}, {4:N0} s; about {5:%h} h {5:mm} min to go" -f ($b + 1), $nb, $part.Count, $p.ExitCode, $sw.Elapsed.TotalSeconds, $left)
	if ($p.ExitCode -ne 0) { Say "FAILED, see $out and $LogDir\UpdateAll_chains$Tag.log"; & $showErrors -Path $out; exit 1 }
}
$rest = @(Get-ToDo)
Say ("done: {0} blocks still without a cache" -f $rest.Count)
if ($rest.Count -eq 0 -or $MaxBlocks -gt 0) { exit 0 } else { exit 1 }
