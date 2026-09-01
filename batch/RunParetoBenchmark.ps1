<#
.SYNOPSIS
    Meetharnas voor ObjectVision/NetworkModel_PBL#115: baseline versus de pareto-optie van
    impedance_matrix in OD_R/OD_L.

.DESCRIPTION
    Draait dezelfde config een aantal keer, telkens met een andere "arm" (combinatie van
    /ModelParameters/Advanced/ParetoLegs_R, ParetoLegs_L, LegDistanceQuantum en
    UseQuantisedLegDistanceInScalarRun), en legt per run wandkloktijd, piekgeheugen en de
    kentallen uit /ParetoBenchmark/Report vast.

    De arm wordt gezet door cfg/main/ModelParameters/ParetoArm.dms IN ZIJN GEHEEL te herschrijven -- geen
    regel-patches in ModelParameters.dms, zodat `git diff cfg/main/ModelParameters/ParetoArm.dms` altijd
    precies laat zien welke arm in de werkboom staat. Aan het eind wordt het bestand
    teruggezet naar de gecommitte versie.

    Waarom deze armen:
      scalar          de huidige code: min-Duration per OD-paar, afstand als bijproduct.
      scalar_q100m    idem, maar met de gekwantiseerde afstand. Isoleert het PRIJS-effect van
                      de kwantisatie, zodat dat niet op het conto van de pareto-optie komt.
      pareto_R_raw    pareto op de ONgekwantiseerde float-afstand. Dit is de arm waarvan
                      GeoDMS doc/bicriteria-impedance.md sectie 5.5 voorspelt dat de fronten
                      ontsporen; hij staat erin om die voorspelling te meten, niet omdat hij
                      een serieuze kandidaat is. Kan lang duren -- vandaar -TimeoutMinutes.
      pareto_R_q100m  het voorstel.
      pareto_RL_q100m ook NS. Verwachting: meer rijen, geen extra prijsopties, want de
                      NS-prijs volgt uit (eerste,laatste) station en dus uit het OD-paar.

.EXAMPLE
    # alleen de goedkope been-trap, alle armen
    .\batch\RunParetoBenchmark.ps1 -Stage Legs

    # de volledige nationale ketenrun, alleen baseline en het voorstel
    .\batch\RunParetoBenchmark.ps1 -Stage Full -Arms scalar,pareto_R_q100m
