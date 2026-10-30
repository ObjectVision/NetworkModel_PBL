# WriteOutputBlocks.ps1: the output step per origin block in portions, as WriteChainBlocks.ps1 does for the chain step.
#
# First requests the list of the blocks (NetworkSetup/ConfigurationPerBlock/Generate_Output/OutputBlocks_List, written to
# batch\log\output_blocks.txt; this also writes or checks the signature of the output folder and the longest path) and then
# calculates them in portions of BatchSize blocks per GeoDmsRun. Each portion is a separate process, so that memory is freed
# between the portions, which a single request for all blocks (NetworkSetup/GenerateOutput/Generate_Output) does not do.
# Then batch\OdTellingen.py makes the counts (od_tellingen.csv, unieke_od_tellingen.csv) from the output of the blocks; in
# the single request the model does this itself (OD_Counts), with the same rules, but that needs the results of all
# blocks in the same process.
# For the merge (component Merged) the list names the merging per block (ComponentMerge/PerBlock). If the list is empty, the
# script runs one request of NetworkSetup/GenerateOutput/Generate_Output.
#
# Call (by UpdateAll.cmd output): WriteOutputBlocks.ps1 -Exe <GeoDmsRun.exe> -Cfg <cfg\main.dms> -LogDir <batch\log> -OutDir <output folder>
#   -Tag        appended to the names of the log and console files, _<component> (UpdateAll.cmd sets it)
#   -Status     a file to which every progress line is appended as well (UpdateAll.cmd: batch\log\UpdateAll_status.txt)
#   -BatchSize  blocks per GeoDmsRun; without this parameter that of the component, Classifications/Components/
#               BlocksPerPortion (the model writes it to batch\log\output_blocks_per_portion.txt); 0 = all blocks in
#               one portion. Every portion pays the start-up again, which takes a few minutes for a national run.
#   -MaxBlocks  at most this many blocks (0 = all; for testing)
# Exit code 0 when all portions and the counts succeeded, otherwise 1; a failed GeoDmsRun call also prints its error
# messages (ShowGeoDmsErrors.ps1).
param(
	[Parameter(Mandatory=$true)][string]$Exe,
	[Parameter(Mandatory=$true)][string]$Cfg,
	[Parameter(Mandatory=$true)][string]$LogDir,
	[Parameter(Mandatory=$true)][string]$OutDir,
	[int]$BatchSize = -1,
	[int]$MaxBlocks = 0,
	[string]$Tag = '',
	[string]$Status = ''
)
$ErrorActionPreference = 'Stop'
$listFile = Join-Path $LogDir 'output_blocks.txt'
$sizeFile = Join-Path $LogDir 'output_blocks_per_portion.txt'
$listItem = '/NetworkSetup/ConfigurationPerBlock/Generate_Output/OutputBlocks_List'
$sizeItem = '/NetworkSetup/ConfigurationPerBlock/Generate_Output/OutputBlocks_PerPortion'
$showErrors = Join-Path $PSScriptRoot 'ShowGeoDmsErrors.ps1'
function Say($m) { $l = "{0} {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m; if ($Status -ne '') { Add-Content -Path $Status -Value $l }; $l }

foreach ($f in $listFile, $sizeFile) { if (Test-Path $f) { Remove-Item $f } }
$p = Start-Process -FilePath $Exe -ArgumentList @("/L$LogDir\UpdateAll_output_blocks$Tag.log", $Cfg, '@statistics', $listItem, '@statistics', $sizeItem) -PassThru -Wait -WindowStyle Hidden -RedirectStandardOutput "$LogDir\UpdateAll_output_blocks$Tag.txt"
if ($p.ExitCode -ne 0 -or -not (Test-Path $listFile) -or -not (Test-Path $sizeFile)) { Say "FAILED: the list of blocks was not made (exit $($p.ExitCode)), see $LogDir\UpdateAll_output_blocks$Tag.log"; & $showErrors -Path "$LogDir\UpdateAll_output_blocks$Tag.txt"; exit 1 }
$blocks = @(Get-Content $listFile | Where-Object { $_.Trim() -ne '' })
if ($BatchSize -lt 0) { $BatchSize = [int](Get-Content $sizeFile -Raw).Trim() }
if ($BatchSize -eq 0) { $BatchSize = [Math]::Max($blocks.Count, 1) }

if ($blocks.Count -eq 0) {
	Say 'output: no blocks, one request of /NetworkSetup/GenerateOutput/Generate_Output'
	$p = Start-Process -FilePath $Exe -ArgumentList @("/L$LogDir\UpdateAll_output$Tag.log", $Cfg, '@statistics', '/NetworkSetup/GenerateOutput/Generate_Output') -PassThru -Wait -WindowStyle Hidden -RedirectStandardOutput "$LogDir\UpdateAll_output$Tag.txt"
	Say "output: exit $($p.ExitCode)"
	if ($p.ExitCode -eq 0) { exit 0 } else { & $showErrors -Path "$LogDir\UpdateAll_output$Tag.txt"; exit 1 }
}

Say ("output per block: {0} blocks, portions of {1}" -f $blocks.Count, $BatchSize)
if ($MaxBlocks -gt 0 -and $blocks.Count -gt $MaxBlocks) { $blocks = $blocks[0..($MaxBlocks - 1)] }
$nb = [Math]::Ceiling($blocks.Count / [double]$BatchSize)
$total = [Diagnostics.Stopwatch]::StartNew()
for ($b = 0; $b -lt $nb; $b++) {
	$part = $blocks[($b * $BatchSize)..([Math]::Min(($b + 1) * $BatchSize, $blocks.Count) - 1)]
	$items = @(); foreach ($it in $part) { $items += '@statistics'; $items += $it }
	$sw = [Diagnostics.Stopwatch]::StartNew()
	$out = Join-Path $LogDir ('UpdateAll_output{0}_b{1:000}.txt' -f $Tag, ($b + 1))
	$p = Start-Process -FilePath $Exe -ArgumentList (@("/L$LogDir\UpdateAll_output$Tag.log", $Cfg) + $items) -PassThru -Wait -WindowStyle Hidden -RedirectStandardOutput $out
	# the expected remaining time: the mean time of the portions so far times the portions still to go
	$left = [TimeSpan]::FromSeconds($total.Elapsed.TotalSeconds / ($b + 1) * ($nb - $b - 1))
	Say ("portion {0}/{1}: {2} blocks, exit {3}, {4:N0} s; about {5:%h} h {5:mm} min to go" -f ($b + 1), $nb, $part.Count, $p.ExitCode, $sw.Elapsed.TotalSeconds, $left)
	if ($p.ExitCode -ne 0) { Say "FAILED, see $out and $LogDir\UpdateAll_output$Tag.log"; & $showErrors -Path $out; exit 1 }
}

$py = Get-Command python -ErrorAction SilentlyContinue
if (-not $py) { Say 'FAILED: no python for the counts (batch\OdTellingen.py)'; exit 1 }
$o = & $py.Source (Join-Path $PSScriptRoot 'OdTellingen.py') $OutDir --force 2>&1
$rc = $LASTEXITCODE
Say ("counts (OdTellingen.py): exit {0}; {1}" -f $rc, (($o | ForEach-Object { "$_" }) -join ' | '))
if ($rc -eq 0) { exit 0 } else { exit 1 }
