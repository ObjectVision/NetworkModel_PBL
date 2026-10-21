# WriteODResults.ps1 (sinds 2026-10-21, #129): de routes van een HB-paar, voor elke component in MergeComponents en samengevoegd.
#
# Maakt per component een runkopie van HEAD (git archive, zoals make_y2025.ps1) met OD_Herkomst, OD_Bestemming en OD_Vertrekmoment, en
# rekent daarmee na elkaar, elk met batch\UpdateAll.cmd van de kopie:
#   1. de benen van voor- en natransport, met hun links (legs), en
#   2. de ketens van het paar met hun benen (chains), beide een keer, in de kopie van de eerste OV-component;
#   3. per component de autostore van het vertrekmoment (cars, alleen Car) en de uitvoer (output): PerBlock/tt_<moment>_1of1.parquet en
#      PerBlock/od_<moment>.gpkg met opties, onderdelen en links;
#   4. het samenvoegen (een kopie met MergeOutput TRUE, output).
# Tussenresultaten in %LocalDataProjDir%\IntermediateResults_<O>_<D>, uitvoer in Output_<O>_<D>; /OD_Results in de GUI leest ze, met
# dezelfde instellingen in ModelParameters (groep 1 en 6).
#
# Aanroep, bijvoorbeeld de rit Laapersweg 1 Hilversum -> De Boelelaan 1085 om 07:30 (de wiki, Routes of an OD pair):
#   powershell -ExecutionPolicy Bypass -File batch\WriteODResults.ps1 -Org BU04020501 -Dest BU0363KP03 -Moment 07:30
# De engine moet pareto met LinkSet kennen (GeoDMS#1325) voor de autoroutes: standaard de build 20.25.0_06ee574b4; met een oudere
# engine ModelParameters/Advanced/EngineHasParetoLinkSet op FALSE (dan geen autoroute op de kaart).
# Lange runs als eenmalige geplande taak (zie de wiki, How to run the model). -WaitForMemoryGB wacht tot er zoveel geheugen beschikbaar is
# voordat een stap begint, zodat het paar andere runs niet laat pagineren; de ketenstap rekent alle OV-benen van het net (20-30 GB).
param(
	[Parameter(Mandatory=$true)][string]$Org,
	[Parameter(Mandatory=$true)][string]$Dest,
	[string]$Moment = '',
	[string]$AnalysisMoment = 'Y2026',
	[string]$Dagdeel = 'Ochtendspits',
	[string]$Orgset = 'Buurt2025',
	[string]$Destset = 'Buurt2025',
	[string]$Label = 'od',
	[string]$Components = '',
	[string]$Exe = 'C:\LocalData\GeoDMS_engine\20.25.0_06ee574b4\GeoDmsRun.exe',
	[string]$Root = 'C:\LocalData\NM_PBL_runs',
	[int]$WaitForMemoryGB = 0
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
	if (([regex]::Matches($t, $re)).Count -ne 1) { throw "parameter $name niet eenmaal in $file" }
	[IO.File]::WriteAllText($file, [regex]::Replace($t, $re, { param($m) $m.Groups[1].Value + $value }), (New-Object System.Text.UTF8Encoding($true)))
}
function SetType($file, $name, $type) {
	$t = [IO.File]::ReadAllText($file)
	$re = "($name := /Classifications/TimeInvariantTypes/V/)\w+"
	if (([regex]::Matches($t, $re)).Count -ne 1) { throw "$name niet gevonden in $file" }
	[IO.File]::WriteAllText($file, [regex]::Replace($t, $re, { param($m) $m.Groups[1].Value + $type }), (New-Object System.Text.UTF8Encoding($true)))
}
function WaitForMemory {
	if ($WaitForMemoryGB -le 0) { return }
	while ($true) {
		$free = (Get-Counter '\Memory\Available MBytes').CounterSamples[0].CookedValue / 1024
		if ($free -ge $WaitForMemoryGB) { return }
		Say ("wacht op geheugen: {0:N1} GB beschikbaar, {1} GB nodig" -f $free, $WaitForMemoryGB)
		Start-Sleep -Seconds 300
	}
}
# De onderdelen van een component, zoals RunFrontValidation.ps1: WW, CC, Car, of <voortransport>_PT_<natransport>.
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
Say "HB-paar $Org -> $Dest, moment '$Moment', $AnalysisMoment $Dagdeel, $Orgset/$Destset, componenten $($comps -join ','), commit $commit, engine $Exe"

