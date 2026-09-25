# Audit NetworkModel_PBL, bijgewerkt 25 september 2026

Dit is de bijgewerkte versie van de audit van 23 september 2026 (`doc/Audit_NetworkModel_PBL_2026-09-23.md`, ongewijzigd bewaard). De genummerde bevindingen van sectie 3 (toepassing van modelparameters) en sectie 4 (netwerkgeneratie) zijn op 24 en 25 september afgehandeld: gerepareerd, of, waar het geen fout in de config bleek maar een beperking van de data of een ontwerpkeuze, onderbouwd toegelicht. Per bevinding staat eerst de oorspronkelijke vondst, daarna de stand. De overige secties zijn overgenomen met hun stand van vandaag; sectie 9 geeft wat nog open staat.

De metingen zijn gedaan met de lokale build van GeoDMS 20.21 (ObjectVision/GeoDMS c2f64650). Markering zoals in de audit: **[V]** zelf nagelezen of gemeten, **[A]** alleen door een zoekagent gelezen, **[S]** vermoeden. Commits verwijzen naar de repository `NetworkModel_PBL`; de wiki-pagina's zijn bij elke reparatie bijgewerkt.

## 1. Oordeel in het kort

- **Modelparameters (sectie 3)**: alle negen genummerde configfouten zijn gerepareerd, van de onbruikbare NS-korting tot de datum van de vorige dag. De namen van de stores dragen nu de instellingen waar hun inhoud van afhangt, zodat een gewijzigde parameter of datum niet meer stil een oude store leest.
- **Netwerkgeneratie (sectie 4)**: twaalf van de vijftien bevindingen zijn gerepareerd, waaronder de TomTom-freeflowsnelheid (4.1 tot en met 4.3), de 130 km/u op het OSM-autonet (4.7), de 8,3% OSM-wegen met onbekend wegtype (4.8), de verkeerd om gedigitaliseerde eenrichtingswegen (4.9) en de dubbele TomTom-wegelementen (4.5). Drie (4.12, 4.13, 4.15) zijn toegelicht: geen fout, wel een grens van de data of een keuze.
- **Kruispuntpenalty (sectie 5)**: telt nu een keer per kruispunt, en de aanhechtpunten van herkomsten en bestemmingen zijn geen kruispunt meer.
- **Pareto-dominantie (sectie 6)**: de vier handgeschreven vergelijkers zijn vervangen door `pareto_optimal_eps` (GeoDMS 20.21). Open blijven 6.1 (andere criteria in de ketenrijger dan in het eindfront) en 6.5 (de merge-keten over blokken en vertrekmomenten).
- **Gevolg voor de rekenresultaten**: het TomTom-autonet, het OSM-net, de GTFS-dienstdagen en de haltenummering zijn veranderd. Alle stores van voor 25 september zijn daardoor achterhaald; de nieuwe namen (revisies `_r2`/`_r3`, datumtags) voorkomen dat ze nog gelezen worden. De resultaten worden opnieuw gerekend, voor de peildata 1 oktober 2024, 30 september 2025, 16 juni 2026 en (voorlopig) 6 oktober 2026.

## 2. Consistentie met de wiki

De bevindingen van 23 september staan in de oorspronkelijke audit. Sindsdien bijgewerkt, telkens in dezelfde sessie als de reparatie: How to run the model (UpdateAll en de geplande taak, storenamen en revisies, GTFS-feeds ophalen en klaarzetten, de nieuwe parameters), Private transport (TomTom-snelheden per richting, plafond overdag, OSM-wegtypen, eenrichting, maxspeed-kwantiel, handmatige verbindingen, Fietstelweek, TomTom-wegselectie), Public transport (epsilon-dominantie in de ketenrijging), Public transport fares (NS-korting), Decay (parameters per modaliteit) en Create routable network from GTFS files (dienstdagen en datumcontroles). Daarmee zijn uit sectie 2 afgehandeld: de naam `TomTom_StreetTypeSelection`, de rol van `UseActualCyclingSpeeds`, de decay-parameters, de dagselectie en de datumcontrole van GTFS, en de beschrijving van de cachenaam. De overige punten van sectie 2 (onder meer de Script-reference met de namen van voor april, de minimale GeoDMS-versie, de defaults in How to run, de dode batchbestanden in README) staan nog open.

