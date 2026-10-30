# RunFrontValidation.ps1: two runs side by side and the comparison of their fronts (ObjectVision/NetworkModel_PBL#53, step 2).
#
#   powershell -ExecutionPolicy Bypass -File batch\RunFrontValidation.ps1 -Label <label> [-CritA Time,Car,Bike]
#        [-BaseRun <run copy>\NetworkModel_PBL]                          B = an existing run with output, calculate only A
#        [-CritB 'Price,Time,Car,Bike'] [-AnalysisMoment Y2026] [-PartOfDay Ochtendspits] [-Component W_PT_W]
#                                                                          without -BaseRun: calculate A and B
#        [-Blocks (1..10)] [-NrOrgBlocks 450] [-WaitFor others|base|none] [-MinFreeRamGB 24] [-Exe <GeoDmsRun.exe>]
#        [-RunsDir C:\LocalData\NM_PBL_runs] [-OutRoot C:\LocalData\NetworkModel_PBL\Output] [-DryRun]
#
# Run A gets MinimiseCriteria CritA, run B CritB; otherwise they are equal. The analysis moment (AnalysisMoment, with the
# day and the feed from the preset table) and the part of the day (PartOfDay) are parameters of the model (#125). The
# component (#117) is WW, CC, Car or <pre-transport>_PT_<post-transport>, such as W_PT_W; the default is W_PT_W. In a fresh
# run copy the script makes it the only component of the variant (ModelParameters, group 2: its pre- and post-transport type,
# or its direct trip, on, the rest off, no merge), and its GeoDmsRun steps get it as GEODMS_Overridable_RunComponent.
# Each run that is calculated is a run copy in <RunsDir>\<Label>\{A,B}\NetworkModel_PBL with OutputLabel <Label>_A or
# <Label>_B, so that its output lands in <OutRoot>\<Analysis_date>_<Label>_{A,B}_<component> (a folder per variant, #118,
# with the component after it, #117). Then come the chain step (batch\UpdateAll.cmd chains in the copy), the output for the
# origin blocks -Blocks and batch\ValidateFronts.py. Progress goes to <RunsDir>\<Label>\status.txt, the report to
# <RunsDir>\<Label>\verslag.md.
#
# With -BaseRun, B is an existing run copy whose output already exists, for example the base run
# C:\LocalData\NM_PBL_runs\20261006\NetworkModel_PBL. A is then a copy of its cfg, data and batch (so the same commit, feed,
# day and ConfigSettings.dms), with only MinimiseCriteria and OutputLabel changed; CritB, AnalysisMoment and PartOfDay are
# then ignored. The output of B for -Blocks and its signature.txt are copied at the start to <RunsDir>\<Label>\B_uitvoer,
# so that a later run under the same label does not disturb the comparison. After the output of A the script compares the
# signatures of A and B without the criteria and reports any other difference.
#
# Waiting: -WaitFor others (the default without -BaseRun) waits before every heavy step until no GeoDmsRun of another
# NetworkModel_PBL run is running; base (the default with -BaseRun) waits only until the base run is finished; none does not
# wait. Besides that the script waits as long as less than -MinFreeRamGB of memory is free, and stops when C: drops below
# 15 GB free.
#
# A chain step takes hours (about 4 hours for 500 stop blocks); the output for 10 origin blocks then takes 10 to 15 minutes.
# With -DryRun the script only makes the run copies and shows the parameters it set.
param(
	[Parameter(Mandatory = $true)][string]$Label,
	[string]$CritA        = 'Time,Car,Bike',
	[string]$BaseRun      = '',
	[string]$CritB        = 'Price,Time,Car,Bike',
	[string]$AnalysisMoment = 'Y2026',
	[string]$PartOfDay      = 'Ochtendspits',
	[ValidatePattern('^(WW|CC|Car|(W|C|C_RM|C_RMT|C_Ric)_PT_(W|C|RM_C|RMT_C|OVf_C))$')][string]$Component = 'W_PT_W',
	[int[]] $Blocks       = (1..10),
	[int]   $NrOrgBlocks  = 450,
	[ValidateSet('others', 'base', 'none')][string]$WaitFor = '',
	[int]   $MinFreeRamGB = 24,
	[string]$Exe          = 'C:\Program Files\ObjectVision\GeoDms20.27.0.m\GeoDmsRun.exe',
	[string]$RunsDir      = 'C:\LocalData\NM_PBL_runs',
	[string]$OutRoot      = 'C:\LocalData\NetworkModel_PBL\Output',
	[switch]$DryRun
)
$ErrorActionPreference = 'Stop'
if ($Label -notmatch '^[A-Za-z0-9_-]{1,18}$') { throw "Label '$Label': only letters, digits, - and _, at most 18 characters (OutputLabel <Label>_A)" }
if (-not $WaitFor) { $WaitFor = if ($BaseRun) { 'base' } else { 'others' } }
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$base = Join-Path $RunsDir $Label
$env:GEODMS_EXE = $Exe
New-Item -ItemType Directory -Force $base | Out-Null
$status = Join-Path $base 'status.txt'