function MakeCopy($name, $comp, $merge) {
	$dst = Join-Path $runs "$name\NetworkModel_PBL"
	if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
	New-Item -ItemType Directory -Force $dst | Out-Null
	& (Join-Path $env:SystemRoot 'System32\tar.exe') -xf $archive -C $dst
	if ($LASTEXITCODE -ne 0) { throw "tar: exit $LASTEXITCODE" }
	foreach ($f in 'ConfigSettings.dms', 'config.ini') { $src = Join-Path $repo "cfg\main\$f"; if (Test-Path $src) { Copy-Item $src (Join-Path $dst "cfg\main\$f") } }
	Set-Content -Path (Join-Path $dst 'COMMIT.txt') -Value "$commit (git archive, plus ConfigSettings.dms en config.ini uit de working copy)"
	$mp = Join-Path $dst 'cfg\main\ModelParameters.dms'
	SetParam $mp 'AnalysisMoment'   "'$AnalysisMoment'"
	SetParam $mp 'Dagdeel'          "'$Dagdeel'"
	SetParam $mp 'Orgset'           "'$Orgset'"
	SetParam $mp 'Destset'          "'$Destset'"
	SetParam $mp 'OutputLabel'      "'$Label'"
	SetParam $mp 'MergeComponents'  "'$Components'"
	SetParam $mp 'OD_Herkomst'      "'$Org'"
	SetParam $mp 'OD_Bestemming'    "'$Dest'"
	SetParam $mp 'OD_Vertrekmoment' "'$Moment'"
	if ($merge) { SetParam $mp 'MergeOutput' 'TRUE' }
	elseif ($comp -in 'WW', 'CC', 'Car') { SetParam $mp 'Component' "'$comp'" }
	else {
		$x = [regex]::Match($comp, '^(.+)_PT_(.+)$')
		SetParam $mp 'Component' "'PT'"; SetType $mp 'Voortransport' $voor[$x.Groups[1].Value]; SetType $mp 'Natransport' $na[$x.Groups[2].Value]
	}
	return $dst
}
function Run($dst, $section, $extra) {
	WaitForMemory
	$env:GEODMS_EXE = $Exe
	$sw = [Diagnostics.Stopwatch]::StartNew()
	& cmd /c "`"$dst\batch\UpdateAll.cmd`" $section $extra" | Out-Null
	$rc = $LASTEXITCODE
	Say ("{0} {1} {2}: exit {3}, {4:N0} s" -f (Split-Path (Split-Path $dst) -Leaf), $section, $extra, $rc, $sw.Elapsed.TotalSeconds)
	if ($rc -ne 0) { throw "$section in $dst mislukt, zie $dst\batch\log" }
}

# Benen en ketens in de kopie van de eerste OV-component: UpdateAll.cmd legs en chains slaan een component zonder OV over.
$pt = $comps | Where-Object { $_ -match '_PT_' } | Select-Object -First 1
if ($pt) {
	$dst = MakeCopy $pt $pt $false
	Run $dst 'legs' ''
	Run $dst 'chains' ''
}
foreach ($c in $comps) {
	$dst = if ($c -eq $pt) { Join-Path $runs "$c\NetworkModel_PBL" } else { MakeCopy $c $c $false }
	if ($c -eq 'Car') {
		$td = if ($Moment) { 'TD' + $Moment.Replace(':', 'h') + 'm' } else { '' }
		Run $dst 'cars' $td
	}
	Run $dst 'output' ''
}
$dst = MakeCopy 'Merged' '' $true
Run $dst 'output' ''
Remove-Item $archive
Say "klaar: de uitvoer staat in Output_$($Org)_$($Dest); open /OD_Results in GeoDmsGui met dezelfde instellingen"