## 3. Toepassing van modelparameters

### Configfouten

1. **NS-korting onbruikbaar** [V]. `OVprijzen.dms` las `Price_20pct_Discount`/`Price_40pct_Discount`; de tarieftabel noemt ze `Discount_20pct`/`Discount_40pct`, dus alleen het volle tarief werkte.
   **Hersteld** (1f0440f). Gemeten over 156.816 stationsparen: vol tarief gemiddeld 22,29 euro, 20% korting 17,83, 40% korting 13,37.

2. **Loop- en fietsdecay met auto-parameters** [V] (`NetworkSetup.dms`).
   **Hersteld** (1f0440f). `Calc_Traveltimes_T` krijgt de modaliteit mee en leest `walk_*` of `bike_*` (e-bike gebruikt de fiets). PBL heeft geen loopparameters geleverd; `walk_a/b/c` zijn voorlopig die van de fiets. Gedecayde bereikbaarheid van eerdere runs is niet vergelijkbaar met nieuwe.

3. **OSM-auto in de spits 130 km/u overal** [V]. De spitssnelheden waren null en de terugval vergeleek hoofdlettergevoelig met `'Car'` terwijl de netten met `'car'` gemaakt worden.
   **Hersteld** (1f0440f). `lowercase(NetworkType) == 'car'`; koppellinks rijden 30 km/u; de spitssnelheid van het OSM-autonet is de maximumsnelheid met het plafond van het moment. Daarbij op verzoek een plafond overdag: `CongestionTimes/MaxSpeed` 100 km/u in ochtend- en middagspits (TomTom en OSM), geen plafond in de avondspits en bij freeflow.

4. **Cachenaam van de ketenstore onvolledig** [V]. Een gewijzigde prijs- of overstapparameter las stil de oude ketens terug.
   **Hersteld** (debb335, a3600bc). De naam draagt `_gtfs<datum>` als de feed van `Analysis_date` afwijkt, `Advanced/ChainStore_ParamTag` met prijsmethode, NS-korting, overstapafstand en -snelheid, tijdkosten van lopen en wachten, overstappenalty's en halteclusterafstanden (bij de defaults `_dova_ov500-3750-19-5-0-35_h100-350`), en de revisie `Advanced/ChainStore_Revision` (`_r2`).

5. **"Gisteren" als getal** [V]. `uint32(Analysis_date) - 1` is op de eerste van een maand een datum die niet bestaat; met de default 20241001 deed geen enkele rit van 30 september mee, terwijl de feed die dag bevat. Links van gisteren zonder shape-afstand kregen lengte 0.
   **Hersteld** (a3600bc). Een tijdas van 48 uur in seconden sinds 00:00 van D, met de dienstdagen D-1 (ritten na middernacht, min 24 uur), D en D+1 (hele ritten die voor het einde van het venster beginnen, plus 24 uur); D-1 en D+1 via een dagnummer (`Templates/DayNr_T`, `CivilDate_T`, getest op schrikkeldagen, de jaarwisseling en de zomertijdwissels). Drie controles bij het opbouwen van het OV-netwerk (`LoadFeeds/ServiceDays`): elke benodigde dienstdag heeft minstens 95% van de ritten van de drukste gelijke weekdag in de feed, de weekdag past bij de congestiedag van de auto, en geen zomertijdwissel. Gemeten op 20241001: 32.301 links van 30 september (7 in het venster van 07:00), 45.651 in plaats van 45.033 haltes; de OV-knooppunten clusteren alleen haltes met vertrekken op D en zijn identiek gebleven (462).

