# ODPairReport.ps1 (#166): the whole route of one OD pair in one call, from the run to the gpkg and the pictures, with every setting as an
# argument. Three steps, by default all three (-Steps run,export,images):
#   run     batch\WriteODResults.ps1: a run copy of -Ref with the pair and the variant, and UpdateAll.cmd all with the settings of group 1,
#           MergeCriteria and NS_TariffChoice (-set) and the merge variant (-variant).
#   export  GeoDmsRun of /Output/OD_PairRoutes/Export/Write on the run copy: od_paar.gpkg and fronten.csv in the folder of the merged output
#           of the pair, with the options of all components and departure moments, the column OpFront for the merged front on
#           MergeCriteria, the parts with the route of each part as one line, and the links.
#   images  GeoDmsGuiQt on the run copy (skill od-paar-beelden): the map of the routes of the merged front, per departure moment the
#           chart of the merged front with one series per group that has points (ZonderAutoFiets, MetFiets, MetAuto, MetAutoFiets, the
#           criteria Car and Bike), and with -ComponentMaps the map of those components. A GUI window shows for a minute or two per
#           picture, the clipboard is overwritten, and typing in that window disturbs the script; run this step in an interactive session.
# The gpkg, fronten.csv and the pictures end up in -Out, by default <Root>\od_<O>_<D>\rapport_<Label>.
# MergeCriteria is Price,Time,Car,Bike by default: the merged front then also keeps an option that needs no car or own bike next to a
# faster or cheaper one that does, which the chart shows as one line per group.
#
# For example, Laapersweg 1 Hilversum to De Boelelaan 1085 Amsterdam at 07:30 (the wiki, Routes of an OD pair):
#   powershell -ExecutionPolicy Bypass -File batch\ODPairReport.ps1 -Org BU04020501 -Dest BU0363KP03 -Moment 07:30 `
#     -Components 'WW,CC,Car,W_PT_W,C_PT_W,C_PT_ovfC' -WaitForMemoryGB 40
# The run step calculates the chains of all rides of the network (20 to 30 GB); start a long run as a one-off scheduled task with
# -Steps run,export, and make the pictures afterwards with -Steps images.
param(
	[Parameter(Mandatory = $true)][string]$Org,
	[Parameter(Mandatory = $true)][string]$Dest,
	[string]$Moment = '',
	[string]$AnalysisMoment = 'Y2026',
	[string]$PartOfDay = 'Morning',
	[string]$Orgset = 'Buurt2025',
	[string]$Destset = 'Buurt2025',
	[string]$Label = 'od',
	[string]$Components = '',
	[string]$Variant = '',
	[string]$MergeCriteria = 'Price,Time,Car,Bike',
	[string]$NS_TariffChoice = '',
	[string]$Ref = 'HEAD',
	[string]$Root = 'C:\LocalData\NM_PBL_runs',
	[string]$Out = '',
	[string]$Steps = 'run,export,images',
	[string]$ComponentMaps = '',
	[string]$Exe = '',
	[string]$GuiExe = '',
	[string]$NetworkModelDir = '',
	[string]$PrivDir = '',
	[int]$WaitForMemoryGB = 0
)
$ErrorActionPreference = 'Stop'
$repo  = Split-Path -Parent $PSScriptRoot
$runs  = Join-Path $Root "od_$($Org)_$($Dest)"
if (-not $Out) { $Out = Join-Path $runs "rapport_$Label" }
$todo  = @($Steps.Split(',') | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_ })
foreach ($s in $todo) { if ($s -notin 'run', 'export', 'images') { throw "unknown step $s; use run, export and images" } }
if ($Variant -and $Variant.Contains(',')) { throw '-Variant takes one merge variant here: the export reads the merged output of one merge' }
if ($Variant -and $Components) { throw 'give -Components or -Variant, not both' }
New-Item -ItemType Directory -Force $Out | Out-Null
$status = Join-Path $Out 'status.txt'
function Say($m) { $l = "{0} {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m; $l; Add-Content -Path $status -Value $l }

# The engine, as batch\WriteODResults.ps1 finds it; the GUI is GeoDmsGuiQt.exe next to it.
if (-not $Exe) { $Exe = $env:GEODMS_EXE }
if (-not $Exe) {
	$ver = (Select-String -Path (Join-Path $PSScriptRoot 'UpdateAll.cmd') -Pattern '^set GEODMS_VERSION=(\S+)').Matches[0].Groups[1].Value
	foreach ($f in 'm', 'c') {
		if ($Exe) { break }
		$loc = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\GeoDms$ver.$f" -Name InstallLocation -ErrorAction SilentlyContinue).InstallLocation
		if ($loc -and (Test-Path (Join-Path $loc 'GeoDmsRun.exe'))) { $Exe = Join-Path $loc 'GeoDmsRun.exe' }
		elseif (Test-Path "$env:ProgramW6432\ObjectVision\GeoDms$ver.$f\GeoDmsRun.exe") { $Exe = "$env:ProgramW6432\ObjectVision\GeoDms$ver.$f\GeoDmsRun.exe" }
	}
}
if (-not $Exe) { throw 'No GeoDmsRun.exe found: install GeoDMS, or give -Exe or set GEODMS_EXE.' }
if (-not $GuiExe) { $GuiExe = Join-Path (Split-Path -Parent $Exe) 'GeoDmsGuiQt.exe' }

# The settings of the call for GeoDmsRun and the GUI, as batch\UpdateAll.cmd gives them to its steps (ConfigSettings/Overridable): a setting
# that is not given gets ModelParameters, so that no value of an earlier call or of the registry counts. The source data folders only when
# given, for a shell whose registry view is not to be trusted.
$settings = [ordered]@{ 'AnalysisMoment' = $AnalysisMoment; 'PartOfDay' = $PartOfDay; 'Orgset' = $Orgset; 'Destset' = $Destset; 'OutputLabel' = $Label
                        'MergeCriteria' = $MergeCriteria; 'NS_TariffChoice' = $NS_TariffChoice; 'Variant' = $Variant }
foreach ($n in $settings.Keys) { Set-Item "Env:GEODMS_Overridable_$n" $(if ($settings[$n]) { $settings[$n] } else { 'ModelParameters' }) }
if ($NetworkModelDir) { $env:GEODMS_Overridable_NetworkModel_Dir = $NetworkModelDir }
if ($PrivDir)         { $env:GEODMS_Overridable_NetworkModel_PrivDir = $PrivDir }
$config = Join-Path $runs 'variant\NetworkModel_PBL\cfg\main.dms'
Say ("OD pair $Org -> $Dest, moment '$Moment', steps $($todo -join ','); " + (($settings.Keys | Where-Object { $settings[$_] } | ForEach-Object { "$_ $($settings[$_])" }) -join ', '))

if ('run' -in $todo) {
	$wr = @{ Org = $Org; Dest = $Dest; Moment = $Moment; AnalysisMoment = $AnalysisMoment; PartOfDay = $PartOfDay; Orgset = $Orgset; Destset = $Destset
	         Label = $Label; MergeCriteria = $MergeCriteria; NS_TariffChoice = $NS_TariffChoice; Components = $Components; Variant = $Variant
	         Exe = $Exe; Root = $Root; WaitForMemoryGB = $WaitForMemoryGB; Ref = $Ref }
	& (Join-Path $PSScriptRoot 'WriteODResults.ps1') @wr | ForEach-Object { Say "run: $_" }
}
if (-not (Test-Path $config)) { throw "no run copy $config; run the step run first" }

# The folder of the merged output: the %LocalDataProjDir% of the run copy, which has the config.ini of the working copy.
$ini = Join-Path $runs 'variant\NetworkModel_PBL\cfg\main\config.ini'
$proj = 'C:\LocalData\NetworkModel_PBL'
if (Test-Path $ini) { $m = Select-String -Path $ini -Pattern '^\s*localDataProjDir\s*=\s*(.+?)\s*$' | Select-Object -First 1; if ($m) { $proj = $m.Matches[0].Groups[1].Value } }
$outRoot = Join-Path $proj "Output_$($Org)_$($Dest)"

if ('export' -in $todo) {
	$t0 = Get-Date
	$log = Join-Path $Out 'export.log'
	& cmd /c "`"$Exe`" `"/L$log`" `"$config`" @statistics /Output/OD_PairRoutes/Export/Write > `"$Out\export.txt`" 2>&1"
	$rc = $LASTEXITCODE
	Say "export: GeoDmsRun exit $rc, $([int]((Get-Date) - $t0).TotalSeconds) s"
	if ($rc -ne 0) { Get-Content "$Out\export.txt" | Select-String '\[E\]|\[F\]' | Select-Object -First 5 | ForEach-Object { Say "export: $($_.Line)" }; throw "the export failed, see $Out\export.txt" }
	$gpkg = Get-ChildItem -Path $outRoot -Filter 'od_paar.gpkg' -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -ge $t0.AddSeconds(-2) } | Select-Object -First 1
	if (-not $gpkg) { throw "the export wrote no od_paar.gpkg under $outRoot" }
	Copy-Item $gpkg.FullName (Join-Path $Out 'od_paar.gpkg') -Force
	Copy-Item (Join-Path $gpkg.DirectoryName 'fronten.csv') (Join-Path $Out 'fronten.csv') -Force
	Say "export: $($gpkg.FullName), copied to $Out"
}

if ('images' -in $todo) {
	$fronts = Join-Path $Out 'fronten.csv'
	if (-not (Test-Path $fronts)) { throw "no $fronts; run the step export first" }
	$scripts = Join-Path $repo '.claude\skills\od-paar-beelden\scripts'
	# Each picture in a PowerShell process of its own: the scripts define a type W32 with other members, and a second Add-Type of the same
	# name in one session keeps the first. The child gets the settings through the environment.
	$common = @('-Config', $config, '-Exe', $GuiExe)
	if ($NetworkModelDir) { $common += @('-NetworkModelDir', $NetworkModelDir) }
	if ($PrivDir)         { $common += @('-PrivDir', $PrivDir) }
	function Capture($name, [string[]]$more) { & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $scripts $name) @common @more 2>&1 | ForEach-Object { Say "images: $_" } }
	$png = Join-Path $Out 'kaart_samen.png'
	Capture 'capture_view.ps1' @('-Kind', 'kaart', '-Item', '/Output/OD_PairRoutes/Combined/Links/Mode_rel', '-Png', $png)
	# Per departure moment one chart with the series that have points, in the order of Usage.
	$rows = @(Import-Csv -Path $fronts -Delimiter ';' | Where-Object { [int]$_.opties -gt 0 })
	foreach ($g in ($rows | Group-Object moment)) {
		$series = @($g.Group | ForEach-Object { "/Output/OD_PairRoutes/Combined/Chart/$($_.serie)/Points/Prijs" })
		Say "images: front $($g.Name), series $(($g.Group | ForEach-Object { "$($_.groep) ($($_.opties))" }) -join ', ')"
		$png = Join-Path $Out "fronten_$($g.Name).png"
		Capture 'capture_fronts.ps1' @('-Series', ($series -join ','), '-Png', $png)
	}
	foreach ($c in ($ComponentMaps.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
		$png = Join-Path $Out "kaart_$c.png"
		Capture 'capture_view.ps1' @('-Kind', 'kaart', '-Item', "/Output/OD_PairRoutes/PerComponent/$c/Links/Mode_rel", '-Png', $png)
	}
}
Say "done: $Out"
