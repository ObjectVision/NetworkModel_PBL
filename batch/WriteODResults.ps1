# WriteODResults.ps1 (#129): the routes of one OD pair, for every component in MergeComponents and merged.
#
# Makes a run copy of HEAD per component (with git archive) with OD_Origin, OD_Destination and OD_DepartureTime, and with
# these copies calculates one after the other, each with batch\UpdateAll.cmd of the copy:
#   1. the legs of pre- and post-transport, with their links (legs), and
#   2. the chains of the pair with their legs (chains), both once, in the copy of the first public transport component;
#   3. per component the car cache of the departure moment (cars, only Car) and the output (output):
#      PerBlock/tt_<moment>_1of1.parquet and PerBlock/od_<moment>.gpkg with options, parts and links;
#   4. the merging (a copy with MergeOutput TRUE, output).
# Intermediate results go to %LocalDataProjDir%\IntermediateResults_<O>_<D>, output to Output_<O>_<D>; /Output/OD_PairRoutes
# in the GUI reads them, with the same settings in ModelParameters (groups 1 and 6).
#
# Call, for example for the trip Laapersweg 1 Hilversum -> De Boelelaan 1085 at 07:30 (the wiki, Routes of an OD pair):
#   powershell -ExecutionPolicy Bypass -File batch\WriteODResults.ps1 -Org BU04020501 -Dest BU0363KP03 -Moment 07:30
# The engine must know pareto with LinkSet (ObjectVision/GeoDMS#1325) for the car routes: GeoDMS 20.26.0 or later.
# -AlleenUitvoer skips the legs and the chains when their caches already exist (to repeat the output after a change to it).
# Run long runs as a one-off scheduled task (see the wiki, How to run the model). -WaitForMemoryGB waits until that much
# memory is available before a step starts, so that the pair does not make other runs page; the chain step calculates all
# public transport legs of the network (20 to 30 GB).
param(
	[Parameter(Mandatory=$true)][string]$Org,
	[Parameter(Mandatory=$true)][string]$Dest,
	[string]$Moment = '',
	[string]$AnalysisMoment = 'Y2026',
	[string]$PartOfDay = 'Ochtendspits',
	[string]$Orgset = 'Buurt2025',
	[string]$Destset = 'Buurt2025',
	[string]$Label = 'od',
	[string]$Components = '',
	[string]$Exe = 'C:\Program Files\ObjectVision\GeoDms20.27.0.m\GeoDmsRun.exe',
	[string]$Root = 'C:\LocalData\NM_PBL_runs',
	[int]$WaitForMemoryGB = 0,
	[switch]$AlleenUitvoer
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$runs = Join-Path $Root "od_$($Org)_$($Dest)"
$status = Join-Path $runs 'status.txt'
New-Item -ItemType Directory -Force $runs | Out-Null
function Say($m) { $l = "{0} {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m; $l; Add-Content -Path $status -Value $l }
function SetParam($file, $name, $value) {
	$t = [IO.File]::ReadAllText($file)
	$re = "(parameter<\w+>\s+$name\s+:=\s+)('[^']*'|TRUE|FALSE)"
	if (([regex]::Matches($t, $re)).Count -ne 1) { throw "parameter $name does not occur exactly once in $file" }
	[IO.File]::WriteAllText($file, [regex]::Replace($t, $re, { param($m) $m.Groups[1].Value + $value }), (New-Object System.Text.UTF8Encoding($true)))
}
function SetType($file, $name, $type) {
	$t = [IO.File]::ReadAllText($file)
	$re = "($name := /Classifications/TimeInvariantTypes/V/)\w+"
	if (([regex]::Matches($t, $re)).Count -ne 1) { throw "$name not found in $file" }
	[IO.File]::WriteAllText($file, [regex]::Replace($t, $re, { param($m) $m.Groups[1].Value + $type }), (New-Object System.Text.UTF8Encoding($true)))
}
function WaitForMemory {
	if ($WaitForMemoryGB -le 0) { return }
	while ($true) {
		$free = (Get-Counter '\Memory\Available MBytes').CounterSamples[0].CookedValue / 1024
		if ($free -ge $WaitForMemoryGB) { return }
		Say ("waiting for memory: {0:N1} GB available, {1} GB needed" -f $free, $WaitForMemoryGB)
		Start-Sleep -Seconds 300
	}
}
# The parts of a component, as in RunFrontValidation.ps1: WW, CC, Car, or <PreTransport>_PT_<PostTransport>.
$voor = @{ 'W' = 'Org2Stops_Walking'; 'C' = 'Org2Stops_Cycling'; 'C_RM' = 'Org2RM_Stops_Cycling'; 'C_RMT' = 'Org2RMT_Stops_Cycling'; 'C_Ric' = 'Org2Ric_Stops_Cycling' }
$na   = @{ 'W' = 'Stops2Dest_Walking'; 'C' = 'Stops2Dest_Cycling'; 'RM_C' = 'RM_Stops2Dest_Cycling'; 'RMT_C' = 'RMT_Stops2Dest_Cycling'; 'OVf_C' = 'OVF_Stops2Dest_Cycling' }

if (-not $Components) {
	$m = [regex]::Match([IO.File]::ReadAllText((Join-Path $repo 'cfg\main\ModelParameters.dms')), "parameter<string>\s+MergeComponents\s+:=\s+'([^']*)'")
	$Components = $m.Groups[1].Value
}
$comps = $Components.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
$archive = Join-Path $runs 'head.tar'
& git -C $repo archive --format=tar -o $archive HEAD cfg data batch
if ($LASTEXITCODE -ne 0) { throw "git archive: exit $LASTEXITCODE" }
$commit = & git -C $repo rev-parse HEAD
Say "OD pair $Org -> $Dest, moment '$Moment', $AnalysisMoment $PartOfDay, $Orgset/$Destset, Components $($comps -join ','), commit $commit, engine $Exe"

function MakeCopy($name, $comp, $merge) {
	$dst = Join-Path $runs "$name\NetworkModel_PBL"
	if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
	New-Item -ItemType Directory -Force $dst | Out-Null
	& (Join-Path $env:SystemRoot 'System32\tar.exe') -xf $archive -C $dst
	if ($LASTEXITCODE -ne 0) { throw "tar: exit $LASTEXITCODE" }
	# ConfigSettings.dms is in git (paths that differ per machine come from the registry, see that file); config.ini is local to the machine.
	foreach ($f in 'config.ini') { $src = Join-Path $repo "cfg\main\$f"; if (Test-Path $src) { Copy-Item $src (Join-Path $dst "cfg\main\$f") } }
	Set-Content -Path (Join-Path $dst 'COMMIT.txt') -Value "$commit (git archive, plus config.ini from the working copy)"
	$mp = Join-Path $dst 'cfg\main\ModelParameters.dms'
	SetParam $mp 'AnalysisMoment'   "'$AnalysisMoment'"
	SetParam $mp 'PartOfDay'          "'$PartOfDay'"
	SetParam $mp 'Orgset'           "'$Orgset'"
	SetParam $mp 'Destset'          "'$Destset'"
	SetParam $mp 'OutputLabel'      "'$Label'"
	SetParam $mp 'MergeComponents'  "'$Components'"
	SetParam $mp 'OD_Origin'      "'$Org'"
	SetParam $mp 'OD_Destination'    "'$Dest'"
	SetParam $mp 'OD_DepartureTime' "'$Moment'"
	if ($merge) { SetParam $mp 'MergeOutput' 'TRUE' }
	elseif ($comp -in 'WW', 'CC', 'Car') { SetParam $mp 'Component' "'$comp'" }
	else {
		$x = [regex]::Match($comp, '^(.+)_PT_(.+)$')
		SetParam $mp 'Component' "'PT'"; SetType $mp 'PreTransport' $voor[$x.Groups[1].Value]; SetType $mp 'PostTransport' $na[$x.Groups[2].Value]
	}
	return $dst
}
function Run($dst, $section, $extra) {
	WaitForMemory
	$env:GEODMS_EXE = $Exe
	$sw = [Diagnostics.Stopwatch]::StartNew()
	# The output of UpdateAll.cmd, stderr included, goes to a file in the log of the copy, so that a cmd message is not an error of this script.
	& cmd /c "`"$dst\batch\UpdateAll.cmd`" $section $extra > `"$dst\batch\log\od_$section.txt`" 2>&1"
	$rc = $LASTEXITCODE
	Say ("{0} {1} {2}: exit {3}, {4:N0} s" -f (Split-Path (Split-Path $dst) -Leaf), $section, $extra, $rc, $sw.Elapsed.TotalSeconds)
	if ($rc -ne 0) { throw "$section in $dst failed, see $dst\batch\log" }
}

# Legs and chains in the copy of the first public transport component: UpdateAll.cmd legs and chains skip a component without it.
$pt = $comps | Where-Object { $_ -match '_PT_' } | Select-Object -First 1
if ($pt -and -not $AlleenUitvoer) {
	$dst = MakeCopy $pt $pt $false
	Run $dst 'legs' ''
	Run $dst 'chains' ''
}
foreach ($c in $comps) {
	$dst = if ($c -eq $pt -and -not $AlleenUitvoer) { Join-Path $runs "$c\NetworkModel_PBL" } else { MakeCopy $c $c $false }
	if ($c -eq 'Car') {
		$td = if ($Moment) { 'TD' + $Moment.Replace(':', 'h') + 'm' } else { '' }
		Run $dst 'cars' $td
	}
	Run $dst 'output' ''
}
$dst = MakeCopy 'Merged' '' $true
Run $dst 'output' ''
Remove-Item $archive
Say "done: the output is in Output_$($Org)_$($Dest); open /Output/OD_PairRoutes in GeoDmsGui with the same settings"
