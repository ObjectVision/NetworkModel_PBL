# Several fronts of an OD pair run in one chart of the GeoDMS GUI (skill od-paar-beelden), as on the wiki page Routes of an OD pair (The
# chart): a Scatter Chart of the first series, the other series added to it, each shown as Points + Line, zoomed to all series and one
# step out, and the viewport saved as png. Typically the merged fronts of one departure moment:
#   /Output/OD_PairRoutes/Combined/Chart/At_07h00m00s_ZonderAutoFiets/Points/Prijs, ..._MetFiets/..., ..._MetAuto/...
#
# Adding a series to an open chart is a double-click on its TreeItem (MainWindow::defaultViewOrAddItemToCurrentView); the GUI script
# language has no verb for it, and UI Automation shows no TreeItems once a view is open. So the /T script first expands the tree to every
# series, top to bottom, and selects the first again; this runner then notes where the TreeItem Prijs of every other series is, the script
# opens the chart, and at fixed moments within the waits of the script this runner posts the mouse messages of a double-click to the main
# window at those places. Posted messages do not move the cursor of the user and need no focus. The GUI log (/L) is only written when the
# GUI closes, so the runner keeps time from the moment the chart window appears.
# Run it unsandboxed: the GUI must draw, take window messages and own the clipboard. It overwrites the clipboard of the user.
param(
	[Parameter(Mandatory = $true)][string]$Config,
	[Parameter(Mandatory = $true)][string[]]$Series,
	[Parameter(Mandatory = $true)][string]$Png,
	[string]$Exe = 'C:\Program Files\ObjectVision\GeoDms20.28.0.m\GeoDmsGuiQt.exe',
	[string]$NetworkModelDir = '',
	[string]$PrivDir = '',
	[int]$Width = 2000,
	[int]$Height = 1450
)
$ErrorActionPreference = 'Continue'
Add-Type -AssemblyName System.Windows.Forms, System.Drawing, UIAutomationClient, UIAutomationTypes
Add-Type -Name W32 -Namespace '' -MemberDefinition @'
[DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr hWnd, int x, int y, int w, int h, bool repaint);
[DllImport("user32.dll")] public static extern bool PostMessage(IntPtr hWnd, uint msg, IntPtr wParam, IntPtr lParam);
[DllImport("user32.dll")] public static extern bool ScreenToClient(IntPtr hWnd, ref POINT p);
[StructLayout(LayoutKind.Sequential)] public struct POINT { public int X; public int Y; }
'@
if ($NetworkModelDir) { $env:GEODMS_Overridable_NetworkModel_Dir = $NetworkModelDir }
if ($PrivDir)         { $env:GEODMS_Overridable_NetworkModel_PrivDir = $PrivDir }
$Series = ($Series -join ',').Split(',')
$n = $Series.Count
$folder = $Series | ForEach-Object { ($_ -split '/')[-3] }   # the TreeItem of the series, above Points/Prijs
$base   = [IO.Path]::ChangeExtension($Png, $null).TrimEnd('.')
$script = "$base.dmsscript"
$log    = "$base.log"

# The timing of the script: the chart opens (t0), 21 s later the first 15 s wait for a next series starts; each next series has 18 s.
$lines = @()
for ($k = 0; $k -lt $n; $k++) { $lines += "ActivateItem `"$($Series[$k])`""; $lines += 'WAIT 2000' }
$lines += "ActivateItem `"$($Series[0])`""
$lines += @('WAIT 10000', 'SEND 12 1 1', 'WAIT 15000', 'TileSubWindows', 'WAIT 3000', 'SEND 4 3 1 "Show chart as" "Points + Line"', 'WAIT 3000')
for ($k = 1; $k -lt $n; $k++) { $lines += @('WAIT 15000', 'SEND 4 3 1 "Show chart as" "Points + Line"', 'WAIT 3000') }
$lines += @('SEND 3 2 273 0', 'WAIT 3000', 'SEND 3 2 273 4', 'WAIT 3000', 'SEND 3 2 273 18', 'WAIT 3000', 'SEND 1 3 16 0 0')   # zoom to all, one step out, copy, close
Set-Content -Path $script -Value $lines -Encoding ASCII
if (Test-Path $log) { [IO.File]::Delete($log) }
[System.Windows.Forms.Clipboard]::Clear()

$A = [System.Windows.Automation.AutomationElement]
$p = Start-Process -FilePath $Exe -ArgumentList @("/L$log", "/T$script", $Config) -PassThru
function MainWin {
	$c = New-Object System.Windows.Automation.PropertyCondition($A::ProcessIdProperty, $p.Id)
	foreach ($w in $A::RootElement.FindAll([System.Windows.Automation.TreeScope]::Children, $c)) { if ($w.Current.Name -match 'main\.dms') { return $w } }
	return $null
}
function TreeItems {
	$w = MainWin; if (-not $w) { return @() }
	$tc = New-Object System.Windows.Automation.PropertyCondition($A::ControlTypeProperty, [System.Windows.Automation.ControlType]::TreeItem)
	return @($w.FindAll([System.Windows.Automation.TreeScope]::Descendants, $tc))
}
function ChartIsOpen {
	$w = MainWin; if (-not $w) { return $false }
	foreach ($e in $w.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)) {
		if ($e.Current.Name -match 'Scatterplot|Point & Line Chart') { return $true }
	}
	return $false
}

