# Bevindingen paretofronten: directe autorit en OV-ketenrijging, september 2026

Stand 24 september 2026, voor latere bespreking. Engine: de lokale build van GeoDMS 20.21 (`C:\dev\GeoDMS_2026\bin\Release\x64`, ObjectVision/GeoDMS c2f64650, met `pareto_optimal` uit #1281 en de epsilon-dominantie uit #1282). Op de geinstalleerde 20.20.0.m valt de configuratie via de versieguard `Advanced/EngineHasParetoEpsilon` terug op het oude gedrag. Samenvattingen staan ook in NetworkModel_PBL#88 (comment 5811058363) en GeoDMS#1282 (comment 5811109856). Wikipagina's: Private transport, "Car costs and the (time, cost) front", en Public transport, "Pareto filtering within ChainJoiner_T".

## 1. Directe autorit als front op (reistijd, kosten)

**Wat er gebouwd is.** Met `Advanced/ParetoLegs_Car` rekent `impedance_matrix_od64` met de pareto-optie: per HB-paar alle routes die niet door een andere route in zowel reistijd als kosten worden verslagen, de eerste rij per paar de snelste (76c58b2). Het tweede criterium is de kostprijs per link op het TomTom-net, niet de afstand (eeb5c5b, cc725b1, 0af2a3d):

```
LinkCost = LengthKm * (Car_VariableCosts_PerKm * Car_VariableCosts_RoadTypeFactor[FRC] + Car_FixedCosts_PerKm)
         + penalty-seconden aan beide linkuiteinden * Car_TurnCosts_PerPenaltyMinute * Car_TurnCosts_RoadTypeFactor[FRC]
```

met 0,20 EUR/km variabel, 0,21 EUR/km vast (in de prijs) en 0,30 EUR per penaltyminuut. De factoren per wegklasse:

| TomTom FRC | typische snelheid | factor kilometerprijs | optrekfactor | grondslag optrekfactor |
|---|---:|---:|---:|---|
| NA (ook de OD-koppellinks) | | 1,00 | 1,00 | |
| 0 snelweg | 100-130 | 1,05 | 0 | doorrijden, zie hieronder |
| 1 autoweg | 100 | 0,95 | 0 | idem |
| 2 provinciale weg | 80 | 0,85 | 1,69 | tijd-equivalent |
| 3 secundaire weg | 70 | 0,90 | 1,52 | tijd-equivalent |
| 4 | 60 | 0,95 | 1,44 | (v/50)^2 |
| 5 | 50 | 1,00 | 1,00 | (v/50)^2 |
| 6 | 40 | 1,10 | 0,64 | (v/50)^2 |
| 7 en 8 | 30 | 1,20 | 0,36 | (v/50)^2 |

**Waarom 0 op snelweg en autoweg** (b33d315). `CorrectImpedanceForCrossroads` rekent de kruispuntpenalty voor elke knoop met drie of meer links, dus ook voor de aansluitingen die doorgaand verkeer op de snelweg zonder afremmen passeert. Met de kinetische factor (130/50)^2 = 6,76 kostte elke gepasseerde afrit 13,5 ct en elk knooppunt 34 tot 40 ct. Elk alternatief dat zo'n knoop mijdt (een afrit eerder, de parallelweg) werd daardoor goedkoper en maar iets langzamer, dus een eigen frontlid.

**Waarom tijd-equivalent op FRC 2 en 3** (18e9368). Daar kost een kruispunt nu precies de kilometerprijs van de afstand die je in de penaltytijd op die weg zou rijden: `Car_TypicalSpeed_kmh / 60 * kilometerprijs / Car_TurnCosts_PerPenaltyMinute`. Een omweg om het kruispunt kost dan per seconde evenveel als het kruispunt zelf en wordt geen frontlid. Per klasse aan te zetten met `Car_TurnCosts_UseTimeEquivalent`; de afgeleide waarde volgt de kostenparameters.

**Epsilon-dominantie** (eba4c0c). `pareto(imp2_epsilon)` met `Advanced/CarFrontCostEpsilon` = 10 ct: per knoop en bestemmingszone hoogstens een route per kostenbak van 10 ct, de snelste. Na het lezen van de store dunt `Car_Front` nog eens uit met `pareto_optimal_eps` op 60 s (`CarFrontTimeEpsilon`) en 10 ct. De store houdt het front van de zoektocht; `Direct/Car` leest het uitgedunde front. Tags: `_paretoCare10ct` in de storenaam, `_carfront60s10ct` in de uitvoernaam.

**Testset** (535 buurten in de Kop van Noord-Holland naar 462 OV-knooppunten, ochtendspits, 78.717 bereikbare HB-paren, snelste rit gemiddeld 66 min):

| instelling | frontrijen | routes per paar (gem / max) | kosten per paar min tot max (gem) | rekentijd |
|---|---:|---:|---:|---:|
| 1 ct per link, (v/50)^2 op alle klassen | 4.381.117 | 55,7 / 368 | 36,96 tot 39,76 EUR | 12,5 min |
| idem, 0 op snelweg en autoweg | 1.808.990 | 23,0 / 203 | 32,25 tot 33,70 EUR | 3,5 min |
| idem, tijd-equivalent op FRC 2 en 3 | 1.493.572 | 19,0 / 182 | 31,81 tot 33,08 EUR | 3 min |
| zoek-epsilon 10 ct (geen kwantisatie per link) | 330.862 | 4,2 / 27 | 31,95 tot 33,10 EUR | 39 s |
| plus uitdunning 60 s en 10 ct bij het lezen | 227.530 | 2,9 | | seconden |

- Met de zoek-epsilon is de snelste route in alle 78.717 paren gelijk aan die van de store met 1 ct per link.
- De mediane stap tussen twee opeenvolgende frontleden van een paar was met 1 ct per link 7 s en 2 ct (63% van de stappen hoogstens 10 s, 78% hoogstens 5 ct); met de epsilon 36 s en 20 ct. Zonder epsilon bestonden de fronten dus vooral uit microvarianten: ditherruis van de kwantisatie, kleine kruispuntkosten op lokale wegen, afwijkende linksnelheden.

**Volledige set, nacht van 23 op 24 september** (88.126 herkomsten in clusters van 500 m naar 462 OV-knooppunten, MaxCarTime 90 min, `batch\UpdateAll.cmd all -nosources`):

| moment | HB-paren | frontrijen | routes per paar (gem / p90 / max) | reistijd per paar min tot max (gem) | kosten per paar min tot max (gem) | telpas | vulpas | piek commit | store |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| MorningRush | 12,95 M | 55,6 M | 4,3 / 9 / 53 | 62,2 tot 65,8 min | 29,76 tot 30,92 EUR | 97 min | 97 min | 5,1 GB | 0,9 GB |
| NoonRush | 15,68 M | 68,8 M | 4,4 / 9 / 53 | 62,0 tot 66,1 min | 32,90 tot 34,17 EUR | 131 min | 132 min | 5,3 GB | 1,1 GB |
| LateEveningRush | 16,78 M | 77,1 M | 4,6 / 10 / 52 | 61,8 tot 66,2 min | 34,13 tot 35,48 EUR | 150 min | 150 min | 5,4 GB | 1,2 GB |
| Freeflow | | | | | | | | | |

- Geen fouten. PeakLiveLarge was 4,1 GB in alle drie; geheugen is geen beperking.
- Het aantal paren verschilt per moment door MaxCarTime: in de spits is minder binnen 90 minuten bereikbaar.
- Freeflow is om 10:09 afgebroken op 40.235 van de 88.126 herkomsten en moet nog gerekend worden: `batch\UpdateAll.cmd cars Freeflow`, naar verwachting 3 tot 4 uur.

## 2. OV-ketenrijging met pareto_optimal_eps

**Wat er gebouwd is** (5831c8e). De configuratie had vier handgeschreven pareto-vergelijkers (voorselectie met `min_index`, dan een self-join per groep): de ketenrijger (`ChainJoiner_T`, criteria `Price_augm` en de twee resttijden), de selectie per haltenblok en de twee condensaties per vertrekmoment (`Price` en `TravelTime`). Achter de versieguard is elk nu `pareto_optimal_eps(<groep>, crit1, eps1, ...)`, met `Advanced/ChainParetoPriceEpsilon` = 10 ct op de prijscriteria en `Advanced/ChainParetoTimeEpsilon` = 60 s op de tijdcriteria (`EpsilonExpr` per criterium in `Classifications`). De oude vergelijker blijft als `pareto_condition_classic`. Tag `_chaineps10ct60s` in de naam van de ketenstore en van de uitvoer.

**Blok 1 van 500**, vier vertrekmomenten (07:00 tot 07:45):

| vergelijker | kandidaten in de blokselectie | geselecteerde ketens | wandklok |
|---|---:|---:|---:|
| handgeschreven | 8.208.876 | 1.112.925 | 251 s |
| `pareto_optimal_eps`, eps 0 | 8.208.876 | 1.112.925 | 166 s |
| `pareto_optimal_eps`, 10 ct en 60 s | 7.880.926 | 1.062.875 | 166 tot 180 s |

- Eps 0 selecteert hetzelfde als de oude vergelijker: gelijke aantallen en identieke sommen van `Price`, `Price_augm` en `Traveltime`. Rij voor rij niet vergeleken.
- Met 10 ct en 60 s geeft de ketenrijger 4% minder tussenketens door. Niet gecontroleerd: of de goedkoopste en de snelste keten per groep binnen de epsilon blijven.

**Rekentijd per aantal vertrekmomenten** (blok 1, 10 ct en 60 s):

| vertrekmomenten | ketens in blok 1 | tijd blok 1 | schatting 500 blokken |
|---|---:|---:|---:|
| 1 (07:00) | 460.197 | 38 s | gemeten: 3,5 uur (24,6 s per blok) |
| 2 (07:00, 07:30) | 858.928 | 107 s | ca. 15 uur |
| 4 (07:00 tot 07:45, de standaard) | 1.062.875 | 166 tot 180 s | ca. 24 uur |

**Ketenstore voor 07:00**, 24 september 10:39 tot 14:07 (`batch\UpdateAll.cmd chains`, `PT_DepartureMinutes` tijdelijk op 0, `pareto_optimal_eps` met 10 ct en 60 s in alle stappen):

| | |
|---|---:|
| ketens in de store | 219,8 M |
| ketenrijging, 500 blokken | 205 min (24,6 s per blok) |
| union en schrijven | 1 min |
| piek CommitCharge | 37,3 GB |
| PeakLiveLarge | 27,4 GB |
| store op schijf | 11,5 GB |

- Geen fouten; de voorcheck op haltenblokken en prijsdekking slaagde.
- Store: `IntermediateResults\PT_Chains_07h00m_to_08h44m_20241001_min-Price_Time_maxtransf-3_MaxOV-90min_paretoR_chaineps10ct60s.mmd`. Het venster in de naam volgt uit de vertrekmomenten, dus de config leest deze store alleen met `PT_DepartureMinutes` op 0.
- Met vier vertrekmomenten geeft blok 1 2,3 keer zoveel ketens; store en geheugen groeien naar verwachting mee. Niet gemeten.

## 3. Directe fiets- en looproutes

Lopen en fietsen doen mee met een route per HB-paar, de snelste over het OSM-net, binnen 90 minuten (`MaxWalkingTime_Org2Dest`, `MaxCyclingTime_Org2Dest`); de prijs is 0 zolang `IncludeWalkingCostsInPrice` en `IncludeCyclingCostsInPrice` uit staan (2dc3abe). Een front voor de fiets is niet gebouwd.

Aantal routes voor de volledige set (88.126 herkomsten naar 462 OV-knooppunten, geteld op 24 september, 4 minuten, piek commit 11 GB):

| modaliteit | HB-paren, een route per paar | reistijd gem | afstand gem |
|---|---:|---:|---:|
| lopen | 103.838 | 59 min | 4,3 km |
| fiets | 779.484 | 60 min | 12,7 km |
| auto, ter vergelijking (MorningRush) | 12,95 M paren, 55,6 M frontrijen | 62 tot 66 min | |

De reistijd van de fiets bevat de starttijd (`Cycling_StartTime`); daardoor ligt het maximum net boven de 90 minuten.

## 4. Uitvoer voor 07:00

**Blok 1 van 450 herkomstblokken** (200 herkomsten, 24 september, `PT_DepartureMinutes` tijdelijk op 0): 186 s, piek commit 23,6 GB, een csv van 6,2 MB.

| | rijen |
|---|---:|
| HB-paren met minstens een route | 28.566 (31% van 200 x 462) |
| rijen in het front | 86.642 (3,0 per paar) |
| waarvan auto | 78.326 |
| waarvan OV-keten | 6.223 |
| waarvan fiets | 1.825 |
| waarvan lopen | 268 |

- Het front per paar bestaat vooral uit autoroutes. Een directe rit komt in het front als hij sneller of goedkoper is dan elk ander alternatief.
- De csv-regels misten `TravelDist_V` en `Traveldist_N` terwijl de kop ze noemt (audit 3.6); hersteld in 8982a43. Daarna verdwenen alle autoritten uit de csv, omdat hun afstand null is en een null de hele regel null maakte; sinds 6fe61d3 is een onbekende waarde een leeg veld.
- `Export_PriceInformation` staat standaard op FALSE, dus zonder prijskolom. Voor deze run staat hij tijdelijk op TRUE, omdat een front op prijs en tijd zonder prijs niet te lezen is.

**Alle 450 blokken**, 24 september 14:43 tot 15:04 (`batch\UpdateAll.cmd output`, met de prijskolom): 20 minuten, piek commit 28,6 GB, PeakLiveLarge 21,7 GB, 450 csv-bestanden van samen 3,5 GB, geen fouten, alle regels met 17 velden. De engine rekent meerdere blokken tegelijk, 2,3 s per blok; de eerste 2,5 minuut gaan op aan de loop- en fietsmatrices en het inlezen.

| modaliteit | rijen in het front | HB-paren waar de modaliteit in het front zit | rijen per paar |
|---|---:|---:|---:|
| auto | 35.752.261 | 12.829.221 | 2,8 |
| OV-keten | 2.504.362 | 1.271.365 | 2,0 |
| fiets | 779.274 | 779.274 | 1 |
| lopen | 102.973 | 102.973 | 1 |
| totaal | 39.138.870 | 12.954.623 | 3,0 |

- De auto zit in 99% van de bereikbare paren in het front, het OV in 10%. Fiets en lopen overleven bijna overal waar ze binnen 90 minuten komen (779.274 van 779.484 en 102.973 van 103.838 paren). Lopen kost 0 (`IncludeWalkingCostsInPrice` FALSE) en is daarmee altijd de goedkoopste; de fiets draagt 9 ct per km (`IncludeCyclingCostsInPrice` TRUE) en is meestal goedkoper dan auto en OV.
- Bestanden: `Output\PerBlock\tt_20241001_07h00m_ORG-bag_woonpanden_clustered_500m-Block_<n>of450_DEST-ov_knooppunten_..._paretoCare10ct_carfront60s10ct_chaineps10ct60s.csv`.

## 5. Punten voor bespreking

- De optrekfactoren per wegklasse zijn eerste aannames. De kruispuntpenalty zelf telt ook doorrijden mee; is 0 op snelweg en autoweg en tijd-equivalent op FRC 2 en 3 acceptabel, of moet de penalty per knooptype anders?
- De epsilons: 10 ct in de autozoektocht, 60 s en 10 ct bij het lezen van het autofront, 10 ct en 60 s in de ketenrijging. Passen die bij de nauwkeurigheid die de analyse nodig heeft?
- Het aantal vertrekmomenten voor de ketenstore: 1, 2 of 4, met ca. 4, 15 of 24 uur rekentijd.
- NetworkModel_PBL#88: afstand is geen apart criterium geworden; de kilometerprijs zit in de kosten. Een front voor de fiets ontbreekt nog.
- Voor productie is een geinstalleerde 20.21-setup nodig; nu draait het model op een werkboom-build.
- Moet de prijs standaard in de uitvoer (`Export_PriceInformation`)?

## 6. Bijvangst, hersteld

- `batch\UpdateAll.cmd` gaf GeoDmsRun het pad `batch\..\cfg\main.dms`; GeoDMS leidde daaruit de projectmap `..` af, zodat de stores in `C:\IntermediateResults` kwamen (19afe9a).
- De ketenstore-holder staat in `PublicTransport_Prep/x/Write_Result`; de verwijzingen misten `x/`, waardoor de nachtrun van 23 september direct stopte (62ebbae).
- `subset(...)` is in 20.21 een fout; de configuratie gebruikt `select_with_org_rel`.
- De kostentag in de storenaam droeg float-ruis (`t30.000002`), en `Summary/nr_routes` was niet te berekenen omdat `pcount` over een uint64-domein uint64 levert (bda1a38).