#>
[CmdletBinding()]
param(
    [ValidateSet('Legs', 'Block', 'Full')]
    [string[]] $Stage = @('Legs'),

    [ValidateSet('scalar', 'scalar_q100m', 'pareto_R_raw', 'pareto_R_q100m', 'pareto_RL_q100m')]
    [string[]] $Arms = @('scalar', 'scalar_q100m', 'pareto_R_raw', 'pareto_R_q100m'),

    [string] $GeoDmsRun = 'C:\Program Files\ObjectVision\GeoDms20.19.0.m\GeoDmsRun.exe',

    [string] $OutDir = 'C:\LocalData\NetworkModel_PBL\Output\pareto_benchmark',

    # 0 = geen limiet. pareto_R_raw kan ontsporen; met een limiet blijft de rest van de meting doorgaan.
    [int] $TimeoutMinutes = 0
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot = Split-Path -Parent $PSScriptRoot
$CfgDir   = Join-Path $RepoRoot 'cfg'
$ArmFile  = Join-Path $CfgDir 'main\ModelParameters\ParetoArm.dms'
$MainDms  = Join-Path $CfgDir 'main.dms'

if (-not (Test-Path $GeoDmsRun)) { throw "GeoDmsRun niet gevonden: $GeoDmsRun" }
if (-not (Test-Path $MainDms))   { throw "main.dms niet gevonden: $MainDms" }
if (-not (Test-Path $OutDir))    { New-Item -ItemType Directory -Force -Path $OutDir | Out-Null }

# NB: het item-pad is relatief aan de desktop-root; de top-level container van main.dms
# (container NetworkModel) hoort NIET in het pad.
$StageItem = @{
    # de operator-aanroep zelf: dit is wat er verandert
    Legs  = '/ParetoBenchmark/Report'
    # een enkel haltenblok van de ketenrijger: wat kosten de grotere benen-sets stroomafwaarts?
    Block = '/NetworkSetup/PublicTransport_Prep/KetenGeneratie_PerBlock/Block_1of500/Fence/Result'
    # de volledige nationale ketenrun naar PT_Chains_*.fss
    Full  = '/MakeUnlinkedData/PublicTransportNet/Generate_PT'
}

# ParetoLegs_R, ParetoLegs_L, LegDistanceQuantum[km], UseQuantisedLegDistanceInScalarRun
$ArmDef = @{
    scalar          = @{ R = 'FALSE'; L = 'FALSE'; Q = '0.1'; QScalar = 'FALSE' }
    scalar_q100m    = @{ R = 'FALSE'; L = 'FALSE'; Q = '0.1'; QScalar = 'TRUE'  }
    pareto_R_raw    = @{ R = 'TRUE';  L = 'FALSE'; Q = '0.0'; QScalar = 'FALSE' }
    pareto_R_q100m  = @{ R = 'TRUE';  L = 'FALSE'; Q = '0.1'; QScalar = 'FALSE' }
    pareto_RL_q100m = @{ R = 'TRUE';  L = 'TRUE';  Q = '0.1'; QScalar = 'FALSE' }
}

function Write-ArmFile {
    param([string] $Arm)

    $d = $ArmDef[$Arm]
    $text = @"
// ARM: $Arm
//
// GEGENEREERD door batch/RunParetoBenchmark.ps1 voor ObjectVision/NetworkModel_PBL#115.
// Dit bestand wordt per meet-arm in zijn geheel herschreven; de gecommitte versie is de
// voorstel-arm. Wordt ge-#include-d in ModelParameters/Advanced, dus deze parameters heten
// /ModelParameters/Advanced/<naam>.

parameter<bool>     ParetoLegs_R                              := $($d.R)                   , Descr = "Gebruik de pareto-optie van impedance_matrix voor OD_R: per OD-paar alle Pareto-optimale (reistijd, afstand)-benen in plaats van alleen het snelste.";
parameter<bool>     ParetoLegs_L                              := $($d.L)                   , Descr = "Idem voor OD_L (NS).";
parameter<km>       LegDistanceQuantum                        := $($d.Q)[km]               , Descr = "Kwantisatie van het tweede pareto-criterium (Length). 0[km] = niet kwantiseren.";
parameter<bool>     UseQuantisedLegDistanceInScalarRun        := $($d.QScalar)             , Descr = "Gebruik LegDistanceQuantum ook in de gewone (niet-pareto) run, om het prijs-effect van de kwantisatie te scheiden van dat van de pareto-optie.";
"@
    Set-Content -Path $ArmFile -Value $text -Encoding UTF8
}

function Get-PeakMemoryMB {
    param([string] $LogPath)
    if (-not (Test-Path $LogPath)) { return $null }
    # De afsluitende geheugenregel draagt meerdere cijfers. "Highest CommitCharge" blijft in deze
    # runs op 0 staan; "PeakLiveLarge" is de post die daadwerkelijk meebeweegt met de omvang van
    # de resultaten (745 MB voor de scalaire been-run), dus dat is de zinnige maat hier.
    $line = Select-String -Path $LogPath -Pattern 'PeakLiveLarge:\s*(\d+)\[MB\]' | Select-Object -Last 1
    if ($null -eq $line) { return $null }
    return [int] $line.Matches[0].Groups[1].Value
}

$stamp   = Get-Date -Format 'yyyyMMdd_HHmmss'
$results = New-Object System.Collections.Generic.List[object]
$summaryCsv = Join-Path $OutDir "pareto_benchmark_$stamp.csv"

try {
    foreach ($st in $Stage) {
        $item = $StageItem[$st]
        foreach ($arm in $Arms) {
            Write-ArmFile -Arm $arm

            $log = Join-Path $OutDir "${stamp}_${st}_${arm}.log"
            Write-Host ""
            Write-Host "=== stage=$st arm=$arm ===" -ForegroundColor Cyan
            Write-Host "    item : $item"
            Write-Host "    log  : $log"

            # /SP laat GeoDmsRun de per-operator performance-regels loggen; die dragen de
            # verdeling over de operatoren waarmee een verschil in wandkloktijd toe te wijzen is.
            # niet $args noemen: dat is een automatische variabele in PowerShell
            $runArgs = @("/L$($log -replace '\\','/')", '/SP', ($MainDms -replace '\\','/'), $item)

            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            $p  = Start-Process -FilePath $GeoDmsRun -ArgumentList $runArgs -PassThru -NoNewWindow
            $timedOut = $false
            if ($TimeoutMinutes -gt 0) {
                if (-not $p.WaitForExit($TimeoutMinutes * 60 * 1000)) {
                    $timedOut = $true
                    Write-Warning "arm $arm overschreed $TimeoutMinutes minuten; afgebroken."
                    $p.Kill()
                    $p.WaitForExit()
                }
            } else {
                $p.WaitForExit()
            }
            $sw.Stop()

            $row = [pscustomobject]@{
                stamp       = $stamp
                stage       = $st
                arm         = $arm
                item        = $item
                exitcode    = $p.ExitCode
                timed_out   = $timedOut
                seconds     = [math]::Round($sw.Elapsed.TotalSeconds, 1)
                peak_mb     = Get-PeakMemoryMB -LogPath $log
                log         = $log
            }
            $results.Add($row) | Out-Null
            $results | Export-Csv -Path $summaryCsv -NoTypeInformation -Encoding UTF8

            Write-Host ("    -> exit={0} {1}s peak={2}MB" -f $row.exitcode, $row.seconds, $row.peak_mb) -ForegroundColor Green

            # de been-kentallen die de config zelf wegschrijft
            $legs = Get-ChildItem -Path 'C:\LocalData\NetworkModel_PBL\Output' -Filter 'pareto_benchmark_legs_*.txt' -ErrorAction SilentlyContinue |
                    Sort-Object LastWriteTime | Select-Object -Last 1
            if ($legs -and $legs.LastWriteTime -gt (Get-Date).AddMinutes(-1 * ([math]::Max(1, $sw.Elapsed.TotalMinutes + 1)))) {
                Get-Content $legs.FullName | ForEach-Object { Write-Host "    | $_" }
            }
        }
    }
}
finally {
    # zet de arm terug naar de gecommitte versie, zodat de werkboom niet blijft hangen op de
    # laatst gedraaide arm
    Push-Location $RepoRoot
    try { & git checkout -- 'cfg/main/ModelParameters/ParetoArm.dms' } catch { Write-Warning "kon ParetoArm.dms niet terugzetten: $_" }
    Pop-Location
}

Write-Host ""
Write-Host "samenvatting: $summaryCsv" -ForegroundColor Cyan
$results | Format-Table -AutoSize
