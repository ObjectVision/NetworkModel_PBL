# RunFrontValidation.ps1: twee runs naast elkaar en de vergelijking van hun fronten (ObjectVision/NetworkModel_PBL#53, stap 2).
#
#   powershell -ExecutionPolicy Bypass -File batch\RunFrontValidation.ps1 [-Label val53] [-CritA Time] [-CritB 'Price,Time']
#        [-GtfsDate 20260925] [-AnalysisDate 20261006] [-Blocks (1..10)] [-NrOrgBlocks 450] [-Exe <GeoDmsRun.exe>]
#        [-RunsDir C:\LocalData\NM_PBL_runs] [-OutRoot C:\LocalData\NetworkModel_PBL\Output] [-DryRun]
#
# Maakt van de huidige commit twee runkopieen in <RunsDir>\<Label>\{A,B}\NetworkModel_PBL (git archive van cfg, data en
# batch, plus het machine-lokale cfg\main\ConfigSettings.dms), met MinimiseCriteria CritA en CritB, de feed en dag, en
# OutputLabel <Label>_A en <Label>_B, zodat de uitvoer in <OutRoot>\<AnalysisDate>_<Label>_{A,B} komt (sinds #118 een map per
# variant). Dan na elkaar: de ketenstap van A en B (batch\UpdateAll.cmd chains in de kopie), de uitvoer voor de herkomstblokken
# -Blocks, en batch\ValidateFronts.py. Voor elke zware stap wacht het tot er geen GeoDmsRun van een andere run loopt, en het
# stopt als C: onder 15 GB vrij komt. Voortgang in <RunsDir>\<Label>\status.txt, verslag in <RunsDir>\<Label>\verslag.md.
# OutRoot moet %LocalDataProjDir%\Output uit ConfigSettings.dms zijn; Label alleen letters, cijfers, - en _, hoogstens 18 tekens.
#
# Een ketenstap duurt uren (op 2026-10-02/03 voor 500 haltenblokken: 'Time' 4,0 uur, 'Price,Time' 4,2 uur; de uitvoer voor 10
# herkomstblokken daarna 10 en 13 minuten). Met -DryRun maakt het alleen de runkopieen en toont het de gezette parameters.
param(
	[string]$Label        = 'val53',
	[string]$CritA        = 'Time',
	[string]$CritB        = 'Price,Time',
	[string]$GtfsDate     = '20260925',
	[string]$AnalysisDate = '20261006',
	[int[]] $Blocks       = (1..10),
	[int]   $NrOrgBlocks  = 450,
	[string]$Exe          = 'C:\LocalData\GeoDMS_engine\20.22.1_e04ad20f0\GeoDmsRun.exe',
	[string]$RunsDir      = 'C:\LocalData\NM_PBL_runs',
	[string]$OutRoot      = 'C:\LocalData\NetworkModel_PBL\Output',
	[switch]$DryRun
)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$base = Join-Path $RunsDir $Label
$out  = $OutRoot
$env:GEODMS_EXE = $Exe
New-Item -ItemType Directory -Force $base | Out-Null
$status = Join-Path $base 'status.txt'

