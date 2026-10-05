# RunFrontValidation.ps1: twee runs naast elkaar en de vergelijking van hun fronten (ObjectVision/NetworkModel_PBL#53, stap 2).
#
#   powershell -ExecutionPolicy Bypass -File batch\RunFrontValidation.ps1 -Label <label> [-CritA Time,Car,Bike]
#        [-BaseRun <runkopie>\NetworkModel_PBL]                          B = een bestaande run met uitvoer, alleen A rekenen
#        [-CritB 'Price,Time,Car,Bike'] [-AnalysisMoment Y2026] [-Dagdeel Ochtendspits] [-Component Alles]
#                                                                          zonder -BaseRun: A en B rekenen
#        [-Blocks (1..10)] [-NrOrgBlocks 450] [-WaitFor others|base|none] [-MinFreeRamGB 24] [-Exe <GeoDmsRun.exe>]
#        [-RunsDir C:\LocalData\NM_PBL_runs] [-OutRoot C:\LocalData\NetworkModel_PBL\Output] [-DryRun]
#
# Run A krijgt MinimiseCriteria CritA, run B CritB; verder zijn ze gelijk. De peildatum (AnalysisMoment, met de dag en de feed
# uit de presettabel) en het dagdeel (Dagdeel) zijn sinds 2026-10-05 parameters van het model (#125); tot dan zette dit script
# GTFS_file_date en Analysis_date (-GtfsDate, -AnalysisDate). Ook de component (Component, #117) is een parameter van het
# model; standaard Alles, de run met lopen + OV + lopen naast alle directe ritten, waarvoor de criteria Car en Bike
# betekenis hebben. Elke run die gerekend wordt, is een runkopie in
# <RunsDir>\<Label>\{A,B}\NetworkModel_PBL met OutputLabel <Label>_A of <Label>_B, zodat de uitvoer in
# <OutRoot>\<Analysis_date>_<Label>_{A,B}<_component> komt (sinds #118 een map per variant, sinds #117 met de component
# erachter: _lopen, _fiets, _auto, niets bij Alles). Daarna: de ketenstap (batch\UpdateAll.cmd chains
# in de kopie), de uitvoer voor de herkomstblokken -Blocks en batch\ValidateFronts.py. Voortgang in <RunsDir>\<Label>\status.txt,
# verslag in <RunsDir>\<Label>\verslag.md.
#
# Met -BaseRun is B een bestaande runkopie waarvan de uitvoer er al is, bijvoorbeeld de basisrun C:\LocalData\NM_PBL_runs\20261006\
# NetworkModel_PBL. A is dan een kopie van diens cfg, data en batch (dus dezelfde commit, feed, dag en ConfigSettings.dms), met
# alleen MinimiseCriteria en OutputLabel anders; CritB, AnalysisMoment en Dagdeel tellen dan niet. De uitvoer van B voor -Blocks
# en zijn signature.txt worden aan het begin gekopieerd naar <RunsDir>\<Label>\B_uitvoer, zodat een latere run onder hetzelfde
# label de vergelijking niet verstoort. Na de uitvoer van A vergelijkt het de handtekeningen van A en B zonder de criteria: een
# ander verschil wordt gemeld.
#
# Wachten: -WaitFor others (standaard zonder -BaseRun) wacht voor elke zware stap tot er geen GeoDmsRun van een andere
# NetworkModel_PBL-run loopt; base (standaard met -BaseRun) alleen tot de basisrun klaar is; none niet. Daarnaast wacht het
# zolang er minder dan -MinFreeRamGB werkgeheugen vrij is, en stopt het als C: onder 15 GB vrij komt.
#
# Een ketenstap duurt uren (op 2026-10-02/03 voor 500 haltenblokken: 'Time' 4,0 uur, 'Price,Time' 4,2 uur; de uitvoer voor 10
# herkomstblokken daarna 10 en 13 minuten). Met -DryRun maakt het alleen de runkopieen en toont het de gezette parameters.
param(
	[Parameter(Mandatory = $true)][string]$Label,
	[string]$CritA        = 'Time,Car,Bike',
	[string]$BaseRun      = '',
	[string]$CritB        = 'Price,Time,Car,Bike',
	[string]$AnalysisMoment = 'Y2026',
	[string]$Dagdeel      = 'Ochtendspits',
	[ValidateSet('Lopen', 'Fiets', 'Auto', 'Alles')][string]$Component = 'Alles',
	[int[]] $Blocks       = (1..10),
	[int]   $NrOrgBlocks  = 450,
	[ValidateSet('others', 'base', 'none')][string]$WaitFor = '',
	[int]   $MinFreeRamGB = 24,
	[string]$Exe          = 'C:\LocalData\GeoDMS_engine\20.22.1_e04ad20f0\GeoDmsRun.exe',
	[string]$RunsDir      = 'C:\LocalData\NM_PBL_runs',
	[string]$OutRoot      = 'C:\LocalData\NetworkModel_PBL\Output',
	[switch]$DryRun
)
$ErrorActionPreference = 'Stop'
if ($Label -notmatch '^[A-Za-z0-9_-]{1,18}$') { throw "Label '$Label': alleen letters, cijfers, - en _, hoogstens 18 tekens (OutputLabel <Label>_A)" }
if (-not $WaitFor) { $WaitFor = if ($BaseRun) { 'base' } else { 'others' } }
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$base = Join-Path $RunsDir $Label
$env:GEODMS_EXE = $Exe
New-Item -ItemType Directory -Force $base | Out-Null
$status = Join-Path $base 'status.txt'