6. **Exportkolommen verschoven** [V]. De bodyregels misten `TravelDist_V`/`Traveldist_N`.
   **Hersteld** (8982a43, 6fe61d3). Daarna bleek dat een null in een samengestelde regel de hele regel leeg maakte, waardoor alle directe autoritten verdwenen; de numerieke kolommen schrijven nu een leeg veld. Gemeten op de uitvoer voor 07:00: 39,1 M regels, alle met 17 velden.

7. **MinimiseCriteria hoofdlettergevoelig** [V]. `'Price_Augm'` uit de Descr viel stil terug op Price.
   **Hersteld** (27b2983). De match gebruikt `lowercase` aan beide kanten.

8. **Bestemmingsselectoren** [V]. `Destset_EnkeleProv_Selection` en `Destset_EnkeleCorop_Selection` werden nergens gebruikt; de bestemmingen `Buurt_enkele_Prov/Corop` namen de herkomstselectie.
   **Hersteld** (27b2983). Eigen sets `Enkele_Prov_dest` en `Enkele_Corop_dest` (Twente: 537 buurten); het gekozen gebied staat in `OrgSet_string` en `DestSet_string`, zodat twee selecties geen store of uitvoerbestand delen.

9. **Latent: `LinkSet/IsSlowTrafficRoad` in het TomTom-net** [V].
   **Hersteld** (27b2983). De twee attributen die de nooit aangezette lagere penalty voor knopen met alleen langzame wegen voorbereidden, vervallen; het commentaar zegt waarom.

### Niet of half toegepast [A]

Deze ongenummerde punten van de oorspronkelijke audit (dode parameters, slapende fietstypen, hardcoded waarden, ExportSettings, tegenstrijdige Descr-teksten) zijn niet in deze ronde behandeld, op twee na: de presets mengen niet langer stil een feed met andere jaren, want de naam van de ketenstore draagt de feeddatum en de bestemmingsset de datum van de knooppunten; en `IsSlowTrafficRoad <= 30` in het TomTom-net is weg (3.9).

## 4. Netwerkgeneratie: TomTom, OSM, Fietstelweek, Fietsersbond

### TomTom (auto)

1. **Freeflow-snelheid via een verkeerde sleutel** [V]. Voor freeflow, weekday, weekend en week is `SP_<moment>` een snelheid, maar werd hij als profiel-id opgezocht; elke link kreeg de factor van een willekeurig ander profiel (gemiddeld 0,90).
   **Hersteld** (f0a354e).

2. **Richting van het speedprofiel genegeerd** [V]. Beide richtingen kregen de eerste rij; de bron heeft per wegelement een rij per richting (`VAL_DIR`).
   **Hersteld** (37e5f4e). `VAL_DIR` staat in de Speednetworks-store; elke rijrichting krijgt zijn eigen rij, en een tweerichtingsweg wordt twee gerichte links. 74% van de wegen in de selectie is tweerichting met een rij per richting.

3. **rel_sp op MultiNet-MINUTES** [was S, nu V]. De MultiNet-snelheid ligt op 64% van de links hoger dan `SPFREEFLOW`.
   **Hersteld** (37e5f4e). De spitssnelheid is `SPFREEFLOW` maal de relatieve profielsnelheid. Gemiddelde linksnelheid op de wegselectie, voor en na (dinsdag): freeflow 35,4 en 33,7, ochtendspits 35,6 en 31,7, middagspits 35,8 en 31,8, avondspits 36,5 en 32,4 km/u; freeflow is op 99,9% van de links het snelste moment.

