# FareTable 2023-2026: uitlijning op GTFS-feed-agencies (#112)

**Doel.** De FareTable-match loopt via `Mode_Agency_CG_Lijn` waarbij het agency-deel = `AsItemName(lowercase(agency_name))` uit de geladen GTFS-feed. Agency-namen wijzigen per feed (fusies, splitsingen, hernoemingen), dus elke `FareTable_<jaar>` moet de agency-set van de bijbehorende feed volgen:

| FareTable | feed | rijen | dode labels | onbeprijsde feed-agencies |
|---|---|---|---|---|
| 2023 | 20231003 | 142 | geen | Eu Sleeper¹ |
| 2024 | 20241001 | 144 | geen | Eu Sleeper¹ |
| 2025 | 20251008 | 143 | geen | Eu Sleeper¹ |
| 2026 | 20260316 | 144 | geen | European Sleeper¹ |

¹ internationale nachttrein; valt onder `Agencies/IsNS` (L-net), krijgt bewust geen FareTable-rij.

**Vóór deze fix** waren 2024/25/26 kopieën van de 2023-rijenset met alleen andere prijzen: 12/14/32 rijen matchten hun feed niet ("dood") en 9/11/18 feed-agencies hadden geen prijsrij.

## Toegepaste feed-transities (agency-relabels)

| vanaf | oud label | nieuw | reden |
|---|---|---|---|
| alle jaren | Arriva (prov. Noord-Brabant) | Bravo (Arriva) | Brabant rijdt in alle feeds onder Bravo-branding |
| alle jaren | Arriva (Bus, Groningen-Drenthe) | Qbuzz | GD-bus/Qliner is Qbuzz; Arriva alleen rail |
| alle jaren | R-net lijn 416/488/489/491/stadsBuzz/streekBuzz | Qbuzz | feed-eigenaar (DAV) |
| 2023–2024 | R-net lijn 430/431/432 | Arriva | feed-eigenaar (HWGO); vanaf 2025 niet in feed → rij vervalt |
| 2023–2025 | Keolis (lijn 295) | Syntus Utrecht | feed-eigenaar; 2026: lijn weg, U-OV-rijen dekken |
| 2023–2025 | Transdev (rail Arnhem-Doetinchem) | Breng | feed-eigenaar; 2026 → RRReis Arriva |
| 2024+ | Valleilijn | RRReis (2026: RRReis Keolis) | fusie RRReis-merk dec 2023 |
| 2024+ | Twents (Keolis), OV Regio IJsselmond | RRReis | RRReis-merk |
| 2024+ | Blue Amigo | Waterbus | rebranding; prijzen geactualiseerd (tarieftabel) |
| 2024+ | Texelhopper | Connexxion | feed-eigenaar lijn 28 |
| 2024+ | NIAG | — (vervallen) | niet meer in feed |
| 2024 | Arriva (Rail) | Arriva (OVR) | IFF:ARRIVA heet alléén in feed 20241001 zo |
| 2025+ | Overal (Connexxion) | Connexxion | opgegaan in Connexxion |
| 2025+ | NS International | NS Int | feed-hernoeming |
| 2025+ | Arriva (Bus, Achterhoek-Rivierenland) | RRReis | AR-bus onder RRReis-merk |
| 2026 | Blauwnet | Blauwnet Arriva (Vechtdal/Zutphen-Oldenzaal/IJssel-Vecht) / Blauwnet Keolis (Zwolle-Enschede/Kampen) | feed-splitsing |
| 2026 | R-net | R-net Qbuzz (MerwedeLinge/DAV) | feed-splitsing; R-net NS = nieuwe rij |
| 2026 | Syntus Utrecht | U-OV | concessie-overgang dec 2025 |
| 2026 | Arriva (Rail, Achterhoek-Rivierenland) | RRReis Arriva | feed-splitsing |
| 2026 | Watertaxi Rotterdam | WaterShuttle | feed-naam; prijs geactualiseerd |

Relabels dragen een `[feed: vh. <oude naam>]`-tag in de Opmerking.

## Nieuw beprijsde agencies (workflow-research, adversarieel geverifieerd)