function Say($m) { $l = '{0} {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m; Add-Content -Path $status -Value $l; $l }
# Draait er buiten deze validatie een GeoDmsRun, of een UpdateAll.cmd, waarvan de opdrachtregel op $pattern past?
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
	# Twee keer na elkaar vrij, 30 s uit elkaar: tussen twee stappen van een andere run draait even geen GeoDmsRun.
	$free = 0
	while ($free -lt 2) {
		if (Busy) { $free = 0; Say "wacht: er draait een andere run ($WaitFor)"; Start-Sleep -Seconds 300; continue }
		$ram = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB
		if ($ram -lt $MinFreeRamGB) { $free = 0; Say ('wacht: {0:N0} GB werkgeheugen vrij, minder dan {1}' -f $ram, $MinFreeRamGB); Start-Sleep -Seconds 300; continue }
		$free++; if ($free -lt 2) { Start-Sleep -Seconds 30 }
	}
	$disk = (Get-PSDrive C).Free / 1GB
	if ($disk -lt 15) { Say ('STOP: C: heeft nog {0:N0} GB vrij' -f $disk); exit 2 }
}
function GetParam($file, $name) {
	$m = [regex]::Match([IO.File]::ReadAllText($file), "parameter<\w+>\s+$name\s+:=\s+('([^']*)'|TRUE|FALSE)")
	if (-not $m.Success) { Say "STOP: parameter $name niet gevonden in $file"; exit 3 }
	if ($m.Groups[2].Success) { return $m.Groups[2].Value } else { return $m.Groups[1].Value }
}
# Zet de waarde van een parameter in ModelParameters.dms: "parameter<type>   Naam   := <waarde>", waarde 'tekst', TRUE of FALSE.
function SetParam($file, $name, $value) {
	$t = [IO.File]::ReadAllText($file)
	$re = "(parameter<\w+>\s+$name\s+:=\s+)('[^']*'|TRUE|FALSE)"
	$n = ([regex]::Matches($t, $re)).Count
	if ($n -ne 1) { Say "STOP: parameter $name komt $n keer voor in $file"; exit 3 }
	$t = [regex]::Replace($t, $re, { param($m) $m.Groups[1].Value + $value })
	[IO.File]::WriteAllText($file, $t)
}
# De dag en de feed bij AnalysisMoment $moment in de presettabel van ModelParameters.dms (de tekst $t), sinds 2026-10-05 (#125).
function PresetDates($t, $moment) {
	$row = [regex]::Match($t, "(?m)^\s*'$moment'\s*,(.*)$")
	if (-not $row.Success) { Say "STOP: AnalysisMoment $moment staat niet in de presettabel"; exit 3 }
	# name, OSM date, Regios, OSM_perProv, TomTom, BAG_snapshot, Analysis_date, GTFS_file_date
	$f = @(("'$moment'," + $row.Groups[1].Value) -split ',' | ForEach-Object { $_.Trim().Trim("'") })
	if ($f[6] -notmatch '^\d{8}$' -or $f[7] -notmatch '^\d{8}$') { Say "STOP: AnalysisMoment $moment heeft geen peildatum of feed ('$($f[6])', '$($f[7])')"; exit 3 }
	return @($f[6], $f[7])
}
# Het achtervoegsel van de uitvoermap bij een component (ModelParameters/Advanced/Componenten/UitvoerAchtervoegsel, #117).
function ComponentSuffix($component) { switch ($component) { 'Lopen' { '_lopen' } 'Fiets' { '_fiets' } 'Auto' { '_auto' } default { '' } } }
function BlockFiles($dir, $date, $i) { @(Get-ChildItem -Path $dir -Filter "tt_$($date)_*_$($i)of$NrOrgBlocks.csv" -ErrorAction SilentlyContinue) }
# De handtekening zonder de criteria: MinCrit-..._MaxPT van de uitvoer en _min-..._maxtransf van de ketenstore.
function SigWithoutCrit($file) { ((Get-Content $file -Raw) -replace 'MinCrit-.*?_MaxPT', 'MinCrit-*_MaxPT' -replace '_min-.*?_maxtransf', '_min-*_maxtransf').Trim() }