4. **Wegselectie** [V]. FRC 8 viel weg, ook 259 van de 759 veerelementen; FRC -1 viel via een overloop weg; geen filter op FEATTYP; de Texel-hack kon een afgesloten weg berijdbaar maken; railferries niet meegenomen.
   **Hersteld en toegelicht** (2ca5bef). De selectie neemt nu expliciet alleen wegelementen (FEATTYP 4110) en veerverbindingen (4130); FRC -1 blijkt precies de 375 adresgebiedgrenzen (4165) te zijn. De 259 veren met FRC 8 zijn allemaal gesloten voor auto's (`ONEWAY = 'N'`), net als 308 van de overige 500: het autonet houdt terecht 192 autoveren. De Texel-hack maakt een voor auto's gesloten weg niet meer tweerichting (in editie 2025.12 ligt er geen in de polygoon, dus de uitkomst verandert niet). Railferries (FerryType 2) komen in de NL+BE-levering niet voor.

5. **Dekking en fallback** [A]. 83% van de wegen heeft een speedprofiel; dubbele NW_ID's; alleen NL en BE.
   **Hersteld en toegelicht** (2ca5bef, 37e5f4e). De 4.078 dubbele NW_ID's staan in zowel het Nederlandse als het Belgische bestand en zijn exact gelijk; ze gaven een dubbele link en daardoor een kruispuntpenalty op een gewoon wegpunt. Elk NW_ID telt nu een keer: de wegselectie gaat van 3.800.841 naar 3.796.881 elementen. Zonder speedprofiel geldt de MultiNet-reistijd (sinds 4.3). Dat TomTom alleen Nederland en Belgie dekt is een grens van de levering; de autostores dragen `CarNetwork_Revision` (`_r2`).

6. **Vijf argumenten voor een template met vier parameters** [V].
   **Hersteld** (27b2983). Het vijfde argument verving het item `root`.

### OSM (auto, fiets, lopen)

7. **OSM-auto 130 km/u in de spits en op de koppellinks** [V]. **Hersteld** met 3.3 (1f0440f).

8. **Onbekende fclass wordt connectlink, ook voor de auto** [V]. `track_grade1` tot en met 5, `busway` en `unknown` stonden niet in de wegtypetabel: 620.107 features (8,3%), 197.104 km.
   **Hersteld** (828b4f1). Eigen rijen: tracks niet in het autonet, grade 1 en 2 fietsbaar, grade 3 tot en met 5 alleen lopen; busway en unknown alleen lopen; een onbekende fclass wordt voortaan `unknown` en `Read_Roads_shp/NrUnmappedFclass` telt ze. Autonet 23.962.408 naar 19.545.142 links, fietsnet 31.341.474 naar 28.646.765, loopnet gelijk.

9. **Eenrichting 'T' niet omgedraaid** [V]. 512 wegen (53 km) waren alleen tegen de rijrichting in berijdbaar.
   **Hersteld** (828b4f1). De punten van een 'T'-weg worden bij het inlezen omgekeerd. Fiets- en loopnet blijven tweerichting, omdat de shapefile niet zegt of fietsers zijn uitgezonderd.

10. **maxspeed-regels** [V]. Het 90e percentiel per wegtype werd over alle wegen genomen, inclusief de 75% zonder tag.
    **Hersteld** (2ca5bef). Het kwantiel gaat over de getagde wegen en is de mediaan (`Advanced/OSM_MaxSpeedQuantile` 0,5). Het 90e percentiel van de getagde wegen zou ongetagde servicewegen 50 km/u geven (6% getagd, de snellere); de mediaan geeft service- en woonstraten 30, living streets 15, tertiaire wegen 50. OSM-store `_r3`: gemiddelde maxspeed van de autolinks 41,0 naar 40,4 km/u, aandeel op 30 km/u 49% naar 60%.