# 1. give the main window its size, without activating it
$deadline = (Get-Date).AddMinutes(8)
while (-not (MainWin) -and (Get-Date) -lt $deadline) { Start-Sleep 1 }
foreach ($i in 1..4) { $w = MainWin; if ($w) { [W32]::MoveWindow([IntPtr]$w.Current.NativeWindowHandle, 20, 20, $Width, $Height, $true) | Out-Null }; Start-Sleep 1 }

# 2. when every series is expanded and the first is selected again, note the screen point of the TreeItem Prijs of each other series
$points = @{}
while ((Get-Date) -lt $deadline -and -not $p.HasExited) {
	Start-Sleep -Milliseconds 700
	$items = TreeItems
	if ($items.Count -eq 0) { continue }
	$tops = @{}
	foreach ($f in $folder) { $e = $items | Where-Object { $_.Current.Name -eq $f } | Select-Object -First 1; if ($e) { $tops[$f] = $e.Current.BoundingRectangle.Top } }
	if ($tops.Count -lt $n) { continue }
	$prijs = $items | Where-Object { $_.Current.Name -eq 'Prijs' }
	$rowOf = @{}
	foreach ($f in $folder) { $rowOf[$f] = $prijs | Where-Object { $_.Current.BoundingRectangle.Top -gt $tops[$f] } | Sort-Object { $_.Current.BoundingRectangle.Top } | Select-Object -First 1 }
	$first = $rowOf[$folder[0]]
	if (-not $first) { continue }
	$isSel = $false; try { $isSel = $first.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern).Current.IsSelected } catch {}
	if (-not $isSel) { continue }
	foreach ($f in $folder | Select-Object -Skip 1) {
		if (-not $rowOf[$f]) { continue }
		$r = $rowOf[$f].Current.BoundingRectangle
		$points[$f] = @([int]($r.Left + [Math]::Min(30, $r.Width / 2)), [int]($r.Top + $r.Height / 2), $rowOf[$f].Current.IsOffscreen)
	}
	break
}
foreach ($f in $folder | Select-Object -Skip 1) {
	if ($points[$f]) { "{0}: Prijs at screen {1},{2} offscreen={3}" -f $f, $points[$f][0], $points[$f][1], $points[$f][2] } else { "{0}: Prijs not found (below the tree? a taller -Height helps)" -f $f }
}

# 3. the chart opens; post a double-click on each next series, 6 s into the 15 s wait of the script that belongs to it
while (-not $p.HasExited -and -not (ChartIsOpen) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 500 }
$t0 = Get-Date
for ($k = 1; $k -lt $n; $k++) {
	$at = $t0.AddSeconds(21 + ($k - 1) * 18 + 6)
	while ((Get-Date) -lt $at -and -not $p.HasExited) { Start-Sleep -Milliseconds 200 }
	if ($p.HasExited -or -not $points[$folder[$k]]) { "no double-click for $($folder[$k])"; continue }
	$hwnd = [IntPtr](MainWin).Current.NativeWindowHandle
	$pt = New-Object W32+POINT
	$pt.X = $points[$folder[$k]][0]; $pt.Y = $points[$folder[$k]][1]
	[W32]::ScreenToClient($hwnd, [ref]$pt) | Out-Null
	$l = [IntPtr](($pt.Y -shl 16) -bor ($pt.X -band 0xFFFF))
	foreach ($m in @(@(0x0200, 0), @(0x0201, 1), @(0x0202, 0), @(0x0203, 1), @(0x0202, 0))) {   # MOUSEMOVE, LBUTTONDOWN, LBUTTONUP, LBUTTONDBLCLK, LBUTTONUP
		[W32]::PostMessage($hwnd, [uint32]$m[0], [IntPtr]$m[1], $l) | Out-Null
		Start-Sleep -Milliseconds 40
	}
	"double-click posted for $($folder[$k])"
}

if (-not $p.WaitForExit(300000)) { "timeout: stopping GeoDmsGuiQt pid $($p.Id)"; Stop-Process -Id $p.Id -Force }
Start-Sleep 1
$img = [System.Windows.Forms.Clipboard]::GetImage()
if ($img) { $img.Save($Png, [System.Drawing.Imaging.ImageFormat]::Png); "saved $Png ($($img.Width)x$($img.Height))" } else { "NO IMAGE on the clipboard; see $log" }
Select-String -Path $log -Pattern '\[E\]|TestScript|Execute|Add column' | Select-Object -First 8 | ForEach-Object { 'log: ' + $_.Line.Substring(0, [Math]::Min(200, $_.Line.Length)) }
