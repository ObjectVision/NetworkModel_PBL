# FareTable 2023-2026: volledig dekkingsrapport (audit juli 2026)

Aanleiding: herhaald gevonden contaminatie uit de research-assemblage (#112). Antwoord: geen triage
op "verdacht" maar **volledige dekking** — elke rij × elk jaar heeft een verificatiestatus.

## Verificatielagen

| laag | methode | dekt |
|---|---|---|
| Arriva-sheets (10 regio-tabs, 2024 v1.0 + Noord 2025/2026) | mechanisch geparsed | alle Arriva/Bravo-producten 2023-2024: km-tarieven, Wadden-flats, buurtbussen, Vlinder/flex, Nightliner, Keukenhof, ZHN (W-ZHN-tab), Qliner 315/324/350 |
| arriva.nl / operator-pagina's + wayback | workflow-agents, per jaar | Limburg 25/26, Fryslân-Qbuzz 25/26 (22 product-jaren), zhn/dmg/frl.qbuzz, HTM, RET, allGo, Connexxion, De Lijn, NMBS, TESO/Doeksen/WPD/Waterbus |
| tariefbesluiten (prb, MRDH, Vervoerregio, stateninformatie, OV-bureau GD) | workflow-agents | Gelderland (Breng/Valleilijn/AR), MRDH-gebiedstarieven, Vervoerregio (GVB/EBS/Connexxion/MeerPlus), U-OV, GD-tweetraps-2026 |
| DOVA-overzicht (lokale xlsx) | mechanische kruisvergelijking | alle concessie-km-rijen; rail-rijen noord/oost (Vechtdal, ZHO/Twente, IJssel-Vecht, IJsselmond) |
| adversariële toets | tweede onafhankelijke agent per FOUT-claim | elke voorgestelde correctie; ving o.a. 2 agents die niet-bestaande "huidige" waarden rapporteerden |
| mechanische invariants | basistarief-check, km-banden, sprongscan >30%, quote-pariteit, bron-domein↔vervoerder, 2023-diff tegen baseline c180f05 | alles |

## Uitkomst per ronde

1. **Sheet-ronde**: Vlieland 1.82→2.50 (was Ameland-kopie, óók in origineel-2023), Nightliner-2024 5.00→5.58,
   Limburg-2024 0.228→0.204/0.220, lijn 83 → 0.186, NHN-opstap-2026 1.12→1.16. Retour÷2-methode
   eilanden bevestigd; buurtbussen/Opstapper/820/Vlinder-flats bevestigd.
2. **Workflow-2 (9 clusters)**: 35 correcties — Valleilijn eerste-8km-structuur (vast 1.368/1.412/1.467 + km
   0.202/0.209/0.217), DMG-stadsBuzz droeg snelBuzz-reeks (→0.180/0.186/0.193), streekBuzz stale
   (→0.161/0.167), Transdev=GV-tarief (0.189/0.196) + Breng-tarief C-AN (0.192/0.199), trein
   Arnhem-Doetinchem 0.236/0.245, Texel-lijn-28 0.218/0.229/0.238, Utrecht-grensrijen 0.193/0.201,
   Qliner-350-NH 0.189/0.196, Nightliner-2025 5.77 (prb). Bevestigd: Fryslân-Qbuzz volledig, GVB, HTM,
   RET, EBS, U-OV-hoofdrijen, Connexxion-NHN.
3. **Workflow-3 (8 clusters, rest)**: 53+6 wijzigingen — IJsselmond 0.196/0.203/0.210, GD-generiek-2026
   0.215 (tweetraps per 1-3-2026; feed 20260316 valt erna), Qliner-315/324-GD-duplicaten →
   Fryslân-Qliner-tarief (0.213/0.220/0.229), GD-rail en Vechtdal-rail droegen bus-tarieven →
   0.208/0.215/0.223 (Vechtdal-DOVA; noordelijke treinen = NS-tariefstructuur, benadering),
   ZHO-rail → Twente-rail-DOVA (0.234/0.242/0.251), Vlinder-ZH → ZHN-tarief (0.156/0.161/0.167),
   Keukenhof via zhn.qbuzz-retourprijzen (852: 8.50/9.10; 854: 6.00/6.40; 858 vervallen in 2026;
   **850-Haarlem toegevoegd**: 8.60/4.80/6.00/6.40), De Lijn → 3.00 (per 1-4-2025), NMBS → 2.50/2.60,
   Connexxion-Zeeland-2026 0.257, allGo 0.185/0.192, Westerschelde 5.35/5.60, Wagenborg-2025 7.50,
   **ZHN-concessierijen toegevoegd** (Qbuzz per 14-12-2024: 0.161/0.167),
   **Almere-ring-flats verwijderd** (ritkaartprijzen bij chauffeur; saldo-model prijst via allGo-km-rij).
4. **2023-baseline-diff**: alle afwijkingen van de originele tabel herleidbaar tot gedocumenteerde
   validatiecorrecties; twee extra origineel-2023-fouten gevonden (Vlieland; GD-rail 0.228-Gelderland-kopie → 0.208-benadering).

## Bewust gelaten / open

- **VIAS** (2.60/2.70/2.79) + **TCS/GoVolta**: geen gepubliceerd NL-deel-tarief → analogie, eerlijk GEEN BRON.
- **Nightliner-2026** 6.01: prb-2025-21051 noemt geen nightliner → index.
- **R-net-ZH-generiek** (0.200/0.206/0.214): dekt DMG-R-net/snelBuzz (correct); ZHN-R-net loopt via de
  nieuwe ZHN-concessierij.
- **IJsselmond-2023** 0.185 = Flevoland-deel (keuze invoerder); NW-Overijssel-deel was 0.211.
- **eu_sleeper/european_sleeper**: bewust uitgesloten (IsNS; geen gratis reizen — legs zitten niet in het netwerk).
- **Connexxion-fallback 'Overal'/'Alle'**: alle Connexxion-concessies hebben eigen CG-rijen (AML,
  Haarlem-IJmond, NHN, Zaanstreek(-Waterland), Zeeland, ZH/HWGO + Texel/Parkshuttle; Gooi&Vecht via
  Transdev-rijen, Brabant via Hermes/Bravo, Arnhem-Nijmegen via Breng). De fallback-rij vangt alleen
  grensritten die net buiten die polygonen vallen — zonder die rij zou rlookup willekeurig een
  Connexxion-rij pakken. Waarde = mediaan van de Connexxion/Hermes/Breng-concessietarieven per jaar
  (0.187/0.186/0.192/0.199), niet meer de Zeeland-uitschieter.
- ~~2 toets-agents strandden op een sessielimiet~~ — **gedicht** via een aparte natoets-workflow:
  Keukenhof-2025, ZHN-tarieven en buurtBuzz-ZHN (0.125/0.13) bevestigd met dubbele captures;
  weerlegd werd de 2026-aanbodlijst (lijn 859 Hoofddorp reed als 858-vervanger → toegevoegd, 6.40)
  en de noord-rail-2026-proxy (Voordeel Noord voegt €0,02/km toe → 0.243). PwC-Tariefonderzoek-HRN
  bevestigt primair dat de noordelijke treindiensten 2023-2025 'NS-tarief' rijden zonder eigen
  km-prijs — de Vechtdal-proxy blijft daar de expliciet gemarkeerde benadering.

Rijaantallen na audit: 2023: 141, 2024: 144, 2025: 142, 2026: 143. Invariants: 0 dode agency-labels,
0 onverklaarde prijssprongen >32%, 0 quote-afwijkingen, alleen sleeper onbeprijsd (uitgesloten).

---

# Naslag: feed-uitlijning en systeemwijzigingen

**Principe.** De FareTable-match loopt via `Mode_Agency_CG_Lijn` waarbij het agency-deel =
`AsItemName(lowercase(agency_name))` uit de **geladen** GTFS-feed. Agency-namen wijzigen per feed
(fusies/splitsingen/hernoemingen), dus elke `FareTable_<jaar>` is uitgelijnd op de feed van dat jaar:
2023↔20231003, 2024↔20241001, 2025↔20251008, 2026↔20260316. Vóór de fix waren 2024-2026 klonen van
2023: tot 32 rijen matchten hun feed niet en tot 18 feed-agencies hadden geen prijsrij.

## Feed-transitietabel (agency-relabels; rijen dragen `[feed: vh. …]`-tag)

| vanaf | oud label | nieuw | reden |
|---|---|---|---|
| alle jaren | Arriva (prov. Noord-Brabant) | Bravo (Arriva) | Brabant rijdt onder Bravo-branding |
| alle jaren | Arriva (Bus, Groningen-Drenthe) | Qbuzz | GD-bus/Qliner is Qbuzz; Arriva alleen rail |
| alle jaren | R-net lijn 416/488/489/491/stadsBuzz/streekBuzz | Qbuzz | feed-eigenaar (DAV) |
| 2023–2024 | R-net lijn 430/431/432 | Arriva | feed-eigenaar (HWGO); vanaf 2025 niet in feed → rij vervalt |
| 2023–2025 | Keolis (lijn 295) | Syntus Utrecht | feed-eigenaar; 2026: lijn weg, U-OV dekt |
| 2023–2025 | Transdev (rail Arnhem-Doetinchem) | Breng | feed-eigenaar; 2026 → RRReis Arriva |
| 2024+ | Valleilijn | RRReis (2026: RRReis Keolis) | RRReis-merk |
| 2024+ | Twents (Keolis), OV Regio IJsselmond | RRReis | RRReis-merk |
| 2024+ | Blue Amigo | Waterbus | rebranding |
| 2024+ | Texelhopper | Connexxion | feed-eigenaar lijn 28 |
| 2024+ | NIAG | — (vervallen) | niet meer in feed |
| 2024 | Arriva (Rail) | Arriva (OVR) | IFF:ARRIVA heet alléén in feed 20241001 zo |
| 2025+ | Overal (Connexxion) | Connexxion | opgegaan in Connexxion |
| 2025+ | NS International | NS Int | feed-hernoeming |
| 2025+ | Arriva (Bus, Achterhoek-Rivierenland) | RRReis | AR-bus onder RRReis-merk |
| 2026 | Blauwnet | Blauwnet Arriva (Vechtdal/ZHO/IJssel-Vecht) / Blauwnet Keolis (Zwolle-Enschede/Kampen) | feed-splitsing |
| 2026 | R-net | R-net Qbuzz (MerwedeLinge/DAV); R-net NS = nieuwe rij | feed-splitsing |
| 2026 | Syntus Utrecht | U-OV | concessie-overgang dec 2025 |
| 2026 | Watertaxi Rotterdam | WaterShuttle | feed-naam |

Nieuw beprijsde agencies (adversarieel geverifieerd): TESO, Rederij Doeksen, Wagenborg, Waterbus,
WaterShuttle, MeerPlus, Bravo (plain, lijn 323), ZTM (nachtbus, †14-12-2025 → N40/Qbuzz), TCS OV,
GoVolta (NS-tarieffit — stopt óók in Amersfoort/Deventer/Hengelo, dus geen flat), R-net NS
(NS-tarieffit), Keolis-TVV, KeukenhofBuzz 850/859, ZHN-concessierijen (Qbuzz per 15-12-2024).

## IsNS / grens-treinen

`Agencies/IsNS` sluit agencies volledig uit het netwerk (niet in R-net wegens IsRO; L-net filtert op
exact 'ns'). DB en Eurobahn (regionale grens-stoptreinen Enschede-Dortmund / Hengelo-Bielefeld /
Venlo-Hamm) zijn eruit gehaald en prijzen nu als VIAS/NMBS via de FareTable. NS Int + European
Sleeper blijven uitgesloten (langeafstand, parallel aan NS-IC; uitsluiting ≠ gratis). IsNS/IsForeign
kennen beide feed-naamvarianten (ns_international/ns_int, eu_sleeper/european_sleeper).

## Automatische jaarkoppeling

`FareTable_year := substr(GTFS_file_date, 0, 4)` — prijsjaar volgt de geladen feed (mismatch kan niet
meer). Afgeleiden in `ModelParameters/Advanced`: `PriceMethod_effective` (vóór 2023 altijd DOVA),
`DOVA_year` (klem 2013-2026), `NS_prijzen_year` (klem 2023-2026).

## DOVA-modus: Buitenland-vangnet

DOVA-key = `<modeklasse>_<concessiegebied>` (polygon-lookup). Legs buiten alle polygonen (buitenlandse
trajectdelen) → key `'Buitenland'` → 3 vangnetrijen (opstap = basistarief, km = landelijk
klassegemiddelde van het jaar). Shape-concessies zonder DOVA-rij (Stadsvervoer Lelystad, 2023-shape)
vallen op hetzelfde klassegemiddelde terug. Hiermee slaagt `Price_IntegrityCheck` in DOVA-modus.

## Ontwerpnotities

- Lijn-rijen met beschrijvende labels ('Streek', 'Qliner', 'MerwedeLingeLijn', …) matchen nooit op
  `route_short_name`; ze documenteren producten en prijzen via de CG/agency-fallback (bestaand ontwerp).
- West-Brabant 820: twee productrijen (kris-kras 3.50 / station 1.50) in 2023-2024; vanaf 2025 niet in feed.
- GVB-ponten zijn echt gratis (0/0) — realiteit, geen datagat.
