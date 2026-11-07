# One picture of the GeoDMS GUI for an OD pair run (skill od-paar-beelden): the map of the links of a front (-Kind kaart, the Default View
# of a Mode_rel such as /Output/OD_PairRoutes/Combined/Links/Mode_rel), or the chart of one series of price against travel time (-Kind
# grafiek, a Scatter Chart of a .../Chart/<series>/Points/Prijs shown as Points + Line). A headless GeoDmsGuiQt run with a /T script opens
# the view, copies its viewport to the clipboard (TB_Copy) and closes the app; this script saves the clipboard as png.
# Run it unsandboxed: the GUI must draw and own the clipboard. It overwrites the clipboard of the user, and a GUI window shows for a minute.
#   capture_view.ps1 -Config <copy>\variant\NetworkModel_PBL\cfg\main.dms -Item /Output/OD_PairRoutes/Combined/Links/Mode_rel -Kind kaart -Png x.png
param(
	[Parameter(Mandatory = $true)][string]$Config,
	[Parameter(Mandatory = $true)][string]$Item,
	[ValidateSet('kaart', 'grafiek')][string]$Kind = 'kaart',
	[Parameter(Mandatory = $true)][string]$Png,
	[string]$Exe = 'C:\Program Files\ObjectVision\GeoDms20.28.0.m\GeoDmsGuiQt.exe',
	[string]$NetworkModelDir = '',
	[string]$PrivDir = '',
	[int]$Width = 2400,
	[int]$Height = 1350
)
$ErrorActionPreference = 'Continue'
Add-Type -AssemblyName System.Windows.Forms, System.Drawing, UIAutomationClient, UIAutomationTypes
Add-Type -Name W32 -Namespace '' -MemberDefinition '[DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr hWnd, int x, int y, int w, int h, bool repaint);'
# the source data folders, when the registry view of this shell is not to be trusted (they are read from the registry otherwise)
if ($NetworkModelDir) { $env:GEODMS_Overridable_NetworkModel_Dir = $NetworkModelDir }
if ($PrivDir)         { $env:GEODMS_Overridable_NetworkModel_PrivDir = $PrivDir }

$base   = [IO.Path]::ChangeExtension($Png, $null).TrimEnd('.')
$script = "$base.dmsscript"
$log    = "$base.log"
if ($Kind -eq 'kaart') {
	$lines = @("ActivateItem `"$Item`"", 'DefaultView', 'WAIT 20000', 'TileSubWindows', 'WAIT 8000')
} else {
	# SEND 12 1 1: a Scatter Chart of the current item; Points + Line connects the points in the order of the rows (by travel time)
	$lines = @("ActivateItem `"$Item`"", 'SEND 12 1 1', 'WAIT 15000', 'TileSubWindows', 'WAIT 3000', 'SEND 4 3 1 "Show chart as" "Points + Line"', 'WAIT 3000',
	           'SEND 3 2 273 0', 'WAIT 3000', 'SEND 3 2 273 4', 'WAIT 3000')   # TB_ZoomAllLayers, then TB_ZoomOut1 once
}
$lines += @('SEND 3 2 273 18', 'WAIT 3000', 'SEND 1 3 16 0 0')                   # TB_Copy, then WM_CLOSE to the main window
Set-Content -Path $script -Value $lines -Encoding ASCII
if (Test-Path $log) { [IO.File]::Delete($log) }
[System.Windows.Forms.Clipboard]::Clear()

$p = Start-Process -FilePath $Exe -ArgumentList @("/L$log", "/T$script", $Config) -PassThru
# the main window is the top-level window of the process whose title names the configuration; Process.MainWindowHandle can be the splash
$A = [System.Windows.Automation.AutomationElement]
$cond = New-Object System.Windows.Automation.PropertyCondition($A::ProcessIdProperty, $p.Id)
foreach ($i in 1..30) {
	Start-Sleep 1
	$w = $A::RootElement.FindAll([System.Windows.Automation.TreeScope]::Children, $cond) | Where-Object { $_.Current.Name -match 'main\.dms' } | Select-Object -First 1
	if ($w) { [W32]::MoveWindow([IntPtr]$w.Current.NativeWindowHandle, 20, 20, $Width, $Height, $true) | Out-Null; if ($i -ge 6) { break } }
}
if (-not $p.WaitForExit(300000)) { "timeout: stopping GeoDmsGuiQt pid $($p.Id)"; Stop-Process -Id $p.Id -Force }
Start-Sleep 1
$img = [System.Windows.Forms.Clipboard]::GetImage()
if ($img) { $img.Save($Png, [System.Drawing.Imaging.ImageFormat]::Png); "saved $Png ($($img.Width)x$($img.Height))" } else { "NO IMAGE on the clipboard; see $log" }
Select-String -Path $log -Pattern '\[E\]|TestScript' | Select-Object -First 5 | ForEach-Object { 'log: ' + $_.Line.Substring(0, [Math]::Min(200, $_.Line.Length)) }
