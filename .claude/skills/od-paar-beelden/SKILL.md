---
name: od-paar-beelden
description: Beelden van één HB-paar uit de GeoDMS GUI voor een issue of de wiki - de routes van de opties op een kaart en de pareto-fronten (prijs tegen reistijd) als Points + Line, ook de fronten zonder auto of fiets, met fiets en met auto samen in één grafiek, en een vergelijking voor en na een wijziging tussen twee commits. Gebruik bij controleruns op een HB-paar (#129), als je het effect van een wijziging aan prijzen of ketens wilt laten zien, of voor beelden op de wiki-pagina Routes of an OD pair.
---

# Beelden van een HB-paar

Een controlerun op één HB-paar laat een wijziging zien op een schaal die je kunt nalopen: elke optie met haar onderdelen, haar route op de kaart en haar plaats op het front. De GUI leest de uitvoer terug in `/Output/OD_PairRoutes` (tabellen, kaart en grafiek; zie de wiki-pagina Routes of an OD pair). Deze skill maakt daar beelden van zonder dat iemand in de GUI hoeft te klikken. De scripts staan in `scripts/` naast dit bestand.

Het hele traject in één aanroep is `batch\ODPairReport.ps1` (#166): de run, één gpkg van het hele paar en de beelden, met alle instellingen als argument en `MergeCriteria` standaard op `Price,Time,Car,Bike`. Zie de wiki-pagina Routes of an OD pair, The whole pair in one call. De stappen hieronder zijn wat dat script doet, voor wie een beeld los wil maken of het script wil aanpassen.

- Een `-Ref` met onbewerkte wijzigingen toets je met `git add` van de nieuwe bestanden en `git stash create`: dat geeft een commit van de werkkopie zonder branch, die `git archive` kan lezen. Zonder dat maakt het script een runkopie van HEAD, die de nieuwe code niet heeft.
- Zonder `-set MergeCriteria` voegt UpdateAll samen op `Price,Time`; dan kan een optie met auto of eigen fiets een optie zonder van het front drukken, en heeft de grafiek per groep minder punten.

## 1. Het paar rekenen

`batch\WriteODResults.ps1` maakt een runkopie van een commit (`-Ref`, standaard `HEAD`) en rekent het paar met `UpdateAll.cmd all`: de ketens, het voor- en natransport (de stap `legs`), de autocache van het vertrekmoment, de uitvoer per component en de samenvoeging.

```
powershell -ExecutionPolicy Bypass -File batch\WriteODResults.ps1 -Org BU05460200 -Dest BU06290101 -Moment 07:00 -AnalysisMoment Y2025 `
  -Components 'WW,CC,Car,W_PT_W,W_PT_ovfC,C_PT_W,C_PT_ovfC' -Root C:\LocalData\NM_PBL_runs\voorna\na
```

- Drie fronten (zonder auto of fiets, met fiets, met auto) vragen componenten uit alle drie groepen, zoals hierboven. Met alleen `W_PT_W` is er één front. De OV-fiets telt niet als eigen fiets, dus `W_PT_ovfC` hoort bij het front zonder auto of fiets.
- `-Components` zet schakelaars, geen losse componenten: elk voortransporttype uit de lijst gaat samen met elk natransporttype uit de lijst. `W_PT_W,C_PT_ovfC` geeft dus ook `W_PT_ovfC` en `C_PT_W`.
- Eén vertrekmoment (`-Moment hh:mm`) houdt het kort. Gemeten op 7-11-2026 met GeoDMS 20.28.0 voor Y2025 en de zeven componenten hierboven (zonder `-Components` zijn het er sinds #152 vijftien): ongeveer 6 minuten voor een nieuw paar. Een tweede run van hetzelfde paar duurt 2 tot 3 minuten, omdat de caches van het voor- en natransport en de autocache dan al bestaan. De ketenstap rekent alle OV-ritten van het land. Hij schrijft eerst het voor- en natransport van het paar en rekent dan de ketens per stopblok, elk blok in een eigen GeoDmsRun (#178). Gemeten op 12-11-2026 en 13-11-2026 voor Y2026 vroeg het schrijven van het voor- en natransport 13,0 tot 16,4 GB in drie paren (bij Hilversum naar de VU niet gemeten), en het zwaarste stopblok in vier paren van 1,7 GB (Hilversum naar de VU) tot 68,8 GB (de VU naar PBL), met 85 tot 91 haltes per blok. Het aantal haltes verklaart dat verschil dus niet; de metingen per paar staan in Step 5 van de wiki-pagina Routes of an OD pair. Geef bij andere runs `-WaitForMemoryGB` mee, voor Hilversum naar de VU bijvoorbeeld 20. Het script wacht dan één keer, voordat UpdateAll begint, tot er zoveel geheugen vrij is.
- Voor en na een wijziging: twee runs, één met `-Ref <commit van ervoor>` en één met de nieuwe commit, elk met een eigen `-Root`, zodat de tweede run de runkopie van de eerste laat staan. Beide runkopieën krijgen de `config.ini` van de werkkopie en schrijven dus in dezelfde `%LocalDataProjDir%`, de uitvoer in `Output_<O>_<D>\<datum>_od_<component>_<hash>`; voor `WW` en `CC` staat daar de herkomstset met de herkomst van het paar (`b2025-bu05460200`) op de plaats van `od`. De tweede run krijgt alleen een eigen uitvoermap als de wijziging de signatuur van de uitvoer verandert, bijvoorbeeld met een hogere `PT_Chains_Revision`, die bij elke wijziging aan de ketens of hun prijzen omhoog moet. Anders vindt de tweede run de uitvoer van de eerste compleet en slaat hij hem over.
- De GUI-configuratie is `<Root>\od_<O>_<D>\variant\NetworkModel_PBL\cfg\main.dms`. De `ModelParameters.dms` van die runkopie heeft het paar (groep 6) en de schakelaars van de variant (groep 2), maar niet groep 1: die geeft het script per aanroep met `-set` aan UpdateAll. Zonder dezelfde `AnalysisMoment`, `PartOfDay`, `Orgset`, `Destset` en `OutputLabel` als de aanroep (standaard `Y2026`, `Morning`, `Buurt2025`, `Buurt2025` en `od`) zoekt `OD_PairRoutes` een andere uitvoermap. Zet ze daarom in die `ModelParameters.dms` (de waarde aan het eind van de regel), of zet ze vóór het script als `$env:GEODMS_Overridable_<naam>`: de scripts starten de GUI met `Start-Process`, dat de omgeving doorgeeft. Na `-Variant` hoort daar ook `GEODMS_Overridable_Variant` bij, met de naam van de samenvoegvariant.

Kies een paar dat opties heeft. `od_tellingen.csv` in de uitvoermap telt ze per vertrekmoment. Een paar zonder opties komt meestal door de maximale OV-reistijd (`MaxPTTime`, 90 minuten), door de extra wachttijd van een flexlijn (30 minuten per instap) of door een veerdienst met weinig afvaarten in het venster.

Buurtcodes zoek je op in `%NetworkModel_Dir%\RegioIndelingen\cbsgebiedsindelingen<jaar>.gpkg`, tabel `buurt_labelpoint` (`statcode`, `statnaam`). Open die alleen-lezen, met sqlite3 en `?mode=ro&immutable=1`, zodat er niets op de share wordt geschreven.

## 2. De beelden maken

Draai de scripts zonder sandbox: de GUI moet kunnen tekenen, vensterberichten krijgen en het klembord gebruiken. Zeg het de gebruiker vooraf. Er staat steeds een minuut of twee een GeoDMS-venster op het scherm, het klembord wordt overschreven, en typen in dat venster verstoort het script.

| Beeld | Script en item |
|---|---|
| Kaart van de routes van het samengevoegde front | `capture_view.ps1 -Kind kaart -Item /Output/OD_PairRoutes/Combined/Links/Mode_rel` |
| Kaart van één component | `capture_view.ps1 -Kind kaart -Item /Output/OD_PairRoutes/PerComponent/<component>/Links/Mode_rel` |
| Front van één component en één vertrekmoment | `capture_view.ps1 -Kind grafiek -Item /Output/OD_PairRoutes/PerComponent/<component>/Chart/<moment>/Points/Prijs` |
| Fronten van de groepen samen | `capture_fronts.ps1 -Series <Combined/Chart/<moment>_ZonderAutoFiets/Points/Prijs>,<..._MetFiets/...>,<..._MetAuto/...>` |

Een vertrekmoment heet `At_07h00m00s`; de groepen zijn `ZonderAutoFiets`, `MetFiets`, `MetAuto` en `MetAutoFiets`. Elk script krijgt `-Config` (de `main.dms` van de runkopie) en `-Png`. Op deze machine ook `-NetworkModelDir` en `-PrivDir`, omdat de registerweergave van een shell oud kan zijn. Alleen die twee mappen zetten de scripts zelf als omgevingsvariabele; groep 1 van de aanroep geef je mee zoals in stap 1 staat. Bij een schermschaal van 150% levert een venster van 2000 bij 1450 een beeld van ongeveer 1350 bij 1040 pixels.

De opties zelf staan in de gpkg's van de uitvoer (`od_opties`, `od_onderdelen`). `od_compare.py <map voor> <map na>` zet ze per vertrekmoment naast elkaar, met de OV-ritten en hun prijs; dat is de tabel bij de beelden.

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