11. **Handmatige verbindingen** [V]. Twee lege reeksen als rij zonder punten, veren op 50 km/u, eindpunten aan het dichtstbijzijnde segment op elke afstand; buiten de handmatige links geen veren voor lopen en fietsen.
    **Hersteld en toegelicht** (2ca5bef). Lege reeksen weg (de rij zonder wegtype in de store is weg); veren op `Ferry_Speed` 25 km/u; een verbinding doet alleen mee als beide eindpunten binnen `Advanced/ExtraLink_MaxSnapDistance` (250 m) van het wegennet liggen. De Nederlandse liggen binnen 131 m; de bootverbindingen naar Neuwerk en de Noord-Friese eilanden, buiten de OSM-regio's, lagen op meer dan 1 km en vallen af (6 van 306). De IJ-veren zitten in de handmatige verbindingen; Vlissingen-Breskens niet.

12. **Regio's** [V]. Arnsberg en Detmold (rest van Noordrijn-Westfalen) ontbreken.
    **Toegelicht, geen wijziging.** Geen van beide grenst aan Nederland; voor ritten tussen Nederlandse herkomsten en OV-knooppunten, binnen 90 minuten, zijn ze niet nodig.

### Fietstelweek

13. **Koppeling** [A]. Alleen fietslinks, `connect_info` binnen 8 m, gemiddelde per link.
    **Toegelicht, geen wijziging.** De methode is verdedigbaar; na 4.14 heeft 8,6% van de fietslinks een gemeten snelheid (2,45 M van 28,6 M).

14. **Imputaties als metingen** [A/S]. Bij alle 1,68 M links met `INTENS_MEE = 0` is `SNEL_ABS` 8, 10 of 12 km/u, en dat werd als meting gebruikt.
    **Hersteld** (2ca5bef). Alleen links met gemeten ritten: gekoppelde OSM-links 4,93 M naar 2,45 M, gemiddelde snelheid 12,3 naar 15,8 km/u.

15. **Toepassing** [V]. De gemeten snelheid zit alleen in de fietsmatrices; voor- en natransport en de directe fietsrit rijden altijd 14 km/u; data 2015-2017.
    **Toegelicht, geen wijziging.** Dat is een ontwerpkeuze (de gemeten snelheid dekt 8,6% van de links); de wiki zegt het nu zo.

### Fietsersbond en NDW

Ongewijzigd: de Fietsersbond-lezer is nergens aangesloten, NDW heeft geen data en geen afnemer.

## 5. Connectiviteitstoets, OD-koppeling en clean-up

Ongewijzigd ten opzichte van de audit, op drie punten na:
- **Kruispuntpenalty dubbel** [V]. **Hersteld** (37e5f4e): elke link krijgt de helft van de penalty van zijn begin- en eindknoop (een kruising kost 5 s in plaats van 10), en de knoopgraad telt alleen weglinks, niet de OD-koppellinks en niet de omgekeerde kopie van een tweerichtingsweg. `Car_TurnCosts_PerPenaltyMinute` ging van 0,30 naar 0,60 euro, zodat een kruispunt evenveel optrekkosten houdt.
- **TomTom: 4.078 dubbele wegrecords** verhoogden de knoopgraad. **Hersteld** met 4.5.
- De lege rij in de OSM-store (null-eindpunt, null-wegtype) is weg met 4.11.

Open blijven onder meer: connectiviteit in de OSM-store over alle modaliteiten samen, OD-koppeling zonder maximale afstand, en de stille verschillen tussen het TomTom- en het OSM-autonet.

## 6. Pareto-dominantie

