---
name: od-paar-beelden
description: Beelden van één HB-paar uit de GeoDMS GUI voor een issue of de wiki - de routes van de opties op een kaart en de pareto-fronten (prijs tegen reistijd) als Points + Line, ook de fronten zonder auto of fiets, met fiets en met auto samen in één grafiek, en een vergelijking voor en na een wijziging tussen twee commits. Gebruik bij controleruns op een HB-paar (#129), als je het effect van een wijziging aan prijzen of ketens wilt laten zien, of voor beelden op de wiki-pagina Routes of an OD pair.
---

# Beelden van een HB-paar

Een controlerun op één HB-paar laat een wijziging zien op een schaal die je kunt nalopen: elke optie met haar onderdelen, haar route op de kaart en haar plaats op het front. De GUI leest de uitvoer terug in `/Output/OD_PairRoutes` (tabellen, kaart en grafiek; zie de wiki-pagina Routes of an OD pair). Deze skill maakt daar beelden van zonder dat iemand in de GUI hoeft te klikken. De scripts staan in `scripts/` naast dit bestand.

## 1. Het paar rekenen

`batch\WriteODResults.ps1` maakt een runkopie van een commit en rekent het paar met `UpdateAll.cmd all`: benen, ketens, de autocache van het vertrekmoment, de uitvoer per component en de samenvoeging.

```
powershell -ExecutionPolicy Bypass -File batch\WriteODResults.ps1 -Org BU05460200 -Dest BU06290101 -Moment 07:00 -AnalysisMoment Y2025 `
  -Components 'WW,CC,Car,W_PT_W,W_PT_ovfC,C_PT_W,C_PT_ovfC' -Root C:\LocalData\NM_PBL_runs\voorna\na
```

- Drie fronten (zonder auto of fiets, met fiets, met auto) vragen componenten uit alle drie groepen, zoals hierboven. Met alleen `W_PT_W` is er één front.
- Eén vertrekmoment (`-Moment hh:mm`) houdt het kort. Gemeten op 7-11-2026 met GeoDMS 20.28.0 voor Y2025 en de zeven componenten hierboven: ongeveer 6 minuten voor een nieuw paar. Een tweede run van hetzelfde paar duurt 2 tot 3 minuten, omdat de benen en de autocache dan al bestaan. De ketenstap rekent alle OV-benen van het land (20 tot 30 GB); geef bij andere runs `-WaitForMemoryGB` mee.
- Voor en na een wijziging: twee runs, één met `-Ref <commit van ervoor>` en één met de nieuwe commit, elk met een eigen `-Root`. De uitvoermappen `Output_<O>_<D>\<datum>_od_<component>_<hash>` verschillen door de hash van de signatuur, en `OD_PairRoutes` in elke runkopie leest zijn eigen uitvoer.
- Het pad van de GUI-configuratie is `<Root>\od_<O>_<D>\variant\NetworkModel_PBL\cfg\main.dms`.

Kies een paar dat opties heeft. `od_tellingen.csv` in de uitvoermap telt ze per vertrekmoment. Een paar zonder opties komt meestal door de maximale OV-reistijd (`MaxPTTime`, 90 minuten), door de extra wachttijd van een flexlijn (30 minuten per instap) of door een veerdienst met weinig afvaarten in het venster. De Westerschelde Ferry en Wagenborg Lauwersoog - Schiermonnikoog ontbreken in 2025 helemaal: hun steigers liggen buiten elk concessievlak, zodat `OD_R/Result` hun benen als buitenland weglaat (`IsOD_completely_foreign`).

Buurtcodes zoek je op in `%NetworkModel_Dir%\RegioIndelingen\cbsgebiedsindelingen<jaar>.gpkg`, tabel `buurt_labelpoint` (`statcode`, `statnaam`). Open die alleen-lezen, met sqlite3 en `?mode=ro&immutable=1`, zodat er niets op de share wordt geschreven.

## 2. De beelden maken

Draai de scripts zonder sandbox: de GUI moet kunnen tekenen, vensterberichten krijgen en het klembord gebruiken. Zeg het de gebruiker vooraf. Er staat steeds een minuut of twee een GeoDMS-venster op het scherm, het klembord wordt overschreven, en typen in dat venster verstoort het script.

| Beeld | Script en item |
|---|---|
| Kaart van de routes van het samengevoegde front | `capture_view.ps1 -Kind kaart -Item /Output/OD_PairRoutes/Combined/Links/Mode_rel` |
| Kaart van één component | `capture_view.ps1 -Kind kaart -Item /Output/OD_PairRoutes/PerComponent/<component>/Links/Mode_rel` |
| Front van één component en één vertrekmoment | `capture_view.ps1 -Kind grafiek -Item /Output/OD_PairRoutes/PerComponent/<component>/Chart/<moment>/Points/Prijs` |
| Fronten van de groepen samen | `capture_fronts.ps1 -Series <Combined/Chart/<moment>_ZonderAutoFiets/Points/Prijs>,<..._MetFiets/...>,<..._MetAuto/...>` |

Een vertrekmoment heet `At_07h00m00s`; de groepen zijn `ZonderAutoFiets`, `MetFiets`, `MetAuto` en `MetAutoFiets`. Elk script krijgt `-Config` (de `main.dms` van de runkopie) en `-Png`. Op deze machine ook `-NetworkModelDir` en `-PrivDir`, omdat de registerweergave van een shell oud kan zijn. Bij een schermschaal van 150% levert een venster van 2000 bij 1450 een beeld van ongeveer 1350 bij 1040 pixels.

De opties zelf staan in de gpkg's van de uitvoer (`od_opties`, `od_onderdelen`). `od_compare.py <map voor> <map na>` zet ze per vertrekmoment naast elkaar, met de OV-benen en hun prijs; dat is de tabel bij de beelden.

## 3. Hoe de scripts werken

De GUI draait met `GeoDmsGuiQt.exe /L<log> /T<script> <config>`. De opdrachten staan in de GeoDMS-repo (`qtgui/exe/src/TestScript.cpp`, wiki-pagina Gui-scripting, skill geodms-debug):

| Opdracht | Wat hij doet |
|---|---|
| `ActivateItem "<pad>"` | maakt het item actief in de boom (klapt uit en selecteert) |
| `DefaultView` | opent de standaardweergave van het actieve item, een kaart voor een `Mode_rel` met geometrie |
| `SEND 12 1 1` | opent een Scatter Chart van het actieve item (1 is Scatter, 2 Line) |
| `SEND 4 3 1 "Show chart as" "Points + Line"` | menukeuze op de actieve reeks: verbindt de punten in de volgorde van de rijen, dus van snel en duur naar langzaam en goedkoop |
| `SEND 3 2 273 0`, `... 4`, `... 18` | TB_ZoomAllLayers, TB_ZoomOut1 en TB_Copy: alle reeksen passend, één stap uit zodat de randpunten heel blijven, en het beeld naar het klembord |
| `TileSubWindows` | vult het hoofdvenster met het weergavevenster |
| `SEND 1 3 16 0 0` | sluit de GUI |

Een reeks aan een open grafiek toevoegen gaat in de GUI met slepen of met een dubbelklik op het TreeItem (`defaultViewOrAddItemToCurrentView`). Het script kent daar geen opdracht voor. `capture_fronts.ps1` lost het zo op:

1. Het script klapt de reeksen van boven naar beneden uit en selecteert daarna de eerste opnieuw; zo schuiven de rijen van de andere niet meer en staan ze alle drie in beeld.
2. Zolang er nog geen weergave open is, leest de runner met UI Automation waar het TreeItem `Prijs` van elke volgende reeks staat. Zodra een weergave openstaat, laat UI Automation geen TreeItems meer zien.
3. Het script opent de grafiek. Op vaste momenten in zijn wachttijden post de runner de muisberichten van een dubbelklik naar het hoofdvenster, op die plekken. Geposte berichten bewegen de cursor van de gebruiker niet en het venster hoeft geen focus te hebben.

Valkuilen die bij het maken van deze scripts naar boven kwamen:

- Het log (`/L`) wordt pas weggeschreven als de GUI sluit, dus een runner kan er niet op synchroniseren. Hij rekent vanaf het moment dat het grafiekvenster verschijnt.
- `Process.MainWindowHandle` kan het opstartscherm zijn. Zoek het hoofdvenster op met UI Automation: het topvenster van het proces met `main.dms` in de titel.
- Bij een ander aantal reeksen of een trage machine kunnen de wachttijden te kort zijn. Het script zet dan een reeks niet op Points + Line, of de dubbelklik valt buiten de wachttijd. Kijk in het log of er per reeks een regel `Execute Points + Line` staat, en of het beeld alle reeksen in de legenda heeft.

## 4. In een issue of op de wiki

Een afbeelding in een issue komt uit de wiki-repo: zet de png in `images/` van de lokale wiki-kloon (`E:\prj\pbl\NetwerkModel_PBL.wiki`), commit daar met het issuenummer, en verwijs in het issue naar `https://raw.githubusercontent.com/wiki/ObjectVision/NetworkModel_PBL/images/<naam>.png`. Pushen doet de gebruiker. De tekst van de comment gaat eerst als concept naar de gebruiker; zie de skill git-github-werkwijze.
