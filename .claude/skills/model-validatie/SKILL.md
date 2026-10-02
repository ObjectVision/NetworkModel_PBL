---
name: model-validatie
description: Model-uitkomsten van NetworkModel_PBL valideren - OV-reistijden en -prijzen tegen 9292.nl (stap voor stap in de browser of via URL), consistentiechecks van het pareto-front (#53) en de interne steekproefrapporten. Gebruik als je wilt nagaan of reistijd, prijs, toeslag of vervoerwijze van het model klopt, bij validatie (#53) of na een wijziging aan netwerk of prijzen.
---

# Model-uitkomsten valideren

Drie lagen, van goedkoop naar duur.

1. **Interne steekproeven in de config.** `/RitOpslagReport/Report` (TE-steekproef tegen NS, treinroutes), `/RitOpslagReport/Net/Report` en `/Keten/Report` (benen en ketenprijs), `/FlexReport/Report`. Draaien met GeoDmsRun vanuit PowerShell; zie de skill `ov-prijzen` voor engine en scratchkopie.
2. **Consistentie van het front (#53)**, per HB-paar en vertrekmoment in de uitvoer (`Output/PerBlock/tt_*.csv`), met `python batch\ValidateFronts.py --a "<glob run A>" --b "<glob run B>" [--blocks 1-10] [--md verslag.md]` (ongeveer 1 minuut per 20 blokken x 4 vertrekmomenten). Voor prijschecks moeten beide runs `Export_PriceInformation` = TRUE hebben. De checks:
   - kortste reistijd van de nieuwe opzet (`MinimiseCriteria` 'Price,Time,...') = kortste reistijd van een run op alleen 'Time', binnen `ChainParetoTimeEpsilon` (60 s);
   - prijs bij de kortste reistijd (nieuw) <= prijs bij de kortste reistijd (alleen tijd); bij gelijke tijd kiest de tijd-run een willekeurige prijs;
   - kortste reistijd <= reistijd bij de laagste prijs, en prijs bij de kortste reistijd >= laagste prijs (sanity: in een front altijd waar; een schending wijst op een fout in de condensatie).
3. **Extern tegen 9292.nl**, voor een steekproef van HB-paren en voor bijzondere gevallen (HSL, eilanden, veerboten, grensvervoer). Halte tot halte met `/Validatie/Schrijf` (schrijft `/Validatie/Rows`; `cfg/main/Validatie.dms`): voor de haltenparen in `Validatie/Paren` (GTFS-haltenamen) de ketens uit de ketenstore die tussen `VertrekVan` en `VertrekTot` vertrekken, met vertrek, aankomst, reistijd, prijs, `rit_opslag` (de toeslag die 9292 niet meetelt) en ModeUsed, in `Output/validatie_<feed>_<dag>.csv`. Het leest alleen de blokstores van de vertrekhaltes; zonder ketenstore `LeesStore` = FALSE (rekent die blokken, ~0,5 min en ~17 GB per blok). Vergelijk per paar en vertrektijd de vroegste aankomst en de prijs met 9292 (datum en vertrektijd gelijk, tijd in de URL in UTC).

## 9292.nl in de browser

1. Open `https://9292.nl/`. Bij het eerste bezoek: klik de blauwe knop **Akkoord** rechtsonder in het intro-paneel (op verzoek van de gebruiker; anders "Weigeren"). De knoppen zitten in een shadow-DOM, dus `find` ziet ze niet: klik op coordinaten uit een screenshot.
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

## Bevestigd (2026-10-02)

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

Leg nieuwe controles vast in deze tabel en meld ze bij #53.