$head = (& git -C $repo rev-parse --short HEAD).Trim()
$runs = @()
if ($BaseRun) {
	$BaseRun = (Resolve-Path $BaseRun).Path.TrimEnd('\')
	$bmp = Join-Path $BaseRun 'cfg\main\ModelParameters.dms'
	$bmpText = [IO.File]::ReadAllText($bmp)
	if ($bmpText -match "parameter<\w+>\s+Analysis_date\s+:=\s+'\d{8}'") {
		# een runkopie van voor 2026-10-05: de dag en de feed staan er letterlijk
		$AnalysisDate = GetParam $bmp 'Analysis_date'
		$GtfsDate = GetParam $bmp 'GTFS_file_date'
	} else {
		$AnalysisDate, $GtfsDate = PresetDates $bmpText (GetParam $bmp 'AnalysisMoment')
	}
	$CritB = GetParam $bmp 'MinimiseCriteria'
	$bLabel = GetParam $bmp 'OutputLabel'
	# een runkopie van voor 2026-10-05 kent Component niet: die rekende alles in een run, zonder achtervoegsel
	$Component = if ($bmpText -match "parameter<\w+>\s+Component\s+:=") { GetParam $bmp 'Component' } else { 'Alles' }
	$bOut = Join-Path $OutRoot "$($AnalysisDate)_$bLabel$(ComponentSuffix $Component)"
	$commit = if (Test-Path (Join-Path $BaseRun 'COMMIT.txt')) { (Get-Content (Join-Path $BaseRun 'COMMIT.txt') -TotalCount 1).Substring(0, 7) } else { '?' }
	Say "start: B = basisrun $BaseRun (commit $commit, '$CritB', component $Component, uitvoer $bOut), A '$CritA', feed $GtfsDate, dag $AnalysisDate, blokken $($Blocks -join ','), wacht op $WaitFor"
	$runs += @{ Name = 'A'; Crit = $CritA; From = $BaseRun }
} else {
	$AnalysisDate, $GtfsDate = PresetDates ((& git -C $repo show HEAD:cfg/main/ModelParameters.dms) -join "`n") $AnalysisMoment
	Say "start: commit $head, A '$CritA', B '$CritB', peildatum $AnalysisMoment (feed $GtfsDate, dag $AnalysisDate), dagdeel $Dagdeel, component $Component, blokken $($Blocks -join ','), wacht op $WaitFor, engine $Exe"
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
				if ($LASTEXITCODE -ge 8) { Say "STOP: kopieren van $d uit $($r.From) mislukt (robocopy $LASTEXITCODE)"; exit 6 }
			}
			if (Test-Path (Join-Path $r.From 'COMMIT.txt')) { Copy-Item (Join-Path $r.From 'COMMIT.txt') $dst }
		} else {
			$zip = Join-Path $base "$($r.Name).zip"
			& git -C $repo archive --format=zip -o $zip HEAD cfg data batch
			Expand-Archive -Path $zip -DestinationPath $dst -Force
			Remove-Item $zip
			Copy-Item (Join-Path $repo 'cfg\main\ConfigSettings.dms') (Join-Path $dst 'cfg\main\ConfigSettings.dms')
			Set-Content -Path (Join-Path $dst 'COMMIT.txt') -Value "$(& git -C $repo rev-parse HEAD) (git archive, plus cfg/main/ConfigSettings.dms uit de working copy)"
			SetParam $mp 'AnalysisMoment' "'$AnalysisMoment'"
			SetParam $mp 'Dagdeel'        "'$Dagdeel'"
			SetParam $mp 'Component'      "'$Component'"
		}
		SetParam $mp 'MinimiseCriteria'        "'$($r.Crit)'"
		SetParam $mp 'OutputLabel'             "'$($Label)_$($r.Name)'"
		SetParam $mp 'Export_PriceInformation' 'TRUE'
		Say "runkopie $($r.Name): MinimiseCriteria '$($r.Crit)', uitvoer in $OutRoot\$($AnalysisDate)_$($Label)_$($r.Name)$(ComponentSuffix $Component)"
	}
	$r.Dst = $dst
	$r.Out = Join-Path $OutRoot "$($AnalysisDate)_$($Label)_$($r.Name)$(ComponentSuffix $Component)"
	if ($DryRun) {
		Select-String -Path (Join-Path $dst 'cfg\main\ModelParameters.dms') -Pattern 'parameter<\w+>\s+(AnalysisMoment|Dagdeel|Component|MinimiseCriteria|OutputLabel|Export_PriceInformation)\s+:=\s+\S+' |
			ForEach-Object { '  {0}: {1}' -f $r.Name, $_.Matches[0].Value }
	}
}

