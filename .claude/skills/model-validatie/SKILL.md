---
name: model-validatie
description: Model-uitkomsten van NetworkModel_PBL valideren - OV-reistijden en -prijzen tegen 9292.nl (stap voor stap in de browser of via URL), consistentiechecks van het pareto-front (#53) en de interne steekproefrapporten. Gebruik als je wilt nagaan of reistijd, prijs, toeslag of vervoerwijze van het model klopt, bij validatie (#53) of na een wijziging aan netwerk of prijzen.
---

# Model-uitkomsten valideren

Drie lagen, van goedkoop naar duur.

1. **Interne steekproeven in de config.** `/RitOpslagReport/Report` (TE-steekproef tegen NS, treinroutes), `/RitOpslagReport/Net/Report` en `/Keten/Report` (benen en ketenprijs), `/FlexReport/Report`. Draaien met GeoDmsRun vanuit PowerShell; zie de skill `ov-prijzen` voor engine en scratchkopie.
2. **Consistentie van het front (#53)**, per HB-paar en vertrekmoment in de uitvoer (`Output/<datum>_<OutputLabel>/PerBlock/tt_*.csv`, sinds 2026-10-03 (#118); de parameters van een run staan in `signature.txt` in die map, dus geef twee runs elk een eigen `OutputLabel`), met `python batch\ValidateFronts.py --a "<glob run A>" --b "<glob run B>" [--blocks 1-10] [--md verslag.md]` (ongeveer 1 minuut per 20 blokken x 4 vertrekmomenten). Voor prijschecks moeten beide runs `Export_PriceInformation` = TRUE hebben. De checks:
   - kortste reistijd van de nieuwe opzet (`MinimiseCriteria` 'Price,Time,...') = kortste reistijd van een run zonder prijs, binnen `ChainParetoTimeEpsilon` (60 s);
   - prijs bij de kortste reistijd (nieuw) <= prijs bij de kortste reistijd (zonder prijs); bij gelijke tijd kiest de run zonder prijs een willekeurige prijs;
   - kortste reistijd <= reistijd bij de laagste prijs, en prijs bij de kortste reistijd >= laagste prijs (sanity: in een front altijd waar; een schending wijst op een fout in de condensatie);
   - sinds 2026-10-04, als A en B allebei `Car` of `Bike` noemen: de eerste twee ook per groep reizigers (zonder auto, zonder fiets, zonder beide). Een bool-criterium heeft geen epsilon, dus een groep die alleen in A een optie heeft, is een fout.

   **Referentie: 'Time,Car,Bike', niet 'Time'.** Met alleen 'Time' zijn ook autobezit en fietsbezit geen criterium (`Classifications/OwnershipParetoAttr` alleen bij 'Car'/'Bike' in `MinimiseCriteria`): de uitvoer is dan per paar de ene snelste optie, alsof iedereen auto en fiets heeft; voor blokken 1-10 op 2026-10-06 de auto bij 99,3% van de paren. 'Car' en 'Bike' veranderen de ketenstore niet, de prijs wel (`min-...` in de handtekening).

   Twee runs en de vergelijking in één keer: `powershell -ExecutionPolicy Bypass -File batch\RunFrontValidation.ps1 -Label <label> -BaseRun <runkopie>\NetworkModel_PBL` (B = de uitvoer van een bestaande run, bijv. de basisrun `C:\LocalData\NM_PBL_runs\20261006\NetworkModel_PBL`; A = een kopie van diens cfg, data en batch met alleen `MinimiseCriteria` `-CritA` (standaard 'Time,Car,Bike') en `OutputLabel` `<label>_A`; ongeveer 4,5 uur). Zonder `-BaseRun` rekent het A en B uit runkopieën van HEAD (ongeveer 8,5 uur). `-DryRun` maakt alleen de kopieën. Start het los van de sessie (`Start-Process powershell -WindowStyle Hidden ...`); voortgang in `C:\LocalData\NM_PBL_runs\<label>\status.txt`. Zie de wiki, How to run the model, Validating the Pareto front.

   Uitkomsten: 2026-10-03 'Time' tegen 'Price,Time' (feed 20260925, dag 20261006, blokken 1-10): alles in orde, zie `doc/Frontvalidatie_2026-10-03.md`; de 25 OV-ketens alleen in de tijd-run zijn epsilondominantie (in de prijs-run vervangen door een fiets- of autorit die hoogstens 60 s langzamer en minstens 10 ct goedkoper is), wat alleen kan omdat geen van beide runs 'Car,Bike' noemde. 'Time,Car,Bike' tegen de basisrun: label `val53_tcb`, gestart 2026-10-04.
3. **Extern tegen 9292.nl**, voor een steekproef van HB-paren en voor bijzondere gevallen (HSL, eilanden, veerboten, grensvervoer). Halte tot halte met `/Validatie/Schrijf` (schrijft `/Validatie/Rows`; `cfg/main/Validatie.dms`): voor de haltenparen in `Validatie/Paren` (GTFS-haltenamen) de ketens uit de ketenstore die tussen `VertrekVan` en `VertrekTot` vertrekken, met vertrek, aankomst, reistijd, prijs, `rit_opslag` (de toeslag die 9292 niet meetelt) en ModeUsed, in `Output/validatie_<feed>_<dag>.csv`. Het leest alleen de blokstores van de vertrekhaltes; zonder ketenstore `LeesStore` = FALSE (rekent die blokken, ~0,5 min en ~17 GB per blok). Vergelijk per paar en vertrektijd de vroegste aankomst en de prijs met 9292 (datum en vertrektijd gelijk, tijd in de URL in UTC).

## 9292.nl in de browser

1. Open `https://9292.nl/`. **Eerst het welkomstpaneel:** klik de blauwe knop **Akkoord** rechtsonder in het intro-paneel. De gebruiker wil dat, dus niet "Weigeren", ook al is dat elders de privacyvriendelijke keuze. De knoppen zitten in een shadow-DOM, dus `find` ziet ze niet: klik op coordinaten uit een screenshot. Het profiel van de ingebouwde browser onthoudt de keuze. Verschijnt het paneel niet, dan is er al akkoord gegeven.
2. **Van** en **Naar**: klik het combobox ("adres, station, halte"), typ een naam, wacht ~2 s en klik de juiste suggestie. Lees de suggesties met JavaScript: `document.querySelectorAll('[role=option]')`, tekst als "Merwekade | Veerhaven•Dordrecht"; de klikbare elementen vind je daarna met `find` op de naam. Kies het juiste type (Bushalte, Veerhaven, Treinstation), niet een adres of restaurant.
3. **Datum en tijd**: velden Datum/Tijd onder Vertrek/Aankomst. Sneller via de resultaat-URL: `.../reisplanner/<vanId>/<naarId>/Departure/<jjjj-mm-dd>T<uumm>`; die tijd is **UTC** (zomertijd: lokale tijd min 2 uur, wintertijd min 1). Voorbeeld: dinsdag 13-10-2026 07:15 lokaal = `2026-10-13T0515`.
4. **Plan je reis**, dan per reis in de lijst de prijs ("€ 18,70"; "€ --,--" = onbekend). Klik een reis open ("Geplande vertrektijd: hh:mm") voor de benen, de lijnen en "De prijs van je reis".
5. Lees de pagina met JavaScript: `document.body.innerText`, vanaf "Eerder" (de lijst) en vanaf "Geplande reis" tot "Prijsinformatie" (het detail).

Zonder formulier: `https://9292.nl/reisadvies/<van>/<naar>` met `station-<naam>` of `<plaats>_<type>-<naam>` (bijv. `west-terschelling_halte-veer-terschelling`, `nes-ameland_bushalte-veerhaven`); niet elke oude naam werkt nog.

Als het browservenster verborgen is, mislukken klikken en typen ("tab is not on screen"): vraag de gebruiker het venster te tonen (Ctrl+Shift+B), of lees alleen met `get_page_text` en JavaScript.

## Wat 9292 wel en niet zegt

- De prijs is **2e klas vol tarief, zonder korting**.
- **Toeslagen** (ICD Schiphol-Rotterdam, ICE) staan als melding bij het been ("Toeslag Schiphol - Rotterdam") en zitten **niet** in het totaal. Vergelijk dus 9292-totaal met `Price_L` en tel de toeslag apart.
- "Voor dit deel van de reis is betalen met de OV-chipkaart of OVpay niet mogelijk" plus "We kunnen de prijs van je reis op dit moment niet bepalen" = los kaartje van de vervoerder (veerboten); zonder de eerste zin (De Lijn) = 9292 kent de prijs niet.
- Kies een datum waarop de feed van het model geldt en zonder werkzaamheden (9292 meldde 3-6 oktober 2026: geen treinen van, naar en via Amsterdam Centraal).

## Bevestigd (2026-10-02 en later)

"Model" bij NS-ritten: het tariefnet van 2016 (`NS_tariefnet_year`, #121). Het net van 2013 heeft de gezamenlijke tariefpunten van voor 2016. Losse TE zonder 9292: rijdendetreinen.nl/tickets/tariefafstanden (zie de skill `ov-prijzen`).

| Rit (9292, 2e klas vol) | 9292 | Model |
|---|---|---|
| Schiphol - Rotterdam C | 16,40 + melding toeslag bij ICD | 67 TE, 16,40 + `Price_S` 3,20 op de ICD |
| Amsterdam Zuid - Rotterdam C | 18,70, toeslagmelding bij ICD | 78 TE, 18,70 |
| Hilversum - Rotterdam C | 17,80 alle opties; ICD1800 met toeslagmelding | 74 TE, 17,80 (+3,20 op ICD1800) |
| Hilversum - Rotterdam C, halte tot halte (`/Validatie`, dag 29-9 tegen 13-10): ICD1800 07:23 - 08:18, 07:53 - 08:48; 07:29 - 08:40; 07:48 - 08:55 | tijden gelijk, 17,80 | tijden gelijk; 21,00 = 17,80 + 3,20 op de ICD, anders 17,80 |
| Arnhem C - Zevenaar | 4,72 (ook VIAS) | DOVA-km; FareTable vast 2,79 (fout) |
| Enschede - Glanerbrug (DB) | 3,18 | DOVA 2,01 gem.; FareTable vast 2,79 |
| Nes Veerhaven - Hollum (Qbuzz 1, Ameland) | 3,00 (2 zones, OV-chip) | DOVA km-tarief (fout, zie #55) |
| Merwekade - Erasmusbrug (Waterbus 20), 07:00 - 07:58 | 58 min, 5,78 (OV-chip) | 58 min; DOVA 6,38 (0,243 x 21,5 km; per mijl zou 4,41 zijn); FareTable vast 2,25. Juiste bron: de afstandstabel van de Waterbus |
| Harlingen - Terschelling, Holwerd - Ameland, Vlissingen - Breskens | geen OV-chip, geen prijs | DOVA km-tarief (fout, zie #55) |
| Maastricht - Genk (De Lijn 45) | prijs onbekend | vast 3,00 (Detailed) |
| Utrecht C - Utrecht Maliebaan (pendel-Sprinter, 19 min), 2026-10-04 | 3,00 (minimum, hoogstens 8 TE) | tot #120 geen tarief; nu 8 TE |
| Hilversum Sportpark - Utrecht Maliebaan (overstap Overvecht), 2026-10-04 | 6,90 = 25 TE | 25 TE; met het tariefnet van 2013 26 (#121) |
| Hilversum Sportpark - Utrecht Overvecht, 2026-10-04 | 4,40 = 14 TE | 14 TE; net 2013 15 |
| Gouda - Utrecht Maliebaan (via Utrecht C), 2026-10-04 | 10,20 = 40 TE | 40 TE |
| Amsterdam Zuid - Hilversum, 2026-10-04 | 7,50 = 28 TE | 28 TE |
| Amsterdam Zuid - Hilversum Sportpark (trein; de opties van 7,50 lopen vanaf Hilversum), 2026-10-04 | 7,80 = 29 TE, ook via Utrecht | 29 TE; net 2013 28 |
| Amsterdam Zuid - Hilversum Media Park, 2026-10-04 | 7,30 = 27 TE | 27 TE; net 2013 28 |
| Hilversum Media Park - Utrecht Overvecht / Hilversum - Utrecht Overvecht, 2026-10-04 | 4,90 = 16 TE / 4,60 = 15 TE | 16 / 15 TE; net 2013 15 / 15 |
| Hilversum Sportpark - Utrecht C / Amersfoort C (trein), 2026-10-04 | 5,10 = 17 TE / 5,10 = 17 TE | 17 / 17 TE; net 2013 18 / 16 |
| Utrecht C - Amsterdam RAI / Den Haag HS / Eindhoven Strijp-S / Tilburg Universiteit / Rotterdam Blaak, 2026-10-04 | 8,90 / 14,90 / 18,90 / 17,10 / 14,00 = 34 / 61 / 79 / 71 / 57 TE | gelijk; net 2013 35 / 60 / 80 / 70 / 56 |
| Utrecht C - Amsterdam Zuid / Rotterdam C / Den Haag C / Eindhoven C / Tilburg, 2026-10-04 | 9,10 / 13,80 / 14,70 / 19,10 / 16,90 = 35 / 56 / 60 / 80 / 70 TE | gelijk, ook net 2013 |

Leg nieuwe controles vast in deze tabel en meld ze bij #53.