| agency | jaren | prijs | bron |
|---|---|---|---|
| TESO (veer Texel) | 2024+ | 1.25 / 1.50 / 1.50 vast | teso.nl (retour voetganger ÷ 2) |
| Rederij Doeksen | 2024+ | 20.12 / 20.76 / 22.14 vast | rederij-doeksen.nl e.a. |
| Wagenborg (Ameland/Schier) | 2024+ | 7.23 / 7.59 / 7.95 vast | wpd.nl (2025 = interpolatie) |
| Waterbus (vh. Blue Amigo) | 2024+ | 2.13 / 2.17 / 2.25 vast | Waterbus-tarieftabel |
| WaterShuttle (R'dam–Kinderdijk) | 2026 | 9.75 vast | watershuttle.nl |
| MeerPlus (EBS Zaanstreek-Waterland) | 2025+ | 1.12+0.207 / 1.16+0.215 | vervoerregio.nl tariefbesluiten |
| Bravo (plain; lijn 323) | 2024+ | = Bravo (Hermes) | analogie Zuidoost-Brabant |
| ZTM (nachtbus Zoetermeer–Leiden) | 2024+ | 6.50 vast (pin-only) | wiki.ovinnederland.nl; per 14-12-2025 N40/Qbuzz |
| TCS OV (Venlo–Wuppertal) | 2025 | 2.70 vast | GEEN BRON (analogie VIAS/NS Int) |
| GoVolta (A'dam–Hamburg) | 2026 | 2.79 vast | GEEN BRON (analogie NS Int) |
| R-net NS (Alphen–Gouda) | 2026 | 1.27 + 0.223/km | lineaire fit NS-tariefeenheden 2026 |
| Keolis (TVV 822-824) | 2023 | = Blauwnet | analogie (treinvervangend) |

## Bijbehorende fix: `Classifications.dms` Agencies/IsNS + IsForeign

`IsNS`/`IsForeign` gebruikten alleen de oude feed-namen (`ns_international`, `eu_sleeper`). Vanaf feed 20251008/20260316 heten die `ns_int` en `european_sleeper` → beide varianten opgenomen; `tcs_ov` en `govolta` aan `IsForeign` toegevoegd.

## Grens- en open-access-treinen: routering + beprijzing

`Agencies/IsNS` sluit agencies volledig uit het netwerk (niet in R-net wegens IsRO, niet in L-net want die filtert op exact 'ns'). DB en Eurobahn stonden er ten onrechte in: het zijn regionale grens-stoptreinen (DB: Enschede–Dortmund met NL-stop Glanerbrug; Eurobahn: Hengelo–Bielefeld met NL-traject Hengelo–Oldenzaal, Venlo–Hamm) — vergelijkbaar met VIAS/NMBS, die wél gerouteerd + via FareTable beprijsd worden. **Fix**: DB/Eurobahn uit IsNS; hun FareTable-rijen geharmoniseerd:
- DB: vast 2.60 / 2.70 / 2.79 (analoog VIAS/NS Int), km=0 — was per abuis basistarief-flat (1.08–1.16);
- Eurobahn Limburg 2025/2026: corrupte km-waardes (0.97 / 1.00 €/km) → DOVA Limburg-rail (0.223 / 0.229);
- vervuilde bronlinks (bravoflex/regiotaxi) uit de opmerkingen verwijderd.

NS Int en de European Sleeper blijven in IsNS (langeafstand-internationaal, parallel aan NS-IC's; uitsluiting ≠ gratis reizen — de legs zitten niet in het netwerk). **GoVolta** stopt binnen NL ook in Amersfoort/Deventer/Hengelo → NL-interne OD's mogelijk; vast tarief 2.79 zou fors onderprijzen → omgezet naar NS-tarieffit (1.27 + 0.223/km), zoals R-net NS.

## Automatische koppeling FareTable_year ↔ GTFS_file_date

`FareTable_year := substr(GTFS_file_date, 0, 4)` — het prijsjaar volgt de geladen feed, zodat een mismatch (bv. 2024-prijzen op de 2025-agency-set) niet meer kán. Afgeleiden in `ModelParameters/Advanced`:
- `PriceMethod_effective`: vóór 2023 (geen Detailed-tabellen) altijd DOVA, ongeacht `PriceMethod`;
- `DOVA_year`: geklemd op 2013-2026 (kolommen in het DOVA-overzicht);
- `NS_prijzen_year`: geklemd op 2023-2026 (aanwezige NS-tarieven-csv's).

## DOVA-modus: Buitenland-vangnet (Price_IntegrityCheck)

In DOVA-modus is de match-key `<modeklasse>_<concessiegebied>` via polygon-lookup. Legs buiten alle concessie-polygonen (buitenlandse trajectdelen van De Lijn/DB/Eurobahn/NIAG) kregen geen key → `FareTable_rel` undefined → `Price_IntegrityCheck` FALSE. Fix (tweetraps):
1. `MC_CG_key_DOVA` valt terug op `'Buitenland'` bij een ontbrekend concessiegebied; `FareTable_DOVA` is uitgebreid met 3 vangnetrijen (`BTM/Rail/Ferry_Buitenland`): opstap = landelijk basistarief, km = landelijk DOVA-klassegemiddelde van het gekozen jaar.
2. Shape-concessies zonder DOVA-rij (bv. Stadsvervoer Lelystad, alleen in de 2023-shape) vielen stil op een null-prijs; nu laatste fallback naar hetzelfde klassegemiddelde.

## Bekende restpunten (bewust gelaten)

- **Lijn-niveau-rijen met beschrijvende labels** ('Streek', 'Qliner', 'MerwedeLingeLijn', 'stadsBuzz', 'Vlinder', …) matchen nooit op `route_short_name`; ze prijzen via de CG/agency-fallback. Bestaand ontwerp.
- **West-Brabant 820**: de twee 2023-productrijen (kris-kras 3.50 / station 1.50) hebben in 2024-2026 dezelfde prijs gekregen en zijn daar tot één rij ontdubbeld.
- **Keukenhof-lijnen 852/854/858 (Arriva, ZH)**: lijnnummers wisselen per feed; agency-label klopt, lijn-match niet altijd. Prijst via fallback.
- **eu_sleeper/european_sleeper + ztm-2026**: sleeper via IsNS; ZTM-rij 2026 gedekt hoewel lijn per 14-12-2025 is opgeheven (nog in feed).