if ($BaseRun) {
	# De uitvoer van de basisrun: wachten tot die er is voor alle blokken, dan een kopie, zodat B niet meer kan veranderen.
	$bSnap = Join-Path $base 'B_uitvoer'
	while ($true) {
		$missing = @($Blocks | Where-Object { (BlockFiles (Join-Path $bOut 'PerBlock') $AnalysisDate $_).Count -eq 0 })
		$sigOk = Test-Path (Join-Path $bOut 'signature.txt')
		$baseBusy = Running "*$BaseRun\*"
		if ($missing.Count -eq 0 -and $sigOk -and -not $baseBusy) { break }
		if ($DryRun -or -not $baseBusy) { Say "STOP: de basisrun loopt nog ($baseBusy) of zijn uitvoer ontbreekt in $bOut (blokken $($missing -join ','); signature.txt $sigOk)"; exit 7 }
		Say "wacht tot de basisrun klaar is (uitvoer in $bOut, ontbrekende blokken $($missing -join ','))"; Start-Sleep -Seconds 600
	}
	if (-not $DryRun) {
		New-Item -ItemType Directory -Force (Join-Path $bSnap 'PerBlock') | Out-Null
		Copy-Item (Join-Path $bOut 'signature.*') $bSnap
		foreach ($i in $Blocks) { BlockFiles (Join-Path $bOut 'PerBlock') $AnalysisDate $i | ForEach-Object { Copy-Item $_.FullName (Join-Path $bSnap 'PerBlock') } }
		Say "uitvoer van B gekopieerd naar $bSnap"
	}
}
if ($DryRun) { Say 'DryRun: alleen de runkopieen gemaakt'; exit 0 }

foreach ($r in $runs) {
	WaitTurn
	Say "ketenstap $($r.Name) start"
	$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', ('"{0}\batch\UpdateAll.cmd" chains' -f $r.Dst) -PassThru -Wait -WindowStyle Hidden
	Say "ketenstap $($r.Name) klaar, exit $($p.ExitCode)"
	if ($p.ExitCode -ne 0) { Say "STOP: ketenstap $($r.Name) mislukt, zie $($r.Dst)\batch\log"; exit 4 }
}

foreach ($r in $runs) {
	WaitTurn
	$items = @(); foreach ($i in $Blocks) { $items += '@statistics'; $items += "/NetworkSetup/ConfigurationPerBlock/Block_${i}of$NrOrgBlocks/PublicTransport/Generate_Output/Traveltime_ForEachDepTime_Fence/Generate" }
	$log = Join-Path $r.Dst 'batch\log'
	New-Item -ItemType Directory -Force $log | Out-Null
	Say "uitvoer $($r.Name) start"
	$p = Start-Process -FilePath $Exe -ArgumentList (@("/L$log\frontval_output.log", (Join-Path $r.Dst 'cfg\main.dms')) + $items) -PassThru -Wait -WindowStyle Hidden -RedirectStandardOutput "$log\frontval_output.txt"
	Say "uitvoer $($r.Name) klaar, exit $($p.ExitCode)"
	if ($p.ExitCode -ne 0) { Say "STOP: uitvoer $($r.Name) mislukt, zie $log\frontval_output.txt"; exit 5 }
}

$aOut = $runs[0].Out
$bDir = if ($BaseRun) { $bSnap } else { $runs[1].Out }
$sa = SigWithoutCrit (Join-Path $aOut 'signature.txt'); $sb = SigWithoutCrit (Join-Path $bDir 'signature.txt')
if ($sa -eq $sb) { Say 'handtekeningen van A en B gelijk op de criteria na' } else { Say "LET OP: handtekeningen van A en B verschillen ook buiten de criteria:`r`n  A $sa`r`n  B $sb" }
$md = Join-Path $base 'verslag.md'
& python (Join-Path $repo 'batch\ValidateFronts.py') --a "$aOut\PerBlock\tt_*.csv" --b "$bDir\PerBlock\tt_*.csv" --blocks ($Blocks -join ',') --md $md *> (Join-Path $base 'verslag.txt')
Say "vergelijking klaar (exit $LASTEXITCODE): $md"
Say 'KLAAR'
