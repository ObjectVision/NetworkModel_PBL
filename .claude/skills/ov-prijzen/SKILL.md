---
name: ov-prijzen
description: Kennis over de OV-prijzen in NetworkModel_PBL - NS-tariefeenheden en rit-opslag (HSL, ICE), DOVA- versus Detailed-prijzen, vaste rittarieven (eilandbussen, veerboten, buitenlandse vervoerders) en hoe je tarieven controleert met 9292.nl. Gebruik bij werk aan OVprijzen.dms, FareTables, DOVA, MakeODs/ChainJoiner-prijzen of issues over OV-tarieven (#3, #55, #119).
---

# OV-prijzen in NetworkModel_PBL

## Waar de prijs vandaan komt

- **L-net (NS, sinds #3 ook NS International binnenlands):** de prijs van een NS-reis is de prijs bij de tariefeenheden (TE) van het stationspaar (eerste en laatste station van de NS-reis), uit `data/Tarieven_NS/NS tarieven <jaar>.csv` (0-200 TE, klopt exact met de NS-prijslijst). De TE komen uit de kortste route door `NS_tariefnet.csv` **zonder** de HSL-kanten `hfd-rtd` en `rlb-bdpb` (`OVprijzen/NS/Tariefnet_UitgeslotenKanten`): NS rekent over de klassieke route.
- **Rit-opslag (`Price_S`, #3):** een prijs per been die de ketenrijger los optelt, buiten het maximum van het opstaptarief en buiten het doorgaande NS-tarief. Nu voor de NS-toeslag ICE / IC direct (HSL Schiphol-Rotterdam, ICE binnenland; `ModelParameters/Advanced/RitOpslagTreinen`, bedrag per jaar in `OVprijzen/NS/RitOpslag/PerJaar`).
- **R-net:** `Price_I` (instaptarief) + `Price_O` (km-deel, plus belkosten flex). Binnen een reis met overstap binnen 35 minuten (`MaxTransferTimeForBoardingSurcharge`) neemt de ketenrijger het **maximum** van de `Price_I`'s, anders de som. Bron van de tarieven:
  - `PriceMethod` **DOVA** (standaard, 2013-2026): km-tarief per concessie en modusklasse (BTM, Rail, Ferry) uit `data/DOVA_Overzicht km-tarieven 2013-2026_edit.xlsx` (alleen rijen met `use_for_price` = 1), plus het DOVA-basistarief.
  - `PriceMethod` **Detailed** (alleen 2023-2026): `OVprijzen/FareTable_<jaar>`, per mode/vervoerder/concessie/lijn.
- **Niet gemodelleerd:** daltarief en kortingskaarten in de tijd (`NS_TariffChoice` geldt op elk tijdstip, zie #119), daluurkorting op de toeslag, 1e klas.

## Vaste rittarieven: wanneer gelden ze, ook bij DOVA? (onderzocht 2026-10-02, #55)

Een vast rittarief hangt af van de **lijn**, niet van de prijsmethode. Drie groepen:

1. **Binnen de concessie, met OV-chip/OVpay, maar een vast bedrag per rit of zone.** Het DOVA-overzicht noemt ze zelf "Flatfare", met een bedrag per jaar; in onze bewerkte xlsx staan ze op `use_for_price` = 0, zodat DOVA er nu het km-tarief op zet. **Moeten ook bij DOVA vast zijn.**
   - Eilandbussen Ameland en Terschelling (1 zone 1,95, 2 zones 3,00), Vlieland 1,95, Schiermonnikoog 2,45 (2026; DOVA-reeks vanaf 2017). Betalen met OV-chipkaart of OVpay (fryslan.qbuzz.nl/tarievenoverzicht). In de GTFS heten ze Qbuzz (2024: Arriva) lijn 1, 2, 3, 9.
   - Stadsvervoer Lelystad binnen/buiten A6 (vast t/m 2023, daarna km-tarief), Parkshuttle Rivium (vast 2016-2026).
   - Opstapper Fryslân 2,60 per rit (+4,15 aan de voordeur); staat niet in de feeds van 20241001 en 20260925.
2. **Buiten OV-chip/OVpay: los kaartje van de vervoerder.** 9292 meldt "Voor dit deel van de reis is betalen met de OV-chipkaart of OVpay niet mogelijk" en "We kunnen de prijs van je reis op dit moment niet bepalen". Het DOVA-km-tarief klopt hier niet. **Vast tarief in elke prijsmethode, als los kaartje per rit** (geen 35-minutenregel).
   - Rederij Doeksen (Harlingen-Terschelling/Vlieland), Wagenborg (Holwerd-Ameland, Lauwersoog-Schiermonnikoog), Westerschelde Ferry (Vlissingen-Breskens), TESO (Den Helder-Texel; OV-chip niet op de boot), De Lijn (9292 kan de prijs niet bepalen; Ticket 60 min 3,00).
   - GVB-ponten: gratis, geen check-in (DOVA rekent nu gemiddeld 1,31).
3. **Met OV-chip/OVpay en afstandsafhankelijk: geen vast tarief.** De vaste FareTable-regels zijn hier een slechtere benadering dan DOVA.
   - VIAS: Arnhem-Zevenaar 4,72 (9292, gelijk aan de regionale trein), niet de vaste 2,79.
   - DB RB51: Enschede-Glanerbrug 3,18 (9292); DOVA-overzicht: DB-km-tarief.
   - Waterbus: in- en uitchecken, afstandstabel 1,52-6,51 (Merwekade-Erasmusbrug 5,78; waterbus.nl, OV-tarieven 2026). Het DOVA-overzicht noemt het Waterbus-tarief (0,243 in 2026) **per mijl**; het model gebruikt het als km-tarief. Omrekenen helpt niet: Merwekade-Erasmusbrug (~21,5 km) wordt per km 6,38, per mijl 4,41, en de Waterbus vraagt 5,78. Gebruik de afstandstabel van de Waterbus (of een km-tarief van ongeveer 0,21).

Implementatievoorstel (#55): een vast tarief als `Price_S` per been (`Price_I` = 0), de ketenrijger telt `Price_S` in elke keten op, en na een been van groep 2 loopt een OV-chipreis niet door. Geen extra letter per variant (30 -> 120 ketentypen). Bronnen per lijn: groep 1 uit de DOVA-rijen (per jaar), groep 2 uit de vervoerders.

## Bekende valkuilen

- **FareTable-match (Detailed):** de zoekvolgorde in `OD_extra_attributen` (`FareTable_rel_augmented*`) valt bij een concessie zonder algemene regel terug op de eerste regel van vervoerder en concessie, ook een lijnregel (2024: 24 Bravo (Arriva)-lijnen in West-Brabant kregen 3,50 van lijn 820). De stap op alleen vervoerder (`augmented2`) matcht nooit: de sleutel van een regel zonder concessie eindigt op `__`.
- **Lijnnamen:** FareTable-regels zoeken op `route_short_name`. Eilandbussen ("Ameland 1 zone"), Vlinders ("Vlinder"; in de GTFS nummers 805-881) en de Opstapper matchen daardoor nooit.
- **Venster:** het rapport telt benen in het analysevenster (07:00-ca. 09:15); nacht-, avond- en seizoenslijnen (Nightliner, Avondvlinder, Keukenhof) hebben dan 0 benen.
- **Station zonder kant in het tariefnet:** een station dat wel in `NS_stations.csv` staat maar geen kant heeft in `NS_tariefnet.csv`, heeft geen TE. Rijdt er in het venster een NS-been naar zo'n station, dan stopt de ketenstap op de IntegrityCheck van `OD_L/Price_L` (audit 6.6). Zo stopte de middag van 20261006 op Utrecht Maliebaan (pendel naar het Spoorwegmuseum, alleen overdag). Oplossing (#120): een doodlopende kant naar het station waar NS de TE vanaf rekent (`ut,utm,8`), met de TE afgeleid uit 9292-prijzen van langere ritten. Een doodlopende kant verandert de TE tussen andere stations niet. De benen zonder tarief vind je met een selectie van `OD_L` op `NOT(NS_Station_Price_IntegrityCheck)`.

## Controleren met 9292.nl

Zie de skill `model-validatie`: hoe je 9292 invult (Akkoord, Van/Naar, datum en tijd in UTC in de URL), wat de 9292-prijs wel en niet bevat (2e klas vol tarief; toeslagen alleen als melding) en de tabel met bevestigde ritten. Bevestigd op 9292 (2026-10-02): eilandbus Ameland Nes Veerhaven - Hollum 3,00 (2 zones, OV-chip); Waterbus 20 Merwekade - Erasmusbrug 5,78 (OV-chip, afstandstabel).

## Rapporten

- `/RitOpslagReport/Report`, `/Net/Report`, `/Keten/Report`: TE-steekproef tegen NS, treinroutes en binnenlandse bruikbaarheid, benen met rit-opslag, ketenprijs. Uitvoer `%LocalDataProjDir%/Output/ritopslag_*`.
- Draai GeoDmsRun vanuit PowerShell (Git Bash verminkt `/L...` en itempaden), met de engine-kopie in `C:\LocalData\GeoDMS_engine\...`, niet met `C:\dev\GeoDMS_2026\bin\Release\x64` (daar wordt gebouwd). Wil je met andere `ModelParameters` testen, kopieer dan `cfg` en `data` naar een scratchmap en pas het daar aan, niet in de gedeelde werkkopie.
