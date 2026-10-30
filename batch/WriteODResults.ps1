# WriteODResults.ps1 (#129): the routes of one OD pair, for every component of the variant and merged.
#
# Makes one run copy of HEAD (with git archive) with OD_Origin, OD_Destination and OD_DepartureTime and the variant (ModelParameters,
# group 2, #117), and calculates it with batch\UpdateAll.cmd all -nosources of the copy: per component the legs of pre- and
# post-transport with their links and the chains of the pair with their legs (once, at the first public transport component), the car
# cache of the departure moment (Car) and the output, PerBlock/tt_<moment>_1of1.parquet and PerBlock/od_<moment>.gpkg with options,
# parts and links; then the merge. Intermediate results go to %LocalDataProjDir%\IntermediateResults_<O>_<D>, output to
# Output_<O>_<D>; /Output/OD_PairRoutes in the GUI reads them, with the same settings in ModelParameters (groups 1, 2 and 6).
#
# Call, for example for the trip Laapersweg 1 Hilversum -> De Boelelaan 1085 at 07:30 (the wiki, Routes of an OD pair):
#   powershell -ExecutionPolicy Bypass -File batch\WriteODResults.ps1 -Org BU04020501 -Dest BU0363KP03 -Moment 07:30
# The variant is that of cfg\main\ModelParameters.dms of the working copy; -Components 'WW,W_PT_W,C_PT_OVf_C' sets it instead, from
# the direct trips and the pre- and post-transport types in the names (every pre-transport type with every post-transport type).
# The engine must know pareto with LinkSet (ObjectVision/GeoDMS#1325) for the car routes: GeoDMS 20.26.0 or later.
# -AlleenUitvoer skips the legs and the chains when their caches already exist (to repeat the output after a change to it).
# Run long runs as a one-off scheduled task (see the wiki, How to run the model). -WaitForMemoryGB waits until that much
# memory is available before the run starts, so that the pair does not make other runs page; the chain step calculates all
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
function WaitForMemory {
	if ($WaitForMemoryGB -le 0) { return }
	while ($true) {
		$free = (Get-Counter '\Memory\Available MBytes').CounterSamples[0].CookedValue / 1024
		if ($free -ge $WaitForMemoryGB) { return }
		Say ("waiting for memory: {0:N1} GB available, {1} GB needed" -f $free, $WaitForMemoryGB)
		Start-Sleep -Seconds 300
	}
}
# The switches of the variant (ModelParameters, group 2): the pre- and post-transport types by their code in a component name.
$voor = [ordered]@{ 'W' = 'Org2Stops_Walking'; 'C' = 'Org2Stops_Cycling'; 'C_RM' = 'Org2RM_Stops_Cycling'; 'C_RMT' = 'Org2RMT_Stops_Cycling'; 'C_Ric' = 'Org2Ric_Stops_Cycling' }
$na   = [ordered]@{ 'W' = 'Stops2Dest_Walking'; 'C' = 'Stops2Dest_Cycling'; 'RM_C' = 'RM_Stops2Dest_Cycling'; 'RMT_C' = 'RMT_Stops2Dest_Cycling'; 'OVf_C' = 'OVF_Stops2Dest_Cycling' }
$switches = @($voor.Values) + @($na.Values) + @('DirectWalking', 'DirectCycling', 'DirectCar', 'Merge')
function GetSwitch($file, $name) {
	$m = [regex]::Match([IO.File]::ReadAllText($file), "parameter<bool>\s+$name\s+:=\s+(TRUE|FALSE)")
	if (-not $m.Success) { throw "switch $name not found in $file" }
	return $m.Groups[1].Value
}
# The value of every switch: from -Components, or else from the working copy.
$values = @{}
if ($Components) {
	foreach ($n in $switches) { $values[$n] = 'FALSE' }
	$values['Merge'] = 'TRUE'
	foreach ($c in ($Components.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
		switch ($c) {
			'WW'    { $values['DirectWalking'] = 'TRUE' }
			'CC'    { $values['DirectCycling'] = 'TRUE' }
			'Car'   { $values['DirectCar'] = 'TRUE' }
			default { $x = [regex]::Match($c, '^(.+)_PT_(.+)$'); if (-not $x.Success -or -not $voor.Contains($x.Groups[1].Value) -or -not $na.Contains($x.Groups[2].Value)) { throw "unknown component $c" }; $values[$voor[$x.Groups[1].Value]] = 'TRUE'; $values[$na[$x.Groups[2].Value]] = 'TRUE' }
		}
	}
} else {
	foreach ($n in $switches) { $values[$n] = GetSwitch (Join-Path $repo 'cfg\main\ModelParameters.dms') $n }
}
$archive = Join-Path $runs 'head.tar'
& git -C $repo archive --format=tar -o $archive HEAD cfg data batch
if ($LASTEXITCODE -ne 0) { throw "git archive: exit $LASTEXITCODE" }
$commit = & git -C $repo rev-parse HEAD
Say "OD pair $Org -> $Dest, moment '$Moment', $AnalysisMoment $PartOfDay, $Orgset/$Destset, variant $((@($switches | Where-Object { $values[$_] -eq 'TRUE' })) -join ','), commit $commit, engine $Exe"

$dst = Join-Path $runs 'variant\NetworkModel_PBL'
if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
New-Item -ItemType Directory -Force $dst | Out-Null
& (Join-Path $env:SystemRoot 'System32\tar.exe') -xf $archive -C $dst
if ($LASTEXITCODE -ne 0) { throw "tar: exit $LASTEXITCODE" }
Remove-Item $archive
# ConfigSettings.dms is in git (paths that differ per machine come from the registry, see that file); config.ini is local to the machine.
foreach ($f in 'config.ini') { $src = Join-Path $repo "cfg\main\$f"; if (Test-Path $src) { Copy-Item $src (Join-Path $dst "cfg\main\$f") } }
Set-Content -Path (Join-Path $dst 'COMMIT.txt') -Value "$commit (git archive, plus config.ini from the working copy)"
$mp = Join-Path $dst 'cfg\main\ModelParameters.dms'
SetParam $mp 'AnalysisMoment'   "'$AnalysisMoment'"
SetParam $mp 'PartOfDay'        "'$PartOfDay'"
SetParam $mp 'Orgset'           "'$Orgset'"
SetParam $mp 'Destset'          "'$Destset'"
SetParam $mp 'OutputLabel'      "'$Label'"
SetParam $mp 'OD_Origin'        "'$Org'"
SetParam $mp 'OD_Destination'   "'$Dest'"
SetParam $mp 'OD_DepartureTime' "'$Moment'"
foreach ($n in $switches) { SetParam $mp $n $values[$n] }

WaitForMemory
$env:GEODMS_EXE = $Exe
$args2 = if ($AlleenUitvoer) { 'output -nolegs' } else { 'all -nosources' }
$sw = [Diagnostics.Stopwatch]::StartNew()
# The output of UpdateAll.cmd, stderr included, goes to a file in the log of the copy, so that a cmd message is not an error of this
# script; UpdateAll.cmd writes its progress per step to batch\log\UpdateAll_status.txt of the copy.
& cmd /c "`"$dst\batch\UpdateAll.cmd`" $args2 > `"$dst\batch\log\od_updateall.txt`" 2>&1"
$rc = $LASTEXITCODE
Say ("UpdateAll {0}: exit {1}, {2:N0} s" -f $args2, $rc, $sw.Elapsed.TotalSeconds)
if ($rc -ne 0) { throw "UpdateAll $args2 in $dst failed, see $dst\batch\log\UpdateAll_status.txt" }
Say "done: the output is in Output_$($Org)_$($Dest); open /Output/OD_PairRoutes in GeoDmsGui with the same settings"