De vier handgeschreven vergelijkers zijn vervangen door `pareto_optimal_eps` (5831c8e): met epsilon 0 selecteert die op het eerste haltenblok exact dezelfde ketens, in 166 in plaats van 251 seconden; met epsilon 10 ct en 60 s dunt hij de ketenrijging uit. De directe autorit is een (reistijd, kosten)-front per HB-paar met zoek-epsilon 10 ct (#1282). Open: 6.1 (de ketenrijger snoeit op Price_augm, het eindfront op Price), 6.2 tot en met 6.4, 6.5 (de merge-keten over blokken en vertrekmomenten), 6.6 en 6.7, zoals in de audit beschreven.

## 7. Consistentie met de toegewezen issues

Ongewijzigd ten opzichte van de audit. #88 (afstand als criterium) is nog niet gebouwd; de afstand staat wel in de uitvoer.

## 8. Reparaties na de audit

| wat | commits |
|---|---|
| 3.1, 3.2, 3.3/4.7, plafond overdag | 1f0440f |
| 3.4 naam van de ketenstore | debb335 |
| 3.5 dienstdagen en datumcontroles, knooppunten per dag D | a3600bc |
| 3.6 exportkolommen, lege velden | 8982a43, 6fe61d3 |
| 3.7, 3.8, 3.9, 4.6 | 27b2983 |
| 4.1 freeflow | f0a354e |
| 4.2, 4.3, 5 | 37e5f4e |
| 4.4, 4.5, 4.10, 4.11, 4.14 | 2ca5bef |
| 4.8, 4.9 | 828b4f1 |
| datum van de OV-knooppunten in de bestemmingsset | 050b49a |
| pareto_optimal_eps in de ketenrijging | 5831c8e |
| configpad van UpdateAll, pad van de ketenstore, kostentag, subset | 19afe9a, 62ebbae, bda1a38, eba4c0c |
| UpdateAll als geplande taak | 60009c4 |
| GTFS-feeds 20250930, 20260615, 20260925 | d27f1e8 (en deze sessie) |

**Storenamen en revisies.** Elke store draagt nu de instellingen waar zijn inhoud van afhangt, en een revisie voor codewijzigingen:
- OSM-netwerk: `Final_Network_<datum>_r3.mmd` (`OSM/StoreRevision`); `_r2` kwam met 4.8 en 4.9, `_r3` met 4.10, 4.11 en 4.14.
- Autostores: `..._DEST-ov_knooppunten_<Analysis_date>..._r2.mmd` (`DestSet_DateTag`, `CarNetwork_Revision`).
- Ketenstore: `..._<Analysis_date>[_gtfs<feed>]..._dova_ov500-3750-19-5-0-35_h100-350_r2.mmd`.

Alle stores van voor deze revisies zijn achterhaald en worden onder de nieuwe namen niet meer gelezen.

## 9. Open

- 6.1 criteria per paretostap en 6.5 de merge-keten; verder 6.2 tot en met 6.4, 6.6 en 6.7.
- De ongenummerde punten van 3 ("niet of half toegepast") en de overige punten van 2, 5 en 7.
- Loopparameters voor de decay (PBL).

## 10. Nieuwe peildata

Klaargezet op 25 september 2026, elk op een dinsdag zoals 1 oktober 2024 en de congestiedag van de auto; de dienstdagcontroles van 3.5 en de controle op de DOVA-prijzen slagen:

| `Analysis_date` | `GTFS_file_date` | bron | ritten per dienstdag (D-1 tot D+1) | haltes | OV-knooppunten |
|---|---|---|---:|---:|---:|
| 20241001 | 20241001 | OVapi | 114.281-114.803 | 45.651 | 462 |
| 20250930 | 20250930 | Mobility Database `mdb-1077-202509300053` | 117.295-117.408 | 49.887 | 458 |
| 20260616 | 20260615 | OVapi-archief `NL-20260615` | 122.677-122.901 | 50.771 | 460 |
| 20261006 | 20260925 | OVapi `NL-20260925`, voorlopig | 124.955-125.113 | 50.491 | 460 |

Een feed is de geplande dienstregeling zoals bekend op de dag van publicatie, zonder vertragingen of uitval. Voor 6 oktober 2026 wordt de feed van die dag zelf gebruikt zodra hij in het OVapi-archief staat, zodat de aanlooptijd gelijk is aan die van de andere peildata. OSM (1 juni 2026), TomTom (2025.12) en de BAG-herkomsten (1 januari 2026) zijn voor alle peildata gelijk, zodat verschillen uit de dienstregeling komen.