function Say($m) { $l = '{0} {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m; Add-Content -Path $status -Value $l; $l }
# Is a GeoDmsRun or an UpdateAll.cmd running outside this validation whose command line matches $pattern?
function Running($pattern) {
	$own = "*$base\*"
	@(Get-CimInstance Win32_Process -Filter "Name='GeoDmsRun.exe' OR Name='cmd.exe'" | Where-Object {
		$c = $_.CommandLine
		$c -and $c -notlike $own -and $c -like $pattern -and ($_.Name -eq 'GeoDmsRun.exe' -or $c -like '*UpdateAll.cmd*')
	}).Count -gt 0
}
function Busy {
	switch ($WaitFor) {
		'base'   { return Running "*$BaseRun\*" }
		'others' { return Running '*NetworkModel_PBL*' }
		default  { return $false }
	}
}
function WaitTurn {
	# Free twice in a row, 30 s apart: between two steps of another run there is briefly no GeoDmsRun.
	$free = 0
	while ($free -lt 2) {
		if (Busy) { $free = 0; Say "waiting: another run is busy ($WaitFor)"; Start-Sleep -Seconds 300; continue }
		$ram = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB
		if ($ram -lt $MinFreeRamGB) { $free = 0; Say ('waiting: {0:N0} GB of memory free, less than {1}' -f $ram, $MinFreeRamGB); Start-Sleep -Seconds 300; continue }
		$free++; if ($free -lt 2) { Start-Sleep -Seconds 30 }
	}
	$disk = (Get-PSDrive C).Free / 1GB
	if ($disk -lt 15) { Say ('STOP: C: has only {0:N0} GB free' -f $disk); exit 2 }
}
# The file that declares parameter $name: ModelParameters.dms, or ModelParameters\Advanced.dms beside it.
function ParamFile($file, $name) {
	$re = "parameter<\w+>\s+$name\s+:="
	if ([IO.File]::ReadAllText($file) -match $re) { return $file }
	$adv = Join-Path ([IO.Path]::GetDirectoryName($file)) 'ModelParameters\Advanced.dms'
	if ((Test-Path $adv) -and ([IO.File]::ReadAllText($adv) -match $re)) { return $adv }
	return $file
}
# The text of ModelParameters.dms and, when it exists, of ModelParameters\Advanced.dms beside it, with the preset table.
function ParamText($file) {
	$t = [IO.File]::ReadAllText($file)
	$adv = Join-Path ([IO.Path]::GetDirectoryName($file)) 'ModelParameters\Advanced.dms'
	if (Test-Path $adv) { $t += "`n" + [IO.File]::ReadAllText($adv) }
	return $t
}
function GetParam($file, $name) {
	$file = ParamFile $file $name
	$m = [regex]::Match([IO.File]::ReadAllText($file), "parameter<\w+>\s+$name\s+:=\s+('([^']*)'|TRUE|FALSE)")
	if (-not $m.Success) { Say "STOP: parameter $name not found in $file"; exit 3 }
	if ($m.Groups[2].Success) { return $m.Groups[2].Value } else { return $m.Groups[1].Value }
}
# Sets the value of a parameter in ModelParameters.dms: "parameter<type>   Name   := <value>", with value 'text', TRUE or FALSE.
function SetParam($file, $name, $value) {
	$file = ParamFile $file $name
	$t = [IO.File]::ReadAllText($file)
	$re = "(parameter<\w+>\s+$name\s+:=\s+)('[^']*'|TRUE|FALSE)"
	$n = ([regex]::Matches($t, $re)).Count
	if ($n -ne 1) { Say "STOP: parameter $name occurs $n times in $file"; exit 3 }
	$t = [regex]::Replace($t, $re, { param($m) $m.Groups[1].Value + $value })
	[IO.File]::WriteAllText($file, $t)
}
# The day and the feed of AnalysisMoment $moment in the preset table of ModelParameters.dms (the text $t, #125).
function PresetDates($t, $moment) {
	$row = [regex]::Match($t, "(?m)^\s*'$moment'\s*,(.*)$")
	if (-not $row.Success) { Say "STOP: AnalysisMoment $moment is not in the preset table"; exit 3 }
	# name, OSM date, Regios, TomTom, BAG_snapshot, Analysis_date, GTFS_file_date, OVFiets_year, with the column OSM_perProv (TRUE or
	# FALSE) left out: older run copies have it as the fourth column, the current model as the last.
	$f = @(("'$moment'," + $row.Groups[1].Value) -split ',' | ForEach-Object { $_.Trim().Trim("'") } | Where-Object { $_ -notmatch '^(TRUE|FALSE)$' })
	if ($f[5] -notmatch '^\d{8}$' -or $f[6] -notmatch '^\d{8}$') { Say "STOP: AnalysisMoment $moment has no analysis date or feed ('$($f[5])', '$($f[6])')"; exit 3 }
	return @($f[5], $f[6])
}
# The suffix of the output folder of a component (Classifications/Components/OutputSuffix, #117): _ and the name.
# For a base run from before 2026-10-19 also the old names: _lopen, _fiets and _auto for Lopen, Fiets and Auto, and nothing
# for All and Alles.
# The parts of a public transport component: the code in the name and the type in Classifications/TimeInvariantTypes.
$VoorTypen = [ordered]@{ 'W' = 'Org2Stops_Walking'; 'C' = 'Org2Stops_Cycling'; 'C_RM' = 'Org2RM_Stops_Cycling'; 'C_RMT' = 'Org2RMT_Stops_Cycling'; 'C_Ric' = 'Org2Ric_Stops_Cycling' }
$NaTypen = [ordered]@{ 'W' = 'Stops2Dest_Walking'; 'C' = 'Stops2Dest_Cycling'; 'RM_C' = 'RM_Stops2Dest_Cycling'; 'RMT_C' = 'RMT_Stops2Dest_Cycling'; 'OVf_C' = 'OVF_Stops2Dest_Cycling' }
# PreTransport and PostTransport in a ModelParameters.dms: the declaration with the path (group 1) and the type (group 2). The current
# model has the path on the line after :=, older run copies have it on the same line with /Classifications/ in front, and copies from
# before 2026-10-27 call the parameters Voortransport and Natransport.
$PreTransportRe = '((?:PreTransport|Voortransport)\s+:=\s+(?:/Classifications/)?TimeInvariantTypes/V/)(\w+)'
$PostTransportRe = '((?:PostTransport|Natransport)\s+:=\s+(?:/Classifications/)?TimeInvariantTypes/V/)(\w+)'
# Makes the component the only component of the variant of a ModelParameters.dms (group 2, #117): the switch of its pre- and
# post-transport type, or of its direct trip, on, all other switches off, and no merge.
function SetComponent($mp, $name) {
	foreach ($n in @($VoorTypen.Values) + @($NaTypen.Values) + @('DirectWalking', 'DirectCycling', 'DirectCar', 'Merge')) { SetParam $mp $n 'FALSE' }
	switch ($name) {
		'WW'    { SetParam $mp 'DirectWalking' 'TRUE' }
		'CC'    { SetParam $mp 'DirectCycling' 'TRUE' }
		'Car'   { SetParam $mp 'DirectCar' 'TRUE' }
		default { $m = [regex]::Match($name, '^(.+)_PT_(.+)$'); SetParam $mp $VoorTypen[$m.Groups[1].Value] 'TRUE'; SetParam $mp $NaTypen[$m.Groups[2].Value] 'TRUE' }
	}
}
# The name of the component of a run copy: for a copy with the variant (from 2026-10-30) the component of this validation; All
# for a copy without Component (from before 2026-10-05); otherwise Component itself, and for Component 'PT' the codes of
# PreTransport and PostTransport.
function ComponentName($mpText, $mp) {
	if ($mpText -match "container\s+PreTransport\b") { return $Component }
	if ($mpText -notmatch "parameter<\w+>\s+Component\s+:=") { return 'All' }
	$c = GetParam $mp 'Component'; if ($c -ne 'PT') { return $c }
	$v = [regex]::Match($mpText, $PreTransportRe).Groups[2].Value; $n = [regex]::Match($mpText, $PostTransportRe).Groups[2].Value
	return (@($VoorTypen.Keys | Where-Object { $VoorTypen[$_] -eq $v })[0]) + '_PT_' + (@($NaTypen.Keys | Where-Object { $NaTypen[$_] -eq $n })[0])
}
function ComponentSuffix($component) { switch ($component) { 'Lopen' { '_lopen' } 'Fiets' { '_fiets' } 'Auto' { '_auto' } 'All' { '' } 'Alles' { '' } default { '_' + $component } } }
function BlockFiles($dir, $date, $i) { @(Get-ChildItem -Path $dir -Filter "tt_$($date)_*_$($i)of$NrOrgBlocks.csv" -ErrorAction SilentlyContinue) }
# The signature without the criteria: MinCrit-..._MaxPT of the output and _min-..._maxtransf of the chain cache.
function SigWithoutCrit($file) { ((Get-Content $file -Raw) -replace 'MinCrit-.*?_MaxPT', 'MinCrit-*_MaxPT' -replace '_min-.*?_maxtransf', '_min-*_maxtransf').Trim() }

$head = (& git -C $repo rev-parse --short HEAD).Trim()
$runs = @()
if ($BaseRun) {
	$BaseRun = (Resolve-Path $BaseRun).Path.TrimEnd('\')
	$bmp = Join-Path $BaseRun 'cfg\main\ModelParameters.dms'
	$bmpText = [IO.File]::ReadAllText($bmp)
	if ($bmpText -match "parameter<\w+>\s+Analysis_date\s+:=\s+'\d{8}'") {
		# A run copy from before 2026-10-05 has the day and the feed as literal values.
		$AnalysisDate = GetParam $bmp 'Analysis_date'
		$GtfsDate = GetParam $bmp 'GTFS_file_date'
	} else {
		$AnalysisDate, $GtfsDate = PresetDates (ParamText $bmp) (GetParam $bmp 'AnalysisMoment')
	}
	$CritB = GetParam $bmp 'MinimiseCriteria'
	$bLabel = GetParam $bmp 'OutputLabel'
	# A run copy from before 2026-10-05 has no Component: it calculated everything in one run, without a suffix.
	$Component = ComponentName $bmpText $bmp
	$bOut = Join-Path $OutRoot "$($AnalysisDate)_$bLabel$(ComponentSuffix $Component)"
	$commit = if (Test-Path (Join-Path $BaseRun 'COMMIT.txt')) { (Get-Content (Join-Path $BaseRun 'COMMIT.txt') -TotalCount 1).Substring(0, 7) } else { '?' }
	Say "start: B = base run $BaseRun (commit $commit, '$CritB', component $Component, output $bOut), A '$CritA', feed $GtfsDate, day $AnalysisDate, blocks $($Blocks -join ','), waiting for $WaitFor"
	$runs += @{ Name = 'A'; Crit = $CritA; From = $BaseRun }
} else {
	$AnalysisDate, $GtfsDate = PresetDates (((& git -C $repo show HEAD:cfg/main/ModelParameters.dms) + (& git -C $repo show HEAD:cfg/main/ModelParameters/Advanced.dms 2>$null)) -join "`n") $AnalysisMoment
	Say "start: commit $head, A '$CritA', B '$CritB', analysis moment $AnalysisMoment (feed $GtfsDate, day $AnalysisDate), PartOfDay $PartOfDay, component $Component, blocks $($Blocks -join ','), waiting for $WaitFor, engine $Exe"
	$runs += @{ Name = 'A'; Crit = $CritA }, @{ Name = 'B'; Crit = $CritB }
}

foreach ($r in $runs) {
	$dst = Join-Path $base "$($r.Name)\NetworkModel_PBL"
	if (-not (Test-Path (Join-Path $dst 'cfg\main.dms'))) {
		New-Item -ItemType Directory -Force $dst | Out-Null
		$mp = Join-Path $dst 'cfg\main\ModelParameters.dms'
		if ($r.From) {
			foreach ($d in 'cfg', 'data', 'batch') {
				& robocopy (Join-Path $r.From $d) (Join-Path $dst $d) /E /XD log /NFL /NDL /NJH /NJS /NP | Out-Null
				if ($LASTEXITCODE -ge 8) { Say "STOP: copying $d from $($r.From) failed (robocopy $LASTEXITCODE)"; exit 6 }
			}
			if (Test-Path (Join-Path $r.From 'COMMIT.txt')) { Copy-Item (Join-Path $r.From 'COMMIT.txt') $dst }
		} else {
			$zip = Join-Path $base "$($r.Name).zip"
			& git -C $repo archive --format=zip -o $zip HEAD cfg data batch
			Expand-Archive -Path $zip -DestinationPath $dst -Force
			Remove-Item $zip
			Set-Content -Path (Join-Path $dst 'COMMIT.txt') -Value "$(& git -C $repo rev-parse HEAD) (git archive)"
			SetParam $mp 'AnalysisMoment' "'$AnalysisMoment'"
			SetParam $mp 'PartOfDay'        "'$PartOfDay'"
			SetComponent $mp $Component
		}
		SetParam $mp 'MinimiseCriteria'        "'$($r.Crit)'"
		SetParam $mp 'OutputLabel'             "'$($Label)_$($r.Name)'"
		SetParam $mp 'Export_PriceInformation' 'TRUE'
		Say "run copy $($r.Name): MinimiseCriteria '$($r.Crit)', output in $OutRoot\$($AnalysisDate)_$($Label)_$($r.Name)$(ComponentSuffix $Component)"
	}
	$r.Dst = $dst
	$r.Out = Join-Path $OutRoot "$($AnalysisDate)_$($Label)_$($r.Name)$(ComponentSuffix $Component)"
	if ($DryRun) {
		Select-String -Path (Join-Path $dst 'cfg\main\ModelParameters.dms'), (Join-Path $dst 'cfg\main\ModelParameters\Advanced.dms') -Pattern 'parameter<\w+>\s+(AnalysisMoment|PartOfDay|Component|MinimiseCriteria|OutputLabel|Export_PriceInformation)\s+:=\s+\S+' |
			ForEach-Object { '  {0}: {1}' -f $r.Name, $_.Matches[0].Value }
	}
}

if ($BaseRun) {
	# The output of the base run: wait until it exists for all blocks, then copy it, so that B can no longer change.
	$bSnap = Join-Path $base 'B_uitvoer'
	while ($true) {
		$missing = @($Blocks | Where-Object { (BlockFiles (Join-Path $bOut 'PerBlock') $AnalysisDate $_).Count -eq 0 })
		$sigOk = Test-Path (Join-Path $bOut 'signature.txt')
		$baseBusy = Running "*$BaseRun\*"
		if ($missing.Count -eq 0 -and $sigOk -and -not $baseBusy) { break }
		if ($DryRun -or -not $baseBusy) { Say "STOP: the base run is still running ($baseBusy) or its output is missing in $bOut (blocks $($missing -join ','); signature.txt $sigOk)"; exit 7 }
		Say "waiting until the base run is finished (output in $bOut, missing blocks $($missing -join ','))"; Start-Sleep -Seconds 600
	}
	if (-not $DryRun) {
		New-Item -ItemType Directory -Force (Join-Path $bSnap 'PerBlock') | Out-Null
		Copy-Item (Join-Path $bOut 'signature.*') $bSnap
		foreach ($i in $Blocks) { BlockFiles (Join-Path $bOut 'PerBlock') $AnalysisDate $i | ForEach-Object { Copy-Item $_.FullName (Join-Path $bSnap 'PerBlock') } }
		Say "output of B copied to $bSnap"
	}
}
if ($DryRun) { Say 'DryRun: only the run copies were made'; exit 0 }

# The GeoDmsRun steps of a copy with the variant calculate this component (ConfigSettings/Overridable/RunComponent, #117); a copy
# from before 2026-10-30 does not read it.
$env:GEODMS_Overridable_RunComponent = $Component
foreach ($r in $runs) {
	WaitTurn
	Say "chain step $($r.Name) starts"
	$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', ('"{0}\batch\UpdateAll.cmd" chains' -f $r.Dst) -PassThru -Wait -WindowStyle Hidden
	Say "chain step $($r.Name) finished, exit $($p.ExitCode)"
	if ($p.ExitCode -ne 0) { Say "STOP: chain step $($r.Name) failed, see $($r.Dst)\batch\log"; exit 4 }
}

foreach ($r in $runs) {
	WaitTurn
	$items = @(); foreach ($i in $Blocks) { $items += '@statistics'; $items += "/NetworkSetup/ConfigurationPerBlock/Block_${i}of$NrOrgBlocks/PublicTransport/Generate_Output/Traveltime_ForEachDepTime_Fence/Generate" }
	$log = Join-Path $r.Dst 'batch\log'
	New-Item -ItemType Directory -Force $log | Out-Null
	Say "output $($r.Name) starts"
	$p = Start-Process -FilePath $Exe -ArgumentList (@("/L$log\frontval_output.log", (Join-Path $r.Dst 'cfg\main.dms')) + $items) -PassThru -Wait -WindowStyle Hidden -RedirectStandardOutput "$log\frontval_output.txt"
	Say "output $($r.Name) finished, exit $($p.ExitCode)"
	if ($p.ExitCode -ne 0) { Say "STOP: output $($r.Name) failed, see $log\frontval_output.txt"; exit 5 }
}

$aOut = $runs[0].Out
$bDir = if ($BaseRun) { $bSnap } else { $runs[1].Out }
$sa = SigWithoutCrit (Join-Path $aOut 'signature.txt'); $sb = SigWithoutCrit (Join-Path $bDir 'signature.txt')
if ($sa -eq $sb) { Say 'the signatures of A and B are equal apart from the criteria' } else { Say "WARNING: the signatures of A and B also differ outside the criteria:`r`n  A $sa`r`n  B $sb" }
$md = Join-Path $base 'verslag.md'
& python (Join-Path $repo 'batch\ValidateFronts.py') --a "$aOut\PerBlock\tt_*.csv" --b "$bDir\PerBlock\tt_*.csv" --blocks ($Blocks -join ',') --md $md *> (Join-Path $base 'verslag.txt')
Say "comparison finished (exit $LASTEXITCODE): $md"
Say 'DONE'