function Say($m) { $l = '{0} {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m; Add-Content -Path $status -Value $l; $l }
function WaitForeign {
	while (@(Get-CimInstance Win32_Process -Filter "Name='GeoDmsRun.exe'" | Where-Object { $_.CommandLine -notlike "*NM_PBL_runs\$Label\*" }).Count -gt 0) {
		Say 'wacht: er draait een GeoDmsRun van een andere run'; Start-Sleep -Seconds 300
	}
}
function CheckDisk {
	$free = (Get-PSDrive C).Free / 1GB
	if ($free -lt 15) { Say ('STOP: C: heeft nog {0:N0} GB vrij' -f $free); exit 2 }
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

$head = (& git -C $repo rev-parse --short HEAD).Trim()
Say "start: commit $head, A '$CritA', B '$CritB', feed $GtfsDate, dag $AnalysisDate, blokken $($Blocks -join ','), engine $Exe"

$runs = @(@{ Name = 'A'; Crit = $CritA }, @{ Name = 'B'; Crit = $CritB })
foreach ($r in $runs) {
	$dst = Join-Path $base "$($r.Name)\NetworkModel_PBL"
	if (-not (Test-Path (Join-Path $dst 'cfg\main.dms'))) {
		New-Item -ItemType Directory -Force $dst | Out-Null
		$zip = Join-Path $base "$($r.Name).zip"
		& git -C $repo archive --format=zip -o $zip HEAD cfg data batch
		Expand-Archive -Path $zip -DestinationPath $dst -Force
		Remove-Item $zip
		Copy-Item (Join-Path $repo 'cfg\main\ConfigSettings.dms') (Join-Path $dst 'cfg\main\ConfigSettings.dms')
		$mp = Join-Path $dst 'cfg\main\ModelParameters.dms'
		SetParam $mp 'GTFS_file_date'          "'$GtfsDate'"
		SetParam $mp 'Analysis_date'           "'$AnalysisDate'"
		SetParam $mp 'MinimiseCriteria'        "'$($r.Crit)'"
		SetParam $mp 'OutputLabel'             "'$($Label)_$($r.Name)'"
		SetParam $mp 'Export_PriceInformation' 'TRUE'
		Say "runkopie $($r.Name): MinimiseCriteria '$($r.Crit)', uitvoer in $out\$($AnalysisDate)_$($Label)_$($r.Name)"
	}
	$r.Dst = $dst
	if ($DryRun) {
		Select-String -Path (Join-Path $dst 'cfg\main\ModelParameters.dms') -Pattern 'parameter<\w+>\s+(GTFS_file_date|Analysis_date|MinimiseCriteria|OutputLabel|Export_PriceInformation)\s+:=\s+\S+' |
			ForEach-Object { '  {0}: {1}' -f $r.Name, $_.Matches[0].Value }
	}
}
if ($DryRun) { Say 'DryRun: alleen de runkopieen gemaakt'; exit 0 }

foreach ($r in $runs) {
	WaitForeign; CheckDisk
	Say "ketenstap $($r.Name) start"
	$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', ('"{0}\batch\UpdateAll.cmd" chains' -f $r.Dst) -PassThru -Wait -WindowStyle Hidden
	Say "ketenstap $($r.Name) klaar, exit $($p.ExitCode)"
	if ($p.ExitCode -ne 0) { Say "STOP: ketenstap $($r.Name) mislukt, zie $($r.Dst)\batch\log"; exit 4 }
}

foreach ($r in $runs) {
	WaitForeign; CheckDisk
	$items = @(); foreach ($i in $Blocks) { $items += '@statistics'; $items += "/NetworkSetup/ConfigurationPerBlock/Block_${i}of$NrOrgBlocks/PublicTransport/Generate_Output/Traveltime_ForEachDepTime_Fence/Generate" }
	$log = Join-Path $r.Dst 'batch\log'
	New-Item -ItemType Directory -Force $log | Out-Null
	Say "uitvoer $($r.Name) start"
	$p = Start-Process -FilePath $Exe -ArgumentList (@("/L$log\frontval_output.log", (Join-Path $r.Dst 'cfg\main.dms')) + $items) -PassThru -Wait -WindowStyle Hidden -RedirectStandardOutput "$log\frontval_output.txt"
	Say "uitvoer $($r.Name) klaar, exit $($p.ExitCode)"
	if ($p.ExitCode -ne 0) { Say "STOP: uitvoer $($r.Name) mislukt, zie $log\frontval_output.txt"; exit 5 }
}

$md = Join-Path $base 'verslag.md'
& python (Join-Path $repo 'batch\ValidateFronts.py') --a "$out\$($AnalysisDate)_$($Label)_A\PerBlock\tt_*.csv" --b "$out\$($AnalysisDate)_$($Label)_B\PerBlock\tt_*.csv" --md $md *> (Join-Path $base 'verslag.txt')
Say "vergelijking klaar (exit $LASTEXITCODE): $md"
Say 'KLAAR'
