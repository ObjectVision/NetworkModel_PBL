# ShowGeoDmsErrors.ps1: prints the error messages of a GeoDmsRun call that failed, so that whoever started UpdateAll.cmd
# sees what went wrong and not only the exit code of the step.
#
# GeoDmsRun writes an error as a line that starts with [E] ([F] for the end of a failed run), followed by indented lines
# with the file, line and column, the source line and the context. A syntax error in the configuration stops the first
# GeoDmsRun call of a section, whatever that step makes; its message is only in the console output of that call. The
# script prints these blocks from that output (batch\log\UpdateAll_<step>.txt); without such a line, for example after
# a crash, it prints the last lines of the output.
#
# Call (by UpdateAll.cmd, WriteChainBlocks.ps1 and WriteOutputBlocks.ps1): ShowGeoDmsErrors.ps1 -Path <console output of GeoDmsRun>
#   -MaxLines   at most this many lines of error messages (default 40); the first error is usually the cause, and the
#               follow-up errors of a failed calculation can run into the hundreds
#   -TailLines  the number of last lines of the output printed when it has no error line (default 15)
param(
	[Parameter(Mandatory=$true)][string]$Path,
	[int]$MaxLines = 40,
	[int]$TailLines = 15
)
if (-not (Test-Path $Path)) { "  GeoDmsRun left no output in $Path"; exit 0 }
$lines = @(Get-Content $Path -Encoding UTF8)
$shown = New-Object System.Collections.Generic.List[string]
$inBlock = $false
foreach ($l in $lines) {
	if ($l -match '^\[[EF]\]') { $inBlock = $true; $shown.Add($l) }
	elseif ($inBlock -and $l -match '^\s') { $shown.Add($l) }
	else { $inBlock = $false }
}
if ($shown.Count -eq 0) {
	"  GeoDmsRun wrote no error message; the last lines of ${Path}:"
	$lines | Select-Object -Last $TailLines | ForEach-Object { "  $_" }
	exit 0
}
"  GeoDmsRun reported (from ${Path}):"
$shown | Select-Object -First $MaxLines | ForEach-Object { "  $_" }
if ($shown.Count -gt $MaxLines) { "  ... and {0} more lines of error messages in {1}" -f ($shown.Count - $MaxLines), $Path }
