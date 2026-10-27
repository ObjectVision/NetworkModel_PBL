# Descriptions before the English round of 27-10-2026

The Descr texts and comments of the configuration and the batch scripts as they were before they became one English sentence each (#133). They often hold history and measurements; this file keeps them, the code no longer does.

## cfg/main/ModelParameters.dms

- commentaar regel 1: // De syntax van deze configuratie (items, eenheden, expressies en operatoren) staat in de GeoDMS-wiki: https://github.com/ObjectVision/GeoDMS/wiki
- commentaar regel 4: // DE INSTELLINGEN VAN DE GEBRUIKER: wat een run kiest, en de aannames die PBL wil kunnen variëren.
- commentaar regel 5: // Wat volgt uit andere instellingen, met PBL is afgesproken of de techniek betreft, staat in Advanced. Bij elke aanname staat of hij
- commentaar regel 6: // alleen de uitvoer verandert, of de tussenresultaten in %LocalDataProjDir%/IntermediateResults, die het model dan opnieuw rekent.
- commentaar regel 8: // 1. WAT: peildatum, PartOfDay, herkomsten en bestemmingen, en de uitvoer
- `AnalysisMoment` (regel 9): De peildatum: een jaar uit Advanced/AnalysisMomentPresets (Y2015, Y2023, Y2024, Y2025 of Y2026), met de dag van de analyse (de tweede dinsdag van oktober, #125), de GTFS-feed, OSM, TomTom, de CBS-gebiedsindeling en de BAG.
- `PartOfDay` (regel 10): Het PartOfDay van de vertrekmomenten, uit Advanced/PartsOfDay (#125): 'Ochtendspits' 07:00-07:45, 'Middag' 12:00-12:45 of 'Avond' 19:00-19:45, elk vier momenten per kwartier. Bepaalt ook het congestiemoment van de directe autorit (Impl/Car_CongestionMoment_ForDirect).
- `Orgset` (regel 11): Select the origin set, defined in Advanced/org_domain_list.
- `Destset` (regel 12): Select the destination set, defined in Advanced/dest_domain_list.
- `Orgset_EnkeleBuurt_Selection` (regel 13): If you choose 'enkele_buurt' in the OrgSet, which neighbourhood would you like? Use the BU_CODE.
- `Orgset_EnkeleGem_Selection` (regel 14): If you choose 'enkele_gem' in the OrgSet, which municipality would you like? Use the municipality name.
- `Orgset_EnkeleProv_Selection` (regel 15): If you choose 'enkele_prov' in the OrgSet, which provincie would you like? Use the province name.
- `Orgset_EnkeleCorop_Selection` (regel 16): If you choose 'enkele_corop' in the OrgSet, which COROP would you like? Use the corop name.
- `Destset_Enkele_Selection` (regel 17): If you choose 'enkele_buurt' in the DestSet, which neighbourhood would you like? Use the BU_CODE.
- `Destset_EnkeleCorop_Selection` (regel 18): If you choose 'enkele_corop' in the DestSet, which COROP would you like? Use the corop name.
- `Destset_EnkeleProv_Selection` (regel 19): If you choose 'enkele_prov' in the DestSet, which province would you like? Use the province name.
- `OutputLabel` (regel 20): Korte naam van de variant (#118): de uitvoer staat in %LocalDataProjDir%/Output/<Impl/Analysis_date>_<OutputLabel>_<component> (Impl/OutputDir), met de parameters in signature.txt; een andere parameterset onder hetzelfde label stopt op die handtekening. Letters, cijfers, - en _, hoogstens 20 tekens.
- `OutputFormat` (regel 21): Het formaat van de OV-uitvoer per blok en vertrekmoment: 'parquet' (getypt, zstd, per soort component alleen de variërende kolommen, Impl/ExportClass) of 'csv' (alle kolommen). De tellingen per blok zijn altijd csv; het samenvoegen leest de parquet van de Components en schrijft in dit formaat.
- `Export_TravelledDistance` (regel 24): Would you like to export the travelled distance along with the other attributes in the case of private and public transport?
- `Export_PriceInformation` (regel 25): Exporteert de OV-uitvoer ook de prijs, uitgesplitst naar PreTransport, OV en PostTransport (PretransPrice, PTPrice, PosttransPrice) en per modaliteit (WalkingPrice, CyclingPrice, CarPrice)?
- commentaar regel 27: // 2. DE COMPONENT VAN DEZE RUN (#117): een
- commentaar regel 28: // directe rit, WW, CC of Car, of een OV-reis, PT, met een PreTransport en een PostTransport. De directe ritten zijn aparte
- commentaar regel 29: // Components, want ze gaan anders om met sommige Pareto-attributen en met het front (de auto houdt per HB-paar meer routes).
- commentaar regel 30: // Elke component heeft een eigen uitvoermap; samenvoegen doet een run met MergeOutput (hieronder). Alle combinaties staan in
- commentaar regel 31: // Advanced/Components.
- `Component` (regel 32): Wat deze run rekent: 'WW' (de directe looprit), 'CC' (de directe fietsrit), 'Car' (de directe autorit, met starten en parkeren) of 'PT' (een OV-reis: PreTransport + OV + PostTransport). De naam van de component (Impl/ComponentName) staat achter het label in de uitvoermap (#117, #118).
- `PreTransport` (regel 33): Het PreTransport van de OV-reis (Component 'PT'): een van Advanced/PreTransportTypes; de alternatieven staan als commentaar eronder.
- commentaar regel 34: // /Classifications/TimeInvariantTypes/V/Org2Stops_Cycling      // C: fietsen naar elke halte
- commentaar regel 35: // /Classifications/TimeInvariantTypes/V/Org2RM_Stops_Cycling   // C_RM: fietsen naar een trein- of metrohalte
- commentaar regel 36: // /Classifications/TimeInvariantTypes/V/Org2RMT_Stops_Cycling  // C_RMT: fietsen naar een trein-, metro- of tramhalte
- commentaar regel 37: // /Classifications/TimeInvariantTypes/V/Org2Ric_Stops_Cycling  // C_Ric: fietsen naar een IC-station
- `PostTransport` (regel 40): Het PostTransport van de OV-reis (Component 'PT'): een van Advanced/PostTransportTypes. Alleen de OV-fiets (OVf_C) wordt gehuurd; bij de andere fietsnatransporten staat een eigen fiets bij de laatste halte (PostTransport_Cycling_Time_Costs).
- commentaar regel 41: // /Classifications/TimeInvariantTypes/V/Stops2Dest_Cycling     // C: fietsen van elke halte
- commentaar regel 42: // /Classifications/TimeInvariantTypes/V/RM_Stops2Dest_Cycling  // RM_C: fietsen van een trein- of metrohalte
- commentaar regel 43: // /Classifications/TimeInvariantTypes/V/RMT_Stops2Dest_Cycling // RMT_C: fietsen van een trein-, metro- of tramhalte
- commentaar regel 44: // /Classifications/TimeInvariantTypes/V/OVF_Stops2Dest_Cycling // OVf_C: de OV-fiets, alleen van een halte bij een OV-fietslocatie
- commentaar regel 48: // 3. SAMENVOEGEN van Components tot een front (MergeOutput, NetworkSetup/ComponentMerge)
- `MergeOutput` (regel 49): Voegt deze run, in plaats van te rekenen, de uitvoer van de Components in MergeComponents samen tot een Pareto-front op MergeCriteria (NetworkSetup/ComponentMerge)? Uitvoer in Output/<Impl/Analysis_date>_<OutputLabel>_Merged<MergeRunNr>; Component, PreTransport en PostTransport tellen dan niet.
- `MergeComponents` (regel 50): De Components die MergeOutput samenvoegt, gescheiden door komma's, uit Advanced/Components/name; de standaard geeft de opties van de levering van 2023 (#117). Hun uitvoer moet er zijn, met hetzelfde OutputLabel, dezelfde peildatum, hetzelfde PartOfDay en dezelfde herkomsten en bestemmingen.
- `MergeRunNr` (regel 51): Het nummer van de samenvoeging in de naam van de uitvoermap (_Merged<MergeRunNr>); de samengevoegde Components staan in signature.txt. Geef een andere set MergeComponents of MergeCriteria een ander nummer: onder hetzelfde nummer stopt de run op de handtekening.
- `MergeCriteria` (regel 52): De criteria van het samenvoegen: Price of Price_Augm, Time, Car (NeedsCar) en Bike (NeedsBike). Een duurdere optie blijft alleen als ze meer dan ChainParetoTimeEpsilon sneller is; zonder Car en Bike kan een optie met auto of fiets er een zonder verdringen, en 'Time' of 'Price' alleen geeft een optie per paar.
- commentaar regel 54: // 4. AANNAMES DIE ALLEEN DE UITVOER VERANDEREN: de tussenresultaten blijven geldig
- `MaxTravelTime` (regel 55): Maximum travel time of the complete journey. Only relevant for public transport analysis. Note that limiting this value might result in not being able to reach all destinations.
- `MaxWalkingTime_Org2Dest` (regel 56): Maximum walking time from origin towards destination
- `MaxCyclingTime_Org2Dest` (regel 57): Maximum cycling time from origin towards destination
- `PreTransport_Walking_Time_Costs` (regel 58): To attach a value to walking, the cost thereof (or the time it takes) is incorporated. This is a mechanism to ensure when looking for the cheapest journey the model won't let you walk as much as possible.
- `PostTransport_Walking_Time_Costs` (regel 59): To attach a value to walking, the cost thereof (or the time it takes) is incorporated. This is a mechanism to ensure when looking for the cheapest journey the model won't let you walk as much as possible.
- `Direct_Walking_Time_Costs` (regel 60): To attach a value to walking, the cost thereof (or the time it takes) is incorporated. This is a mechanism to ensure when looking for the cheapest journey the model won't let you walk as much as possible.
- `Direct_Cycling_Time_Costs` (regel 61): To attach a value to cycling, the cost thereof (or the time it takes) is incorporated. This is a mechanism to ensure when looking for the cheapest journey the model won't let you cycle as much as possible.
- `PreTransport_Cycling_Time_Costs` (regel 62): To attach a value to cycling, the cost thereof (or the time it takes) is incorporated. This is a mechanism to ensure when looking for the cheapest journey the model won't let you cycle as much as possible.
- `PostTransport_Cycling_Time_Costs` (regel 63): De kosten van fietsen in het PostTransport (C, RM_C, RMT_C): een eigen fiets bij de laatste halte, met dezelfde kosten als de eigen fiets in het PreTransport. De OV-fiets (OVf_C) kost OVFiets_RentalPrice.
- `OVFiets_RentalPrice` (regel 64): Prijs voor de huur van de fiets voor de eerste 24u. 2023=4.45 euro
- `Car_CostPerKm` (regel 65): Autokosten per km (#88): de prijs van de directe autorit is zijn afstand maal Car_CostPerKm, plus Car_FixedCosts_PerTrip.
- `Car_FixedCosts_PerTrip` (regel 66): Vast bedrag per autorit, bijvoorbeeld parkeren; 0 tot daar een waarde voor is.
- `Car_StartTime` (regel 67): Starttijd van een autorit: naar de auto lopen, instappen, wegrijden. Opgeteld bij de reistijd van de directe autorit in het front. Eerste aanname, door PBL te zetten.
- `Car_ParkingTime` (regel 68): Parkeertijd aan het eind van een autorit: parkeerplek zoeken en naar de bestemming lopen. Opgeteld bij de reistijd van de directe autorit in het front. Eerste aanname, door PBL te zetten.
- commentaar regel 69: // HET AUTOFRONT (#88). De directe autorit is per HB-paar een Pareto-front op reistijd en afstand
- commentaar regel 70: // (Advanced/ParetoLegs_Car: impedance_matrix_od64 met de pareto-optie, de afstand als alternatieve impedantie), en
- commentaar regel 71: // de kosten volgen achteraf: afstand x Car_CostPerKm + Car_FixedCosts_PerTrip. Met een prijs per km is dat front
- commentaar regel 72: // ook het front op reistijd en kosten.
- commentaar regel 74: // 5. AANNAMES DIE TUSSENRESULTATEN OPNIEUW LATEN REKENEN; hun handtekening noemt ze, zodat het model een store met andere waarden niet leest
- commentaar regel 75: // de benen (batch/UpdateAll.cmd legs, ongeveer 10 minuten per peildatum en buurtset)
- `MaxWalkingTime_Org2Stops` (regel 76): Maximum walking time from origin towards first stop
- `MaxWalkingTime_Stops2Dest` (regel 77): Maximum walking time from last stop towards destination
- `MaxCyclingTime_Org2Stops` (regel 78): Maximum cycling time from origin towards first stop
- `MaxCyclingTime_Org2RMT_Stops` (regel 79): Maximum cycling time from origin towards first rail, metro, or tram stop
- `MaxCyclingTime_Org2RM_Stops` (regel 80): Maximum cycling time from origin towards first rail or metro stop (RM_Stops: haltes met Mode Rail of Metro in de GTFS)
- `MaxCyclingTime_Org2Ric_Stops` (regel 81): Maximum cycling time from origin towards first InterCity train station
- `MaxCyclingTime_Stops2Dest` (regel 82): Maximum cycling time from origin towards first stop
- `MaxCyclingTime_OVF_Stops2Dest` (regel 83): Maximum cycling time from last stop which is an OV-fiets station towards destination
- `MaxCyclingTime_RMT_Stops2Dest` (regel 84): Maximum cycling time from last stop which is a RMT station towards destination
- `MaxCyclingTime_RM_Stops2Dest` (regel 85): Maximum cycling time from last stop which is a rail or metro stop (RM_Stops) towards destination (PostTransport RM_C)
- commentaar regel 88: // de ketenstore (batch/UpdateAll.cmd chains, uren per PartOfDay); ook de maximale tijden van het PreTransport hierboven, en de start- en
- commentaar regel 89: // parkeertijd van de fiets: ze bepalen het langste PreTransport (Impl/PT_Max_V_Time) en daarmee het laatste instapmoment van de ketens
- `Cycling_StartTime` (regel 90): Starttijd van elke fietsrit: fiets pakken en wegrijden. Opgeteld bij de reistijd van de directe fietsrit, van elk fietsbeen in het PreTransport en van elk fietsbeen in het PostTransport. Eerste aanname, door PBL te zetten.
- `Cycling_ParkingTime_IC_Station` (regel 91): Extra parkeertijd, bovenop Cycling_PreTransport_Penalty, voor een fietsbeen in het PreTransport dat eindigt op een IC-station (PublicTransport_Prep/Impl/Ric_Stops), bij elk type fietsvoortransport (#117): grote stallingen, langer lopen naar het perron. Eerste aanname, door PBL te zetten.
- `MaxPTTime` (regel 92): Maximum travel time using public transport, including transfers and waiting. Note that limiting this value might result in not being able to reach all destinations.
- `Max_transfers` (regel 93): How many transfers are allowed?
- `Transfer_Walking_Time_Costs` (regel 94): To attach a value to walking, the cost thereof (or the time it takes) is incorporated. This is a mechanism to ensure when looking for the cheapest journey the model won't let you walk as much as possible.
- `Transfer_Waiting_Time_Costs` (regel 95): To attach a value to waiting, the cost thereof (or the time it takes) is incorporated.
- commentaar regel 96: // de autostores (batch/UpdateAll.cmd cars, uren per vertrekmoment)
- `MaxCarTime` (regel 97): Maximum travel time using car transport. Note that limiting this value might result in not being able to reach all destinations.
- `UseTomTomNetworkForCars` (regel 98): Would you like to use the TomTom network car analysis? Or if not, the OSM network is used.
- commentaar regel 100: // 6. EEN HB-PAAR (#129): met OD_Origin en OD_Destination rekent het hele model, met dezelfde stappen (batch/UpdateAll.cmd
- commentaar regel 101: // of batch/WriteODResults.ps1), alleen dat paar, en houdt het per optie de links van de route bij. Tussenresultaten staan dan in
- commentaar regel 102: // %LocalDataProjDir%/IntermediateResults_<O>_<D>, de uitvoer in Output_<O>_<D> (Impl/OD_Tag); /Output/OD_PairRoutes toont ze op kaart, in tabel
- commentaar regel 103: // en grafiek. Leeg: het generieke model, zonder links.
- `OD_Origin` (regel 104): De herkomst van het HB-paar: een naam uit Orgset, zoals OrgName in de uitvoer; bij Buurt2023 en Buurt2025 de CBS-buurtcode, bijvoorbeeld 'BU04020501' (Schilderskwartier, Hilversum, met Laapersweg 1). Leeg = alle herkomsten. Alleen met OD_Destination.
- `OD_Destination` (regel 105): De bestemming van het HB-paar: een naam uit Destset, zoals DestName in de uitvoer, bijvoorbeeld 'BU0363KP03' (VU-kwartier, Amsterdam, met De Boelelaan 1085). Leeg = alle bestemmingen. Alleen met OD_Origin.
- `OD_DepartureTime` (regel 106): Alleen met een HB-paar: een vertrekmoment van PartOfDay als uu:mm, bijvoorbeeld '07:30'; leeg = de vier vertrekmomenten van het PartOfDay. Geldt voor elke component, ook de directe ritten (Impl/SingleDepartureMoment) en de tijdafhankelijke autorit.
- `OD_Option` (regel 107): De optie die de kaart van /Output/OD_PairRoutes apart toont (Kaart/Optie): het nummer in Opties, vanaf 1; 0 = alle opties.

## cfg/main/ModelParameters/Advanced.dms

- `MinimiseCriteria` (regel 6): De criteria van het front van een component: 'Price', 'Price_Augm', 'Time' of een combinatie, zoals 'Price,Time' (#117). 'Car' en 'Bike' maken auto- en fietsbezit criteria van de eindafweging per vertrekmoment, niet van de ketenrijger; voor de Components horen die bij MergeCriteria. Staat in de handtekening van de ketenstore.
- `CentroidWeightType` (regel 7): If you want to use weighted centroids for origins, how would you like to weigh the values comprsing the coentroid? Via addresses or population?
- `MaxWalkingTime_Org2RMT_Stops` (regel 10): Maximum walking time from origin towards first rail, metro, or tram stop
- `MaxWalkingTime_Org2RM_Stops` (regel 11): Maximum walking time from origin towards first rail or metro stop (RM_Stops: haltes met Mode Rail of Metro in de GTFS)
- `MaxWalkingTime_Org2Ric_Stops` (regel 12): Maximum walking time from origin towards first InterCity train station
- `MaxWalkingTime_OVF_Stops2Dest` (regel 13): Maximum walking time from last stop which is an OV-fiets station towards destination
- `MaxWalkingTime_RMT_Stops2Dest` (regel 14): Maximum walking time from last stop which is a RMT station towards destination
- `MaxWalkingTime_RM_Stops2Dest` (regel 15): Maximum walking time from last stop which is a rail or metro stop (RM_Stops) towards destination
- `Buurtsets` (regel 23): De buurtvarianten (#126). Kies er een als Orgset en Destset (org_domain_list, dest_domain_list): dan gelden zijn RegioIndelingen_year en BAG_snapshot, welke peildatum ook gekozen is.
- `Dests_geclusterd` (regel 30): Would you like to cluster destinations? For example useful for firm destinations, with many firms at the same location. To determine the area of clustering look at Dest_location_scale
- `Dest_location_scale` (regel 31): If clustering the destination, at which scale would you like to cluster? Options: '100m', '500m', '1000m', '5000m', '10000m', '50000m'
- `Org_location_scale` (regel 32): Celmaat waarop de BAG-herkomsten geclusterd worden (BAG_woonpanden_Clustered).\nOpties zijn de celmaten uit Geography/Gridsizes: '25m', '100m', '500m', '1000m', '5000m', '10000m', '50000m'.\nStond tot 2026-09-22 vast aan Dest_location_scale; op 100m levert de BAG-snapshot van 1-1-2026 588.903 herkomsten, wat de blokindeling en de OD-omvang onwerkbaar maakt.\nLosgekoppeld omdat de bestemmingen hun eigen maat mogen houden.
- `ExcludeOrgBuurtCentroidsWithoutAddressPop` (regel 36): Would yo like to exclude buurt centroid that do not contain addresses or population (depending on CentroidWeightType).
- `MaxPathLength` (regel 37): Het langste bestandspad dat Windows zonder longPathAware toestaat; GeoDMS vraagt geen lange paden aan. Elke storefamilie controleert er vooraf op (Templates/StoreSignature_T/PathGate), zodat een te lang pad faalt voordat er gerekend wordt (NetworkModel_PBL#118).
- `MakeMedian` (regel 39): Schrijft de uitvoerstap per blok ook de mediaan per HB-paar over de vertrekmomenten (Mediaan/tt_<datum>_mediaan_<n>of<N>)? Dat is de mediaan van de goedkoopste optie per vertrekmoment (laagste Price, bij gelijke prijs de snelste). Standaard niet: de medianen worden niet opgeleverd.
- `NumberOfItersForNetworkCleanUp` (regel 55): In the network clean up method, how many iternations should be used?
- `NS_TariffChoice` (regel 58): Which tarif class for NS would you like to use. Full fare, or a discounted fare? Choices: 'Price_FullFare', 'Price_20pct_Discount' of 'Price_40pct_Discount'.
- `MaxTransferDist` (regel 59): Maximum Euclidean distance between public transport stops that is allowed to be walked for transfers.
- `Concessiegebied_source` (regel 60): Use manual creation of concessiegebieden (based on CROW poster), or shapefile from CROW. Options:  manual, shape
- `PriceMethod` (regel 61): OV-prijsmethode: 'Detailed' (handmatige FareTable per Mode/Agency/Concessie/Lijn, zie OVprijzen/FareTable_2023) of 'DOVA' (concessie-brede km-tarieven uit DOVA-overzicht, terug tot 2013). Bij 'DOVA' bepaalt Impl/FareTable_year welk jaar (2013-2026) wordt gebruikt.
- `DistanceTrainStationsSelection` (regel 62): To find out which GTFS-stops relate to which trainstation a geographic search distance is used.
- `DistanceStopClusters` (regel 63): To cluster stops which belong to the same 'stop' a geographic search distance is used. Stops in opposite directions should be considered the same stop cluster. Travelling from stops within a cluster is non-sensical.
- `OVFiets_Locations` (regel 64): De bestanden met de OV-fietslocaties in %NetworkModel_dir%/Infrastructuur, per jaar (AnalysisMomentPresets/OVFiets_year): 2023 283 locaties, gegeocodeerd door Object Vision; 2025 de lijst van PBL van 13-10-2026, 293 locaties, gegeocodeerd met batch/OVFiets2025_Geocode.dms (kolom Bron).
- `DistanceOVFietsStops` (regel 70): Maximale zoekafstand om OVfiets stations te koppelen aan GTFS haltes.
- `DistanceKnooppuntClusters` (regel 71): Clusterafstand om GTFS-haltes samen te voegen tot een OV-knooppunt (single linkage via connected_parts). Perrons/haltekommen van hetzelfde knooppunt vallen zo samen.
- `Knooppunt_MinLijnen_BTM` (regel 72): Minimaal aantal unieke bus/tram/metro-lijnen op een haltecluster om als BTM-knooppunt te gelden (kruisende lijnen). Treinstations zijn altijd knooppunt; een solitaire metrohalte niet (die telt via de BTM-lijnen mee). Bij 8 lijnen ca. 270 BTM-knopen excl. metro (GTFS 20260316), schaal TBOV-actieagenda (~700 knooppunten totaal); bij 5 lijnen ca. 780.
- `Knooppunt_MinVertrekken_BTM` (regel 73): Minimaal aantal bus+tram+metro-vertrekken per dag (Impl/Analysis_date) op een haltecluster om als BTM-knooppunt te gelden. 150/dag komt overeen met ca. 8-10 vertrekken/uur overdag.
- `Knooppunt_BedrijfsurenPerDag` (regel 74): Aantal bedrijfsuren per dag waarmee vertrekken/dag wordt omgerekend naar frequentie/uur, t.b.v. de ontsluitingswaarde (vlindermodel).
- `Knooppunt_DominantieRadius` (regel 75): Niet verhogen naar 2000m: dan valt o.a. busstation Drachten weg onder een sterkere kandidaat-halte in de buurt. Dominantiefilter (competitie, vgl. Goudappel 2024): een BTM-knooppunt vervalt als binnen deze straal een kandidaat met hogere netwerkwaarde ligt. Voorkomt reeksen knopen langs HOV-corridors (Zuidas, Uithoflijn), meerdere punten per groot complex (Schiphol) en corridorhaltes zonder eigen regiofunctie naast een station (Anderlechtlaan bij Station Zuid, De Hoek bij Hoofddorp). Een sterke BTM-knoop naast een zwak station blijft gewoon staan (Zoetermeer Centrum West naast Zoetermeer station); treinstations zelf vervallen nooit onder BTM-knopen.
- `Knooppunt_DedupRadiusTrein` (regel 76): Twee treinclusters binnen deze straal (bv. NS-perrons en stadshaltes van hetzelfde station die net buiten de clusterafstand vallen, zoals Sloterdijk) worden ontdubbeld: het cluster met de meeste treinvertrekken blijft. Kortste afstand tussen twee echte NL-stations is ca. 800m, dus 400m is veilig.
- `Knooppunt_MinRichtingen_BTM` (regel 77): Minimaal aantal windrichtingen (4 sectoren: O/W/N/Z op basis van de richting naar de volgende halte) waarin BTM-vertrekken het cluster verlaten. Een corridor-bundel (R-net over een as, bv. Ilpendam) heeft er 2; een echt knooppunt met kruisende of uitwaaierende lijnen 3-4. Operationaliseert 'aantal richtingen' uit het vlindermodel.
- `Knooppunt_MinNetwerkwaarde_BTM` (regel 78): Optionele extra drempel op de netwerkwaarde (vlindermodel) voor BTM-knooppunten; 0 = uit. Ter referentie (GTFS 20260316): Amsterdam CS 3400, Station Noord 988, Zoetermeer Centrum West 501, Hoofddorp De Hoek 331, Anderlechtlaan 194, Lemmer busstation 111, Zierikzee busstation 78. Let op: een hoge drempel (bv. 500) schrapt vrijwel alle busstations in spoorloze kernen (Zierikzee, Lemmer, Drachten) - precies de knopen waarvoor deze laag is toegevoegd.
- `MaxTransferTimeForBoardingSurcharge` (regel 79): Maximale overstap tijd om binnen opstap basistarief te blijven. Dit is door Nederlands OV-prijs model bepaald. Dus niet zomaar aanpassen.
- `TransferEffectiveSpeed` (regel 80): De loopsnelheid tijdens het overstappen. X km/uur / 1.2 (correctie voor Manhattan distances) en dan geconverteerd naar meter/sec.
- `IncludeWaitingAtHomeInTravelTime` (regel 81): Wil je dat de wachttijd thuis wordt meegenomen in de totale reisduur, bij vertrektijd vanaf bepaald moment?
- `MinServiceDayTripShare` (regel 82): Minimaal aandeel ritten van elke dienstdag die het analysevenster nodig heeft, ten opzichte van de drukste dag van dezelfde weekdag in de feed. Een feed is na een paar weken onvolledig en een feestdag rijdt een zondagsdienst; verlaag dit alleen bewust.
- `MaxWaitingTimeAtOrigin` (regel 83): Maximale wachttijd thuis. Zet je dit hoog, zonder dat dit in de reistijd zit (WeighingWaitingAtOriginPreTransport = 0) dan kun je ongemerkt veel later vertrekken dan je denkt.
- `GradeSeparatedTransferPenalty` (regel 84): Does a public transport stop have a lot of vertical distance to traverse? In that case a time penalty will be given when traffering through that stop.
- `Cycling_PreTransport_Penalty` (regel 85): Parkeertijd van de fiets aan het eind van elk fietsbeen in het PreTransport (bij een halte of station), opgeteld in de OD-matrix van het been (ExtraTime_seconds).
- `IncludeFlex` (regel 95): Neemt het model het flexvervoer (Routes/IsFlex: gebiedsvervoer op afroep en belbussen) mee? FALSE = alle links (rit- en wachtlinks) van flexlijnen uit het OV-net. De OV-knooppunten tellen de flexvertrekken hoe dan ook mee.
- `FlexMinInterval` (regel 96): Minimum tijdsinterval tussen de ritten van een flexlijn: per ritpatroon (route, eerste en laatste halte, aantal haltes) blijft per blok van dit interval, vanaf 00:00 van de GTFS-dag, alleen de eerste rit in het OV-net (LoadFeeds/FlexOptions). Dunt flexlijnen die als rit per minuut zijn ingeroosterd (#116); 0 = niet dunnen.
- `FlexExtraWaitingTime` (regel 97): Extra wachttijd per instap op een flexlijn, opgeteld bij de reistijd van het been: de beltijd en de onzekerheid over het aanrijtijdstip (#116). Telt mee in de MaxPTTime-grens en maakt TravelTime een criterium van de ketenrijger (Classifications/ChainJoinerParetoAttr_Candidates/HasTimePenalty).
- `FlexCallCosts` (regel 98): Belkosten per instap op een flexlijn, opgeteld bij de prijs van het been (in Price_O, dat de ketenrijger bij elke overstap optelt; #116).
- `FlexRouteTerms` (regel 99): Zoektermen (kleine letters, regex-alternatieven) waarop een GTFS-route als flex geldt; gezocht in lowercase(route_short_name + ' ' + route_long_name). Bewust smal: 'buurtbus'/'wijkbus' (dienstregeling), 'hopper' (Spijkhopper/Maasvlaktehopper zijn gewone EBS-lijnen), 'vlinder' (Arriva-kleinbussen op dienstregeling en de plaatsnaam 'Zaandam De Vlinder') en 'taxibus i.p.v. trein' (treinvervangend) horen er NIET in; die staan als bijna-treffers in FlexNearMissTerms en /Output/FlexLines/NearMiss.
- `FlexNearMissTerms` (regel 105): Termen die op flex lijken maar (nu) niet als flex gelden; alleen voor /Output/FlexLines/NearMiss.
- `IncludeTripSurcharge` (regel 116): Telt de rit-opslag van de treinen in TripSurchargeTrains mee in de prijs, en hun ExtraTijd in de reistijd? FALSE = geen toeslag.
- `IsNSInternationalInLnet` (regel 117): Doen de treinen van NS International (Eurocity Direct, EuroCity, ICE, IC Berlijn) mee in het NS-net (L-net) voor binnenlandse reizen, met het NS-tarief en hun rit-opslag? Treinen waarop een NS-kaartje nooit geldt (Eurostar, Nightjet) vallen er toch uit: zie TrainsWithoutNSTicket, en de GTFS staat op hun NL-haltes meestal geen in- of uitstappen toe (pickup_type of drop_off_type 1). FALSE = alle NS International-treinen buiten het net.
- `TripSurchargeTrains` (regel 118): Treinproducten met een rit-opslag. Station_A en Station_B: NS-stationscodes van het traject waarover de opslag geldt; een been betaalt hem als zijn rit tussen in- en uitstappen beide stations aandoet. Leeg: elk been op het product betaalt hem. ExtraTijd: extra reistijd per instap, zoals FlexExtraWaitingTime (bijvoorbeeld voor reserveren). Het bedrag per jaar staat in SourceData/Infrastructure/OVprijzen/NS/RitOpslag; welke routes bij een product horen in TripSurchargeRouteNames.
- `TripSurchargeRouteNames` (regel 127): De route_short_name's (kleine letters, exact) waaraan een route van het L-net een product van TripSurchargeTrains herkent; zie SourceData/Infrastructure/GTFS/RelevantSelection/Routes/RitOpslag_rel. 'Intercity direct' heet zo bij NS en NS International (2024: HSN-treinen, 2025-2026: ICD-treinen), de ICE heet 'ICE International' (2024-2025) of 'ICE' (2026).
- `TrainsWithoutNSTicket` (regel 133): Treinproducten van het L-net waarop een NS-kaartje nooit geldt (alleen een eigen kaartje met reservering), op route_short_name (kleine letters, exact); hun ritten doen niet mee in het L-net (PublicTransport_Prep/Set_L, GTFS/RelevantSelection/Routes/IsZonderNSKaartje). Nodig naast pickup_type/drop_off_type: in de feed van 20241001 laten 4 van de 30 Eurostar-ritten Amsterdam-Parijs uitstappen in Rotterdam toe, met een Eurostar-kaartje.
- `IncludeWalkingCostsInPrice` (regel 139): Wil je reistijdkosten van lopen meenemen in de uiteindelijke 'te bepalen' prijs.
- `IncludeCyclingCostsInPrice` (regel 140): Wil je reistijdkosten van fietsen meenemen in de uiteindelijke 'te bepalen' prijs.
- `IncludeCarCostsInPrice` (regel 141): Telt de kostprijs van de directe autorit (Car_FixedCosts_PerTrip + afstand x Car_CostPerKm) mee in Price? Zo niet, dan is de auto in het front gratis en wint hij op prijs altijd.
- `PreTransportTypes` (regel 149): De PreTransportTypes van de OV-Components: lopen naar elke halte (W), fietsen naar elke halte (C), naar een trein- of metrohalte (C_RM), naar een trein-, metro- of tramhalte (C_RMT) of naar een IC-station (C_Ric). Namen uit Classifications/TimeInvariantTypes.
- `BlocksPerPortion` (regel 153): Herkomstblokken per GeoDmsRun in de uitvoerstap (batch/WriteOutputBlocks.ps1) van de OV-Components met dit PreTransport, dat het geheugen bepaalt: een kleinere portie houdt het geheugen lager, een grotere betaalt de opstart minder vaak. 0 = alle blokken in een portie. De omgevingsvariabele OUTPUT_BATCHSIZE gaat hier boven.
- `code` (regel 155): W, C, C_RM, C_RMT of C_Ric: zoals in ModeUsed en Impl/OV_PreTransport_Typen/ExportName.
- `PostTransportTypes` (regel 157): De PostTransportTypes van de OV-Components: lopen (W), fietsen van elke halte (C), van een trein- of metrohalte (RM_C) of van een trein-, metro- of tramhalte (RMT_C), of de OV-fiets (OVf_C), alleen van een halte bij een OV-fietslocatie (DistanceOVFietsStops). Alleen de OV-fiets huurt; bij C, RM_C en RMT_C staat een eigen fiets bij de laatste halte (PostTransport_Cycling_Time_Costs). Namen uit Classifications/TimeInvariantTypes.
- `code` (regel 162): W, C, RM_C, RMT_C of OVf_C: zoals in ModeUsed en Impl/OV_PostTransport_Typen/ExportName.
- `PT_Components` (regel 164): De OV-Components: elke combinatie van een voor- en een natransporttype, zonder directe rit.
- `NeedsBike` (regel 171): Vraagt de component een eigen fiets: fietsen in het PreTransport, of in het PostTransport behalve de OV-fiets?
- `UsesCycling` (regel 172): Rijdt de component over het fietsnet: fietsen in voor- of PostTransport, ook de OV-fiets?
- `DirectComponents` (regel 174): De directe ritten als component: WW lopen, CC fietsen, Car de auto (in ModeUsed AA), zonder OV.
- `Components` (regel 182): De Components, te kiezen met /ModelParameters/Component: de directe ritten en de OV-Components (#117). De uitvoer van 2023 is geleverd als W_PT (WW en W_PT_W samen) en C_PT (CC, C_PT_W en C_PT_OVf_C samen).
- `PreTransport` (regel 186): Het voortransporttype; bij een directe rit niet gebruikt.
- `PostTransport` (regel 187): Het natransporttype; bij een directe rit niet gebruikt.
- `WithPT` (regel 191): Doen de OV-ketens mee? Zonder OV leest de eindafweging per vertrekmoment alleen de directe ritten, en hoeft er geen ketenstore te zijn.
- `UsesCycling` (regel 192): Rijdt de component over het fietsnet van CyclingNetwork? CC, en een OV-component met fietsen in voor- of PostTransport, ook de OV-fiets; voor de component van de run gelijk aan Impl/UsesCycling.
- `OutputSuffix` (regel 193): Achter OutputLabel in de naam van de uitvoermap (Impl/OutputDir): _ en de naam van de component, met Impl/CyclingNetwork_DirTag (_fb) als de component over het fietsnet rijdt; het samenvoegen zoekt de Components zo (NetworkSetup/ComponentMerge).
- `BlocksPerPortion` (regel 194): Herkomstblokken per GeoDmsRun in de uitvoerstap: 50 bij een directe rit, bij een OV-component die van zijn PreTransport (PreTransportTypes/BlocksPerPortion).
- `SingleDepartureMoment` (regel 195): Rekent en schrijft deze component een vertrekmoment, dat van het congestiemoment van het PartOfDay (Impl/CongestionMinute; bij de ochtendspits 07:30), in plaats van vier per kwartier? Zo bij WW en CC, die niet van het vertrekmoment afhangen, en bij Car met een autostore per congestiemoment (#132). Het samenvoegen leest het ene bestand voor elk vertrekmoment.
- `SingleDepartureMoment_Eff` (regel 196): SingleDepartureMoment, behalve bij de tijdafhankelijke autorit (Impl/CarTimeDependent): dan verschillen de vertrekmomenten echt.
- `ExportClass` (regel 197): De soort kolommen van de parquet-uitvoer van de component (Impl/ExportClass): Direct (WW, CC), Car of PT. Het samenvoegen leest ze zo.
- `NeedsCar` (regel 198): Vraagt de component een auto? Alleen Car.
- `NeedsBike` (regel 199): Vraagt de component een eigen fiets? CC, en een OV-component met fietsen in voor- of PostTransport behalve de OV-fiets.
- `InMerge` (regel 200): Staat deze component in MergeComponents?
- `DirectModes` (regel 203): De directe modaliteiten die naast het OV in het front per HB-paar kunnen meedoen, met hun schakelaar. De naam is de naam van de bron onder NetworkSetup/PublicTransport_Prep/Direct.
- `abbrev` (regel 207): Letter van de modaliteit in ModeUsed (Modes/Selection/name_abbr); een directe rit heet in de uitvoer WW, CC of AA.
- `NumberOfStopBlocks` (regel 210): In the generation of the unlinked PT-network, how many stop blocks should be used in the Ketenrijger? Less means more memory usage per unit of time. Bij een HB-paar (Impl/IsOD) een blok: de haltes waar een voortransportbeen van de herkomst eindigt (PublicTransport_Prep/OD_Haltes).
- `MaxStopBlockSize` (regel 211): In the generation of the unlinked PT-network, what is maximum stop block size? Make sure that the product of this value and the NumberOfStopBlocks is sufficient to include all stops
- `NumberOfOrgBlocks` (regel 212): In the generation of PT-output files, how many origin blocks should be used? Less means more memory use, but less overhead. Bij een HB-paar (Impl/IsOD) een blok met de ene herkomst. Het product met MaxOrgBlockSize moet minstens het aantal herkomsten zijn; ChecksBeforeRunning/Check_OriginBlocks meldt welk getal nodig is.
- `MaxOrgBlockSize` (regel 213): In the generation of PT-output files, what is maximum origin block size? 200 herkomsten per blok, 33 bij een buurtvariant als Orgset (#126): 450 x 33 dekt de buurten van 2023 en 2025, zodat alle blokken gevuld zijn. Het product met NumberOfOrgBlocks moet minstens het aantal herkomsten zijn.
- `ParetoLegs_Car` (regel 221): Gebruik de pareto-optie van impedance_matrix_od64 voor de directe autorit in het front per HB-paar: per HB-paar alle (reistijd, afstand)-optimale routes in plaats van alleen de snelste. Kost meer rekentijd en geheugen dan de scalaire Dijkstra; zie CarFrontEpsilon.
- `CarLegDistanceQuantum` (regel 222): Alleen met CarFrontEpsilon 0: kwantisatie van het tweede pareto-criterium, de afstand per link, met dithering (ImpedanceMatrix_with_AltImp_pareto_T/AltImp_q), zodat de fronten op een wegennet met continue lengtes niet ontsporen. 40 m is 1 ct bij 0,24 euro per km.
- `CarFrontEpsilon` (regel 223): Relatieve epsilon van het autofront (#88, ObjectVision/GeoDMS#1282): het front loopt in volgorde van afstand, de kortste route eerst, en een langere route blijft alleen als ze meer dan deze fractie sneller is dan de snelste kortere route die blijft. De engine past de epsilon per bestemmingszone toe en zoekt exact. 0 = reistijd eerst met de gekwantiseerde afstand (CarLegDistanceQuantum).
- `CarTD_Search` (regel 224): De zoektocht van de tijdafhankelijke autorit (Impl/CarTimeDependent): 'pareto_alt' = afstand eerst, zoals de momentopname (CarFrontEpsilon), met het tijdprofiel op de reistijd (timedependent_alt, ObjectVision/GeoDMS#1304); 'scalar' = alleen de snelste route, met het tijdprofiel op het enige criterium (timedependent).
- `CarTD_WindowStart` (regel 225): Begin van het venster met tijdvakken van de tijdafhankelijke autorit, in seconden sinds 00:00: een uur voor het uur van de vertrekmomenten (06:00 bij de ochtendspits). De vertrektijd in de zoektocht telt vanaf hier.
- `CarTD_NrSlots` (regel 226): Aantal tijdvakken van de TomTom Speed Profiles (300 s) in het venster: 4 uur. Het laatste vertrekmoment plus Car_StartTime plus MaxCarTime (bij de ochtendspits 09:17) ligt er binnen; daarna zou het profiel van voren af aan beginnen.
- `CarTD_SlotDuration` (regel 227): Duur van een tijdvak van de TomTom Speed Profiles (time_slot loopt in stappen van 300 s).
- `ChainParetoTimeEpsilon` (regel 228): Relatieve epsilon op de reistijd in de eindafweging per vertrekmoment, bij het samenvoegen en, met een tijdpenalty, in de ketenrijger (ObjectVision/GeoDMS#1282): de prijs staat voorop, en een duurdere optie blijft alleen als ze meer dan deze fractie sneller is dan de snelste goedkopere optie die blijft. 0.01: 1%; 0 = exact. Op de prijs en op de resttijden van de ketenrijger is de vergelijking exact.
- `ExtraLink_MaxSnapDistance` (regel 229): Maximale afstand van een eindpunt van een handmatige verbinding (OSM/NetworkPreperation/ExtraVerbindingen) tot het wegennet; een verbinding met een verder eindpunt doet niet mee.
- `OSM_MaxSpeedQuantile` (regel 230): Kwantiel van de getagde maxspeed per wegtype en land, over de getagde wegen, voor OSM-wegen zonder bruikbare maxspeed-tag: de mediaan beschrijft een typische ongetagde weg.
- `PT_Chains_PerBlock` (regel 232): De ketenstap schrijft elk haltenblok in een eigen store (PublicTransport_Prep/StorageBlockDir_Str) en de uitvoerstap leest ze samen; FALSE: een store voor alle blokken (ChainGeneration_Single/Write). Per blok blijven de resultaten niet tot het eind in het geheugen, en een onderbroken ketenstap gaat bij het eerste ontbrekende blok verder (batch/WriteChainBlocks.ps1).
- `IFF_Overstaptijd` (regel 234): Duurt een overstap tussen twee verschillende treinhaltes (perrons) van hetzelfde NS-station minstens de overstaptijd van dat station uit de IFF-dienstregeling van NS (Infrastructure/IFF_Stations), naast de looptijd over de rechte afstand (#123)? Op hetzelfde perron en tussen trein en bus, tram of metro telt alleen de looptijd. In de handtekening van de ketenstore (_iff<datum>).
- `IFF_file_date` (regel 235): De levering van de IFF-dienstregeling van NS (%NetworkModel_Dir%/Infrastructuur/IFF/<datum>/stations.csv), voor alle peildata; de overstaptijden per station veranderen weinig.
- `UseActualCyclingSpeeds` (regel 239): In the case of cycling, would you like to use actual cycling speeds (from Fietstelweek) or a constant speed (as defined in BikingSpeed_kmhr)?
- `CongestionSpeed_DaySelection` (regel 240): Which day (or day selection) do you choose to use TomTom congenstion data from. Options: 'Weekday' 'Weekend' 'Week' 'monday' 'tuesday' 'wednesday' 'thursday' 'friday' 'saturday' 'sunday' 
- `TomTom_StreetTypeSelection` (regel 241): This setting gives to option to exclude certain roadtypes in the TomTom network. Options: 7 FuncRoadClass/V/Local_Road   8 FuncRoadClass/V/Secondary_Road Local_Road_of_Minor_Importance  Local_Road_of_High_Importance 
- `Fietstel_OSM_link_dist` (regel 242): De maximale afstand tussen OSM en FietsTelWeek data om te linken 
- `ConnectSearchDist` (regel 243): Zoek gebied voor connect_info operaties, zoals linken NDW aan NWB en NWB aan OSM, en FietsTelWeek aan OSM. Float64: connect_info op dpoint-rdc verwacht een float64 zoekafstand (kwadratisch).
- `CyclingNetwork` (regel 244): Het net van alle fietsbenen en de directe fietsrit: 'OSM' of 'Fietsersbond' (met eenrichtingsfietspaden, zonder Fietstelweek-snelheden). Standaard OSM, op verzoek van PBL: het Fietsersbond-net van 2024 krijgt geen nieuwe versies en wordt eerst met OSM vergeleken (#124). Lopen gaat altijd over OSM.
- `Fietsersbond_file_date` (regel 245): De levering van het Fietsersbond-routenetwerk (%NetworkModel_Dir%/Infrastructuur/Fietsersbond_<datum>), voor alle peildata.
- `Fietsersbond_MaxVeerpontLengte` (regel 246): Een veerpont van de Fietsersbond tot deze lengte doet mee in het fietsnet (217 van de 279 in de levering van 25-05-2025); de langere overtochten (62, 2 tot 39 km) niet: die horen bij het OV of liggen buiten bereik (#124).
- `Fietsersbond_VeerpontExtraTijd` (regel 247): Wachten en overvaren op een veerpont van de Fietsersbond, bovenop de fietstijd over zijn lengte (#124).
- `CarSpeed_kmhr` (regel 250): Alleen relevant bij OSM
- `CarSpeed_limit_kmhr` (regel 251): Bijvoorbeeld bij 100kmpu op snelwegen overdag. Alleen relevant bij OSM
- `InterpretAllRoadsAsBidirectional` (regel 255): Should car(!) roads be interpreted as bidirectional, or should the OneDirection property be guiding?
- `PT_DepartureHours` (regel 258): Het uur van de vertrekmomenten: dat van PartOfDay (#125). Meer uren in een run: nrofrows ophogen en de uren als lijst geven, bijvoorbeeld [7, 12, 19]; Impl/Car_CongestionMoment_ForDirect volgt dan nog steeds PartOfDay.
- `PT_DepartureMinutes_All` (regel 263): De minuten van de vertrekmomenten in het uur van het PartOfDay, per kwartier.
- `AnalysisMomentPresets` (regel 269): Per peildatum (AnalysisMoment) de bronnen: OSM, CBS-gebiedsindeling, TomTom, BAG-snapshot, de dag van de OV-analyse en de GTFS-feed (#125). Een jaar zonder Analysis_date of GTFS_file_date is geen peildatum en draait niet.
- `Analysis_date` (regel 308): De peildatum (yyyymmdd, #125); leeg = geen peildatum.
- `OVFiets_year` (regel 309): Het jaar van de OV-fietslocaties (Advanced/OVFiets_Locations): 2025 voor de peildata 2025 en 2026, anders 2023.
- `GTFS_file_date` (regel 310): De GTFS-feed van de peildatum (yyyymmdd, #125); leeg = (nog) geen feed.
- `PartsOfDay` (regel 315): De PartsOfDay van een peildatum (#125), te kiezen met /ModelParameters/PartOfDay: vier vertrekmomenten per kwartier vanaf DepartureHour (Impl/PT_DepartureMinutes), en het congestiemoment van de directe autorit (CongestionTimes), in het midden van dat uur.
- `MaxSpeed` (regel 400): Plafond op de autosnelheid per congestiemoment, voor TomTom en OSM; 0 = geen plafond. Overdag (06-19 uur) is de maximumsnelheid op de snelweg 100 km/u; Freeflow heeft geen plafond.
- `Junction_Penalties` (regel 405): bij het reizen over door een netwerk kun je meestal niet zonder vertraging voorbij een kruispunt komen. Daarom geven we hiervoor een penalty afhankelijk van het aantal benen van het kruispunt.
				De set met lower in de prefix, gaat erom dat je andere penalties hanteerd wanneer het kruis benen heeft waarop de snelheid relatief laag is. In dat geval zou de penalty lager kunnen zijn. 
				Neem een kruispunt in een bloemkoolwijk, dan hoef je wellicht niet voor elke zijstraat te stoppen. Nu (sept '25) staat dit op roadType <= 30kmpu (/Classifications/OSM/roadType/IsSlowTrafficRoad).
- `E_BikingSpeed_kmhr` (regel 248): (geen Descr)
- `E_BikingSpeed_actualspeed_addition_kmhr` (regel 249): (geen Descr)
- `CarDefaultSpeed` (regel 252): (geen Descr)
- `CarDefaultSpeed_low` (regel 253): (geen Descr)
- `Ferry_Speed` (regel 254): (geen Descr)
- commentaar regel 4-5: AFGESPROKEN MET PBL. Elke component rekent op prijs en tijd (#117); de criteria van het samenvoegen staan bovenaan (MergeCriteria). MinimiseCriteria staat in de handtekening van de ketenstore.
- commentaar regel 8-9: De maximale looptijd van voor- en PostTransportTypes die geen component gebruikt: geen component loopt naar of van een trein-, metro-, tram-, IC- of OV-fietshalte. Classifications/TimeInvariantTypes vraagt ze wel; gelijk aan die naar en van elke halte.
- commentaar regel 17-17: GENERAL
- commentaar regel 18-22: BUURT NAAR BUURT (#126): twee buurtvarianten, elk met de CBS-buurtgrenzen en de BAG van hetzelfde jaar, en met hetzelfde punt als herkomst en als bestemming: het zwaartepunt van de woonadressen van de buurt (SourceData/RegioIndelingen/Buurt/address_weighted_centroid; een buurt zonder woningen krijgt het midden van zijn vlak). Buurt2023 hoort bij de peildata 2015, 2023 en 2024, Buurt2025 bij 2025 en 2026; de presets van die peildata hebben dezelfde Regios en BAG_snapshot, zodat ook 'Buurt' en de BAG-herkomsten die variant volgen.
- commentaar regel 41-44: De spelling van zeven kolomnamen van de parquet-uitvoer. GeoDMS onthoudt van een naam de spelling waarin hij het eerst gelezen wordt, voor de hele configuratie (namen zijn hoofdletterongevoelig), en gdalwrite.vect schrijft die spelling als kolomnaam. Elders heten deze items Price_augm en Traveldist_... Dit bestand wordt als eerste gelezen, dus deze namen leggen de spelling van de csv-kop vast. Ze worden nergens gebruikt.
- commentaar regel 87-94: FLEXVERVOER: GEBIEDSVERVOER OP AFROEP EN BELBUSSEN (ObjectVision/NetworkModel_PBL#113, #116) Bravoflex, U-flex, SyntusFlex, FlexRRReis, Overal Flex, Texelhopper, Opstapper en belbussen staan in de GTFS-feeds als gewone lijnen met ritten, maar moeten 30-60 min vooraf geboekt worden. NeTEx heeft er geen gebiedsgeometrie voor (alleen de BISON flex-markering), dus de herkenning loopt op lijnnaam (SourceData/Infrastructure/GTFS/RelevantSelection/Routes/IsFlex). IncludeFlex = FALSE neemt geen flex mee; met FlexMinInterval, FlexExtraWaitingTime en FlexCallCosts alle drie 0 rekent het de flexritten zoals de feed ze heeft. De standaard (#116): meenemen, met 15 min, 30 min en 0,00 euro; de flextag van ketenstore en uitvoer (Impl/Flex_FileTag) is daarmee '_flex15i30w0ct'.
- commentaar regel 110-115: RIT-OPSLAG VOOR SPECIALE TREINEN EN NS INTERNATIONAL (#3) De NS-prijs van een reis volgt uit de tariefeenheden van het stationspaar (begin en eind van de NS-reis), over de klassieke route: de HSL telt voor het tarief niet mee (SourceData/Infrastructure/OVprijzen/NS/Tariefnet_UitgeslotenKanten). Wie tussen Schiphol en Rotterdam over de HSL reist (Intercity direct, Eurocity Direct) of binnenlands de ICE neemt, betaalt daarbovenop per rit een toeslag. Die hangt van de rit af, niet van het stationspaar: hij komt per NS-been bij de prijs (Price_S in PublicTransport_Prep/OD_L) en de ketenrijger telt hem los van het doorgaande NS-tarief op.
- commentaar regel 143-148: Components (#117): een component is een directe rit (WW, CC of Car) of een OV-reis <PreTransport>_PT_<PostTransport>, met een voortransporttype uit PreTransportTypes en een natransporttype uit PostTransportTypes; alle 25 combinaties bestaan. Elke component kiest op MinimiseCriteria (prijs en tijd). Samenvoegen is geen component: dat doet een run met MergeOutput, over de Components in MergeComponents, met autobezit en fietsbezit als criteria. Zo is de variant van Object Vision (lopen naar elke halte of fietsen naar trein en metro, lopen na het OV, en direct fietsen) de samenvoeging van W_PT_W, C_RM_PT_W en CC. Een e-bike is in te stellen met de fietsparameters.
- commentaar regel 216-220: PARETO-FRONT VOOR DE DIRECTE AUTORIT (#115, #88). De auto-Dijkstra levert per HB-paar EEN route, de snelste. Met de pareto-optie levert dezelfde operator per HB-paar het (reistijd, afstand)-front: de snelle snelwegroute naast de korte binnenweg. De prijs is afstand x Car_CostPerKm, dus dat is ook het (tijd, prijs)-front dat de eindafweging per HB-paar tegen OV, lopen en fietsen afweegt. Alleen de directe rit (PublicTransport_Prep/Direct/Car) gebruikt de pareto-variant; de auto-exports blijven scalair.
- commentaar regel 275-275: name, OSM date , Regios, OSM_perProv, CarCongestionSpeed_date_TomTom, BAG_snapshot, Analysis_date, GTFS_file_date, OVFiets_year
- commentaar regel 289-299: PEILDATA (#125): de tweede dinsdag van oktober. De feed van een peildatum dekt de dienstdagen D-1 tot D+1 (LoadFeeds/ServiceDays, MinServiceDayTripShare). Y2015 heeft nog geen feed en draait niet. OSM: Y2015 tot en met Y2024 rekenen met de uitsnede 20240524, Y2025 en Y2026 met 20260601. TomTom: de editie van december van het jaar: yr2023_12, yr2024_12 en yr2025_12; Y2026 voorlopig yr2025_12 en Y2015 yr2021_12 (er is geen oudere). CarCongestionSpeed_date is de map %NetworkModel_PrivDir%/TomTom/<naam>/ met de vier stores Roads, Junctions, Speednetworks en Speedprofiles.mmd, en het ruwe materiaal (multinet/, speedprofiles/) om ze te maken (TomTom/Impl/HasRawMaterial; zonder ruw materiaal zet TomTom/Impl/FromFss een oude fss om). Regios en BAG_snapshot: die van de buurtvariant van de peildatum (Advanced/Buurtsets, #126), CBS 2023 en BAG 1-1-2023 voor 2015, 2023 en 2024, CBS 2025 en BAG 1-1-2025 voor 2025 en 2026; ook de BAG-herkomsten rekenen zo. BAG_snapshot is de mapnaam onder %NetworkModel_Dir%/RegioIndelingen/BAG. Regios blijft voor Y2026 op 2025 tot CBS de buurt- en wijkkaart 2026 publiceert: daarop staan de herkomstensets en de regio-aggregaties.
- commentaar regel 459-459: Regio             , OrgSet , OrgPath, Land, Type,
- commentaar regel 482-482: Regio             , OrgSet , OrgPath, Land, Type,

## cfg/main/ModelParameters/Impl.dms

- `GTFS_file_date` (regel 5): De GTFS-feed (map en mmd-store onder %NetworkModel_Dir%/Infrastructuur/GTFS) van de peildatum, uit Advanced/AnalysisMomentPresets (#125). De feed moet de dienstdagen D-1, D en D+1 van Analysis_date dekken (LoadFeeds/ServiceDays).
- `Analysis_date` (regel 8): De dag van de OV-analyse: de peildatum van AnalysisMoment, uit Advanced/AnalysisMomentPresets (#125). Het net bevat de dienstdagen D-1, D en D+1 op een tijdas; LoadFeeds/ServiceDays controleert dat de feed elke dag die het analysevenster nodig heeft compleet heeft.
- `AllowDirectWalking` (regel 14): Doet de directe looprit (OSM-loopnetwerk, tot MaxWalkingTime_Org2Dest) mee in het front per HB-paar? Uit Component (Advanced/Components/DirectWalking, #117); bij het samenvoegen: of een samengevoegde component hem heeft.
- `AllowDirectCycling` (regel 15): Doet de directe fietsrit (het net van Advanced/CyclingNetwork, tot MaxCyclingTime_Org2Dest) mee in het front per HB-paar? Uit Component (Advanced/Components/DirectCycling, #117); bij het samenvoegen: of een samengevoegde component hem heeft.
- `AllowDirectCar` (regel 16): Doet de directe autorit (TomTom of OSM, zie UseTomTomNetworkForCars, tot MaxCarTime) mee in het front per HB-paar? Uit Component (Advanced/Components/DirectCar, #117); bij het samenvoegen: of een samengevoegde component hem heeft. De autoprijs is afstand x Car_CostPerKm.
- `Car_CongestionMoment_ForDirect` (regel 17): Welke reistijd van de auto de directe rit gebruikt: 'MorningRush' (07:30), 'NoonRush' (12:30), 'LateEveningRush' (19:30) of 'Freeflow' (alleen TomTom; bij OSM 'MaxSpeed'). Volgt uit PartOfDay (Advanced/PartsOfDay/CongestionMoment, #125): het midden van het uur van de vertrekmomenten.
- `CarTimeDependent` (regel 20): Rekent de directe autorit met tijdafhankelijke linktijden (#132)? Dan is er per vertrekmoment een autostore (PublicTransport_Prep/Direct/CarPerMoment/TD<moment>), waarin elk wegvak de TomTom-snelheid heeft van het moment waarop de rit het binnenrijdt. FALSE: een momentopname per congestiemoment. Vereist TomTom en een weekdag als Advanced/CongestionSpeed_DaySelection.
- `Buurtset_Org` (regel 23): De buurtvariant van de herkomsten, of null.
- `Buurtset_Dest` (regel 24): De buurtvariant van de bestemmingen, of null.
- `Buurtset` (regel 25): De buurtvariant van de run: die van de herkomsten, anders die van de bestemmingen, anders null (dan gelden de presets van AnalysisMoment). Er is een BAG en een gebiedsindeling per run, dus herkomsten en bestemmingen kunnen geen verschillende buurtvarianten zijn.
- `BAG_snapshot` (regel 28): Naam van de BAG-snapshotmap onder %NetworkModel_Dir%/RegioIndelingen/BAG: die van de buurtvariant (Buurtset) als Orgset of Destset er een is, anders die van AnalysisMoment in de presettabel. Los van RegioIndelingen_year, want de BAG-standdatum en de CBS-gebiedsindeling lopen niet gelijk.
- `BAG_year` (regel 30): Het jaar van de BAG-snapshot, uit BAG_snapshot. Wordt gebruikt om bouwjaren na de standdatum af te kappen en in de exportnamen.
- `RegioIndelingen_year` (regel 32): Het jaar van de CBS-gebiedsindeling: dat van de buurtvariant (Buurtset) als Orgset of Destset er een is, anders per AnalysisMoment in de presettabel.
- `IsOD` (regel 35): Rekent deze run een HB-paar (OD_Origin en OD_Destination)? Dan zijn de herkomsten en bestemmingen elk een element (PublicTransport_Prep/impl/OD_Org, OD_Dest), staan de tussenresultaten en de uitvoer in eigen mappen (OD_Tag) en houden de routes hun links bij.
- `OD_Tag` (regel 38): Achter IntermediateResults en Output in de namen van de mappen van een HB-paar: _<O>_<D>, bijvoorbeeld _BU04020501_BU0363KP03; leeg in het generieke model.
- `IsODMoment` (regel 41): Kiest het HB-paar een vertrekmoment (OD_DepartureTime)?
- `OD_Minute` (regel 42): De minuut van OD_DepartureTime; het uur moet dat van PartOfDay zijn en de minuut een van Advanced/PT_DepartureMinutes_All.
- `IntermediateResultsDir` (regel 45): De map van de stores van de autoritten, de benen en de ketens (PublicTransport_Prep); bij een HB-paar IntermediateResults_<O>_<D> (#129).
- `OutputDir` (regel 47): De map met de OV-uitvoer van deze run (#118): <Analysis_date>_<OutputLabel> met het achtervoegsel van de component (Advanced/Components/OutputSuffix) of _Merged<MergeRunNr>, met _fb als een samengevoegde component over de Fietsersbond fietst; met PerBlock/tt_<moment>_<n>of<N> en signature.txt.
- `fileNamePrefix` (regel 49): De map van de OV-uitvoer per herkomstblok (en van de exports van lopen, fiets en auto).
- `OutputExt` (regel 50): De extensie van de bestanden in PerBlock en Mediaan.
- `ExportClass` (regel 51): Welke kolommen de parquet-uitvoer van deze component heeft (PerDepartureMoment_T, CreateExports/LongFormat/Parquet_<ExportClass>): alleen die binnen de component variëren en niet lineair uit andere volgen. 'Direct' (WW, CC): Traveltime; 'Car': ook TravelDist_Car; 'PT': ook de prijzen, ModeUsed, de wacht-, voor- en natransporttijd en de afstanden per OV-modaliteit.
- `Concessiegebied_year` (regel 52): Which year of the concession areas would you like to use? Relevant for public transport price determination. Concessie-shapes bestaan alleen 2020-2026; voor FareTable_year < 2020 (o.a. DOVA-prijzen terug tot 2013) wordt Y2020 als proxy gebruikt.
- `FareTable_year` (regel 53): Prijsjaar: het jaar van GTFS_file_date, zodat de agency-labels van de FareTable bij de geladen feed horen (data/FareTable_dekkingsrapport.md). Detailed-FareTables bestaan voor 2023-2026; voor eerdere jaren rekent de prijs met DOVA (Impl/PriceMethod_effective).
- `PriceMethod_effective` (regel 54): Effectieve prijsmethode: Detailed-FareTables bestaan alleen voor 2023-2026, dus voor FareTable_year < 2023 (oudere GTFS-feeds) wordt altijd DOVA gebruikt, ongeacht Advanced/PriceMethod.
- `DOVA_year` (regel 55): Jaarkolom in het DOVA-overzicht (y2013..y2026); geklemd op dat bereik (bv. feed 20120917 -> 2013-prijzen).
- `NS_prijzen_year` (regel 56): Jaargang van de NS-tarieven-csv (data/Tarieven_NS/NS tarieven <jaar>.csv, 2013-2026 aanwezig); geklemd op dat bereik.
- `NS_tariefnet_year` (regel 57): Jaargang van het NS-tariefnet (data/Tarieven_NS/NS_tariefnet_<jaar>.csv) bij NS_prijzen_year (#121): 2013 het NDOV-net met de gezamenlijke tariefpunten (stations met 0 TE ertussen), 2016 zonder die punten (elk stationspaar minstens 1 TE).
- `OVFiets_year` (regel 58): (geen Descr)
- `OVFiets_File` (regel 59): Het bestand van de OV-fietslocaties van deze peildatum (SourceData/Infrastructure/OV_Fiets_Stations).
- `OVFiets_FileTag` (regel 60): In de handtekening van de OV-uitvoer als het PostTransport de OV-fiets heeft (PT_Output_ParamTag); leeg bij de locaties van 2023.
- `PT_FirstDepartureMoment` (regel 61): Begin van het analysevenster van het OV: het eerste vertrekmoment, in seconden sinds 00:00 van Analysis_date.
- `PT_LastArrivalMoment` (regel 62): Einde van het analysevenster van het OV: het laatste vertrekmoment plus MaxPTTime en de wachttijd thuis. Voorbij 24:00 (86400) loopt het venster door in de volgende dag, en gebruikt het netwerk ook de ritten van de dienstdag na Analysis_date.
- `PT_Max_V_Time` (regel 64): Langste voortransportbeen dat nog geldig kan zijn: de grootste Max*Time-grens (op netwerktijd) plus de start- en parkeertijden in het been. Begrenst per vertrekmoment het venster van OV-vertrekken (PerDepartureMoment_T) en het laatste instapmoment van de ketens.
- `PT_LastBoardingMoment` (regel 66): Laatste instapmoment waarop een keten nog gebruikt kan worden: het laatste vertrekmoment plus het langste PreTransport en de wachttijd thuis, de bovengrens van Within_VW_Window. De ketenstap begint geen ketens die later instappen.
- `PrevServiceDayTailEnd` (regel 68): De ritten van de dienstdag voor Analysis_date die na middernacht doorrijden (GTFS-tijd 24:00 en later) vertrekken vrijwel alle voor 06:00; begint het analysevenster eerder, dan moet die dag compleet in de feed staan.
- `FlexMinInterval_sec` (regel 69): Advanced/FlexMinInterval in hele seconden, voor de blokken van LoadFeeds/FlexOptions.
- `FlexHasTimePenalty` (regel 70): Krijgt een flexbeen extra wachttijd bij zijn reistijd?
- `Flex_FileTag` (regel 71): Deel van de handtekening van de ketenstore (PublicTransport_Prep/PT_Chains_Signature) en van de OV-uitvoer (PT_Output_ParamTag): '_noflex' zonder flex, '_flex<interval>i<wachttijd>w<belkosten in ct>ct' met de flexparameters, leeg als die alle drie 0 zijn.
- `FlexRoutePattern` (regel 72): (geen Descr)
- `FlexNearMissPattern` (regel 73): (geen Descr)
- `TripSurchargeHasTimePenalty` (regel 74): Krijgt een been met rit-opslag extra reistijd?
- `TripSurcharge_Flags` (regel 75): (geen Descr)
- `TripSurcharge_FileTag` (regel 76): Deel van de handtekening van de ketenstore (PublicTransport_Prep/PT_Chains_Signature) en van de OV-uitvoer (PT_Output_ParamTag): leeg met de standaard (NS International mee, rit-opslag mee, geen extra tijd), anders '_' met I (zonder NS International), R (zonder rit-opslag) of w<min> (extra tijd in minuten); kort vanwege de padlengte (#118).
- `IsMerged` (regel 78): Voegt deze run de Components samen (MergeOutput)?
- `WithPT` (regel 79): Doen de OV-ketens mee in deze run (Advanced/Components/WithPT)? Niet bij een directe rit en niet bij het samenvoegen.
- `ComponentName` (regel 80): De naam van de component van deze run: WW, CC, Car, of bij Component 'PT' <PreTransport>_PT_<PostTransport> uit PreTransport en PostTransport, bijvoorbeeld W_PT_W of C_RM_PT_OVf_C.
- `Component_PreTransport` (regel 82): De naam van het voortransporttype (/ModelParameters/PreTransport); bij een directe rit niet gebruikt.
- `Component_PostTransport` (regel 83): De naam van het natransporttype (/ModelParameters/PostTransport); bij een directe rit niet gebruikt.
- `SingleDepartureMoment` (regel 84): Rekent deze run een vertrekmoment, dat van het congestiemoment (Advanced/Components/SingleDepartureMoment; de directe ritten, Car niet met CarTimeDependent)?
- `CongestionMinute` (regel 85): De minuut van het congestiemoment van het PartOfDay (Advanced/CongestionTimes/Time, bij de ochtendspits 0730): het vertrekmoment van een component met SingleDepartureMoment.
- `SingleDepartureMoment_Shrt` (regel 86): De korte naam van dat vertrekmoment, als Time/TemplatableTextShrt (07h30m): zo heet het bestand per blok van een component met SingleDepartureMoment, dat ComponentMerge voor elk vertrekmoment leest.
- `SingleDepartureMoment_Minute` (regel 87): De minuut van het ene vertrekmoment van een component met SingleDepartureMoment: CongestionMinute, of bij een HB-paar met OD_DepartureTime dat (OD_Minute).
- `BlocksPerPortion` (regel 88): Herkomstblokken per GeoDmsRun in de uitvoerstap van deze run (Advanced/Components/BlocksPerPortion); bij het samenvoegen 10: in een opvraging ongeveer 7 GB per blok.
- `DirectModes_Selected` (regel 89): De toegestane directe modaliteiten.
- `Direct_str` (regel 90): De directe modaliteiten zoals ze in de handtekening staan (V-<Direct_str>,<PreTransport>_N-<PostTransport>): WW, CC en/of AA, in de volgorde van Advanced/DirectModes.
- `PriceExportsAndIntegrityChecksNeeded` (regel 94): (geen Descr)
- `CarFrontMaxDistance` (regel 95): De grens op het eerste criterium van de zoektocht op afstand eerst (Advanced/CarFrontEpsilon), die de engine verplicht stelt: de afstand die in MaxCarTime met 150 km/u te halen is, zodat hij niets afsnijdt; de echte grens is MaxCarTime op de reistijd, het tweede criterium.
- `Car_PriceTag` (regel 96): Deel van de handtekening van de OV-uitvoer (PT_Output_ParamTag, #88): de prijs van de directe autorit, in ct per km en, als dat niet 0 is, per rit; _car0 als Advanced/IncludeCarCostsInPrice uit staat. De autostore bevat alleen reistijd en afstand, dus de prijs staat niet in zijn handtekening.
- `ChainPareto_FileTag` (regel 97): Deel van de handtekening van de ketenstore en van de OV-uitvoer: de relatieve epsilon op de reistijd in procenten, leeg als die 0 is.
- `PT_Chains_ParamTag` (regel 98): Deel van de handtekening van de ketenstore (PublicTransport_Prep/PT_Chains_Signature) met de parameters waar de ketens van afhangen en die de rest van de handtekening niet noemt: de prijsmethode (dova of detailed, met -ns20/-ns40 bij NS-korting en -noprice als de prijzen niet worden bewaard), _ov<Advanced/MaxTransferDist m>-<Advanced/TransferEffectiveSpeed m/uur>-<Transfer_Walking_Time_Costs ct/min>-<Transfer_Waiting_Time_Costs ct/min>-<Advanced/GradeSeparatedTransferPenalty min>-<Advanced/MaxTransferTimeForBoardingSurcharge min> en _h<Advanced/DistanceStopClusters m>-<Advanced/DistanceTrainStationsSelection m>. Het prijsjaar volgt uit GTFS_file_date, dat de handtekening noemt als het van Analysis_date afwijkt.
- `CarNetwork_Revision` (regel 107): Revisie van het TomTom-autonet in de handtekening van de autostores (en zo in de hash in hun naam): verhoog hem bij elke codewijziging die het autonet verandert, anders wordt de oude store gelezen. Wat per revisie veranderde, staat in de commits en in #88.
- `PT_Chains_Revision` (regel 109): Revisie van de ketenopbouw in de handtekening van de ketenstore (en zo in de hash in zijn naam): verhoog hem bij elke codewijziging die de ketens verandert, anders wordt de oude store gelezen. Wat per revisie veranderde, staat in de commits en in de issues.
- `ParetoLegs_Car_FileTag` (regel 111): Deel van de handtekening van de autostores en van de OV-uitvoer, want het front met de directe autorit hangt van deze parameters af (#88): 'D-r1pct', afstand eerst met de relatieve epsilon in procenten, of de kwantisatie in m; leeg als Advanced/ParetoLegs_Car uit staat.
- `CyclingNetwork_FileTag` (regel 112): In de handtekening van de OV-uitvoer als een fietsbeen of de directe fietsrit meedoet (PT_Output_ParamTag); leeg met OSM.
- `CyclingNetwork_DirTag` (regel 113): Achter de naam van de uitvoermap van een component over het fietsnet (Advanced/Components/OutputSuffix): '_fb' met de Fietsersbond, leeg met OSM, zodat de uitvoer over beide netten naast elkaar staat; WW, W_PT_W en Car hebben een map voor beide (#124).
- `OrgSet_SelectionTag` (regel 114): Het gekozen gebied van een enkele-gebied-herkomstenset in de bestandsnamen, zodat twee selecties geen autostore of uitvoerbestand delen. Bij een HB-paar (IsOD) de herkomst, zodat ook de handtekeningen het paar noemen en WalkingMirror niet geldt.
- `DestSet_SelectionTag` (regel 116): Het gekozen gebied van een enkele-gebied-bestemmingenset in de bestandsnamen; bij een HB-paar (IsOD) de bestemming.
- `DestSet_DateTag` (regel 118): Datum van de bestemmingsset in de bestandsnamen, als die uit de dienstregeling volgt: de OV-knooppunten hangen af van de feed en van de vertrekken op Analysis_date, dus een andere datum krijgt een eigen autostore.
- `DestSet_string_nodate` (regel 120): De bestemmingsset zonder DestSet_DateTag, in de handtekening van de OV-uitvoer (PT_Output_ParamTag), die Analysis_date al noemt.
- `PT_CombinationType` (regel 122): De directe modaliteiten en de voor- en PostTransportTypes zoals ze in de handtekening van de OV-uitvoer staan; zonder OV (Car) alleen de directe modaliteiten.
- `UsesCycling` (regel 124): Doet een fietsbeen of de directe fietsrit mee? Dan noemt de handtekening van de OV-uitvoer het fietsnet (CyclingNetwork_FileTag).
- `PT_Output_ParamTag` (regel 126): De parameters van de OV-uitvoer na datum en herkomstset, voor de handtekening van de uitvoer (NetworkSetup/GenerateOutput/Output_Signature, #118): bestemmingenset, modaliteiten, criteria en de tags; de OV-tags (overstappen, MaxPT, flex, rit-opslag) alleen als het OV meedoet, de autotags alleen als de directe autorit meedoet (#117).
- `DestSet_string` (regel 128): De bestemmingsset zoals hij in de bestandsnamen staat, met DestSet_SelectionTag en DestSet_DateTag.
- `OrgSet_string` (regel 131): De herkomstenset zoals hij in de bestandsnamen staat, met OrgSet_SelectionTag bij een enkel gebied. Bij een geclusterde set hoort de celmaat erbij, anders overschrijft een 500m-run de uitvoer van een 100m-run, net zoals DestSet_string dat voor de bestemmingen doet.
- `OrgSet_PathTag` (regel 135): De herkomstenset in de namen van stores en bestanden, kort voor de padlengte: OrgSet_string met b voor buurt, bijvoorbeeld b2025 voor buurt2025. De handtekeningen houden OrgSet_string.
- `DestSet_PathTag` (regel 136): De bestemmingenset in de namen van stores en bestanden: DestSet_string met b voor buurt. De handtekeningen houden DestSet_string.
- `OrgSet_NameTag` (regel 137): De herkomstenset in de naam van een benen-store, met een hoofdletter: Legs_B2025toStops_Walking.
- `DestSet_NameTag` (regel 138): De bestemmingenset in de naam van een benen-store, met een hoofdletter: Legs_Stops2B2025_Walking.
- `OV_PreTransport_Typen` (regel 140): Het voortransporttype van deze run: dat van Component (Advanced/Components/PreTransport, #117). RMT=Rail+Metro+Tram, OVF=OV-fiets, Ric=InterCity station.
- `OV_PostTransport_Typen` (regel 152): Het natransporttype van deze run: dat van Component (Advanced/Components/PostTransport, #117). RMT=Rail+Metro+Tram, OVF=OV-fiets, Ric=InterCity station.
- `PT_DepartureMinutes` (regel 164): De minuten van de vertrekmomenten van deze run: alle van Advanced/PT_DepartureMinutes_All, bij SingleDepartureMoment alleen die van het congestiemoment (CongestionMinute, #132), en bij een HB-paar met OD_DepartureTime alleen dat (OD_Minute, #129), ook voor een component met SingleDepartureMoment.
- `SampleDay` (regel 170): (geen Descr)
- `MeasureMoments` (regel 185): (geen Descr)
- commentaar regel 4-4: AFGELEID UIT DE INSTELLINGEN BOVENAAN, niet zelf in te stellen
- commentaar regel 11-13: Directe ritten naast het OV. De ketenrijger voegt per HB-paar de directe rit(ten) bij de OV-ketens en houdt het Pareto-front op Advanced/MinimiseCriteria (prijs, tijd) over; zie NetworkSetup/PublicTransport_Prep/Direct_OD. De drie schakelaars volgen uit Component (#117).
- commentaar regel 34-34: HET HB-PAAR (#129): zie groep 6 bovenaan.


## cfg/main.dms

- `ChecksBeforeRunning` (regel 11): (geen Descr)
- `PT_CheckBlocks` (regel 13): Passen alle haltes in de haltenblokken (MaxStopBlockSize x NumberOfStopBlocks)? Zo niet, maak de blokken groter of talrijker.
- `PT_CheckPrices` (regel 17): Heeft elk OV-been een geldige prijs (een FareTable-rij met prijzen), als de instellingen prijzen vragen? Rekent na de netwerkbouw; de ongeprijsde combinaties staan in NetworkSetup/PublicTransport_Prep/Impl/OD_R/impl/Ongeprijsd/uniek, de goedkope voorcheck is PT_CheckPriceCoverage.
- `PT_CheckPriceCoverage` (regel 18): Goedkope voorcheck, te draaien VOOR de (uren durende) netwerkbouw en blokruns, bij elke nieuwe feed of nieuw prijsjaar: dekt de actieve prijstabel alle (mode,agency)-combinaties van de geladen GTFS-feed, en zijn alle tabelprijzen gevuld en plausibel? PT_CheckPrices blijft de sluitende check op OD-niveau (na netwerkbouw); diagnose bij FAIL daarvan: NetworkSetup/PublicTransport_Prep/Impl/OD_R/impl/Ongeprijsd/uniek.
- `Check_OriginBlocks` (regel 20): (geen Descr)
- `OSM_Network` (regel 31): (geen Descr)
- `TomTom_Networks` (regel 33): (geen Descr)
- `GTFS_Feed` (regel 34): (geen Descr)
- `Generate_All` (regel 40): Alle basissets in een keer, zoals UpdateAll.cmd legs: de drie hieronder, en Stops2Dest_Walking als herkomsten en bestemmingen verschillen (anders is lopen van de halte naar de bestemming het spiegelbeeld van Org2Stops_Walking).
- `Org2Stops_Walking` (regel 42): Lopen van elke herkomst naar elke halte, over OSM: Legs_<set>toStops_Walking_<hash>.parquet.
- `Org2Stops_Cycling` (regel 44): Fietsen van elke herkomst naar elke halte, over het net van ModelParameters/Advanced/CyclingNetwork: Legs_<set>toStops_Cycling_<hash>.parquet.
- `Stops2Dest_Cycling` (regel 46): Fietsen van elke halte naar elke bestemming: Legs_Stops2<set>_Cycling_<hash>.parquet. Een eigen store, want het Fietsersbond-net heeft eenrichtingsfietspaden.
- `Step3_PT_Chains` (regel 50): De OV-ketenstore van het PartOfDay: een store per haltenblok in %LocalDataProjDir%/IntermediateResults/PT_Chains_<datum>_<venster>_<hash>, dezelfde als UpdateAll.cmd chains maakt.
- `Check_Blocks` (regel 53): Passen alle haltes in de haltenblokken (MaxStopBlockSize x NumberOfStopBlocks)?
- `Check_PriceCoverage` (regel 54): Dekt de prijstabel alle combinaties van modaliteit en vervoerder in de feed? Seconden; draai hem voor de ketens.
- `BlocksWritten` (regel 55): Hoeveel blokken van de ketenstore met de huidige handtekening er al zijn (een blok telt als zijn 0Dictionary.dms bestaat).
- `Generate_ToDo` (regel 57): Rekent en schrijft de blokken zonder store in een opvraging; UpdateAll.cmd chains rekent ze in porties, elk in een eigen GeoDmsRun, zodat het geheugen tussen de porties vrijkomt.
- `PerBlock` (regel 59): Per haltenblok: Write rekent en schrijft de store van dat blok, bijvoorbeeld om een blok te proberen.
- `Writers` (regel 76): (geen Descr)

## cfg/main/ModelParameters (staartcommentaar)

- cfg/main/ModelParameters/Advanced.dms: Hier worden de paden voor elke org set opgegeven. En wanneer er nieuwe bij komen dat hier ook toegevoegd worden.
- cfg/main/ModelParameters/Advanced.dms: Hier worden de paden voor elke dest set opgegeven. En wanneer er nieuwe bij komen dat hier ook toegevoegd worden.
- cfg/main/ModelParameters/Impl.dms: TomTom kent Freeflow/MorningRush/NoonRush/LateEveningRush; OSM alleen MaxSpeed, want de OSM-spitsen zijn null-placeholders
- cfg/main/ModelParameters/Impl.dms: minstens een van AllowDirectWalking/Cycling/Car, behalve met OV (sinds 2026-10-19 de _OVf-Components: alleen ketens, Direct_OD leeg via PublicTransport_Prep/HasDirectTI) en bij Merged

## cfg/main/NetworkSetup/PublicTransport_Prep.dms

- `Org_unit` (regel 10): Het pad van de herkomsten: Orgset (Org_domain), of bij een HB-paar de ene herkomst daarvan (OD_Org).
- `Dest_unit` (regel 11): Het pad van de bestemmingen: Destset (Dest_domain), of bij een HB-paar de ene bestemming daarvan (OD_Dest).
- `OD_Org` (regel 14): De herkomst van het HB-paar: het element van Orgset met de naam OD_Origin.
- `OD_Dest` (regel 21): De bestemming van het HB-paar: het element van Destset met de naam OD_Destination.
- `name` (regel 32): Bij een HB-paar precies een herkomst, met de naam OD_Origin.
- `name` (regel 44): Bij een HB-paar precies een bestemming, met de naam OD_Destination.
- `IsFlexLink` (regel 120): #113: link van een flex-lijn; wachtlinks dragen Route_rel van hun rit en vallen dus mee. MakeDefined: een null-conditie telt in select_with_attr_by_cond stil als false.
- `Block_rel` (regel 145): Het haltenblok van de ketenstap waarin een keten vanaf deze halte instapt: een random blok van MaxStopBlockSize haltes, of bij een HB-paar (sinds 2026-10-21, #129) het ene blok van de haltes van de herkomst (OD_Haltes/IsVStop) en anders geen.
- `StoreName` (regel 153): Naam van de blokstore in StorageBlockDir_Str (sinds 2026-09-30 zonder 'Block_', voor de padlengte).
- `Create_Optimised_Network_Cycling` (regel 161): Network for pre- and post-transport. Sinds 2026-10-13 (#124) het fietsnet van ModelParameters/Advanced/CyclingNetwork (standaard de Fietsersbond), tot dan OSM.
- `DirectModes_Selected` (regel 175): De directe modaliteiten die meedoen; minstens een moet aan staan.
- `Direct` (regel 178): (geen Descr)
- `CarMoments` (regel 210): De congestiemomenten waarvoor een store van de directe autorit bestaat: de drie spitsen en de vrije stroom (TomTom: Freeflow, OSM: MaxSpeed); Car_CongestionMoment_ForDirect kiest er een. Met CarTimeDependent (sinds 2026-10-09, #132) daarnaast per vertrekmoment een tijdafhankelijke store, TD<moment> (TD07h00m), waaruit de eindafweging van dat moment per blok haar rijen leest (PerDepartureMoment_T, CarRows).
- `CarPerMoment` (regel 216): Per congestiemoment: Write_Car (schrijft de store), Read_Car (leest hem) en Car (met prijs, Summary per HB-paar en het front, Car/Front).
- `DirectCarStore_T` (regel 219): (geen Descr)
- `IsTD` (regel 223): Een tijdafhankelijke store van een vertrekmoment (CarTimeDependent, sinds 2026-10-09)?
- `Calc_Car` (regel 224): Rekenkant: de (pareto-)afstandsmatrix van PrivateTransport_Car_T op dit moment, of de tijdafhankelijke zoektocht van dit vertrekmoment (Traveltimes/TD). Niet zelf gebruiken; Write_Car schrijft hem weg en Car leest hem terug.
- `MaxSpeed` (regel 228): Het snelheidsplafond van dit moment (0 = geen), voor de storenaam; bij een tijdafhankelijke store dat van het congestiemoment.
- `TD_Tag` (regel 229): Deel van de handtekening van een tijdafhankelijke store: de referentie, het venster (begin in minuten, aantal tijdvakken), Car_StartTime (die verschuift de vertrektijd op het netwerk) en de zoektocht.
- `Signature` (regel 233): Handtekening van de store: congestiemoment, net en editie, MaxCarTime, herkomst- en bestemmingenset, snelheidsplafond, pareto-tag en revisie. De kosten staan er sinds 2026-10-05 niet meer in (#88): de store bevat reistijd en afstand, de prijs volgt bij het lezen. Tot 2026-10-03 (NetworkModel_PBL#118) was dit de naam; nu staat hij als hash in de naam en voluit in signature.txt in de map van de store (sinds 2026-10-06; tot dan in <naam>.signature.txt ernaast).
- `NetTag` (regel 243): Het wegennet in de naam van de store (sinds 2026-10-21): TT en de TomTom-editie (TT2025-12 voor yr2025_12) of OSM en de datum van de OSM-extractie. Een autostore hangt van de editie af, niet van de peildatum: Y2025 en Y2026 delen yr2025_12.
- `StorageBase_Str` (regel 247): Naam van de store zonder extensie: het wegennet (NetTag, sinds 2026-10-21), het congestiemoment, de herkomst- en bestemmingenset leesbaar (sinds 2026-10-20 kort, OrgSet_PathTag: b2025 voor buurt2025), de rest als hash van Signature. Bijvoorbeeld DirectCar_TT2025-12_TD07h00m_b2025_b2025_3dc99b97.mmd.
- `Sig` (regel 250): De handtekening in de map van de store (signature.txt, naast 0Dictionary.dms; sinds 2026-10-06, tot dan <naam>.signature.txt ernaast in IntermediateResults): Write_Car schrijft hem, Read_Car controleert hem.
- `Write_Car` (regel 252): Schrijft de afstandsmatrix van de directe autorit op dit moment naar StorageName_Str, en de handtekening ernaast (Sig); bereken dit item om de store (opnieuw) te maken.
- `impedance` (regel 255): De reistijd van de route; met de relatieve epsilon (sinds 2026-10-05) het tweede zoekcriterium, de afstand het eerste.
- `alt_imp` (regel 256): De afstand van de route (sinds 2026-10-05, #88; tot dan de linkkosten in euro).
- `Write_CarLinks` (regel 264): Schrijft de links van de routes naar LinksName_Str; bereken Write_CarLinks/links. Alleen in de HB-paarmodus, bij een tijdafhankelijke store.
- `Route` (regel 269): De rij van de store (Write_Car).
- `Read_Car` (regel 283): Kale lezer van de store; declareert niets. Faalt als de handtekening ontbreekt of afwijkt (Sig/CheckGate); bestaat de store niet, bereken dan eerst Write_Car.
- `Car` (regel 285): De directe autorit uit de hele store: per HB-paar de snelste route (scalair) of het (reistijd, afstand)-front (ParetoLegs_Car), met prijs, de samenvatting per HB-paar in Summary en het uitgedunde front in Front (tot 2026-10-12 Car_Front, naast Car).
- `Distance` (regel 304): De afstand van de route; tot 2026-10-05 onbekend (leeg), toen de matrix de kosten droeg.
- `Cost_Euro` (regel 305): Afstand x Car_CostPerKm plus het bedrag per rit (#88).
- `Summary` (regel 313): Per HB-paar: nr_routes, min_impedance, max_impedance, min_alt_imp, max_alt_imp.
- `nr_routes` (regel 319): pcount over een uint64-domein levert uint64, vandaar de conversie.
- `Front` (regel 338): Het uitgedunde front (keep), wat meedoet in Direct_OD. Zonder epsilon, of op een engine voor 20.21.0, gelijk aan Rows.
- `stat_front_mean` (regel 351): Routes per HB-paar na de uitdunning; vergelijk met ../stat_front_mean.
- `Car` (regel 356): De directe autorit op het congestiemoment Car_CongestionMoment_ForDirect, uit de store van CarPerMoment/<moment>; bekijk het front en de samenvatting daar.
- `DirectModes_TI` (regel 372): De directe modaliteiten die niet van het vertrekmoment afhangen: alle toegestane, behalve de auto met CarTimeDependent.
- `Direct_OD` (regel 375): Alle directe ritten van de toegestane modaliteiten die niet van het vertrekmoment afhangen, volledige HB-tabel; per blok gefilterd in PublicTransport/Direct_OD.
- `TimeInvariantConnections` (regel 387): i.e. voor/na transport
- `Create_TimeInvariantConnection_T` (regel 393): (geen Descr)
- `WalkingMirror` (regel 431): Zijn herkomsten en bestemmingen dezelfde set? Dan is lopen van een halte naar een bestemming het spiegelbeeld van lopen van die buurt naar de halte, en komt er geen store voor Stops2Dest_Walking (sinds 2026-10-20; gemeten voor Buurt2025: op 56 van de 149.164 benen na in beide richtingen, met dezelfde reistijd).
- `BaseLegTypes` (regel 437): De basissets van de benen met een store, elk een Dijkstra over het hele netwerk met de maximale tijd van het type.
- `LegStore_T` (regel 444): (geen Descr)
- `NetworkTag` (regel 450): Het netwerk en de snelheid, voor de handtekening: het Fietsersbond-fietsnet (CyclingNetwork_FileTag) of de OSM-netwerkstore.
- `Signature` (regel 454): Handtekening van de store: het type, netwerk en snelheid, de maximale tijd, de herkomsten, de bestemmingen en de haltes (feed en peildatum; het aantal plaatsen en haltes ter controle), het formaat en de revisie.
- `StorageBase_Str` (regel 462): Naam van de store zonder extensie: het type met de herkomsten- of bestemmingenset (OrgSet_NameTag: Legs_B2025toStops_Walking, Legs_Stops2B2025_Cycling), de rest als hash van Signature.
- `Sig` (regel 465): De handtekening naast de store, in <naam>.signature.txt: Write_Legs schrijft hem, Legs_store controleert hem.
- `Legs` (regel 544): Per type van voor- of PostTransport de benen uit de store van zijn basisset (sinds 2026-10-19), met dezelfde kolommen als TimeInvariantConnections/<type>/Create_Routes/ODMatrix.
- `Legs_T` (regel 549): (geen Descr)
- `IsMirror` (regel 556): Lopen naar de bestemmingen als spiegelbeeld van lopen van de buurten naar de haltes (WalkingMirror).
- `StopSet` (regel 558): De haltes van dit type: Stops (alle), RM_Stops, RMT_Stops, Ric_Stops of OVF_Stops.
- `IsVBoarding` (regel 604): Instappen bij een halte waar een voortransportbeen van de component eindigt (NetworkSetup/impl/IsVStop)? Alleen zulke ketens kan de uitvoer gebruiken (PT_V).
- `ChainGeneration_PerBlock` (regel 621): (geen Descr)
- `ChainGeneration_PerBlock_T` (regel 627): (geen Descr)
- `Price_S` (regel 667): Rit-opslag van de keten (#3), het deel van Price dat per been geldt (ICD/ICE-toeslag); voor Validation tegen 9292 (#53), dat de toeslag niet in de prijs telt.
- `Chain_rel` (regel 675): Het rijnummer van de keten in Chain_Generation/<Allowed_ChainsK_rel>/Result.
- `EindigtBijD` (regel 676): Alleen in de HB-paarmodus: stapt de keten uit bij een halte vanwaar de bestemming te bereiken is (OD_Haltes/IsNStop)?
- `StarEvent2Stop` (regel 684): (instaptijdhalte, bestemmingshalte). Tot 2026-09-27 union_unit_uint64(Stops, Stops): dezelfde sleutelwaarden, maar een unit van 2 x #Stops elementen voor een sleutel tot #uq_c_FromTime_Stop x #Stops (audit 6.7).
- `BlockResultContainer` (regel 693): hack om deadlock te omzeilen
- `Allowed_Chains_rel` (regel 699): De keten in Allowed_Chains, om hem terug te leiden naar zijn benen (alleen gevraagd in de HB-paarmodus, OD_Ketens).
- `Calc` (regel 747): Rekenkant van de geunionede ketenresultaten per block (niet opgeslagen).
- `Write` (regel 769): Deze set bevat de geunionede resultaten per block.
- `Read` (regel 791): Kale lezer van de ketenstore; declareert niets. Faalt als de handtekening ontbreekt of afwijkt (PT_Chains_Sig/CheckGate).
- `Keten` (regel 827): Het rijnummer van de keten in de store van het blok, zoals OD_Ketens/Read_Benen/Keten (sinds 2026-10-21, #129; alleen gevraagd in de HB-paarmodus).
- `Item` (regel 837): De schrijver van het blok; bij een HB-paar (sinds 2026-10-21, #129) OD_Ketens/Write, die ook de benen en links van de ketens schrijft, in dezelfde opvraging.
- `ToDo_List` (regel 839): De schrijvers van de blokken die nog geen store hebben, een per regel; batch/WriteChainBlocks.ps1 leest dit bestand. Het is het eerste wat dat script opvraagt, dus via PT_Chains_Sig/ForWriting schrijft of controleert het hier de handtekening en het langste pad (PT_Chains_Sig/PathLength), voordat er gerekend wordt. Tot 2026-10-03 deed PT_Chains_Blocks/PathLength dat laatste: op 2026-09-30 maakte de flextag _flex5i5w15ct het langste pad 265 tekens, waarna elk blok pas bij het schrijven faalde.
- `IsVBoarding_PT` (regel 887): Alleen met de ene store van voor 2026-09-29 (PT_Chains_PerBlock FALSE): de ketens van PT_V.
- `Keten` (regel 902): Het rijnummer van de keten in de store van zijn blok (sinds 2026-10-21, #129; alleen gevraagd in de HB-paarmodus, met een blok: OD_Ketens/Read_Benen/Keten).
- `PT_Chains_Window` (regel 908): Het tijdvenster van de ketens, bijvoorbeeld 07h00m-09h29m: van het eerste vertrekmoment tot de laatste aankomst.
- `StorageBase_Str` (regel 934): Naam van de ketenstore zonder extensie (sinds 2026-10-03, NetworkModel_PBL#118): datum en tijdvenster leesbaar, de rest als hash van PT_Chains_Signature. Bijvoorbeeld PT_Chains_20261006_07h00m-09h29m_11a52bac; tot dan stond de hele handtekening in de naam en was het langste pad 252 tekens.
- `StorageName_Str` (regel 936): De ene ketenstore van ChainGeneration_Single/Write (PT_Chains_PerBlock FALSE).
- `StorageBlockDir_Str` (regel 937): Map van de ketenstore per blok (sinds 2026-09-29): de naam van de ene store zonder .mmd (tot 2026-09-30 met _blocks erachter), met daarin <n>of<N>.mmd per blok.
- `PT_Chains_Sig` (regel 939): De handtekening in de map van de ketenstore (signature.txt; sinds 2026-10-06, tot dan <naam>.signature.txt ernaast in IntermediateResults): Write_Block, ChainGeneration_Single/Write en PT_Chains_Blocks/ToDo_List schrijven hem (en controleren het langste pad, met uq_c_FromTime_Stop_rel als langste attribuutnaam), ChainGeneration_Single/Read en PT_Chains_Blocks/Read controleren hem.
- commentaar regel 5-7: Sinds 2026-10-21 (#129): bij een HB-paar (ModelParameters/Impl/IsOD) zijn de herkomsten en de bestemmingen elk het ene element van Orgset en Destset met de naam OD_Origin en OD_Destination (OD_Org, OD_Dest). Alles erna (de plaatsen, de herkomstblokken, de benen, de directe ritten en de auto) heeft dan een herkomst en een bestemming. De buurtvariant blijft die van de sets (ModelParameters/Impl/Buurtset).
- commentaar regel 12-13: Met select_with_org_rel en de attributen die het model leest: select_with_attr_by_cond zou alle attributen van de set meenemen, ook die van bronnen die er niet zijn (de inwoners per 100 m-vierkant bij de buurten).
- commentaar regel 86-87: #123: het NS-station van een halte (ook van een bushalte bij een station) en, voor een treinhalte, de IFF-overstaptijd van dat station; null voor andere haltes en met IFF_Overstaptijd uit. CreateTransfers_T legt hem op als ondergrens.
- commentaar regel 123-127: #113: zonder flex (ModelParameters/Advanced/IncludeFlex = FALSE) gaan alle links van flex-lijnen uit beide netten (Set_L laat wachtlinks van flexritten bij stations toe, vandaar ook daar). Leeg als flex meedoet, zodat de select-expressie van Set_R/Set_L letterlijk gelijk blijft aan die van voor #113. Exact, want in Set_R/Set zijn de samenhangende Components per route (NodeSet = (tijd, halte, route)): flex-links weglaten verwijdert precies de flex-Components en raakt geen enkel ander been.
- commentaar regel 131-132: Het L-net: de vervoerders met NS-tarief (Agencies/IsLnet: NS en, sinds 2026-10-02 (#3), NS International) zonder de treinen waarop een NS-kaartje nooit geldt (Routes/IsZonderNSKaartje: Eurostar, Nightjet), plus de stilstandlinks op NS-stations.
- commentaar regel 164-174: Directe ritten naast het OV. Per toegestane modaliteit (ModelParameters/Impl/AllowDirectWalking, -Cycling, -Car; de lijst staat in Advanced/DirectModes) de volledige HB-tabel uit /NetworkSetup/PrivateTransport, samengevoegd tot een tabel met dezelfde kolommen. De ketenrijger (PublicTransport/PerDepartureMoment_T, Union_with_DirectOD) voegt per blok deze rijen bij de OV-ketens en houdt per HB-paar het Pareto-front op MinimiseCriteria (prijs, tijd) over. Tot 2026-09-23 deed of lopen of fietsen mee en de auto niet.  Prijs per modaliteit: lopen en fietsen krijgen een tijdwaardering (Direct_*_Time_Costs), die alleen in Price meetelt als Include*CostsInPrice aan staat; de auto krijgt een kostprijs: Car_FixedCosts_PerTrip plus afstand x Car_CostPerKm (sinds 2026-10-05, #88; tot dan de som van linkkosten). Price_Augm is voor lopen en fietsen de tijdwaardering zelf en voor de auto gelijk aan Price: een tijdwaardering voor autorijden is er niet. De autoreistijd is die van Car_CongestionMoment_ForDirect.
- commentaar regel 198-209: De auto-HB-tabel met afstand (de _w_AltImp-variant van PrivateTransport_Car_T: alt_imp is de afstand in km), TomTom of OSM. Met ParetoLegs_Car de _pareto-variant: per HB-paar het (reistijd, afstand)-front, dus meerdere rijen per paar; de eindafweging houdt daarvan per paar het niet-gedomineerde deel over. De prijs volgt bij het lezen: afstand x Car_CostPerKm + Car_FixedCosts_PerTrip (sinds 2026-10-05, #88). Tot dan droeg de store de linkkosten (kilometerprijs per wegklasse en optrekkosten) als tweede criterium, en was de afstand onbekend.  Per congestiemoment een store volgens de MMD-regels van 20.19.0 (#1245), zoals de ketens: Calc_Car is de rekenkant, Write_Car de holder die alleen de vier kolommen bewaart, Read_Car de kale lezer (declareert niets, de dictionary van de mmd levert de kolommen) en Car (CarFront_T) de afgeleiden, de samenvatting per HB-paar en het uitgedunde front (Car/Front). De handtekening (Signature) draagt alles wat de inhoud bepaalt; de naam sinds 2026-10-03 alleen het moment, de herkomst- en bestemmingenset en een hash van de handtekening (NetworkModel_PBL#118). Eerst Write_Car berekenen (40 min scalair, langer met pareto; batch/UpdateAll.cmd cars doet alle momenten), dan herladen.
- commentaar regel 260-261: DE LINKS VAN DE ROUTES (sinds 2026-10-21, #129), alleen in de HB-paarmodus met een tijdafhankelijke store: per route (een rij van de store) de links in de volgorde van de rit, met de vorm van de weg uit TomTom.
- commentaar regel 289-293: De directe autorit uit (een deel van) een autostore: Rows met de vier kolommen van de store, de afgeleiden per rit, de samenvatting per HB-paar en het uitgedunde front (Front). DirectCarStore_T neemt de hele store; met CarTimeDependent neemt de eindafweging van elk blok en vertrekmoment alleen de rijen van de herkomsten van haar blok (PerDepartureMoment_T, DirectCar; sinds 2026-10-12, #132). Een HB-paar ligt binnen een herkomst, en pareto_optimal_eps beslist per paar, in de volgorde van de rijen, dus het front van een paar is in beide hetzelfde. De paden zijn absoluut: in een blok heet de herkomstenset van het blok ook impl/org.
- commentaar regel 310-311: Samenvatting per HB-paar (Org_Dest): aantal routes in het front, kortste en langste reistijd, kortste en langste afstand. Scalair is nr_routes overal 1 en zijn min en max gelijk.
- commentaar regel 331-334: Uitdunning bij het lezen (GeoDMS >= 20.21.0, pareto_optimal_eps), sinds 2026-10-05 met de relatieve CarFrontEpsilon (GeoDMS #1282): in volgorde van afstand (de prijs) blijft een langere route alleen als ze meer dan die fractie sneller is dan de kortere routes die blijven, de regel van de zoektocht zelf; met dezelfde epsilon als de store dunt dit niets meer uit. De kortste route blijft altijd. Eerder op 2026-10-05 reistijd eerst, met tijdbakken van 60 s en afstandsbakken van 400 m, waarin een kortere route de snelste kon vervangen.
- commentaar regel 355-355: De directe autorit die meedoet in het front: het moment van Car_CongestionMoment_ForDirect.
- commentaar regel 369-371: Met CarTimeDependent (sinds 2026-10-09, #132) hangt de autorit van het vertrekmoment af: hij staat dan niet in Direct_OD, maar per moment in een eigen store (Direct/CarPerMoment/TD<moment>), en de eindafweging van elk blok en moment leest daaruit de rijen van haar herkomsten en voegt ze toe (PerDepartureMoment_T, CarRows en Direct_OD_M). Zonder andere directe modaliteit (Component Auto) is Direct_OD dan leeg.
- commentaar regel 418-430: DE BENEN VAN HET VOOR- EN PostTransport IN STORES (sinds 2026-10-19): een keer per peildatum, herkomstenset en bestemmingenset de basissets, lopen en fietsen naar elke halte en fietsen van elke halte, elk een parquet-bestand in IntermediateResults (LegStores/<type>/Write_Legs; batch/UpdateAll.cmd legs), zodat ze ook buiten het model bruikbaar zijn: per been de buurt (CBS-code), de halte (GTFS stop_id en stop_name), de netwerkreistijd in minuten en de afstand in meter (float64, zodat het model ze exact terugleest). De naam noemt de buurtset: Legs_B2025toStops_Walking_<hash>.parquet, Legs_Stops2B2025_Cycling_ <hash>.parquet; de handtekening staat ernaast in <naam>.signature.txt. Lopen van een halte naar de bestemmingen is het spiegelbeeld van lopen van de buurten naar de haltes als herkomsten en bestemmingen dezelfde set zijn (WalkingMirror): het loopnet heeft geen eenrichting. Fietsen niet: het fietsnet van de Fietsersbond heeft eenrichtingsfietspaden. Ze hangen niet af van het PartOfDay of de component. De andere typen zijn een selectie daaruit (Legs/<type>/ODMatrix): de route naar een halte is dezelfde, welke haltes er ook doelen zijn, dus C_RM, C_RMT en C_Ric zijn C_ naar die haltes, RM_C, RMT_C en OVf_C zijn _C van die haltes, met hun eigen maximale tijd (die niet langer mag zijn dan die van de basisset). Start- en parkeertijd en de prijs volgen bij het lezen, zoals in Templates/CreateNetwork_Pedestrian_Bike_T. Tot 2026-10-20 waren de stores mmd, tot 2026-10-19 rekende elke run (elke portie blokken) de benen van zijn component opnieuw.
- commentaar regel 504-505: DE LINKS VAN DE BENEN (#129), alleen in de HB-paarmodus (ModelParameters/Impl/IsOD): per been, in de volgorde van de reis, de links van zijn route over het vereenvoudigde net (Create_Routes/Links), elk met zijn rechte lijn, als gpkg naast de store.
- commentaar regel 563-563: de buurt is een herkomst in het PreTransport en een bestemming in het PostTransport, ook bij het spiegelbeeld
- commentaar regel 578-578: start- en parkeertijd en prijs zoals in Templates/CreateNetwork_Pedestrian_Bike_T
- commentaar regel 594-595: Sinds 2026-10-20 ook de plaats en de (tijd, plaats) van elke in- en uitstapgebeurtenis, zoals PT ze per keten rekent: de ketens van een herkomstblok (PublicTransport/PT_InBlock) zoeken ze hier op, in plaats van dat PT ze voor alle ketens uitrekent.
- commentaar regel 674-674: om een keten terug te leiden naar zijn benen (sinds 2026-10-21, #129; alleen gevraagd in de HB-paarmodus, OD_Ketens)
- commentaar regel 718-720: Sinds 2026-09-29 schrijft elk blok zijn ketens in een eigen store (StorageBlockDir_Str/<n>of<N>.mmd), zodat de resultaten niet tot het eind in het geheugen blijven en een onderbroken ketenstap bij het eerste ontbrekende blok verder kan (batch/WriteChainBlocks.ps1, PT_Chains_Blocks/ToDo).
- commentaar regel 743-746: De traceer-attributen Block_rel en result_rel staan BUITEN de store: sinds GeoDMS 20.19.0 (issue #1245) weigert de MMD-writer elk item met DisableStorage onder zijn holder, want alles onder de holder hoort bij de store. Calc is de rekenkant met die twee erbij; Write houdt de naam en de StorageName en schrijft alleen de resultaatkolommen.
- commentaar regel 789-790: Een read-only MMD-lezer mag zelf niets declareren (#1245): de dictionary van de store bepaalt de kolommen. Read is de kale lezer, PT geeft ze door en houdt de afgeleide relaties.
- commentaar regel 798-800: De ketenstore per blok (sinds 2026-09-29, ModelParameters/Advanced/PT_Chains_PerBlock): een lezer per blok, de blokken waarvan de store nog ontbreekt (0Dictionary.dms wordt als laatste geschreven) en de lijst van hun schrijvers voor batch/WriteChainBlocks.ps1.
- commentaar regel 811-812: De ketens van dit haltenblok die de uitvoer kan gebruiken (sinds 2026-10-20, voor PT_V): die instappen bij een halte waar een voortransportbeen van de component eindigt, met de kolommen die de vertrekmomenten lezen. collect_by_cond leest de store per tegel.
- commentaar regel 845-845: PT leest de ketens uit de store per blok (PT_Chains_PerBlock) of uit de ene store van voor 2026-09-29 (ChainGeneration_Single/Read).
- commentaar regel 880-886: De ketens die de uitvoer kan gebruiken (sinds 2026-10-20): die instappen bij een halte waar een voortransportbeen van de component eindigt (NetworkSetup/impl/IsVStop), alleen met de kolommen die de vertrekmomenten lezen, uit de store per haltenblok (PT_Chains_Blocks/PerBlock/<blok>/VBoarding). Elk herkomstblok kiest hieruit de ketens van zijn eigen PreTransport (PublicTransport/PT_InBlock), en elk vertrekmoment daaruit zijn venster (PerDepartureMoment_T/Within_VW_Window). Tot dan kozen de vertrekmomenten uit PT: alle ketens met hun afgeleide relaties in het geheugen, voor Y2025, Buurt2025 naar Buurt2025, 572 miljoen ketens en een piek van ±99 GB vastgelegd geheugen in elke portie van de uitvoerstap (W_PT_OVf_C, 2026-10-20), ongeacht de grootte van de portie. Een keten staat in de store van het haltenblok van zijn instaphalte, dus de delen overlappen niet.
- commentaar regel 905-907: De handtekening van de ketenstore: alle parameters waar de ketens van afhangen. Tot 2026-10-03 was dit de naam van de store (zonder .mmd); sinds NetworkModel_PBL#118 staat hij als hash in de naam (StorageBase_Str) en voluit in signature.txt in de map van de store (sinds 2026-10-06; tot dan in <naam>.signature.txt ernaast).
- commentaar regel 918-920: De pareto-benen (ObjectVision/NetworkModel_PBL#115) veranderen de inhoud van dit bestand, dus moeten ze in de handtekening staan: anders overschrijft een pareto-run stilzwijgend het scalaire resultaat waarmee hij vergeleken moet worden.
- commentaar regel 924-924: Flexvervoer (ObjectVision/NetworkModel_PBL#113, #116): '_noflex', of '_flex<i>i<w>w<c>ct' met de flexparameters; leeg als die alle drie 0 zijn.
- commentaar regel 926-926: NS International en rit-opslag (ObjectVision/NetworkModel_PBL#3): leeg met de standaard, anders '_' met I, R of w<min>.
- commentaar regel 928-928: Prijs-, overstap- en halteparameters (audit 3.4): zonder deze tag las een gewijzigde parameter stil de oude ketens terug.
- commentaar regel 930-930: Een HB-paar (sinds 2026-10-21, #129): de ketens van de haltes van de herkomst naar die van de bestemming, met de maximale tijden van het PostTransport.

## cfg/main/NetworkSetup/PublicTransport.dms

- `Rijen` (regel 12): Per vertrekmoment de rijen per soort optie.
- `Paren` (regel 16): Per vertrekmoment de unieke HB-paren per groep.
- `Traveltime` (regel 32): De reistijd van de snelste optie van het paar op dit vertrekmoment.
- `NrMoments` (regel 54): pcount over een uint64-domein levert uint64, vandaar de conversie.
- `Paren_Samen` (regel 59): De unieke HB-paren per groep over alle vertrekmomenten samen.
- `File` (regel 94): Per HB-paar: herkomst en bestemming, van de goedkoopste optie van elk vertrekmoment de mediane, snelste en traagste reistijd (min), de mediane afstand (m) en prijs (euro), en het aantal vertrekmomenten met een optie.
- `Places` (regel 125): Alle plaatsen (haltes, herkomsten, bestemmingen). Tot 2026-10-07 met origin_sub_rel, de herkomst in het blok, waarop V en Direct_OD hun rijen kozen; nu kiezen die op het herkomstblok (NetworkSetup/impl/OrgBlockSelections/OrgBlock_rel).
- `OD_code` (regel 126): Een element per paar (herkomst, bestemming) van Places; voor de unieke HB-paren van de tellingen.
- `V` (regel 135): PreTransport
- `PT_V_rel` (regel 165): De keten in PT_V, om een optie terug te leiden (sinds 2026-10-21, #129; alleen gevraagd in de HB-paarmodus).
- `N` (regel 168): PostTransport
- `PerVertrekmoment` (regel 181): (geen Descr)
- commentaar regel 7-9: Tellingen van dit blok voor <OutputDir>/od_tellingen.csv en unieke_od_tellingen.csv (sinds 2026-10-04), uit de kleine resultaten achter het hek van elk vertrekmoment (PerDepartureMoment_T, LongFormat/Results_Traveltime/Tellingen). De blokken hebben elk hun eigen herkomsten, dus NetworkSetup/ConfigurationPerBlock/Generate_Output/OD_Tellingen telt ze op.
- commentaar regel 21-22: De unieke paren over alle vertrekmomenten samen: de paren van de momenten onder elkaar, dan per paar of een van de momenten het paar in de groep heeft.
- commentaar regel 46-48: De goedkoopste optie van elk vertrekmoment over de momenten met een optie (sinds 2026-10-19; van 2026-10-08 tot 2026-10-19 de snelste, #53), voor Mediaan/File: de mediaan van de reistijd (rth_element interpoleert, dus bij een even aantal het gemiddelde van de twee middelste), de snelste en de traagste reistijd, en de afstand en de prijs, elk apart.
- commentaar regel 55-55: OD_code is combine_unit_uint64(Places, Places): de eerste factor, de herkomst, varieert het langzaamst.
- commentaar regel 69-72: De tellingen van dit blok in een klein bestand (sinds 2026-10-16), Tellingen/tellingen_<n>of<N>.csv: batch/OdTellingen.py telt die van de blokken op tot od_tellingen.csv en unieke_od_tellingen.csv, zonder de uitvoer opnieuw te lezen (die kan parquet zijn, ModelParameters/OutputFormat). Per regel de tabel (rijen of paren), de soort of groep, de tellingen per vertrekmoment en het totaal: bij rijen de som, bij paren de unieke paren over de momenten samen.
- commentaar regel 82-87: De mediaan per HB-paar over de vertrekmomenten (sinds 2026-10-08, #53), alleen met ModelParameters/Advanced/MakeMedian (sinds 2026-10-19 standaard uit; de medianen worden niet opgeleverd). Per vertrekmoment de goedkoopste optie (de laagste prijs, bij gelijke prijs de laagste reistijd; Tellingen/Paren achter het hek van het moment; tot 2026-10-19 de snelste, zoals geleverd voor Y2023), dan per paar de mediaan over de momenten met een optie (Tellingen/UniekeParen). Een bestand per blok, Mediaan/tt_<datum>_mediaan_<n>of<N>.csv (sinds 2026-10-09 in een eigen map; tot dan in PerBlock), in dezelfde opvraging als de uitvoer. Tot 2026-10-08 las een Python-script (75a0884) daarvoor de csv's opnieuw (Auto, Buurt2023: 284 GB).
- commentaar regel 99-100: Hetzelfde als parquet (sinds 2026-10-16, ModelParameters/OutputFormat 'parquet'), met zstd; zie PerDepartureMoment_T, CreateExports/LongFormat/Parquet.
- commentaar regel 131-134: Het voor- en PostTransport van dit blok (sinds 2026-10-07): de voortransportbenen van NetworkSetup/impl/V_org met dit herkomstblok, met de tekst OrgName alleen voor die benen, en alle natransportbenen (NetworkSetup/impl/N). Tot dan verenigde elk blok alle benen opnieuw en koos het de voortransportbenen waarvan de herkomst in het blok lag (IsRelevantForOrgSubset): dezelfde benen, in dezelfde volgorde.
- commentaar regel 141-144: De OV-ketens van dit blok (sinds 2026-10-20): die van PublicTransport_Prep/PT_V die instappen bij een halte waar een voortransportbeen van dit blok eindigt, met de relaties die de vertrekmomenten lezen; elk vertrekmoment kiest hieruit zijn venster (PerDepartureMoment_T/Within_VW_Window). Andere ketens koppelt Add_V_to_PT aan geen enkel been, dus het front verandert niet. Een halte die meer herkomsten van het blok bereiken, telt een keer; de koppeling per herkomst komt pas in Add_V_to_PT.
- commentaar regel 170-173: De directe ritten van de herkomsten van dit blok: de rijen van NetworkSetup/impl/Direct_OD met dit herkomstblok, met de tekst ModeUsed alleen voor die rijen. Tot 2026-10-07 rekende elk blok de plaatsen, het bezit en de tekst over de hele tabel (Direct_OD_all) en koos het daarna de rijen waarvan de herkomst in het blok lag (IsRelevantForOrgSubset): dezelfde rijen, in dezelfde volgorde, want elke herkomst is een plaats en het blok kiest zijn herkomsten op OrgBlockSelections/OrgBlock_rel.

## cfg/main/NetworkSetup/PublicTransport_Prep/Get_Windowed_Agency_Set_T.dms

- `Get_Windowed_Agency_Set_T` (regel 1): (geen Descr)
- `DepTrip_rel` (regel 59): #3: de rit van een link die uit deze knoop vertrekt (een geplande link of een stilstandlink, die ook bij een rit hoort). Een been ligt op een route en volgt in de praktijk een rit; MakeODs/OD_L bepaalt hiermee of het de HSL Schiphol-Rotterdam berijdt.
- commentaar regel 53-56: #3 (sinds 2026-10-02): mag een been hier beginnen (instappen) of eindigen (uitstappen)? Volgens de GTFS-stop_time van de rit(ten) op deze knoop: het begin van de vertrekkende en het eind van de aankomende links in de set, geplande en wachtlinks (zie PublicTransportNet/FromPickupAllowed). MakeODs/OD_L en OD_R houden alleen benen met CanBoard aan het begin en CanAlight aan het eind.

## cfg/main/NetworkSetup/PublicTransport_Prep/CreateTransfers_T.dms

- `CreateTransfers_T` (regel 1): (geen Descr)
- commentaar regel 42-45: Sinds 2026-10-13 (#123): tussen twee verschillende treinhaltes (perrons) van hetzelfde NS-station minstens de IFF-overstaptijd van dat station (Stops/IFF_Overstaptijd_rel, ModelParameters/Advanced/IFF_Overstaptijd), naast de looptijd over de rechte afstand. Op dezelfde halte en tussen trein en bus, tram of metro blijft het de looptijd. Tot dan alleen de looptijd: in Utrecht Centraal 0,7 min van perron 1 naar perron 5, waar 9292 tussen 4 en 6 min eist en de IFF 5 min.

## cfg/main/NetworkSetup/PublicTransport_Prep/OD_extra_attributen.dms

- `IsFlexLeg` (regel 28): #113: been op een flex-lijn = een instap op een flex-lijn
- `ModeCode` (regel 38): De mode van het been als cijfer van ModeCode (Classifications/GTFS_Modes/CodeDigits): mode-id + 1. Tot 2026-10-06 ModeUsed, de letter (name_abbr).
- commentaar regel 22-27: #113: een been ligt op een route (NodeSet is per route), dus een been = precies een instap; de flex-toeslag hoort daarom bij het been en niet bij de links. Post hoc is exact: Dijkstra kiest binnen een OD-paar niet tussen routes, de concurrentie tussen routes gebeurt in de ketenrijger, die deze Traveltime sinds 2026-09-26 als criterium heeft zodra er een tijdpenalty is (Classifications/ChainJoinerParetoAttr_Candidates, audit 6.2); tot dan niet, zodat een keten met flex-been een even dure zonder kon verdringen. Zonder extra wachttijd voor flex (ModelParameters/Impl/FlexHasTimePenalty) blijft de expressie letterlijk 'Impedance[s]' (CalcCache).
- commentaar regel 29-30: #3: de extra tijd van de rit-opslag (ModelParameters/Advanced/TripSurchargeTrains/ExtraTijd) staat in TripSurcharge_ExtraTime van OD_L (0 in OD_R) en komt er alleen bij als hij ergens groter dan 0 is, zodat de expressie anders gelijk blijft.
- commentaar regel 34-35: #3 (sinds 2026-10-02): mag je aan het begin van dit been instappen en aan het eind uitstappen (GTFS pickup_type en drop_off_type, zie Set/NodeSet/CanBoard en CanAlight)? OD_L/Result en OD_R/Result houden alleen deze benen.
- commentaar regel 70-72: DOVA-modus: key = mode-klasse (BTM/Rail/Ferry) + '_' + concessie. NS-trein zit in het L-net en komt hier niet. Legs buiten alle concessie-polygonen (buitenlandse trajectdelen De Lijn/DB/Eurobahn) krijgen 'Buitenland' en matchen de vangnetrijen in FareTable_DOVA; anders faalt Price_IntegrityCheck in DOVA-modus.
- commentaar regel 79-81: Check niet alleen dat er een FareTable-rij matcht, maar ook dat die rij daadwerkelijk prijzen bevat (een gematchte rij met lege prijs zou anders stilletjes null-prijzen opleveren). IsDefined() geeft altijd een echte bool (ook bij null-rel), dus de && propageert geen nulls.
- commentaar regel 86-87: Diagnose bij FAIL van Price_IntegrityCheck (duur, alleen on-demand bekijken): de unieke combinaties zonder FareTable-match of met een rij zonder prijs, met het aantal getroffen OD-legs per combinatie.

## Group A (trailing comments)

- cfg/main/NetworkSetup/PublicTransport_Prep.dms: //indirection, want dan kun je die later gebruiken in een select_with_attr_by_cond waarbij alle attributen worden opgehaald.
- cfg/main/NetworkSetup/PublicTransport_Prep.dms: //inEind
- cfg/main/NetworkSetup/PublicTransport_Prep.dms: // bij een HB-paar het laatste been van de langste ketens alleen naar de haltes van de bestemming (sinds 2026-10-21, #129)
- cfg/main/NetworkSetup/PublicTransport_Prep.dms: //fka uq_OD_key; bij een HB-paar alleen de ketens naar de haltes van de bestemming (sinds 2026-10-21, #129)
- cfg/main/NetworkSetup/PublicTransport_Prep.dms: // '_chainrel1pct': de relatieve epsilon op de reistijd in de ketenrijging (GeoDMS #1282; tot 2026-10-05 '_chaineps10ct60s'), leeg als die uit staan
- cfg/main/NetworkSetup/PublicTransport_Prep.dms: PT_Chains_Revision; // '_r2' sinds audit 3.5 (2026-09-25)

## cfg/main/NetworkSetup/PublicTransport/PerDepartureMoment_T.dms

- `PerDepartureMoment_T` (regel 1): (geen Descr)
- `Max_V_Time` (regel 6): Langste voortransportbeen dat nog geldig kan zijn: de grootste Max*Time-grens (op netwerktijd) plus de start- en parkeertijden die sinds 2026-09-23 in het been zitten. Begrenst het venster van OV-vertrekken; te ruim is onschadelijk, te krap laat combinaties weg.
- `Within_VW_Window` (regel 16): Opties binnen PreTransport + wachten thuis window
- `IsPT_departureEvent_ActualPT0` (regel 65): the departure event should be a depature event, and not waiting or already a transfer. To make sure, this check is built in.
- `V_time_net` (regel 76): Netwerkreistijd van het PreTransport, zonder start- en parkeertijd; hierop toetst IsVTimeNotTooLong.
- `Price_V` (regel 92): Het deel van Price voor het PreTransport: V_price als dat meetelt (V_PriceCounts), anders 0. Sinds 2026-10-02 apart in de uitvoer (PretransPrice).
- `VPT_rel` (regel 137): De rij van Add_V_to_PT (alleen gevraagd in de HB-paarmodus, OD_Uitvoer).
- `N_time_net` (regel 153): Netwerkreistijd van het PostTransport, zonder starttijd; hierop toetst IsNTimeNotTooLong.
- `Price_N` (regel 163): Het deel van Price voor het PostTransport, zoals Price_V voor het PreTransport (PosttransPrice in de uitvoer).
- `VPTN_rel` (regel 217): De rij van Add_N_to_VPT (alleen gevraagd in de HB-paarmodus, OD_Uitvoer).
- `Org_InBlock` (regel 237): Is de herkomst in dit blok? Zoals ConfigurationPerOrgBlock_T/org.
- `CarRows` (regel 242): De rijen van de store van dit moment voor de herkomsten van dit blok, in de volgorde van de store: dezelfde rijen als de keuze uit de hele tabel tot 2026-10-12.
- `Store_rel` (regel 249): De rij van de autostore (alleen gevraagd in de HB-paarmodus, OD_Uitvoer).
- `Bron_rel` (regel 318): De rij van Add_N_to_VPT/Result of, bij een directe rit (IsDirectTravel), van Direct_OD_M (alleen gevraagd in de HB-paarmodus, OD_Uitvoer).
- `Union_rel` (regel 373): Alleen gevraagd in de HB-paarmodus (OD_Uitvoer).
- `Price_PT` (regel 393): Het OV-deel van Price: de ketenprijs zonder voor- en PostTransport; 0 bij een directe rit.
- `First_rel` (regel 422): Alleen gevraagd in de HB-paarmodus (OD_Uitvoer).
- `N_IsWalking` (regel 433): FALSE bij een directe rit: N_mode_rel is daar leeg.
- `TravelDist_Car` (regel 437): De afstand van de directe autorit (PublicTransport_Prep/Direct/Car, sinds 2026-10-05 de afstand van de route in het front op reistijd en afstand, #88), 0 bij elke andere optie.
- `CreateExports` (regel 450): (geen Descr)
- `Columns` (regel 497): De kolommen van de OV-uitvoer na OrgName en DestName, in deze volgorde en elk met het vertrekmoment achter de naam; name is ook het item hierboven. kind 'dist' komt alleen in het bestand met Export_TravelledDistance, 'price' alleen met Export_PriceInformation. Nieuwe kolommen achteraan, zodat een lezer op positie de bestaande houdt.
- `Parquet_Direct` (regel 537): WW en CC: alleen de reistijd (een route per HB-paar; afstand en prijs volgen uit de reistijd).
- `Parquet_Car` (regel 548): Car: reistijd en afstand van elke route in het front (de prijs is Car_FixedCosts_PerTrip plus de afstand maal Car_CostPerKm).
- `Parquet_PT` (regel 560): Een OV-component: reistijd, prijs, de gewaardeerde prijs, de vervoerwijzen, het wachten thuis, de tijd van voor- en PostTransport en de afstand per OV-vervoerwijze.
- `Generate` (regel 586): Schrijft File, de csv van dit blok en vertrekmoment, of bij OutputFormat 'parquet' (sinds 2026-10-16) de parquet-schrijver van de soort component (Parquet_<ExportClass>, sinds 2026-10-19), en geeft alleen 'Ready' terug. Tot 2026-10-07 ='File': dan ging de hele tekst door de opvraging, en plakte de opvraging over alle blokken alle teksten aan elkaar (Auto, Buurt2023 naar Buurt2023: 284 GB), die tot het eind per blok in het geheugen bleven.
- `TravelDist` (regel 628): Voor-, OV- en PostTransport; bij een directe rit alleen TravelDist_V.
- `TijdBijGoedkoopste` (regel 631): De reistijd van een rij met de laagste prijs van zijn paar, anders leeg: min_index kiest zo de snelste van de goedkoopste.
- commentaar regel 9-13: De OV-ketens die binnen PreTransport plus wachten thuis vertrekken. Sinds 2026-09-27 (audit 6.7) met de ondergrens inTime: een keten die eerder vertrekt haalt IsWaitingTimeValid toch nooit, maar werd wel aan alle voortransportbenen gekoppeld; bij vertrek 07:45 met de ketenstore 07:00-09:29 was dat 59% van de rijen (307 van 523 miljoen op herkomstblok 1). Sinds 2026-10-20 uit de ketens van het blok (PublicTransport/PT_InBlock), tot dan uit alle ketens (PublicTransport_Prep/PT): dezelfde rijen voor het front, in dezelfde volgorde, zonder de ketens die bij geen voortransportbeen van het blok instappen.
- commentaar regel 23-23: de letters per been (sinds 2026-10-06 uit de uint32 ModeCode van de ketenstore), een keer per verschillende code
- commentaar regel 41-41: de herkomst van elke rij, om een optie terug te leiden (sinds 2026-10-21, #129; alleen gevraagd in de HB-paarmodus, OD_Uitvoer)
- commentaar regel 70-72: Aankomst bij de halte uiterlijk op het vertrek; sinds 2026-09-27 (audit 6.7) mag dat ook precies op het vertrek, zoals bij een overstap (CreateTransfers_T: Transfer_Time >= Walking_Time). Tot dan niet, zodat vanaf een herkomst met toegangstijd 0 het vertrek op het vertrekmoment zelf ontbrak (herkomstblok 1, 07:45: 32 van 31.903 paren een ander front).
- commentaar regel 89-90: Het PreTransport telt in Price mee zoals de directe rit van dezelfde modaliteit: fietsen met IncludeCyclingCostsInPrice, lopen sinds 2026-09-26 met IncludeWalkingCostsInPrice (audit 6.4; tot dan betaalde alleen de directe looprit).
- commentaar regel 161-161: Het PostTransport net als het PreTransport (audit 6.4).
- commentaar regel 221-222: Zonder OV (Component Auto, ModelParameters/Impl/WithPT FALSE, #117) alleen de directe ritten: dan verwijst niets naar Add_N_to_VPT, en rekent de eindafweging geen ketens, voor- en PostTransport.
- commentaar regel 225-226: De directe ritten van dit vertrekmoment (sinds 2026-10-09, #132): die van het blok (Direct_OD, niet afhankelijk van het moment) en, met de tijdafhankelijke autorit (ModelParameters/Impl/CarTimeDependent), de autoritten van dit moment uit de store van dit moment.
- commentaar regel 231-236: Sinds 2026-10-12 kiest het blok zijn rijen uit de store zelf en rekent het prijs, front (CarFront_T) en plaatsen alleen voor die rijen. Tot dan kozen de blokken uit tabellen met alle rijen en hun afgeleiden (NetworkSetup/impl/DirectCarTD), die voor Y2023, Buurt2023 naar Buurt2023, 4 x 800 miljoen rijen in het geheugen hielden: een piek van 97,9 GB vastgelegd geheugen in de uitvoerstap, 88,3 GB voor de eerste portie van 50 blokken. Nu is dat 2,5 GB, met dezelfde uitvoer (byte voor byte). De keuze gaat per tegel van de store (64K rijen): collect_by_cond leest alleen de tegels waarin het blok rijen heeft. Een lookup in de store (<kolom>[rij]) maakt eerst een aaneengesloten kopie van de hele kolom (3,2 GB), per blok, moment en kolom; een variant die zo per herkomst de rijen las, deed 100 s per blok.
- commentaar regel 277-277: de herkomst van elke rij (sinds 2026-10-21, #129; alleen gevraagd in de HB-paarmodus): een rij van Direct_OD of, met CarTD, van DirectCar_M
- commentaar regel 304-304: De directe rit staat, net als zijn reistijd (V_time) en afstand (TravelDist_V), in de kolom van het PreTransport.
- commentaar regel 310-311: Criteria van de eindafweging als MinimiseCriteria 'Car' en 'Bike' noemt (Classifications/OwnershipParetoAttr, #117). Een OV-keten vraagt geen auto (er is geen P+R-PreTransport), en alleen een fiets als een voor- of natransporttype dat doet.
- commentaar regel 319-320: Modaliteit van het voor- en PostTransport, voor de uitsplitsing naar lopen, fiets en auto in de uitvoer. Een directe rit staat in het PreTransport (zie Price_V); zijn PostTransport heeft geen modaliteit.
- commentaar regel 339-340: NeedsCar en NeedsBike (#117) zijn bool-criteria zonder epsilon (GeoDMS #1287, vanaf e04ad20f0; een oudere engine geeft 'Cannot find operator').
- commentaar regel 382-383: NeedsCar en NeedsBike (#117) zijn bool-criteria zonder epsilon (GeoDMS #1287, vanaf e04ad20f0; een oudere engine geeft 'Cannot find operator').
- commentaar regel 424-428: Sinds 2026-10-03 (bespreking PBL 21-09-2026, punt 2) afstand, reistijd en prijs ook per modaliteit. Het OV is de OV-keten (TravelDist_PT, PT_time, Price_PT), met het lopen en wachten bij overstappen; lopen, fiets en auto zijn het voor- en PostTransport en de directe rit met die modaliteit. De wachttijd thuis (W_time) valt onder geen van de vier. De auto had van 2026-10-03 tot 2026-10-05 geen afstand, toen het autofront de kosten droeg in plaats van de afstand (0eb61ea); sinds het front op reistijd en afstand staat (#88) is TravelDist_Car er weer.
- commentaar regel 456-459: Een onbekende waarde wordt een leeg veld: de directe autorit had tot 2026-10-05 geen afstand (TravelDist_V null), en een null in de samengestelde regel maakte de hele regel null, zodat alle autoritten uit de csv verdwenen (2026-09-24). Sinds 2026-10-03 heet elk item hieronder naar zijn kolom (zonder het vertrekmoment), en bepaalt Columns welke kolommen in welke volgorde in het bestand komen; tot dan waren er vier met de hand bijgehouden varianten van kop en regel (audit 3.6).
- commentaar regel 464-464: Sinds 2026-10-02 (#117) een eigen kolom per bezitscriterium, 0 of 1, ook als MinimiseCriteria ze niet noemt.
- commentaar regel 478-479: Sinds 2026-10-02 (bespreking PBL 21-09-2026, punt 2) Price uitgesplitst zoals de reistijd: PreTransport, OV en PostTransport, samen precies Price. Een directe rit staat in het PreTransport, zoals bij V_time en TravelDist_V.
- commentaar regel 483-485: Sinds 2026-10-03 de OV-afstand in een kolom, en afstand, reistijd en prijs per modaliteit (zie Result_AfterSecondCondensation). Het OV per modaliteit is het OV-deel hierboven: TravelDist_PT, PTTime en PTPrice. TravelDist_Car (sinds 2026-10-05 weer, #88) staat als laatste kolom, zodat de kolommen van 2026-10-03 hun plaats houden.
- commentaar regel 523-528: Sinds 2026-10-16 de uitvoer ook als parquet (ModelParameters/OutputFormat 'parquet', sinds 2026-10-19 de standaard), met zstd, getypt (tijden in min en prijzen in euro als float32, afstanden in m als uint32), een onbekende waarde null, zonder het vertrekmoment in de kolomnamen (dat staat in de bestandsnaam). Export_TravelledDistance en Export_PriceInformation gelden alleen voor de csv. GDAL_LayerCreationOptions staat naast de containers met de storage: erin zag de schrijver hem als kolom van een laag zonder domein (Domain mismatch ... layerDomain void, 2026-10-16); hij zoekt hem ook in de containers erboven.
- commentaar regel 530-536: Sinds 2026-10-19 per soort component alleen de kolommen die binnen de component varieren en niet lineair uit andere volgen (zoals de afstand van een loop- of fietsrit uit de reistijd, of de autoprijs uit de afstand); ModelParameters/Advanced/ ExportClass kiest de schrijver, en alleen die wordt opgevraagd (Generate). De andere kolommen zijn constant in de component (ModeUsed van een directe rit, NeedsCar, NeedsBike, WaitingTime 0) of een lineaire combinatie: TravelDist_V en _N uit de tijden van voor- en PostTransport, TravelDist_PT als som van de OV-afstanden, PTTime = Traveltime - PretransTime - PosttransTime, de prijsdelen uit Price en die tijden (het voor- en PostTransport kost per minuut, de OV-fiets een vast bedrag), en de kolommen per modaliteit uit die van voor- en PostTransport.
- commentaar regel 589-591: Tellingen voor <OutputDir>/od_tellingen.csv en unieke_od_tellingen.csv (sinds 2026-10-04). Ze staan binnen het hek, uit het eindresultaat dat voor File toch al gerekend is. De telling per blok (PublicTransport/Generate_Output/ Traveltime_ForEachDepTime/Tellingen) gebruikt alleen deze kleine resultaten, zodat het eindresultaat na de fase vrij kan.
- commentaar regel 602-602: Rijen per soort, in de volgorde van Classifications/OD_Tellingen_Soort: alle, en de vier soorten.
- commentaar regel 610-610: Unieke HB-paren, met per groep (Classifications/OD_Tellingen_Groep) of het paar een optie van die groep heeft.
- commentaar regel 621-623: De goedkoopste optie van het paar, voor de mediaan per blok (ModelParameters/Advanced/MakeMedian; PublicTransport/Generate_Output/Traveltime_ForEachDepTime/Tellingen/UniekeParen): de laagste prijs, bij gelijke prijs de laagste reistijd. Van 2026-10-08 tot 2026-10-19 de snelste optie (overleg PBL 19-10-2026).
- commentaar regel 632-632: Een telling per groep, in de volgorde van Classifications/OD_Tellingen_Groep.
- commentaar regel 647-647: De opties van het HB-paar met hun onderdelen en links (sinds 2026-10-21, #129; alleen in de HB-paarmodus), in dezelfde opvraging als de uitvoer.
- commentaar regel 653-656: Sinds 2026-10-20 alleen vertrekmoment en blok: tt_<moment>_<n>of<N>.csv of .parquet in <OutputDir>/PerBlock; de datum staat al in de naam van de uitvoermap (wens PBL 20-10, MAX_PATH). Van 2026-10-03 (NetworkModel_PBL#118) tot dan tt_<datum>_<moment>_ <n>of<N>. De herkomstenset, _DEST, modaliteiten, overstappen, criteria, MaxPT en de tags staan in de handtekening van de uitvoermap (NetworkSetup/GenerateOutput/Output_Signature); tot 2026-10-03 stonden ze hier, tot 261 tekens in het langste pad.

## cfg/main/NetworkSetup/PublicTransport/PerDepartureMoment_T.dms (trailing comments)

- // sinds 2026-10-01 met NeedsCar en NeedsBike (#117); tot dan FinalParetoAttr
- // start- en parkeertijden zitten sinds 2026-09-23 in het been zelf (ODMatrix/Duration_seconds_ext)
- //attribuut om partitionering van price/traveltime etc te doen.
- //zou allemaal false moeten zijn.In Amsterdam komen dit voor vanwege gratis ferry.
- // schrijft de handtekening van de uitvoermap, of faalt bij een andere of een te lang pad (#118)
- // WW, CC en/of AA; sinds 2026-09-23 uit DirectModes
- unit<uint64> Add_V_to_PT   := join_equal_values_uint64(V/To_Place_rel, Within_VW_Window/From_Place_rel)
- unit<uint64> Add_N_to_VPT   := join_equal_values_uint64(Add_V_to_PT/Result/To_Place_rel, N/From_Place_rel)
- unit<uint64> Union_with_DirectOD   := ='union_unit_uint64(' + (WithPT ? 'Add_N_to_VPT/Result, ' : '') + 'Direct_OD_M)'

## cfg/main/NetworkSetup/PublicTransport/PerDepartureMoment_T/OD_Uitvoer.dms

- `OD_Uitvoer` (regel 12): (geen Descr)
- `Optie` (regel 16): Het nummer van de optie van dit vertrekmoment, vanaf 1.
- `VPTN_Res` (regel 31): De rij van Add_N_to_VPT/Result.
- `Keten` (regel 38): Het rijnummer van de keten in de ketenstore van het paar, zoals OD_Ketens/Read_Benen/Keten.
- `Benen` (regel 54): Zonder OV de lege benen: dan is er geen ketenstore.
- `Delen` (regel 135): uint32: de begin- en eindpunten van impedance_matrix vragen een uint32-domein.
- `Eigen` (regel 142): De zoektocht van elk been naar zijn eigen eindknoop.
- commentaar regel 1-11: DE OPTIES VAN EEN HB-PAAR MET HUN ONDERDELEN EN LINKS (sinds 2026-10-21, #129; alleen in de HB-paarmodus, ModelParameters/Impl/IsOD). Per vertrekmoment de opties van het front (Result_AfterSecondCondensation), elk teruggeleid tot de rij van de eindafweging waar hij uit komt: een OV-reis (voortransportbeen, keten, natransportbeen) of een directe rit. Onderdelen beschrijft elke optie in de volgorde van de reis; Links geeft elk onderdeel zijn links, met een lijn per link: - voor- en PostTransport: de links van het been uit de benenstore (PublicTransport_Prep/LegStores/<basistype>/Links); - een OV-been: de halte-tot-haltelinks binnen de rit, uit een zoektocht in Set_L of Set_R tussen de begin- en eindknoop van het been (OD_Ketens/Read_Benen), die op het tijd-geexpandeerde net hetzelfde pad geeft als het been (elk pad tussen twee knopen duurt even lang, en met ParetoLegs is de keuze bij gelijke tijd de kortste, Length); - een overstap: de rechte looplijn tussen de haltes; - de directe loop- en fietsrit: de links van de zoektocht (PrivateTransport/<modaliteit>/Calc_Traveltimes_maxspeed_<modaliteit>/Links). Write schrijft ze als drie lagen van <OutputDir>/PerBlock/od_<moment>.gpkg (od_opties, od_onderdelen en od_links; GeoDMS-namen zijn
- commentaar regel 27-27: DE OV-OPTIES: de herkomst door de eindafweging heen, tot de keten in de ketenstore van het paar
- commentaar regel 53-53: de onderdelen van de keten van elke OV-optie, uit de benen van de ketenstore van het paar
- commentaar regel 68-69: ONDERDELEN: per optie in de volgorde van de reis; een directe rit is een onderdeel, een OV-reis het PreTransport, de benen en overstappen van de keten en het PostTransport.
- commentaar regel 80-81: een OV-been van zijn vertrek tot zijn aankomst volgens de dienstregeling (Rit_Vertrek, Rit_Aankomst), niet van zijn begin- tot zijn eindknoop: die kunnen een minuut stilstand bij instappen of uitstappen bevatten (07:52 instappen, 07:53 vertrek)
- commentaar regel 96-96: voor- en PostTransport: de links van het been uit de benenstore van zijn basistype, gekoppeld op de halte
- commentaar regel 127-127: een OV-been: de links binnen de rit, uit een zoektocht in zijn net tussen de begin- en eindknoop van het been
- commentaar regel 155-158: De dienstregelingstijden van het been: het vertrek van zijn eerste en de aankomst van zijn laatste geplande link. De begin- en eindknoop kunnen de aankomst- en de vertrekknoop zijn van een halte waar de rit stilstaat (instappen bij aankomst, uitstappen bij vertrek), zodat hun tijden een minuut stilstand kunnen bevatten. Binnen een rit lopen de tijden op (Time: 48 uur, zonder omslag), dus het eerste vertrek is het kleinste en de laatste aankomst de grootste.
- commentaar regel 168-169: de dienstregelingstijden van elk OV-been (een overstap heeft ze niet), voor Onderdelen; zonder OV niets, zodat een run zonder OV Set_L en Set_R niet vraagt
- commentaar regel 173-173: een overstap: de rechte looplijn
- commentaar regel 189-189: de directe loop- en fietsrit: de links van de zoektocht van het HB-paar, voor elke directe optie van die modaliteit (er is een route)
- commentaar regel 209-210: de directe autorit van dit vertrekmoment (CarTD): de links van zijn route uit de autostore van het moment (Read_CarLinks), gekoppeld op de rij van de store: optie -> Direct_OD_M -> DirectCar_M = DirectCar/Front -> CarRows -> rij van de store
- commentaar regel 229-230: De delen van Links die deze run heeft: het OV met WithPT, de directe ritten van de toegestane modaliteiten, voor- en PostTransport van de typen van de component (de andere leveren geen rijen, maar zo leest de run hun store niet).

## cfg/main/NetworkSetup/PublicTransport_Prep/OD_Ketens.dms

- `OD_Haltes` (regel 14): De haltes van het HB-paar: waar een voortransportbeen van de herkomst eindigt (IsVStop) en waar een natransportbeen naar de bestemming begint (IsNStop), met de typen van de OV-Components in MergeComponents. De typen met een stopklasse (C_RM, RM_C, OVf_C enzovoort) zijn een selectie uit de basistypen, dus die volstaan.
- `LopenV` (regel 18): Loopt een OV-component in MergeComponents naar de eerste halte?
- `FietsV` (regel 19): (geen Descr)
- `LopenN` (regel 20): (geen Descr)
- `FietsN` (regel 21): (geen Descr)
- `TypeTag` (regel 22): De typen in de handtekening van de ketenstore van het paar.
- `OD_Ketens` (regel 29): (geen Descr)
- `Blok` (regel 31): Het ene haltenblok van de HB-paarmodus (ModelParameters/Advanced/NumberOfStopBlocks).
- `Ketens` (regel 32): De ketens van het blok, in de volgorde van de store (Write_Block).
- `Chain_rel` (regel 34): Het rijnummer van de keten in Blok/Chain_Generation/<K_rel>/Result.
- `Volgnr` (regel 78): De plaats in de keten, vanaf 0: de benen op de even plaatsen, de overstappen ertussen.
- `IsL` (regel 79): Een been in het L-net (NS); anders het R-net. Bij een overstap: het been erna.
- `Duur` (regel 87): De reistijd van het been, of de tijd van de overstap: lopen en wachten.
- `Prijs` (regel 89): De prijs van het been alleen; in de keten kan een doorgaand tarief of het maximum van de opstaptarieven gelden.
- `BeginKnoop` (regel 92): De knoop van het begin van het been in Set_L/Set/NodeSet (IsL) of Set_R/Set/NodeSet.
- `EindKnoop` (regel 93): (geen Descr)
- `Benen` (regel 98): Per keten van de store de OV-benen en de overstappen, ongesorteerd; Keten_rel en Volgnr geven de volgorde.
- `Keten` (regel 125): Het rijnummer van de keten in de ketenstore van het blok (Write_Block).
- `Read_Benen` (regel 143): Kale lezer van de benen van de ketens van het HB-paar; declareert niets.
- `Benen_leeg` (regel 145): De benen in een run zonder OV (WW, CC, Car), met de kolommen van Read_Benen: daar is geen ketenstore.
- `Write` (regel 167): De ketenstap van het HB-paar: de ketens van het blok en hun benen, in een opvraging (PT_Chains_Blocks/ToDo).
- commentaar regel 1-13: DE KETENS VAN EEN HB-PAAR MET HUN BENEN (sinds 2026-10-21, #129; alleen in de HB-paarmodus, ModelParameters/Impl/IsOD). De ketenstap rekent dan een haltenblok: de ketens die vertrekken bij een halte die de herkomst bereikt met een voortransporttype, met als laatste been van de langste ketens alleen benen naar een halte vanwaar de bestemming te bereiken is, en hij houdt alleen de ketens naar zulke haltes (ChainGeneration_PerBlock_T, BlockResultContainer/Result). Voor die haltes zijn het dezelfde ketens als in de generieke store: de ketenrijger groepeert per (instapmoment, uitstapmoment, eerste NS-station), het blokfront per (instapmoment, bestemmingshalte), en de rechterbenen, overstappen en LastBoardingMoment zijn over het hele net. Eén ketenstore dient zo alle OV-Components van het paar.  Benen: per keten van de store, in de volgorde van de reis, de OV-benen en de overstappen ertussen, teruggeleid door de ketenrijger: het laatste been van een keten van type K is Right_rel (een rij van OD_<letter>/Result of Result_ToD), de overstap ervoor Valid1_rel->Transfers_rel, en de rest is Left_rel, een keten van het type zonder de laatste letter (Classifications/Chains/left), tot het eerste been in Chain_Generation/L of R. Elk OV-been houdt de begin- en eindknoop in Set_<letter>/Set/NodeSet, waaruit de uitvoerstap de halte-tot-haltelinks binnen de rit opzoekt. Write schrijft de ketens (Write_Block) en Benen (Write_Benen) in een opvraging, zodat de ketenrijger een keer rekent (de ketenstap, batch/UpdateAll.cmd chains, met PT_Chains_Blocks/ToDo).
- commentaar regel 36-36: Per ketentype en positie van een been een stuk van Benen; vanaf de tweede positie ook de overstap ervoor.
- commentaar regel 63-63: de keten van type KPos waarvan dit been het laatste is: Left_rel vanaf de keten zelf, N - Pos keer
- commentaar regel 69-69: het been: bij de eerste positie de keten van een been zelf (Chain_Generation/L of R), anders het rechterbeen van KPos; de overstap ervoor
- commentaar regel 120-120: De store van de benen, naast de ketenstore van het blok (StorageBlockDir_Str), met dezelfde handtekening.

## cfg/main/NetworkSetup/PublicTransport_Prep/MakeODs.dms

- `IsBinnenlandsBeen` (regel 38): #3: een been van NS, of een been tussen twee NS-stations in Nederland met een NS-prijs (NS International binnenlands).
- `IsRitOpslagBeen` (regel 79): Kost dit been de rit-opslag van zijn product?
- `Price_S` (regel 81): Rit-opslag van dit been (#3); de ketenrijger telt hem op naast het NS-tarief.
- `TripSurcharge_ExtraTime` (regel 83): Extra reistijd van de rit-opslag (TripSurchargeTrains/ExtraTijd), via Traveltime in OD_extra_attributen.
- `ModeFactor` (regel 91): 16 tot de macht het aantal benen van deze keten (een been): een ketenrijger met deze keten rechts schuift de ModeCode van links met ModeFactor op (ChainJoiner_T).
- `Price_T` (regel 96): Augmented costs for tranfers
- `Last_RO_AlightTime` (regel 103): om te kijken of een volgende regionale rit R of O moet zijn na een K of L, moeten we de laatste uitstaptijd bijhouden
- `Price_O` (regel 135): Variabel deel van de prijs, plus sinds 2026-09-30 de belkosten per instap op een flexlijn (ModelParameters/Advanced/FlexCallCosts): de ketenrijger telt Price_O bij elke overstap op en maximeert Price_I binnen een reis, dus belkosten horen hier.
- `Price_T` (regel 139): Augmented costs for tranfers
- `Price_S` (regel 140): Rit-opslag (#3): alleen in het L-net.
- `TripSurcharge_ExtraTime` (regel 141): Extra tijd van de rit-opslag (#3): alleen in het L-net.
- `ModeFactor` (regel 156): 16 tot de macht het aantal benen van deze keten (een been): een ketenrijger met deze keten rechts schuift de ModeCode van links met ModeFactor op (ChainJoiner_T).
- `Last_RO_AlightTime` (regel 160): om te kijken of een volgende regionale rit R of O moet zijn na een K of L, moeten we de laatste uitstaptijd bijhouden
- commentaar regel 1-8: OD_L / OD_R zoeken per (vertrekmoment,halte) de benen binnen één tariefgroep. Zonder de pareto-optie levert impedance_matrix per OD-paar precies het SNELSTE been op, met de afgelegde afstand als bijproduct; een langzamer maar korter -- en daarmee in het R-net goedkoper -- been bestaat dan simpelweg niet meer voor de ketenrijger. Dat is ObjectVision/NetworkModel_PBL#19. Met ';pareto' erbij doet dezelfde operator een bi-criteria label-setting zoektocht op (Duration, Length) en levert hij één rij per Pareto-optimale route; de eerste rij per OD-paar draagt gegarandeerd nog steeds de scalaire minimum-reistijd (GeoDMS#856, doc/bicriteria-impedance.md). Zie /ModelParameters/Advanced/ParetoLegs_R en ParetoLegs_L.
- commentaar regel 27-32: NS specifiek Sinds 2026-09-27 (audit 6.6) moet elk NS-been een prijs hebben, niet alleen een start-eindstationpaar: een been met een paar dat niet in TariffUnitsMatrix staat kreeg Price_L null, en een rij met een null-criterium is in pareto_optimal_eps nooit optimaal, zodat het been en elke keten erover stil uit de ketens verdween. In de feed van 20241001 geen enkel. Sinds 2026-10-02 (#3) rijden ook de treinen van NS International in het L-net; hun benen naar of van het buitenland hebben geen NS-prijs en vallen uit Result (IsBinnenlandsBeen). De check blijft dus voor de benen van NS zelf.
- commentaar regel 42-47: RIT-OPSLAG (#3, sinds 2026-10-02). De toeslag van een speciale trein (ModelParameters/Advanced/TripSurchargeTrains) hangt van de rit af, niet van het stationspaar. Een been ligt op een route, en omdat de wachtlinks stilstand binnen een rit zijn, in de praktijk op een rit: die van de link waarmee het uit zijn beginknoop vertrekt (NodeSet/DepTrip_rel). Een product met een traject (HSL: Schiphol-Rotterdam) kost de opslag als die rit tussen in- en uitstaptijd beide stations aandoet, ook zonder daar te stoppen of over te stappen; een product zonder traject (ICE) kost hem op elk been. De opslag staat apart in Price_S, zodat de ketenrijger hem bij een doorgaand NS-tarief (dat Price_L herberekent) niet kwijtraakt.
- commentaar regel 52-52: De passages van de ritten met een trajectproduct langs de stations van hun traject: per geplande link begin en eind.
- commentaar regel 109-110: Bij een HB-paar (sinds 2026-10-21, #129): de benen naar een halte vanwaar de bestemming te bereiken is (OD_Haltes/IsNStop), het laatste been van de langste ketens (ChainGeneration_PerBlock_T); org_rel blijft die naar OD_L.
- commentaar regel 133-133: R specifiek
- commentaar regel 147-151: #113: bij extra wachttijd voor flex (ModelParameters/Impl/FlexHasTimePenalty) hier dezelfde grens als IsJourneyLongerThanAllowed in de ketenrijger, want de cut van impedance_matrix zit op de ruwe impedantie en de enkelvoudige keten R passeert de ketenrijger niet. Equivalent aan een cut van MaxPTTime-toeslag op alleen de flex-links (Components zijn per route). #3 (sinds 2026-10-02): alleen benen waar de GTFS in- en uitstappen toestaat (IsBoardAlightAllowed); zo valt onder meer GoVolta binnenlands af (op zijn NL-haltes alleen instappen, met reservering; uitstappen pas in Duitsland).
- commentaar regel 168-169: Bij een HB-paar (sinds 2026-10-21, #129): de benen naar een halte vanwaar de bestemming te bereiken is (OD_Haltes/IsNStop), het laatste been van de langste ketens (ChainGeneration_PerBlock_T); org_rel blijft die naar OD_R.

## cfg/main/NetworkSetup/PublicTransport_Prep/ChainJoiner_T.dms

- `ChainJoiner_T` (regel 1): (geen Descr)
- `Join_Left_Transf0` (regel 31): join left To_rel met de de transfer from_rel
- `Join_LeftT_Right` (regel 45): join Left+Transfer To_rel met de de Right from_rel
- `Price_S` (regel 100): Rit-opslag van de speciale treinen in de keten (#3, MakeODs/OD_L/Price_S): per been, dus los van het doorgaande NS-tarief in Price_L.
- `Price` (regel 112): te betalen prijs
- `x` (regel 155): hack om deadlock te omzeilen
- `Result` (regel 159): Geaggregeerde set naar 'OD-paren' om minimalisatie criterium op toe te passen
- `ModeFactor` (regel 166): 16 tot de macht het aantal benen van deze keten: het product van links en rechts (16 bij een been, OD_R/Result en OD_L/Result). Een volgende ketenrijger met deze keten rechts schuift de ModeCode van links met ModeFactor op.
- `ModeCode` (regel 167): De modes van de benen (Classifications/GTFS_Modes/CodeDigits), sinds 2026-10-06 een uint32 in plaats van de string ModeUsed; links opgeschoven met de ModeFactor van rechts. Sinds 2026-09-29 alleen voor de overgebleven ketens samengesteld; tot dan voor elke combinatie van Join_LeftT_Right (bij RRRR van haltenblok 1: 268 miljoen voor 1 miljoen ketens), ruim een derde van de rekentijd van de ketenstap.
- `First_NS_Station` (regel 171): om achteraf de NS-kosten te herberekenen moeten we bijhouden van de eerste en laaste ns-stations zijn.
- `Last_NS_Station` (regel 173): om achteraf de NS-kosten te herberekenen moeten we bijhouden van de eerste en laaste ns-stations zijn.
- `Price_augm` (regel 191): te betalen prijs, plus kosten voor tijd van vervoer/wachten die niet beprijst zijn. 
- `Last_NS_AlightTime` (regel 198): om te kijken of een volgende regionale rit R of O moet zijn na een K of L, moeten we de laatste uitstaptijd bijhouden
- `Last_RO_AlightTime` (regel 199): om te kijken of een volgende regionale rit R of O moet zijn na een K of L, moeten we de laatste uitstaptijd bijhouden
- commentaar regel 28-30: Sinds 2026-09-29 vallen de combinaties van linkerketen en overstap die met het kortste rechterbeen al boven MaxPTTime komen weg voor de tweede koppeling: bij RRRR van haltenblok 1 gaat Join_LeftT_Right van 268 naar 166 miljoen rijen, met dezelfde geldige ketens (IsJourneyLongerThanAllowed toetst dezelfde som plus een eventuele penalty).
- commentaar regel 102-102: deze tussenstapppen zijn alleen nodig indien NS_transfer_possible t.b.v. herberekeking van het treinkaartje
- commentaar regel 130-130: De eerste NS-station van de lopende NS-reis; de NS-prijs van een verlenging tegen doorgaand tarief hangt ervan af.
- commentaar regel 137-143: De groep van de paretoselectie: het OD-paar en het eerste NS-station (sinds 2026-09-26, audit 6.3). Twee ketens met een ander eerste station kunnen na verlenging met NS van volgorde in prijs wisselen, omdat het doorgaande tarief degressief is; gemeten op haltenblok 1 van 1 oktober 2024 gaf de groepering alleen op het OD-paar in 218 van 754.029 groepen een blokfront dat gemiddeld 33 ct (hoogstens 1,61 euro) te duur was. Een keten zonder NS-station telt als eigen station. Sinds 2026-09-29 is de groepering een 64-bits sleutel die pareto_optimal_eps rechtstreeks gebruikt; tot dan nummerden twee unique_uint32 over alle geldige combinaties (bij RRRR van haltenblok 1: 112 miljoen) eerst het OD-paar en dan de groep.

## cfg/main/NetworkSetup/PublicTransport_Prep/ChainJoiner_T.dms (trailing comments)

- , Descr = "deze set bevat alle mogelijke 'paden' en kan dus later geaggregeerd worden door group-by OD. En dus per OD-pair het kortste/goedkoopste pad te kiezen."
- (ObjectVision/GeoDMS#965).", URL = "https://github.com/ObjectVision/GeoDMS/issues/965"
- //van: bus, tram, walk    to bus, tram, walk  --> niks
- //van: bus, tram, walk to metro, rail, ferry --> penalty
- //van: metro, rail, ferry to metro, rail, ferry --> penalty
- //van: metro, rail, ferry to bus, tram, walk --> penalty

## cfg/main/NetworkSetup/PublicTransport_Prep/MakeODs.dms (trailing comments)

- Descr = "The last alighting time from a regional trip, kept to check whether a following regional trip after a K or L must be R or O."

## cfg/main/NetworkSetup/ComponentMerge.dms

- `ComponentMerge_Def` (regel 1): De Components en de handtekening van het samenvoegen (MergeOutput, #117); apart van ComponentMerge, want de schrijvers daar vragen via NetworkSetup/GenerateOutput/Output_Sig deze handtekening op.
- `Comps` (regel 4): De Components die samengevoegd worden, in de volgorde van Advanced/Components.
- `MergeComponents_OK` (regel 6): Noemt MergeComponents alleen namen uit Advanced/Components, elk een keer? Gecontroleerd bij het schrijven (de IntegrityCheck van ComponentMerge/PerBlock/../Write); de handtekening heeft anders _samen?-.
- `BaseDir` (regel 8): De uitvoermap van de variant zonder het achtervoegsel van de component.
- `CompSignature_T` (regel 13): (geen Descr)
- `Stored` (regel 17): De handtekening van de uitvoer van deze component; ontbreekt hij, dan is de component (nog) niet gerekend.
- `CompSignatures` (regel 21): De handtekeningen van de Components achter elkaar, elk tussen [ en ].
- `Signature` (regel 23): De handtekening van de samengevoegde uitvoer: datum, herkomstenset, de Components, de criteria (MergeCriteria) en epsilons, het formaat (sinds 2026-10-20, -m2: uit de parquet van de Components), en de handtekeningen van de Components zelf. Is een component opnieuw gerekend met andere parameters, dan klopt de samengevoegde uitvoer niet meer.
- `ComponentMerge` (regel 45): Het samenvoegen van de Components tot een Pareto-front (MergeOutput), uit de parquet van de Components; zie het commentaar hierboven. Bereken Generate, of batch/UpdateAll.cmd output met MergeOutput.
- `Generate` (regel 49): Voegt alle blokken en vertrekmomenten samen; een blok per fase, zodat zijn tussenresultaten daarna vrijkomen.
- `MergeBlock_T` (regel 53): (geen Descr)
- `Generate` (regel 94): Schrijft de samengevoegde uitvoer per vertrekmoment en de tellingen van het blok, en geeft alleen 'Ready' terug.
- `MergeMoment_T` (regel 99): (geen Descr)
- `FileTail` (regel 104): De naam van het bestand na tt, zonder extensie: tt_<moment>_<n>of<N> (sinds 2026-10-20 zonder de datum); de datum en de component of samenvoeging staan in de naam van de map.
- `Rows` (regel 225): De rijen van alle Components, in de volgorde van Comps; bij een gelijke stand op alle criteria wint de eerste (pareto_optimal_eps).
- `keep` (regel 258): Met een criterium (MergeCriteria 'Time' of 'Price') per paar de ene snelste of goedkoopste rij: het eerste criterium heeft geen epsilon.
- `CsvColumns` (regel 336): De kolommen van de csv na OrgName en DestName, in de volgorde van Parquet/tt.
- `Write` (regel 348): Schrijft de samengevoegde uitvoer van dit blok en vertrekmoment, als parquet of csv (OutputFormat).
- commentaar regel 11-11: De handtekening van elke component, zoals zijn uitvoer hem heeft geschreven.
- commentaar regel 32-44: HET SAMENVOEGEN VAN DE Components (MergeOutput; overleg PBL 5-10-2026, #117; sinds 2026-10-20 uit parquet). Per herkomstblok en vertrekmoment leest het de parquet van de Components in MergeComponents (Output/<Analysis_date>_<OutputLabel>_<component>/PerBlock), elk met de kolommen van zijn soort (Advanced/Components/ExportClass), en vult het aan wat daar constant is of uit de kolommen volgt: - WW en CC: de prijs uit de reistijd (Direct_Walking_Time_Costs, Direct_Cycling_Time_Costs, zoals PublicTransport_Prep/Direct), ModeUsed WW of CC, PretransTime = Traveltime; ze gelden voor elk vertrekmoment (SingleDepartureMoment); - Car: de prijs uit de afstand (Car_FixedCosts_PerTrip + Car_CostPerKm), ModeUsed AA, PretransTime = Traveltime; - een OV-component: alles staat in het bestand. Dan per HB-paar de rijen die niet gedomineerd worden op de criteria van het samenvoegen (Classifications/OutputParetoAttr, uit ModelParameters/MergeCriteria), met dezelfde epsilons en operator (pareto_optimal_eps) als in een run, met prijs en tijd in Ct en s; NeedsCar en NeedsBike volgen uit de component (Advanced/Components). Het resultaat in ModelParameters/OutputFormat, csv of parquet, in Output/<Analysis_date>_<OutputLabel>_Merged<MergeRunNr>/PerBlock, met de kolom Component (waar de regel vandaan komt), en de tellingen per blok in Tellingen (batch/OdTellingen.py telt ze op). Tot 2026-10-20 las het de csv van de Components en schreef het de regels ongewijzigd door; dat vroeg dezelfde kolommen in alle Components.
- commentaar regel 62-64: De tellingen van dit blok, Tellingen/tellingen_<n>of<N>.csv, zoals een componentrun ze schrijft (PublicTransport/ Generate_Output/Traveltime_ForEachDepTime/Tellingen): rijen per soort en unieke HB-paren per groep, per vertrekmoment, en de paren over de momenten samen.
- commentaar regel 107-108: Het bestand van elke component in dit blok en vertrekmoment; een component met SingleDepartureMoment (WW, CC, en Car zonder CarTimeDependent) heeft er een per blok, dat van het congestiemoment, dat voor elk vertrekmoment geldt.
- commentaar regel 114-116: Per soort component (Advanced/Components/ExportClass) een lezer, die de kolommen van zijn schrijver leest (PerDepartureMoment_T, CreateExports/LongFormat/Parquet_<ExportClass>) en de andere aanvult tot het gezamenlijke schema. WW en CC: OrgName, DestName, Traveltime.
- commentaar regel 133-133: zoals PublicTransport_Prep/Direct: de tijdwaardering, die alleen in Price telt met Include*CostsInPrice
- commentaar regel 166-166: zoals PublicTransport_Prep/Direct/Car: Car_FixedCosts_PerTrip + afstand x Car_CostPerKm; de afstand staat in hele meters in het bestand
- commentaar regel 182-182: Een OV-component: de kolommen van Parquet_PT; NeedsBike volgt uit voor- en PostTransport (Advanced/Components/NeedsBike).
- commentaar regel 247-248: de criteria (Classifications/OutputParetoAttr) in de eenheden van de eindafweging, Ct en s, zodat de epsilons dezelfde bakken geven als in een run; GeoDMS-namen zijn ongevoelig voor hoofdletters, dus TravelTime naast Traveltime_min
- commentaar regel 283-283: de tellingen van dit vertrekmoment, voor Tellingen in het blok; een OV-keten heeft een _ in ModeUsed (W_BBR_W)
- commentaar regel 310-311: De uitvoer volgens ModelParameters/OutputFormat: parquet, getypt en zonder het vertrekmoment in de kolomnamen (dat staat in de bestandsnaam), of csv, met het vertrekmoment achter de kolomnamen, zoals de csv van een component, en een onbekende waarde leeg.

## cfg/main/NetworkSetup.dms

- `Org_str` (regel 8): De herkomsten: Orgset, of bij een HB-paar de ene herkomst (sinds 2026-10-21, #129).
- `OrgBlock_rel` (regel 13): Het herkomstblok van deze herkomst: ConfigurationPerOrgBlock_T/org en de directe ritten per blok (PublicTransport/Direct_OD) kiezen hierop.
- `OrgZone_rel` (regel 26): De herkomst in de volledige herkomstenset, zoals PublicTransport_Prep/Impl/Places/Origin_rel.
- `NeedsCar` (regel 29): Criterium van de eindafweging (Classifications/OwnershipParetoAttr, NetworkModel_PBL#117).
- `NeedsBike` (regel 30): Idem.
- `V_org` (regel 40): PreTransport
- `impedance_net` (regel 48): Netwerkreistijd van het been, zonder start- en parkeertijd; hierop toetsen de Max*Time-grenzen, net als de cut van de Dijkstra.
- `OrgZone_rel` (regel 51): De herkomst van het been in de volledige herkomstenset; leeg als het been niet bij een herkomst begint.
- `IsVStop` (regel 54): Eindigt hier een voortransportbeen van de component (sinds 2026-10-20)? Alleen ketens die bij zo'n halte instappen, leest de uitvoer uit de ketenstore (PublicTransport_Prep/PT_V).
- `N` (regel 57): PostTransport
- `impedance_net` (regel 65): Netwerkreistijd van het been, zonder start- en parkeertijd; hierop toetsen de Max*Time-grenzen, net als de cut van de Dijkstra.
- `FileName` (regel 73): Het blok in de naam van de uitvoer per blok, PerBlock/tt_<moment>_<n>of<N>.csv (sinds 2026-10-20 zonder de datum, sinds 2026-10-03 zonder 'Block_', NetworkModel_PBL#118).
- `Output_CarSignature` (regel 88): De handtekening van de autostore van de directe autorit (Car_CongestionMoment_ForDirect) met een _ ervoor, leeg zonder AllowDirectCar. Met CarTimeDependent die van de store van het eerste vertrekmoment, die de tijdafhankelijke zoektocht in TD_Tag draagt (sinds 2026-10-09).
- `Output_Signature_Run` (regel 94): Handtekening van de OV-uitvoer: datum, herkomstenset en PT_Output_ParamTag (tot 2026-10-03 de bestandsnaam zonder vertrekmoment en blok), de kolommen (Export_TravelledDistance, Export_PriceInformation), de handtekeningen van de ketenstore (alleen als het OV meedoet, ModelParameters/Impl/WithPT) en van de autostore, en sinds 2026-10-16 _parquet bij OutputFormat 'parquet' (de lezers en samenvoegers lezen csv), sinds 2026-10-19 met de soort component erachter (_parquet-PT, -Car of -Direct: de kolommen, ModelParameters/Impl/ExportClass).
- `Output_Signature` (regel 102): De handtekening van de uitvoermap: Output_Signature_Run van een run, of bij MergeOutput (#117) die van ComponentMerge, met de handtekeningen van de samengevoegde Components.
- `Output_Sig` (regel 104): De handtekening in de uitvoermap: de schrijver per blok schrijft hem (en controleert het langste pad, PerBlock/tt_<moment>_<n>of<N>.csv of .parquet; tot 2026-10-20 met de datum na tt_), de lezers en samenvoegers controleren hem.
- `OutputDir_ForBatch` (regel 112): De uitvoermap voor batch/UpdateAll.cmd output, dat er voor de uitvoerstap de bestanden van het model uit weghaalt (tt_*.csv, tt_*.xml en de handtekening).
- `Generate_Output` (regel 114): De uitvoerstap (batch/UpdateAll.cmd output): de uitvoer per blok en vertrekmoment, met de tellingen, of bij MergeOutput het samenvoegen van de Components (ComponentMerge; sinds 2026-10-05, #117). Bij Samen maakt batch/OdTellingen.py de tellingen.
- `OutputBlocks_List` (regel 134): De opvragingen per herkomstblok, een per regel, voor batch/WriteOutputBlocks.ps1 (sinds 2026-10-07): de uitvoer per blok, of bij MergeOutput het samenvoegen per blok (ComponentMerge/PerBlock; in een opvraging groeide dat met ongeveer 7 GB per blok). Via Output_Sig/ForWriting schrijft of controleert dit eerst de handtekening van de uitvoermap en het langste pad.
- `OutputBlocks_PerPortion` (regel 141): Herkomstblokken per GeoDmsRun voor batch/WriteOutputBlocks.ps1: ModelParameters/Advanced/Components/BlocksPerPortion van de component, 0 = alle blokken in een portie.
- `File_Rijen` (regel 168): Rijen van de OV-uitvoer per soort optie (Classifications/OD_Tellingen_Soort), per vertrekmoment en in totaal.
- `File_Paren` (regel 171): Unieke HB-paren per groep (Classifications/OD_Tellingen_Groep), per vertrekmoment en over de momenten samen.
- `Links` (regel 363): De links van de route van elke rit, alleen in de HB-paarmodus (IsOD).
- commentaar regel 16-19: De directe ritten van alle herkomsten (PublicTransport_Prep/Direct_OD) met wat niet van het blok afhangt, een keer gerekend: de plaatsen van herkomst en bestemming, het bezit dat de rit vraagt en het herkomstblok; elk blok kiest daaruit zijn rijen (PublicTransport/Direct_OD). Tot 2026-10-07 rekende elk blok dat over de hele tabel (PublicTransport/Direct_OD_all), met twee rlookups en een tekst per rij: voor Auto met Buurt2023 naar Buurt2023 779 miljoen rijen, 450 keer.
- commentaar regel 36-39: Het voor- en PostTransport van alle herkomsten (sinds 2026-10-19 uit de stores van de benen, PublicTransport_Prep/Legs), een keer verenigd over de typen van de component (OV_PreTransport_Typen, OV_PostTransport_Typen); elk blok kiest zijn voortransportbenen op het herkomstblok (PublicTransport/V) en gebruikt alle natransportbenen (PublicTransport/N). Tot 2026-10-07 verenigde elk blok alle benen opnieuw, met voor elk voortransportbeen de tekst OrgName en de keuze IsRelevantForOrgSubset.
- commentaar regel 82-87: De handtekening van de OV-uitvoer (sinds 2026-10-03, NetworkModel_PBL#118). De uitvoer staat in ModelParameters/Impl/OutputDir (Output/<Analysis_date>_<OutputLabel>), met in de bestandsnamen alleen datum, vertrekmoment en blok; alle parameters staan in <OutputDir>/signature.txt. De schrijver per blok (PublicTransport/PerDepartureMoment_T, LongFormat/File) schrijft hem en weigert een map met een andere handtekening; de lezers en samenvoegers (ReadExport_OV_perTime_T, Merge_Regions_OV_T, Merge_Times, PostAnalysis/FindMedian) weigeren te lezen als hij ontbreekt of afwijkt. De ketenstore en de autostore horen erbij, want de uitvoer is uit hun inhoud gerekend.
- commentaar regel 127-128: Sinds 2026-10-04 ook de tellingen (OD_Tellingen), in dezelfde opvraging: die gebruiken de resultaten achter de hekken van de blokken, en die zijn er alleen in de fase waarin de blokken gerekend worden.
- commentaar regel 131-133: Sinds 2026-10-07 rekent batch/WriteOutputBlocks.ps1 de uitvoer in porties van blokken, een GeoDmsRun per portie, zoals WriteChainBlocks.ps1 de ketenstap: in een opvraging voor alle blokken (hierboven) groeide het geheugen van de uitvoer van Auto voor Buurt2023 naar Buurt2023 met ongeveer 0,7 GB per blok tot 386 GB. De tellingen maakt dan batch/OdTellingen.py.
- commentaar regel 145-147: Tellingen naast de OV-uitvoer (sinds 2026-10-04), in <OutputDir>: od_tellingen.csv met de rijen per soort optie en per vertrekmoment (en het totaal), en unieke_od_tellingen.csv met de unieke HB-paren per groep en per vertrekmoment (en over de momenten samen). De blokken hebben elk hun eigen herkomsten, dus de tellingen per blok worden opgeteld.
- commentaar regel 346-347: In de HB-paarmodus (ModelParameters/Impl/IsOD, sinds 2026-10-21, #129) vraagt de zoektocht ook de LinkSet, en geeft Links per rit de links van zijn route (Templates/RouteLinks_T); de reistijden zijn dezelfde.
- commentaar regel 362-362: sinds 2026-10-13 (#124) met eenrichtingsfietspaden van de Fietsersbond (not(IsOneDirection)); OSM-lopen en -fietsen hebben geen eenrichting
- commentaar regel 368-369: De routes van alle ritten, ook buiten de HB-paarmodus, om te bekijken. Sinds 2026-10-21 de lijn per route uit RouteLinks_T; tot dan was geometry de rechte lijn van een link per rit (TravelledJourney/Route[invert(Sequence_rel)]).

## cfg/main/NetworkSetup.dms (trailing comments)

- // WW, CC en/of AA; sinds 2026-09-23 uit DirectModes

## cfg/main/SourceData.dms

- `Network_Cycling` (regel 14): Het fietsnet van het model: Fietsersbond/Network_Cycling of OSM/Network_Cycling, naar ModelParameters/Advanced/CyclingNetwork (#124).

## cfg/main/SourceData/Fietstelweek.dms

- `Fietstelweek` (regel 1): download via http://opendata.cyclingintelligence.eu/
- commentaar regel 14-15: Sinds 2026-09-25 (audit 4.14) alleen links met gemeten ritten: bij alle 1,68 M links met INTENS_MEE = 0 is SNEL_ABS geimputeerd (8, 10 of 12 km/u) en was hij toch als meting gebruikt, waardoor gekoppelde links langzamer werden dan de fallback.

## cfg/main/SourceData/Infrastructure.dms

- `Overstaptijd_rel` (regel 91): De overstaptijd van het station (changetime in stations.dat).
- commentaar regel 80-83: De overstaptijd per station uit de IFF-dienstregeling van NS (#123): stations.dat uit ns-latest.zip (NDOV Loket), als csv met kop naast de zip (code, overstaptijd en max_overstaptijd in minuten, land, x, y, naam). De levering van 13-10-2026 (geldig 12-10 tot 12-12-2026): 44 stations 5 min (de grote knooppunten, Utrecht Centraal, Amsterdam Centraal, Zwolle), 235 4 min, 130 2 min, en 390 buitenlandse 0. De code is die van OVprijzen/NS/NS_Stations, dus van GTFS-haltes met NS_Stations_rel.

## cfg/main/SourceData/OSM/NetworkPreperation.dms (achter code)

- commentaar of Descr achter code: Verzameling van alle netwerken, inclusief de subnetwerken.
- commentaar of Descr achter code: uitgangspunt: het netwerk met de meeste nodes is het relevante netwerk
- commentaar of Descr achter code: het resulterende verbonden wegennetwerk

## cfg/main/SourceData/Fietsersbond.dms

- `Fietsersbond` (regel 18): Fietsersbond-routenetwerk 25-05-2025 (PBL): links/nodes met van_id/naar_id-topologie, zonder fietssnelheden.
- `lengte` (regel 37): Lengte in meter volgens de levering; komt overeen met arc_length(geometry).
- `toegang` (regel 38): Fietstoegang per richting: 'beide', 'heen' (in tekenrichting van_id -> naar_id), 'terug', 'geen'.
- `toegang_sp` (regel 39): Idem voor de speed-pedelec.
- `navigatie` (regel 45): 'standaard', 'onderdeel van kruispunt', 'onderdeel van rotonde' of leeg.
- `ongelijkv` (regel 46): Ongelijkvloers: 'nee', 'ergens overheen', 'ergens onderdoor', 'tunnel > 200 m'.
- `wegNiveau` (regel 47): 'overige weg', 'belangrijke hoofdweg', 'langs hoofdweg', 'autosnelweg', 'ONBEKEND' of leeg.
- `wegtype` (regel 48): 18 klassen, o.a. 'normale weg', 'fietspad (langs weg)', 'solitair fietspad', 'fietsstraat', 'weg met fiets(suggestie)strook', 'voetgangersgebied', 'veerpont'.
- `wegdeksrt` (regel 49): Wegdek: 'asfalt/beton', 'klinkers', 'tegels', 'halfverhard', 'onverhard', 'schelpenpad', 'overig (hout/kinderkopjes e.d.)'.
- `wegkwal` (regel 50): Wegkwaliteit: 'goed', 'redelijk', 'slecht'.
- `hinder` (regel 51): Hinder van ander verkeer: 'zeer weinig', 'weinig', 'redelijk', 'veel', 'zeer veel'.
- `maxsnelheid` (regel 56): Maximumsnelheid voor AUTO's op de weg (km/u als tekst, ook 'stapvoets (15)'), geen fietssnelheid.
- `hoofdroute` (regel 57): Onderdeel van een Fietsersbond-hoofdroute: 'beide', 'heen', 'terug', 'geen'.
- `knooppunt` (regel 58): Onderdeel van het fietsknooppuntennetwerk: 'beide', 'heen', 'terug', 'geen'.
- `lf` (regel 59): LF-routes over deze link.
- `BiBK` (regel 61): Bromfiets op de rijbaan / in de bebouwde kom: 'ja', 'nee'.
- `snelfiets` (regel 64): Snelfietsroute: 'ja', 'nee'.
- `breedtekls` (regel 65): Breedteklasse van het fietspad ('< 1 meter' t/m '5 meter en breder'), meestal leeg.
- `gem_st_fwd` (regel 66): Gemiddelde stijging heen: '<1%', '1-2%', '2-4%', '>4%'.
- `max_st_fwd` (regel 68): Maximale stijging heen: '<1%' t/m '>20%'.
- `IsReversed` (regel 79): Alleen tegen de tekenrichting in berijdbaar; bij gebruik als gericht netwerk F1/F2 (of de geometrie) omkeren.
- `NrLinksZonderNode` (regel 82): Links waarvan van_id of naar_id in nodes.shp ontbreekt: 18 in de levering van 25-05-2025 (alle 'beide', o.a. Graaf Arnoldlaan, Printerweg, Mauritsweg). Bij netwerkbouw weglaten of het losse eind via connect aan de dichtstbijzijnde node hangen.
- `knooppunt` (regel 97): Nummer van het fietsknooppunt op deze node, 0 als geen knooppunt.
- `NrZonderPositie` (regel 106): Nodes zonder echte positie: 1 in de levering van 25-05-2025 (id -1 op xy(0;0), geen knooppunt); de rest ligt binnen RD-extent xy(5.413;301.007)-xy(286.008;620.479).
- `geometry_digitised` (regel 126): In tekenrichting, van van_id naar naar_id.
- `MaxSnelheidAuto` (regel 129): Het eerste getal in maxsnelheid ('stapvoets (15)' is 15), 0 zonder.
- `IsWeg` (regel 131): Een weg met auto's, geen fietspad of voetgangersgebied.
- `geometry` (regel 137): In de rijrichting: een link met toegang 'terug' omgekeerd.
- `OSM_id` (regel 139): De link-id van de Fietsersbond, onder de naam die OSM/Network_Cycling heeft.
- `Connectable` (regel 142): Een herkomst, bestemming of halte hangt niet aan een veerpont.
- `speed_congested_cycling` (regel 151): Geen Fietstelweek: de vrije snelheid.
- commentaar regel 1-16: Fietsersbond-routenetwerk (routeplanner.fietsersbond.nl), levering via PBL van 25-05-2025: '250525 Data fietsersbond netwerk.zip', uitgepakt in %NetworkModel_Dir%/Infrastructuur/ Fietsersbond_20250525. Shapefiles in RD New (EPSG:28992), dus direct in rdc.  links.shp (1.771.242 lijnen) en nodes.shp (1.241.323 punten) vormen samen een topologisch netwerk: links/van_id en links/naar_id verwijzen naar nodes/id, zodat F1/F2 met een rlookup volgen en er geen connect-stap nodig is (18 links missen een node, zie links/NrLinksZonderNode). lengte komt op 0,03% overeen met arc_length; 82% van de links is voor fietsers toegankelijk, 10% eenrichting. Het netwerk kent GEEN gemeten fietssnelheden (die zitten in Fietstelweek); wel per link de fietstoegang per richting (toegang), wegtype, wegdek, kwaliteit, hinder, verlichting, omgeving, hellingklassen en de maximumsnelheid voor auto's. De overige 22 shapefiles zijn POI-lagen (knooppunten, paaltjes, veerponten, hindernissen, ...); de *_relations.txt koppelen die aan nodes resp. links. Hier zijn alleen de fietsknooppunten opgenomen; de andere lagen hebben veldnamen met spaties en zijn voor routering niet nodig.  Sinds 2026-10-13 (#124) is Network_Cycling het fietsnet van het model, als ModelParameters/Advanced/CyclingNetwork 'Fietsersbond' is (de standaard); tot dan ging fietsen over OSM/Network_Cycling.
- commentaar regel 110-120: Het fietsnet van het model (#124), met de attributen van OSM/Network_Cycling, zodat CreateNetwork_Efficient_T en de fietsbenen er ongewijzigd mee werken: - de links met fietstoegang en twee bekende knopen; een veerpont alleen tot Fietsersbond_MaxVeerpontLengte; - eenrichting (toegang 'heen' of 'terug'): IsOneDirection, met de geometrie in de rijrichting, dus 'terug' omgekeerd; - snelheid CyclingSpeed_kmhr en E_BikingSpeed_kmhr; op een veerpont lager, zodat de tijd over de link lengte / snelheid + Fietsersbond_VeerpontExtraTijd is; geen Fietstelweek, dus de spitssnelheid is de vrije; - roadType_rel voor de kruispuntpenalty (IsSlowTrafficRoad): 'ferry' voor een veerpont, 'tertiary' voor een weg met auto's boven 30 km/u, 'residential' voor een weg tot 30 km/u, 'cycleway' voor de rest (fietspaden, voetgangersgebied). Het model bouwt de topologie uit de eindpunten van de segmenten (arc2segm), niet uit van_id en naar_id. Op 4 plekken liggen twee knopen op dezelfde plek, en op 11.116 plekken vallen tussenpunten van verschillende links samen; daar verbindt het model ook, zoals bij OSM.

## cfg/main/SourceData/TomTom.dms

- `HasRawMaterial` (regel 19): Heeft de editie het ruwe materiaal (multinet/)? Zo niet, dan komen de stores uit de fss (FromFss).
- `VAL_DIR` (regel 98): validity direction: 2 = positieve richting (van F_JNCTID naar T_JNCTID van het wegelement), 3 = negatieve richting
- `time_slot` (regel 119): (lege Descr)
- `Rank` (regel 229): De hoeveelste rij van zijn wegelement, vanaf 0.
- `VAL_DIR` (regel 239): validity direction: 2 = positieve richting (van F_JNCTID naar T_JNCTID van het wegelement), 3 = negatieve richting; afgeleid uit de rijvolgorde (FromFss/ValDir)
- `Files_HSNP` (regel 380): Historical Speed Network Profile: Gemiddelde snelheden per segment, gebaseerd op historische metingen op een bepaald tijdstip of per tijdvak. Wordt per link gedefinieerd.
- `Files_HSPR` (regel 387): Historical Speed Profile: Gedetailleerd snelheidsprofiel, vaak met snelheidswaarden per 5 of 15 minuten voor typische dagen (bijv. dinsdag vs. zaterdag).
- `Read_Junctions` (regel 403): Kale lezer van de Junctions-store; declareert niets, de dictionary levert de kolommen.
- `Read_Roads` (regel 450): Kale lezer van de Roads-store; declareert niets, de dictionary levert de kolommen.
- `Read_Speednetworks` (regel 582): Kale lezer van de Speednetworks-store; declareert niets, de dictionary levert de kolommen.
- `NW_DIR_key` (regel 593): Sleutel (wegelement, richting); een wegelement heeft een rij per richting (audit 4.2).
- `DayProfile_rel` (regel 609): Het profiel van de dag CongestionSpeed_DaySelection (een weekdag; SP_<dag> draagt dan een profiel-id) in SpeedProfileKeys, voor de tijdafhankelijke autorit (ModelParameters/Impl/CarTimeDependent, sinds 2026-10-09); null zonder profiel, zoals de momentopname dan MINUTES neemt.
- `IsSpeedMoment` (regel 644): TRUE als SP_<moment> een snelheid is in plaats van een profiel-id.
- `Speed` (regel 646): De snelheid van deze rij (een richting van een wegelement) op dit moment; null zonder snelheid of profiel.
- `factor` (regel 651): De relatieve snelheid van het profiel op dit tijdstip; null voor een snelheidsmoment.
- `Read_Speedprofiles` (regel 657): Kale lezer van de Speedprofiles-store; declareert niets, de dictionary levert de kolommen.
- `ProfileDaySlot_key` (regel 677): De plaats in ProfileDaySlot: profiel na profiel, per profiel de tijdvakken van 300 s vanaf 00:00.
- `SpeedProfileKeys` (regel 683): De snelheidsprofielen: regio en profiel-id (Speedprofiles/SP_profile_ID), 1.465 voor NL en BE in de edities 2023.12 en 2025.12.
- `VariesInWindow` (regel 686): Verandert de relatieve snelheid van dit profiel in het venster (of ontbreekt hij in een tijdvak)? Zo niet, dan is de linktijd daar constant en krijgt de link geen eigen profiel.
- `ProfileDaySlot` (regel 689): Per profiel de 288 tijdvakken van 300 s van een dag, profiel na profiel.
- `rel_speed` (regel 692): De snelheid ten opzichte van SP_freeflow (rel_sp is in procenten).
- `WindowSlot` (regel 694): Per profiel de tijdvakken van het venster, profiel na profiel.
- commentaar regel 17-18: De vier stores uit het ruwe materiaal (Merge_*, map multinet/ van de editie) of, voor een editie die alleen als oude fss bestaat, uit die fss (FromFss; sinds 2026-10-08). UpdateAll.cmd sources roept deze vier aan.
- commentaar regel 123-130: Omzetter voor de edities die alleen als fss van Object Vision bestaan, yr2022_12 en yr2023_12 (sinds 2026-10-08). Die fss zijn geschreven toen rdc fpoint was, dragen geen waardetypen en hebben geen ruw materiaal meer naast zich, dus Merge_* kan ze niet maken. FromFss leest ze met de waardetypen van toen (de geometrie als Geography/rdc_f32, daarna [rdc]) en schrijft dezelfde vier mmd-stores als Merge_*, in dezelfde map. De fss blijven staan. Toets van yr2023_12 tegen yr2025_12 (2026-10-08): dezelfde kolommen, behalve VAL_DIR in Speednetworks; de lengte van de lijnen is METERS (mediaan 1,0000); de knopen liggen op 0,9 cm (mediaan) van dezelfde JNCTID in 2025; per wegtype 0,6 tot 4,0% minder wegen en 0,1 tot 1,5% minder km (de selectie van het model: 3.711.669 wegen en 349.938 km, tegen 3.796.881 en 352.642); de profiel-id's van de weekdagen worden even vaak gevonden (65%).
- commentaar regel 212-221: VAL_DIR uit de rijvolgorde. Het ruwe materiaal geeft per wegelement eerst de positieve richting (2), dan de negatieve (3); de vier rijen van een element dat in het NL- en het BE-bestand staat zijn twee zulke paren. Een element met een rij heeft alleen de rijrichting: 3 bij ONEWAY 'TF', anders 2. Getoetst op yr2025_12, waar VAL_DIR er is: 6.323.310 van 6.331.226 rijen goed (99,87%). Fout zijn 7.259 rijen van elementen met twee rijen (0,13%), vrijwel alle met de volgorde omgekeerd, zodat de twee richtingen elkaars profiel krijgen, en 657 enkele rijen van wegen die voor auto's gesloten zijn (ONEWAY 'N'), waar het om en om is. Met de afstand tot de eerste rij van het element in plaats van de rang waren de elementen met vier rijen (NL en BE) voor 75% goed in plaats van alle. In de ochtendspits (dinsdag 07:30, plafond 100 km/u) krijgen daardoor op yr2025_12 315 van de 3.519.862 wegen van de selectie een andere linktijd, samen 129 van de 1.227.696 linkminuten (0,010%); zonder richting (beide richtingen de eerste rij, zoals voor audit 4.2) waren dat 1.772.531 wegen en 7,4% van de linkminuten. De Speedprofiles (relatieve snelheid per profiel en kwartier) van yr2023_12 zijn gelijk aan die van yr2025_12, alle 421.920 rijen.
- commentaar regel 286-286: faalt dit? work-around; cmd op multinet map en dan
- commentaar regel 288-288: dan
- commentaar regel 293-293: bovenaan een regel toeveogen met 'path'
- commentaar regel 295-295: voor profiles:
- commentaar regel 301-301: bovenaan een regel toeveogen met 'path'
- commentaar regel 398-402: Een read-only MMD-lezer mag sinds GeoDMS 20.19.0 (issue #1245) zelf geen sub-items declareren: de dictionary van de store bepaalt ze en controleert bij het lezen de waardetypen (0Dictionary.dms in de mmd). Daarom per store een kale lezer <naam>_store, met daarnaast de unit die de config al gebruikte: die geeft de opgeslagen kolommen door en houdt de afgeleiden. Alle paden buiten dit bestand blijven zo gelijk.
- commentaar regel 448-449: Kale lezer, zie de toelichting bij Read_Junctions: onder een read-only MMD-lezer mag niets gedeclareerd worden (#1245), dus staan de doorgeefkolommen en de afgeleiden een niveau hoger.
- commentaar regel 480-481: De Texel-hack maakt de wegen bij de veerhaven tweerichting, maar sinds 2026-09-25 niet een weg die voor auto's gesloten is (ONEWAY 'N'; audit 4.4). In editie 2025.12 ligt er geen zo'n weg in de polygoon, dus de uitkomst verandert niet.
- commentaar regel 489-492: Sinds 2026-09-25 (audit 4.4 en 4.5): alleen wegelementen (FEATTYP 4110) en veerverbindingen (4130), niet de 375 adresgebiedgrenzen (4165, FRC -1) die tot dan alleen via een overloop in FRC_rel wegvielen; en elk NW_ID een keer: de 4.078 NW_ID's die zowel in het NL- als het BE-bestand staan (exact gelijk) gaven een dubbele link, waardoor een gewoon wegpunt als kruispunt een penalty kreeg.
- commentaar regel 500-503: Het speedprofile heeft per wegelement een rij per richting (VAL_DIR 2 = positief, van F_JNCTID naar T_JNCTID; 3 = negatief), met eigen profielen en een eigen freeflowsnelheid. 'fwd' is de rijrichting van het wegelement zoals het autonet hem gebruikt (F_JNCTID_directed naar T_JNCTID_directed; bij TF de negatieve richting), 'bwd' de tegenrichting van een tweerichtingsweg. Tot 2026-09-25 kregen beide richtingen de eerste rij (audit 4.2).
- commentaar regel 545-546: Plafond op de autosnelheid van dit congestiemoment (ModelParameters/Advanced/CongestionTimes/MaxSpeed; 0 = geen): 100 km/u overdag. Freeflow valt er niet onder. Sinds 2026-09-25.
- commentaar regel 559-562: Reistijd per rijrichting: lengte gedeeld door de TomTom-snelheid van die richting op dit moment (Speednetworks/CalcTimes/<tijd>/PerMoment/<moment>/Speed); zonder speedprofile-rij de reistijd van het wegennet (MINUTES van MultiNet). Minutes en kph zijn de rijrichting van het autonet (fwd), Minutes_bwd en kph_bwd de tegenrichting van een tweerichtingsweg (audit 4.1, 4.2 en 4.3, 2026-09-25).
- commentaar regel 581-581: Kale lezer, zie de toelichting bij Read_Junctions (#1245).
- commentaar regel 638-643: De weekdagen dragen in SP_<dag> een profiel-id (profile_1..7), met per kwartier een relatieve snelheid in procenten van SPFREEFLOW; freeflow, weekday, weekend en week dragen in SP_<moment> zelf een snelheid in km/u. Speed is daarom SP_<moment> voor een snelheidsmoment en SP_freeflow x relatieve snelheid voor een weekdag. Tot 2026-09-25 werd een snelheid als profiel-id opgezocht (audit 4.1, gemiddeld factor 0,90 van een willekeurig profiel) en werd de relatieve snelheid op de MultiNet-reistijd gezet (audit 4.3), die op 64% van de links sneller is dan SPFREEFLOW; Freeflow was daardoor het langzaamste moment.
- commentaar regel 656-656: Kale lezer, zie de toelichting bij Read_Junctions (#1245).
- commentaar regel 680-682: Tijdafhankelijke autorit (ModelParameters/Impl/CarTimeDependent, sinds 2026-10-09, NetworkModel_PBL#132): de relatieve snelheid per profiel en tijdvak als tabel, en welke profielen in het venster van de vertrekmomenten (CarTD_WindowStart, CarTD_NrSlots) veranderen. De linktijden per tijdvak en de factoren voor de zoektocht staan in Templates/CreateNetwork_TomTom_T, TimeDependent.

## cfg/main/SourceData/TomTom.dms (achter code)

- commentaar of Descr achter code: relevant voor latere routen (bij direction = 3 moet je f_ en t_ swappen, bij 3 & 4 geldt oneWayTraffic)

## cfg/main/SourceData/GTFS/LoadFeeds.dms

- `StoreName` (regel 9): Naam van de tabel IN de mmd-store, in de schrijfwijze waarmee de rest van de config hem leest (Read/Stop_times, Read/Shapes, ...). Name is de bestandsnaam van de csv en blijft kleine letters.
- `CalendarDates` (regel 171): De datums in calendar_dates, met het aantal ritten per datum en de drukste datum per weekdag, voor de controle in ServiceDays.
- `NrTrips` (regel 177): Ritten van de diensten die op deze datum worden toegevoegd (exception_type 1).
- `ServiceDays` (regel 181): De dienstdagen rond Analysis_date (D): D-1, D en D+1. Het netwerk legt ze op een tijdas in seconden sinds 00:00 van D: van D alle ritten met hun GTFS-tijd (ook 24:00 en later), van D-1 de ritten na middernacht (GTFS-tijd 24:00 en later, min 24 uur), van D+1 de ritten die beginnen voor het einde van het analysevenster (plus 24 uur). De datums volgen uit een dagnummer, niet uit rekenen op de cijfers.
- `IsDSTChange` (regel 198): Laatste zondag van maart of oktober: de GTFS-tijden van die dag tellen vanaf 12:00 min 12 uur, en dat is dan geen middernacht.
- `IsNeeded` (regel 199): D altijd; D-1 als het venster voor PrevServiceDayTailEnd begint; D+1 als het venster na middernacht doorloopt.
- `Check_ServiceDaysComplete` (regel 219): Elke dienstdag die het analysevenster nodig heeft staat in de feed met minstens MinServiceDayTripShare van de ritten van de drukste dag van dezelfde weekdag. Zie Report voor de aantallen.
- `Check_WeekdayMatchesCongestionDay` (regel 224): De weekdag van Analysis_date past bij Advanced/CongestionSpeed_DaySelection, de dag van de TomTom-snelheden voor de auto.
- `Check_NoDSTChange` (regel 231): D, en D+1 als het venster na middernacht doorloopt, is geen dag van een zomertijdwissel (de ritten van D-1 na middernacht komen ook dan goed uit).
- `sel_tomorrow_window` (regel 266): Ritten van D+1 die beginnen voor het einde van het analysevenster; bij een venster voor middernacht geen enkele.
- `KeepFlexOption` (regel 273): Doet de rit mee in het OV-net? Alleen ritten van flexlijnen kunnen afvallen, zie FlexOptions.
- `SelTomorrow` (regel 285): Hele ritten van D+1 die voor het einde van het venster beginnen; GTFS-tijd onder 24:00, zodat ze plus 24 uur binnen de tijdas van 48 uur vallen.
- `SelYesterdayNet` (regel 286): SelYesterday zonder de gedunde flexopties (protoTrips/KeepFlexOption): de ritten van het OV-net.
- `SelTodayNet` (regel 287): SelToday zonder de gedunde flexopties (protoTrips/KeepFlexOption): de ritten van het OV-net.
- `SelTomorrowNet` (regel 288): SelTomorrow zonder de gedunde flexopties (protoTrips/KeepFlexOption): de ritten van het OV-net.
- `Yesterday` (regel 314): Ritten van D-1 na middernacht (GTFS-tijd 24:00 en later), min 24 uur.
- `Today` (regel 315): Ritten van D met hun GTFS-tijd, ook na middernacht (24:00 en later).
- `Tomorrow` (regel 316): Ritten van D+1 die voor het einde van het analysevenster beginnen, plus 24 uur.
- `First` (regel 335): de eerste rit van elk blok; bij gelijke starttijd de eerste in de feed
- `Services` (regel 378): (lege Descr)
- commentaar regel 38-51: De store-holder bevat per tabel alleen domain en data. Dat is geen stijlkeuze: sinds GeoDMS 20.19.0 (issue #1245) weigert de MMD-writer elk item met DisableStorage onder zijn holder, en een template kan zijn case-parameters niet buiten de instantiatie houden. Het oude LoadDataForWriting_T stond WEL onder de holder, met DisableStorage op inFile en op CSV_attributes; van inFile ging die vlag voor de #1245-fix verloren bij instantiatie, waardoor hij in 20241001.mmd als parameter meegeschreven is (zie 0Dictionary.dms daar), en CSV_attributes werd stil overgeslagen. Met een actuele engine is dat een harde fout. Het inlezen gebeurt dus in Load (buiten de holder) en de tabellen verwijzen daar rechtstreeks naar; een template onder de holder is niet meer nodig.  of een meta-gescripte verwijzing per tabelnaam) schrijft NIETS en meldt dat niet: de sub-items van een verwezen container zijn engine-schaduwen, die de writer overslaat, en de run eindigt met exit 0 zonder store. Vandaar de acht expliciete blokken; de tabelnamen staan als File_Structure/StoreName ook in de lijst hierboven.
- commentaar regel 163-164: Sinds 2026-09-25 (audit 3.5) via ServiceDays: tot dan was gisteren uint32(Analysis_date) - 1, op de eerste van een maand een datum die niet bestaat (20241001 - 1 = 20241000), zodat geen enkele rit van de vorige dag meedeed.
- commentaar regel 218-218: De drie controles worden gerekend zodra het OV-netwerk wordt opgebouwd (ExplicitSuppliers van RelevantSelection/ScheduledLinks).
- commentaar regel 244-248: Sinds 2026-10-21: een halte met de coordinaten (0, 0) in de feed krijgt het punt van zijn parent_station. In de feed van 20260925 zijn het er 187, waarvan 45 met stop_times: Duitse perrons van de ICE Amsterdam-Berlijn/Hamburg en van DB (Muenster, Dortmund, Luenen), alle met een parent met een punt. Tot dan lagen ze samen in de Golf van Guinee: een stopcluster, overstappen op afstand 0, en in de PT_NetworkExport (#57) segmenten van 6000 km. Zonder parent met een punt blijft het punt uit de feed.
- commentaar regel 269-271: Flexvervoer (sinds 2026-09-30): een rit van een flexlijn die in hetzelfde blok van ModelParameters/Advanced/FlexMinInterval vertrekt als een eerdere rit van hetzelfde ritpatroon, doet niet mee in het OV-net (FlexOptions, protoStopTimes/Sel*Net). De OV-knooppunten tellen alle ritten (StopTimes/SelToday), zodat de bestemmingen niet van de flexparameters afhangen.
- commentaar regel 294-296: #3 (sinds 2026-10-02): GTFS pickup_type en drop_off_type 1 = hier geen in- of uitstappen; 2 en 3 (bellen, afspreken met de chauffeur) gelden als toegestaan, zoals bij flexlijnen. Leeg = 0. Zo vallen Eurostar, Nightjet, European Sleeper en GoVolta binnenlands af: op hun NL-haltes staat instappen (2) of uitstappen (1) toe, nooit allebei.
- commentaar regel 311-313: De links per dienstdag, op de tijdas in seconden sinds 00:00 van Analysis_date (D). Sinds 2026-09-25 (audit 3.5) uit een template: D+1 is erbij gekomen, en de lengte van een link van D-1 zonder bruikbare shape_dist_traveled valt terug op de hemelsbrede afstand zoals bij D (tot dan 0).
- commentaar regel 319-322: Dunnen van de flexopties (ModelParameters/Advanced/FlexMinInterval, sinds 2026-09-30). De feeds van 2026 roosteren een deel van het gebiedsvervoer op afroep als rit per minuut in (U-flex Maarssen/Utrecht-Noordwest en Houten-Schalkwijk: 296 tot 728 ritten per richting per dag), wat ~550 OV-benen per vertrek en haltenblokken van 150-200 GB gaf. Per ritpatroon (route, eerste en laatste halte, aantal haltes) blijft per blok van FlexMinInterval, geteld vanaf 00:00 van de GTFS-dag, de eerste rit.
- commentaar regel 424-425: shape 25637 dist 6831

## cfg/main/SourceData/GTFS.dms

- commentaar regel 30-34: De halte van de link zelf. Tot 2026-10-21 rlookup(geometry, Stops/geometry): de eerste halte met hetzelfde punt. In de feed van 20260925 delen 810 van de 49947 gebruikte haltes hun punt met een andere, zodat 75244 van de 4,0 miljoen gebeurtenissen een andere halte kregen. Een stilstand op zo'n halte (2393, waarvan 1893 in NL, onder meer Amsterdam Bijlmerplein, Oostzanerdijk en Buiteneilandlaan (tram) en Groningen P+R Hoogkerk) verbond dan de knopen van de andere halte, zodat een been daar niet kon doorrijden: de ketens stapten uit en in hetzelfde voertuig weer in.
- commentaar regel 37-37: #3: in- en uitstappen van de stop_time van dit moment (aankomst of vertrek, dezelfde GTFS-regel).
- commentaar regel 44-44: bij elke c_Time_Stop_rel wordt er een wachtlink toegevoegd tot aan de volgende time_rel op die stop.
- commentaar regel 80-81: #3: stilstand tussen aankomst en vertrek op een halte hoort bij een GTFS-stop_time; beide knopen krijgen diens in- en uitstapregel. Nodig aan de rand van het tijdvenster, waar de binnenkomende geplande link buiten de set valt.
- commentaar regel 113-116: Het NS-station van een halte, voor de NS-prijs en de doorprijs: het station binnen DistanceTrainStationsSelection, en sinds 2026-09-27 (audit 6.6) anders het station met precies dezelfde naam (alleen voor treinhaltes; perronhaltes heten als hun station). Nodig voor Vught: in de feed van 20260925 liggen de perrons na de verdiepte ligging ~600 m ten zuiden van het stationspunt, zodat 118 NS-benen geen prijs kregen en NS_Station_Price_IntegrityCheck (MakeODs) faalde.
- commentaar regel 152-153: #3: in- en uitstappen volgens de GTFS-stop_times, aan begin en eind van elke link (ook een wachtlink: stilstand binnen een rit, met de regel van zijn stop_time); zie Get_Windowed_Agency_Set_T/Set/NodeSet/CanBoard en CanAlight.

## cfg/main/SourceData/GTFS.dms (achter code)

- commentaar of Descr achter code: fka uq_c_Trip_Time

## cfg/main/SourceData/GTFS/OV_Knooppunten.dms

- `Score_Trein` (regel 16): Score per treinvertrek; geen onderscheid HSL/IC/sprinter want niet afleidbaar uit route_type in NL-GTFS.
- `KnooppuntTypen` (regel 22): Typering per knooppunt: trein gaat voor BTM (bus/tram/metro). Trein_IC volgt de NS-stationstypologie ((knooppunt)intercity-/megastation) uit de treinstations-shape, zodat afnemers stations naar zwaarte kunnen wegen.
- `VertrekVandaag` (regel 31): Halteringen op de Analysis_date, op een gebruikte halte.
- `HalteVandaag` (regel 52): Halte met een haltering op Analysis_date.
- `NearbyStopPairs` (regel 54): Alle paren van haltes met vertrekken op Analysis_date binnen clusterafstand; input voor connected_parts.
- `Knopen` (regel 61): Halteclusters: elke samenhangende groep haltes is een knooppunt-kandidaat. Subitem PartNr relateert elke halte aan zijn cluster.
- `MainStop_rel` (regel 64): Drukste halte van het cluster; bepaalt naam en geometrie.
- `NrLijnen_BTM` (regel 78): Aantal unieke bus/tram/metro-lijnen (route_id's) dat het cluster op de Analysis_date aandoet.
- `NrRichtingen_BTM` (regel 79): Aantal windrichtingen (max 4) waarin BTM-vertrekken het cluster verlaten. Corridor-bundel = 2, kruisend/uitwaaierend knooppunt = 3-4.
- `IsKandidaat` (regel 88): Haalt de drempels; wordt pas knooppunt na het dominantiefilter (zie Kandidaten).
- `Ontsluitingswaarde` (regel 110): 0,2 x frequentie/uur x modaliteitsscore, gesommeerd over modaliteiten. Vertrekken/dag over beide richtingen gedeeld door bedrijfsuren benadert frequentie x richtingen.
- `LigtInNL` (regel 149): De GTFS-feed bevat ook buitenlands OV (De Lijn, grensstations, internationale treinen). Alle knooppunten buiten NL vervallen.
- `Export_Knooppunten` (regel 175): OV-knooppunten als puntenbestand (RD new), voor o.a. bereikbaarheidsanalyses (reistijd naar dichtstbijzijnde knooppunt).
- `Reistijd_node` (regel 221): Bewust ongericht (eenrichtingsverkeer genegeerd): voorkomt onbereikbare zakken achter oneway-links (industrieterreinen, havens); voor een regionale reistijdproxy is de fout verwaarloosbaar.
- `Diag_NullCellen` (regel 237): Diagnose van org-punten zonder reistijd: geen netwerk-node gevonden (rlookup) of node niet bereikt door de dijkstra (onbereikbare subcomponent / buiten MaxCarTime).
- `Reistijd` (regel 268): Reistijd (min) per auto naar het dichtstbijzijnde OV-knooppunt, per 25m-cel, landsdekkend binnen NL.
- commentaar regel 49-51: Sinds 2026-09-25 (audit 3.5) bevat Stops ook haltes die alleen de ritten van de vorige dag na middernacht of van de volgende dag gebruiken. Die tellen niet mee in de clustering: een knooppunt beschrijft de dienstregeling van Analysis_date, en zo'n halte zou twee clusters kunnen verbinden (op 20241001 verschoof daardoor het hoofdpunt van 23 van de 462 knooppunten).

## cfg/main/SourceData/GTFS/OV_Knooppunten.dms (meerregelige Descr)

- `container OV_Knooppunten : using = "RelevantSelection"`: Operationalisering van OV-knooppunten op basis van GTFS, t.b.v. o.a. Redevelopment issue #18 (OV-knooppuntbereikbaarheid als regionale locatievariabele). Er bestaat geen wettelijke definitie van een OV-knooppunt. Deze operationalisering volgt de gangbare kaders: - Actieagenda OV-knooppunten / Toekomstbeeld OV 2040: alle treinstations + belangrijke stedelijke/regionale HOV-knooppunten; - Nationale Standaard invloedsgebieden OV-knooppunten (Goudappel/IenW, feb 2024): typen A/B (grote stations), C (treinstation/metrohalte/HOV-knooppunt), D (HOV-halte); - Vlindermodel Vereniging Deltametropool: netwerkwaarde = verbindingswaarde + ontsluitingswaarde, met ontsluitingswaarde = frequentie/uur x richtingen x 0,2 x modaliteitsscore. Concreet: (1) haltes worden spatiaal geclusterd tot knooppunt-kandidaten; knooppunten buiten NL vervallen; (2) elk cluster met trein is knooppunt, getypeerd naar NS-stationstypologie (Trein_IC versus Trein) zodat lichte stations (Assendelft) herkenbaar en apart weegbaar zijn; (3) een cluster zonder trein is knooppunt als het aantal unieke bus/tram/metro-lijnen, het aantal BTM-vertrekken/dag en het aantal vertrekrichtingen (sectoren) alle boven een drempel liggen (zie ModelParameters/Advanced) - het richtingencriterium weert corridor-bundels (R-net over een as) die wel veel lijnen tellen maar geen overstappunt zijn. Metrohaltes zijn dus niet automatisch knooppunt: een solitaire metrohalte op een corridor is een halte van een hoogwaardige lijn, geen bundeling met overstap (CROW-kern). Metroknopen met kruisende lijnen of een busstation (Beurs, Noord, Zuidplein) halen de gecombineerde drempel vanzelf; (4) dominantiefilter: een BTM-kandidaat vervalt als binnen Knooppunt_DominantieRadius een sterker knooppunt ligt, tegen knopen-reeksen langs corridors en meerdere punten per complex; (5) als extra attribuut wordt een netwerkwaarde volgens het vlindermodel meegegeven, zodat afnemers zelf een andere drempel kunnen kiezen. Vereenvoudigingen t.o.v. het vlindermodel: het aantal richtingen wordt niet apart bepaald (vertrekken tellen beide richtingen al mee) en binnen trein wordt geen onderscheid HSL/IC/sprinter gemaakt.
- `container Bereikbaarheid_Auto`: Reistijd per auto (OSM-netwerk, maximumsnelheden) naar het dichtstbijzijnde OV-knooppunt, t.b.v. Redevelopment issue #18 (vervangt tt_Trainstation_2006 als regionale locatievariabele). Vereist ModelParameters/Orgset = 'BAG_woonpanden_Clustered' en Destset = 'OV_Knooppunten' (dan zijn org/dest van het Car-netwerk de woonpanden resp. de knooppunten). Werking: een multi-source dijkstra (impedance_table, zelfde patroon als PostAnalysis) vanaf alle knooppunt-nodes geeft per netwerk-node de reistijd naar het dichtstbijzijnde knooppunt; elk woonpand krijgt de reistijd van zijn netwerk-node. Output: tif op rdc_25m (alleen cellen met een woonpand krijgen een waarde, overige cellen nodata) - voldoende voor koppeling aan woningtransacties.

## cfg/main/SourceData/GTFS/OV_Knooppunten.dms (achter code)

- commentaar of Descr achter code: // Modaliteitsscores, benadering van vlindermodel 2.1 (HSL 125pt ... ontsluitende bus/tram 25pt; Goudappel 2024 hanteert 25pt voor alle bussen)
- commentaar of Descr achter code: // Hulpattributen op halte- en stop_time-niveau
- commentaar of Descr achter code: // Vertrekrichting: sector (O/W/N/Z) van de rit naar de volgende halte; operationaliseert 'aantal richtingen' uit het vlindermodel
- commentaar of Descr achter code: // Stap 1: haltes clusteren tot knooppunt-kandidaten (single linkage binnen DistanceKnooppuntClusters)
- commentaar of Descr achter code: // Stap 2/3: knooppuntselectie
- commentaar of Descr achter code: // IC-typering via NS-stationstypologie (koppeling aan treinstations-shape binnen DistanceTrainStationsSelection)
- commentaar of Descr achter code: // Stap 4: netwerkwaarde volgens vlindermodel (benadering)
- commentaar of Descr achter code: // Unieke (knoop, lijn)-combinaties voor de lijnen-drempel
- commentaar of Descr achter code: // Unieke (knoop, vertreksector)-combinaties voor het richtingencriterium
- commentaar of Descr achter code: // Dominantiefilter: BTM-kandidaat vervalt als binnen Knooppunt_DominantieRadius een sterkere kandidaat ligt (trein, of hogere netwerkwaarde).
- commentaar of Descr achter code: // Voorkomt knopen-reeksen langs HOV-corridors en meerdere punten per groot complex (Schiphol); treinstations vervallen nooit.
- commentaar of Descr achter code: // BTM-kandidaat vervalt voor elke kandidaat met hogere netwerkwaarde binnen de dominantieradius.
- commentaar of Descr achter code: // Bewust op netwerkwaarde en niet op 'trein wint altijd': een sterke busknoop naast een zwak station (Zoetermeer Centrum West, Zuidplein) moet blijven.
- commentaar of Descr achter code: // treincluster vervalt alleen voor een treincluster met meer treinvertrekken binnen de (kleinere) dedupradius: perron- en pleinclusters van hetzelfde station
- commentaar of Descr achter code: // Export: puntenbestand met alle knooppunten
- commentaar of Descr achter code: // dekkende origin-set: alle 100m-celmiddens op NL-land (provincie-landmasker via poly2grid; bewust niet perGridsize/points, die hangt aan het kapotte geos_union_polygon NL-item)
- commentaar of Descr achter code: // eigen netwerk-instantie met de gridpunten als org en de knooppunten als dest (onafhankelijk van ModelParameters/Orgset/Destset)
- commentaar of Descr achter code: // vangnet: 100m-cellen die na de netwerkberekening leeg blijven (losse netwerkcomponenten) vullen met een 2km-potentiaalgemiddelde van omliggende gevulde cellen.
- commentaar of Descr achter code: // Alleen binnen NL; kwelders/eilanden zonder weg binnen 2km blijven terecht null (geen autoreistijd mogelijk).
- commentaar of Descr achter code: // 100m -> 25m: elke 25m-cel krijgt de waarde van zijn 100m-cel (directe grid-naar-grid mapping)

## cfg/main/SourceData/GTFS/RelevantSelection.dms

- `ScheduledLinks` (regel 69): De geplande links van de dienstdagen D-1, D en D+1 op een tijdas (LoadFeeds/ServiceDays). Bij het opbouwen worden de controles van ServiceDays gerekend.
- `SL_Places` (regel 114): unique scheduled links locations. However duplicate locations with different a stop_rel do exist.
- `uq_TimeStop` (regel 123): aka SSTE aka ScheduledSpaceTimeEvents
- `Routes` (regel 137): Transit routes. A route is a group of trips that are displayed to riders as a single service. Plus voor- en PostTransport.
- `FlexMatch` (regel 158): gematchte flex-term; null = geen match
- `FlexNearMiss` (regel 159): gematchte bijna-treffer-term; null = geen match
- `IsPseudoRoute` (regel 160): voor-/PostTransport-pseudoroutes uit de union_unit
- `IsFlex` (regel 161): flex-/belbuslijn: boeken vooraf, geen vaste dienstregeling; zie ModelParameters/Advanced/IncludeFlex en de flexparameters erna
- `IsZonderNSKaartje` (regel 168): #3: trein waarop een NS-kaartje nooit geldt (Eurostar, Nightjet, ...); rijdt niet mee in het L-net, zie PublicTransport_Prep/Set_L.
- commentaar regel 87-87: #3: mag je aan het begin (From) en eind (To) van de link in- of uitstappen (GTFS pickup_type/drop_off_type, zie LoadFeeds/protoStopTimes)?
- commentaar regel 153-156: #113: flex-/belbuslijnen op naam (zoektermen in ModelParameters/Advanced/FlexRouteTerms). MakeDefined: een null in een van beide namen zou de zoektekst null maken en de route stil ongemarkeerd laten. lowercase() omdat de flag-parameter van regex_search in de motor niet doorkomt (Regex.cpp leest args[3] bij een ternaire operator). regex_search geeft de gematchte term, of null als er geen match is.
- commentaar regel 164-165: #3: het product met rit-opslag (ModelParameters/Advanced/TripSurchargeTrains) van een route van het L-net, herkend aan de route_short_name (TripSurchargeRouteNames); null = geen opslag. Routes buiten het L-net krijgen een lege zoeknaam.

## cfg/main/SourceData/OSM.dms

- `OSM_NL_prov` (regel 6): (lege Descr)
- `OSM_Regios` (regel 8): (lege Descr)
- `geometry_rd` (regel 75): Geometrie in RD, in de rijrichting als de weg eenrichting is.
- `rth_maxspeed_per_roadType` (regel 110): Kwantiel van de getagde maxspeed per wegtype (audit 4.10).
- `Final_Network_src` (regel 142): Rekenkant van het uiteindelijke OSM-netwerk (niet opgeslagen); Make_Final_Network schrijft hiervan de te bewaren attributen naar de mmd.
- `StoreRevision` (regel 169): Revisie van de netwerkopbouw in de naam van de OSM-netwerkstore; verhoog hem bij elke wijziging die de inhoud van de store verandert, anders wordt de oude store gelezen. _r2 (2026-09-25): expliciete klassen voor track_grade1-5, busway en unknown (audit 4.8) en omgedraaide oneway-'T'-wegen (audit 4.9). _r3 (2026-09-25): maxspeed-kwantiel over getagde wegen (4.10), handmatige verbindingen zonder lege reeksen en veren op Ferry_Speed (4.11), Fietstelweek zonder geimputeerde snelheden (4.14).
- `Read_Final_Network` (regel 188): Kale lezer van de OSM-netwerkstore; declareert niets, de dictionary van de mmd levert geometry, roadType_rel, maxspeed, OSM_id, IsOneDirection en congestion_speed_bike.
- commentaar regel 67-69: Sinds 2026-09-25 (audit 4.9) liggen de punten van een eenrichtingsweg met oneway 'T' (rijrichting tegen de digitaliseerrichting in) omgekeerd, zodat de rijrichting van elke eenrichtingsweg van het eerste naar het laatste punt loopt: het netwerk gebruikt een eenrichtingslink alleen van F1 naar F2. Daarvoor waren deze wegen (512, 53 km in OSM 20260601) alleen tegen de rijrichting in berijdbaar.
- commentaar regel 81-82: Een fclass die niet in Classifications/OSM/roadType staat wordt 'unknown' (alleen beloopbaar); tot 2026-09-25 werd hij null en daarna connectlink, ook in het autonet (audit 4.8). NrUnmappedFclass telt ze, om nieuwe fclasses op te merken.
- commentaar regel 134-141: De rekenkant van het netwerk staat BUITEN de store: sinds GeoDMS 20.19.0 (issue #1245) weigert de MMD-writer elk item met DisableStorage onder zijn holder, want alles onder de holder hoort bij de store ("Move this item outside the holder or drop the property"). ConnectedNetwork_rel, values en AddBikeCongestionSpeeds waren met de oude fss-store nog als DisableStorage uit te sluiten; opslaan is geen alternatief (values is een tweede exemplaar van de geometrie en AddBikeCongestionSpeeds/Impl is de connect_info met alle Fietstelweek-dynapunten). Make_Final_Network houdt de naam en de store, zodat /MakeUnlinkedData/OSM/Step1_Generate_roads_Final_Network en Final_Network ongewijzigd blijven werken.
- commentaar regel 183-187: Een read-only MMD-lezer mag sinds GeoDMS 20.19.0 (issue #1245) zelf geen sub-items declareren: de dictionary van de store bepaalt ze (en controleert bij het lezen de waardetypen, zie 0Dictionary.dms in de mmd). Read_Final_Network is daarom de kale lezer; Final_Network geeft de zes opgeslagen attributen door en voegt de afgeleiden toe, onder dezelfde naam en paden als voorheen, zodat Network_Car/Network_Cycling/Network_Walking en de templates onveranderd zijn.
- commentaar regel 266-268: OSM heeft geen congestie; de spitssnelheid is de maximumsnelheid van de weg met het plafond van het moment (ModelParameters/Advanced/CongestionTimes/MaxSpeed: 100 km/u overdag). Tot 2026-09-25 waren deze null en viel het autonet door een hoofdlettergevoelige vergelijking terug op 130 km/u (audit 3.3 en 4.7).

## cfg/main/SourceData/OSM.dms (achter code)

- commentaar of Descr achter code: congestion in OSM gebruiken we niet, maar om alle templates te laten werken wel deze placeholder.
- commentaar of Descr achter code: congestion in OSM gebruiken we niet, maar om alle templates te laten werken wel deze placeholder.
- commentaar of Descr achter code: congestion in OSM gebruiken we niet, maar om alle templates te laten werken wel deze placeholder.
- commentaar of Descr achter code: Verzameling van alle netwerken, inclusief de subnetwerken.
- commentaar of Descr achter code: uitgangspunt: het netwerk met de meeste nodes is het relevante netwerk

## cfg/main/SourceData/OSM/NetworkPreperation/ExtraVerbindingen.dms

- `coordinates` (regel 3), source: handmatig gedigitaliseerd
- `SnapDist_first` (regel 824): Afstand van het beginpunt tot het dichtstbijzijnde wegsegment.
- commentaar regel 16-16: Uit script (ODA)
- commentaar regel 665-665: Extra verbindingen
- commentaar regel 679-679: Pont Centraal-Buikslotermeer
- commentaar regel 682-682: Weg StrandZuid
- commentaar regel 685-685: Pont Centraal-NDSM
- commentaar regel 688-688: Pont Centraal-Buikslotermeer
- commentaar regel 691-691: Pont KNSMeiland-Nieuwdammerham
- commentaar regel 694-694: Pont Hembrug
- commentaar regel 712-712: 156677.196,576569.383, 260,1,76, //punt connect aan voetpad
- commentaar regel 731-731: Extra verbindingen
- commentaar regel 789-789: Verbind ZeeuwsVlaanderen aan hoofdnetwerk met fictieve pad
- commentaar regel 799-799: Sinds 2026-09-25 (audit 4.11) rijden als veer getypeerde handmatige verbindingen op Ferry_Speed, zoals ExtraBoatConnections; tot dan 50 km/u.
- commentaar regel 811-812: Sinds 2026-09-25 (audit 4.11) alleen reeksen met punten: de reeksen 239 (Texel) en 258 (Den Helder) zijn uitgecommentarieerd maar bestonden als lege link, die als rij met 0 punten en zonder wegtype in de OSM-netwerkstore belandde.
- commentaar regel 832-835: Sinds 2026-09-25 (audit 4.11): connect koppelt een eindpunt aan het dichtstbijzijnde wegsegment zonder maximumafstand. De bootverbindingen naar Neuwerk en de Noord-Friese eilanden (Pellworm, Hooge, Langeness, Amrum, Foehr, Sylt) liggen buiten de OSM-regio's van het model en werden aan een weg op meer dan 1 km gekoppeld; alleen verbindingen waarvan beide eindpunten binnen ExtraLink_MaxSnapDistance van het wegennet liggen doen nog mee (de Nederlandse liggen binnen 131 m).

## cfg/main/SourceData/OSM/NetworkPreperation/ExtraVerbindingen/ExtraBoatConnections.dms (achter code)

- commentaar of Descr achter code: Niet op basis van OSM, alhoewel deze wel ergens in de OSM zitten
- Source: ,	Source     = "op basis van AND Netwerk"
- commentaar of Descr achter code: Sylt - vasteland

## cfg/main/SourceData/RegioIndelingen.dms

- `geometry` (regel 319): geos_* vereist float64-coordinaten; rdc is daarom dpoint.
- commentaar regel 73-73: controles
- commentaar regel 112-113: Sinds 2026-09-25 (audit 3.8) eigen bestemmingssets: tot dan gebruikten de bestemmingen Buurt_enkele_Prov/Corop de herkomstselectie, en waren Destset_EnkeleProv_Selection en Destset_EnkeleCorop_Selection nergens in gebruik.
- commentaar regel 622-624: Concessie-shapes bestaan voor 2020 t/m 2026 (Concessie_YYYY.shp). Gegenereerd per jaar zodat Concessiegebied_year='Y'+FareTable_year werkt voor elk beschikbaar jaar (relevant voor PriceMethod='DOVA'). LET OP: voor jaren < 2020 (DOVA-km-tarieven gaan terug tot 2013) bestaat geen shape; kies dan een proxy-jaar.

## cfg/main/SourceData/BAG.dms

- `X_ext` (regel 97): null voor panden zonder geometrie (lege bounds geven anders int32-overflow); die vallen daarmee uit Pand_selection_condition.
- commentaar regel 192-192: controles
- commentaar regel 209-209: controles
- commentaar regel 225-225: controles

## cfg/main/SourceData/BAG.dms (achter code)

- commentaar of Descr achter code: pand_woon_vbo_rel

## cfg/main/Templates/Check_Connectiveness_T.dms

- `Check_Connectiveness_T` (regel 1): (geen Descr)
- `IsVerbonden` (regel 16): (geen Descr)
- `NodesNotConnected` (regel 18): (geen Descr)

## cfg/main/Templates/Check_Connectiveness_T_adhoc.dms

- `Check_Connectiveness_T_adhoc` (regel 1): (geen Descr)
- `IsVerbonden` (regel 9): (geen Descr)

## cfg/main/Templates/RouteLinks_T.dms

- `RouteLinks_T` (regel 6): (geen Descr)
- `Rows` (regel 17): Een rij per link van een route, in de volgorde van de LinkSet (van het eind naar het begin).
- `Volgnr` (regel 23): De plaats van de link in de reis, vanaf 0.
- `Volgende_rel` (regel 24): De link die in de reis volgt: de vorige rij, want de LinkSet loopt achteruit.
- `EindKnoop` (regel 27): (geen Descr)
- `BeginKnoop` (regel 28): (geen Descr)
- `IsVooruit` (regel 29): Gaat de reis over de link van F1 naar F2?
- `geometry` (regel 30): Een rechte lijn van de begin- naar de eindknoop.
- commentaar regel 1-5: DE LINKS VAN ROUTES (sinds 2026-10-21, #129; alleen in de HB-paarmodus, ModelParameters/Impl/IsOD): uit de LinkSet van een impedance_matrix per route de links in de volgorde van de reis, met de knoop waar elke link begint en eindigt, en per route een lijn langs die knopen. De LinkSet loopt van het eind van de route naar het begin (GeoDMS, Dijkstra.cpp WriteLinkSets); Volgnr telt vanaf het begin. Een link eindigt in de knoop die hij deelt met de volgende link; de laatste link eindigt in EndNode, de eindknoop van de route. Zo is de richting ook goed op een tweerichtingsnet, waar F1 en F2 niets over de rijrichting zeggen.
- commentaar regel 39-39: De lijn per route: de beginknoop van de eerste link en dan de eindknoop van elke link.
- commentaar regel 50-50: De plaatshouder van RouteLinks_T buiten de HB-paarmodus: de zoektochten vragen dan geen LinkSet.

## cfg/main/Templates/ReadExport_OV_perTime_T.dms

- `ReadExport_OV_perTime_T` (regel 1): (geen Descr)
- `IsRegionMerged` (regel 15): (geen Descr)
- `ColSuffix` (regel 34): De uitvoer per blok zet het vertrekmoment in de kolomnamen, de samengevoegde uitvoer in de bestandsnaam.
- commentaar regel 7-14: Leest de OV-uitvoer van een herkomstblok (Org_str = blok) of de per vertrekmoment samengevoegde uitvoer (Org_str = 'All'). Sinds 2026-10-03 (NetworkModel_PBL#118) uit ModelParameters/Impl/OutputDir, met alleen datum, vertrekmoment en blok in de naam, en alleen als de handtekening van die map klopt (NetworkSetup/GenerateOutput/Output_Sig/ForReading). Sinds 2026-09-25 (audit 6.5) met dezelfde naamopbouw als de schrijver (tot dan zocht de lezer _ORG-<Orgset> en _MaxOV-, de schrijver schrijft _ORG-<OrgSet_string> en _MaxPT- plus de pareto-tags), met de kolomnamen van de schrijver (PretransTime/PosttransTime, niet VoortransTime/NatransTime), Price alleen als de kolom er is (zonder Export_PriceInformation heeft het bestand hem niet), en via GDAL in plaats van het hele bestand als een string: een vertrekmoment samengevoegd over de 450 blokken is 39 M regels.
- commentaar regel 44-49: Sinds 2026-10-03 de getallen als float64 en de bezitscriteria als uint8, niet meer als tekst: dat scheelt het meeste geheugen bij het samenvoegen (een vertrekmoment is 39 M regels, de dag vier keer zoveel), en float64 schrijft de tekst van de uitvoer per blok ongewijzigd terug (7.35 blijft 7.35). Een kolom die het bestand niet heeft, wordt leeg: Price en de prijsdelen zonder Export_PriceInformation, de afstanden zonder Export_TravelledDistance, en de kolommen van na de uitvoer die gelezen wordt (NeedsCar en NeedsBike sinds 2026-10-02, de prijsdelen sinds 2026-10-02, TravelDist_PT en de kolommen per modaliteit sinds 2026-10-03).

## cfg/main/Templates.dms

- `GTFS_getTimes_T` (regel 28): (geen Descr)
- `DayNr_T` (regel 48): (geen Descr)
- `y_mar` (regel 56): Het jaar dat op 1 maart begint.
- `DayNr` (regel 61): Dagen sinds 1970-01-01.
- `Weekday` (regel 62): 0 = maandag, zoals Units/Weekdays.
- `CivilDate_T` (regel 65): (geen Descr)
- commentaar regel 17-18: Merge_Regions_Car_T, ReadExport_Car_T, ReadExport_PedestrianBike_T en Merge_Regions_PedestrianBike_T zijn op 2026-09-25 verwijderd (audit 6.5): ze verwezen naar Advanced/Regio, dat niet bestaat, en werden nergens geinstantieerd.
- commentaar regel 45-47: Datumrekenen zonder datumtype (audit 3.5): een datum jjjjmmdd als dagnummer, het aantal dagen sinds 1 januari 1970, en terug. Zo is de dag voor 20241001 20240930 en niet 20241000. De formules zijn die van de gregoriaanse kalender (H. Hinnant, days_from_civil en civil_from_days), in uint32, geldig vanaf 1 maart 1970.

## cfg/main/Templates/StoreNames_T.dms

- `StringHash_T` (regel 21): (geen Descr)
- `P` (regel 26): 2^31 - 1, een priemgetal.
- `W` (regel 57): 16807^positie modulo P.
- `Hex` (regel 62): De hash als 8 hexadecimale tekens, voor in de naam van een store.
- `StoreSignature_T` (regel 79): (geen Descr)
- `PathLength` (regel 86): Lengte van het langste bestandspad in de store of map. Windows staat er 259 toe (ModelParameters/Advanced/MaxPathLength).
- `Written` (regel 89): Schrijft de handtekening; alleen via IsEnsured, als SignatureFile nog niet bestaat.
- `Stored` (regel 91): De handtekening zoals hij in SignatureFile staat.
- `PathGate` (regel 95): Faalt als het langste pad (PathLength) langer is dan Windows toestaat; maak dan LocalDataDir of OutputLabel korter.
- `EnsureGate` (regel 98): Faalt als SignatureFile een andere handtekening heeft dan Signature (Stored tegen Signature). Bij de uitvoer: kies een ander OutputLabel, of maak de uitvoermap leeg (batch/UpdateAll.cmd output doet dat). Bij een cache: een hashbotsing, of een met de hand gewijzigd bestand.
- `CheckGate` (regel 101): Faalt als SignatureFile ontbreekt of een andere handtekening heeft dan Signature (Stored tegen Signature): de store of uitvoer is niet (of met andere parameters) gemaakt. Maak hem eerst, of herstel de parameters.
- `ForWriting` (regel 104): Voor de ExplicitSuppliers van een schrijver: schrijft de handtekening als die er nog niet is, en faalt bij een te lang pad of een andere handtekening.
- `ForReading` (regel 106): Voor de StorageName van een lezer: Path, of een fout als de handtekening ontbreekt of afwijkt.
- commentaar regel 1-11: Namen van stores en uitvoer (NetworkModel_PBL#118, sinds 2026-10-03).  Tot 2026-10-03 droeg de naam van elke cache (ketenstore, autostores) en elk uitvoerbestand alle parameters waarvan de inhoud afhangt. Bij de stores is de naam de cachesleutel: een store die bestaat, wordt gelezen. Zo groeide het langste pad tot 252 a 257 van de 259 tekens die Windows toestaat, en faalde een te lang pad pas bij het schrijven, na het rekenen. Nu staat in de naam alleen wat leesbaar moet zijn (datum, tijdvenster of vertrekmoment, herkomst- en bestemmingenset, blok), en voor de caches een hash van 8 tekens over de handtekening: de tekst met alle parameters die de inhoud bepalen, dezelfde tekst die tot nu toe de naam was. De handtekening staat in signature.txt in de map van de store of de uitvoermap (sinds 2026-10-06; daarvoor bij de stores in <naam>.signature.txt ernaast). Een schrijver schrijft hem als hij er nog niet is en weigert te schrijven als er een andere staat; een lezer weigert te lezen als hij ontbreekt of afwijkt. Een hashbotsing geeft zo een fout in plaats van stil een verkeerde store.
- commentaar regel 13-20: Polynoomhash van een tekst: som over de tekens van code(teken) x 16807^positie, modulo 2^31 - 1, als 8 hexadecimale tekens. GeoDMS heeft geen stringhash (gezocht in 20.22.1); deze is alleen gewone gehele rekenkunde, dus stabiel over versies en platforms, wat een cachesleutel nodig heeft. code(teken) is de positie in Alphabet plus 1, 0 voor een teken dat er niet in staat (de handtekeningen bestaan uit letters, cijfers en leestekens; de enkele aanhalingsteken en de backslash zijn in een GeoDMS-tekst niet zonder escape te schrijven en staan er niet in). 16807 is een primitieve wortel modulo 2^31 - 1, dus de machten zijn verschillend; twee verschillende teksten van n tekens botsen met een kans van orde n / 2^31. De machten volgen uit de bits van de positie (B1 tot en met B1024), zodat alles per element te rekenen is; vandaar hoogstens 2047 tekens. Gecontroleerd tegen een Python-implementatie van dezelfde formule: 'Ab_9-x,=;' geeft 57154c6e.
- commentaar regel 70-78: De handtekening van een store of uitvoermap: schrijven, lezen en controleren, plus de padlengtecontrole vooraf. - Een schrijver neemt ForWriting op in zijn ExplicitSuppliers. Bestaat SignatureFile niet, dan schrijft ForWriting hem met Signature; bestaat hij wel, dan moet hij gelijk zijn aan Signature. Daarnaast moet het langste pad (PathLength) binnen ModelParameters/Advanced/MaxPathLength blijven, zodat een te lang pad faalt voordat er gerekend wordt. - Een lezer bouwt zijn StorageName met ForReading: dat is Path als SignatureFile bestaat en gelijk is aan Signature, anders een fout. Het schrijven moet via ExplicitSuppliers: een StorageName-expressie rekent Written wel uit, maar schrijft het bestand niet (getest met 20.22.1). En de IntegrityCheck staat op een leverancier (EnsureGate, CheckGate) en niet op het item in de StorageName-expressie, want alleen zo stopt een afwijking het lezen.

## cfg/main/Templates/Merge_Regions_OV_T.dms

- `Merge_Regions_OV_T` (regel 1): (geen Descr)
- commentaar regel 7-11: Voegt de OV-uitvoer van alle herkomstblokken voor een vertrekmoment samen tot <OutputDir>/tt_<datum>_<moment>.csv; tot 2026-10-03 (NetworkModel_PBL#118) %LocalDataProjDir%/Output/tt<datum, moment, herkomstenset en PT_OutputFileTail>.csv. Sinds 2026-09-25 (audit 6.5) geschreven met GDAL, met de vertrekmomentloze kolomnamen en de naamstaart van de schrijver. Sinds 2026-10-03 met afstand, reistijd en prijs per categorie (PreTransport, OV, PostTransport; lopen, fiets, auto), en de getallen als getal: GDAL schrijft ze zonder aanhalingstekens, een lege waarde als leeg veld (ReadExport_OV_perTime_T).

## cfg/main/Templates/ReadMergeExports_OV_perType_T.dms

- `ReadMergeExports_OV_perType_T` (regel 1): (geen Descr)
- `Merge_Times_OV_T` (regel 30): (geen Descr)
- commentaar regel 6-10: Samenvoegen van de OV-uitvoer: eerst per vertrekmoment over alle herkomstblokken (Merge_Regions), dan over de vertrekmomenten (Merge_Times). Sinds 2026-09-25 (audit 6.5) met de naamstaart van de schrijver en via GDAL; de bestandsnaam van Merge_Times begint met 'tt_<datum>', zoals FindMedian (PostAnalysis) hem leest (tot dan 'tt__'). Sinds 2026-10-03 (NetworkModel_PBL#118) in ModelParameters/Impl/OutputDir: tt_<datum>_<moment>.csv en tt_<datum>.csv, alleen als de handtekening van die map klopt (NetworkSetup/GenerateOutput/Output_Sig/ForReading).
- commentaar regel 38-38: Sinds 2026-10-03 dezelfde kolommen als de bestanden per vertrekmoment, de getallen als getal (zie Merge_Regions_OV_T).

## cfg/main/Templates/CreateNetwork_Pedestrian_Bike_T.dms

- `CreateNetwork_Pedestrian_Bike_T` (regel 1): (geen Descr)
- `IsBidirectional` (regel 19): Sinds 2026-10-13 (#124): een eenrichtingsfietspad van de Fietsersbond alleen van F1 naar F2; de OSM-netten voor lopen en fietsen hebben geen eenrichting.
- `ExtraTime_seconds` (regel 68): Alleen een fietsbeen in het PreTransport zoekt op of het op een IC-station eindigt; de andere benen hebben een vaste extra tijd.
- `Price` (regel 82): De huurprijs bij de OV-fiets; anders de tijdwaardering over de verlengde tijd, bij fietsen in het PostTransport voor een eigen fiets bij de laatste halte (sinds 2026-10-19; tot dan kreeg RMT_Stops2Dest_Cycling met UseOVFietsPriceForAllCyclingPostTransport de huurprijs).
- `Links` (regel 100): De links van de route van elk been, alleen in de HB-paarmodus (IsOD); de geometrie is die van het vereenvoudigde net, een rechte lijn per link.
- commentaar regel 32-33: In de HB-paarmodus (ModelParameters/Impl/IsOD, sinds 2026-10-21, #129) vraagt de zoektocht ook de LinkSet, en geeft Links per been de links van zijn route (Templates/RouteLinks_T); de reistijden zijn dezelfde.
- commentaar regel 55-62: Extra tijd op het been, bovenop de netwerkreistijd: voor een fietsbeen de starttijd, in het PreTransport ook de parkeertijd bij de halte en, als het been op een IC-station eindigt, de extra parkeertijd daar. De V- en N-unions in PublicTransport.dms lezen Duration_seconds_ext, en de prijs hieronder rekent over dezelfde verlengde tijd, zodat parkeren ook in de tijdwaardering meetelt. Het IC-station is sinds 2026-10-05 een kenmerk van de rit (de halte waar hij eindigt staat in impl/Ric_Stops), niet meer van het type: tot dan kreeg alleen het type Org2Ric_Stops_Cycling (StopClass 'Ric') de extra tijd, en een fietsbeen van Org2Stops_Cycling naar een IC-station, zoals in de component Fiets (#117), niet.

## cfg/main/Templates/CreateNetwerk_Basic_T.dms

- `CreateNetwerk_Basic_T` (regel 1): (geen Descr)
- commentaar regel 111-113: hiermee wordt voor ieder begin en eind node het aantal geconnecte links bepaald dit bepaalt of het een bocht (2 links), zijweg (3 links), kruising (4 links) of complexe kruising (meer dan 4 links) is afhankelijk van dit aantal wordt een aantal seconden opgeteld bij de totale impedance
- commentaar regel 115-115: helft van de opgegeven waarden omdat er zowel bij begin als einde een factor wordt opgeteld

## cfg/main/Templates/PrivateTransport_Car_T.dms

- `PrivateTransport_Car_T` (regel 1): (geen Descr)
- `ImpedanceMatrix_T` (regel 86): (geen Descr)
- `ImpedanceMatrix_with_AltImp_T` (regel 116): (geen Descr)
- `Car_Time` (regel 145): De reistijd van de route, onder dezelfde naam als in ImpedanceMatrix_with_AltImp_pareto_T.
- `Car_Distance` (regel 146): De afstand van de route, onder dezelfde naam als in ImpedanceMatrix_with_AltImp_pareto_T.
- `TD_ImpedanceMatrix_T` (regel 161): (geen Descr)
- `Departure` (regel 170): departure_time van de zoektocht: het vertrekmoment plus Car_StartTime, vanaf het begin van het venster.
- `MetLinks` (regel 177): (geen Descr)
- `Car_Time` (regel 201): De reistijd van de route, aankomst min vertrek op het netwerk.
- `Car_Distance` (regel 202): De afstand van de route.
- `Links` (regel 205): De links van elke route, alleen in de HB-paarmodus (MetLinks).
- `LinkGeometrie` (regel 209): De vorm van de weg van elke link, uit TomTom.
- `ImpedanceMatrix_with_AltImp_pareto_T` (regel 212): (geen Descr)
- `Car_Time` (regel 266): De reistijd van de route: het tweede criterium als op afstand eerst gezocht is, anders het eerste.
- `Car_Distance` (regel 267): De afstand van de route: het eerste criterium als op afstand eerst gezocht is, anders het tweede.
- `ImpedanceMatrix_with_Linkset_T` (regel 272): (geen Descr)
- commentaar regel 71-75: Het front van de directe autorit (PublicTransport_Prep/Direct/Car; sinds 2026-10-05 op reistijd en afstand, #88). De scalaire variant is _w_AltImp hierboven (per HB-paar de snelste route met haar afstand, ook voor de exports), _w_AltImp_pareto is het (reistijd, afstand)-front per HB-paar (Advanced/ParetoLegs_Car). De prijs volgt pas bij het lezen: afstand x Car_CostPerKm. Tot 2026-10-05 waren dit _w_Cost en _w_Cost_pareto, met als tweede criterium de linkkosten (kilometerprijs per wegklasse en optrekkosten; op het OSM-net lengte x kilometerprijs).
- commentaar regel 151-154: Tijdafhankelijke autorit (ModelParameters/Impl/CarTimeDependent, sinds 2026-10-09, NetworkModel_PBL#132, GeoDMS#1304): per vertrekmoment een zoektocht op het TomTom-netwerk, met de linktijden van Create_Network_TomTom/TimeDependent: de vaste linktijd T_ref (de momentopname van het congestiemoment) en per link met een profiel de factor per tijdvak. De vertrektijd telt vanaf het begin van het venster (CarTD_WindowStart), plus Car_StartTime: de rit op het netwerk begint na het starten.
- commentaar regel 165-167: 'pareto_alt' (ModelParameters/Advanced/CarTD_Search): afstand eerst, zoals ImpedanceMatrix_with_AltImp_pareto_T met de relatieve CarFrontEpsilon, en het tijdprofiel op het tweede criterium, de reistijd (timedependent_alt). 'scalar': alleen de snelste route, met het tijdprofiel op het enige criterium (timedependent), voor toetsen op een engine zonder timedependent_alt.
- commentaar regel 176-176: In de HB-paarmodus (sinds 2026-10-21, #129) ook de links van elke route (pareto met LinkSet: GeoDMS#1325).
- commentaar regel 219-236: Een bi-criteria label-setting zoektocht met per HB-paar een rij per Pareto-optimale route (GeoDMS#856, doc/bicriteria-impedance.md). Car_Time en Car_Distance geven reistijd en afstand, in welke volgorde ook gezocht is.  Sinds 2026-10-05 (CarFrontEpsilon > 0, GeoDMS #1282): AFSTAND EERST, want de prijs is afstand x Car_CostPerKm en het rapportagethema is bereikbaarheidsarmoede. De engine neemt per bestemmingszone de routes aan in volgorde van afstand, de kortste (goedkoopste) eerst, en een langere route alleen als haar reistijd meer dan de fractie CarFrontEpsilon onder de snelste al aangenomen reistijd ligt (pareto(imp2_epsilon), relatief). De grens van MaxCarTime is die op het tweede criterium (pareto(OrgZone_max_imp2)), en met zo'n grens zoekt de engine exact en dunt hij alleen per zone uit (GeoDMS c1d0aacbb): per knoop kon een deelroute die minder dan 1% sneller is, de enige zijn die binnen de grens blijft. De eerste rij per paar is de kortste route, exact; de snelste blijft als ze meer dan CarFrontEpsilon sneller is dan elke kortere route die blijft. De verplichte grens op het eerste criterium is CarFrontMaxDistance, ruim genoeg om niets af te snijden.  Op een engine voor 20.21.0, of met CarFrontEpsilon 0: reistijd eerst, met de afstand per link gekwantiseerd (AltImp_q). Afronden naar het dichtstbijzijnde veelvoud laat elke link onder een half kwantum wegvallen, en de meeste TomTom-links zijn korter dan het kwantum. Daarom dithering: per link een vaste pseudo-toevallige drempel u in [0,1) uit het link-id, en AltImp_q = rounddown(Distance/q + u) * q. De verwachting over u is Distance, dus de som over een route is onvertekend. (in uint64, want GeoDMS meldt een overflow bij uint32-vermenigvuldiging in plaats van te wikkelen) Tot 2026-10-05 ook met de epsilon reistijd eerst, met afstandsbakken van 400 m (CarFrontDistanceEpsilon).

## cfg/main/Templates/CreateNetwork_TomTom_T.dms

- `CreateNetwork_TomTom_T` (regel 1): (geen Descr)
- `Road_rel` (regel 77): Het wegelement, voor de tijdafhankelijke linktijden (TimeDependent, sinds 2026-10-09).
- `FRC_rel` (regel 86): Wegklasse, voor de kilometerprijs per wegklasse van de directe autorit.
- `F1_node` (regel 148): Beginknoop van het wegelement, voor de knoopgraad.
- `F2_node` (regel 149): Eindknoop van het wegelement, voor de knoopgraad.
- `IsOneDirection` (regel 195): Wegelementen zijn gerichte links (een tweerichtingsweg heeft ook een omgekeerde kopie); de OD-koppellinks zijn in beide richtingen berijdbaar.
- `IsBackward` (regel 196): De omgekeerde kopie van een tweerichtingsweg.
- `Road_rel` (regel 197): Het wegelement van de link; null voor de OD-koppellinks.
- `FRC_rel` (regel 201): Wegklasse per link; de OD-koppellinks krijgen Not Applicable.
- `LengthKm` (regel 221): Ook het tweede criterium van het front van de directe autorit (sinds 2026-10-05, #88); tot dan waren dat de linkkosten LinkCost (kilometerprijs per wegklasse en optrekkosten).
- `MaxSpeed` (regel 308): Het plafond van het congestiemoment (100 km/u overdag), voor alle tijdvakken van het venster.
- `RefSlot` (regel 310): Het tijdvak van het congestiemoment in het venster (07:30 bij een venster vanaf 06:00: 18).
- `Sn_rel` (regel 315): De rij van de Speednetworks in de richting van de link.
- `T_ref` (regel 318): De vaste linktijd van de zoektocht: de momentopname van het congestiemoment.
- `Profile` (regel 320): De links met een eigen profiel, met de grootheden van hun linktijd die niet van het tijdvak afhangen.
- `Profile_rel` (regel 333): link_profile_rel van de zoektocht; null houdt T_ref.
- `ProfileSlot` (regel 335): Per profiel de tijdvakken van het venster, profiel na profiel (de volgorde van combine(Profile, Slot), die de zoektocht verwacht).
- `T` (regel 346): De linktijd van de momentopname van dit tijdvak.
- `factor` (regel 347): profile_slot_factor van de zoektocht: T_ref / T; 1 in het tijdvak van het congestiemoment.
- `NrRefMismatch` (regel 351): Moet 0 zijn.
- `NrBadFactor` (regel 354): Moet 0 zijn.
- commentaar regel 61-61: De snelheden van de tegenrichting van een tweerichtingsweg (audit 4.2).
- commentaar regel 169-171: Een tweerichtingsweg wordt twee gerichte links, elk met de snelheid van zijn eigen richting (audit 4.2): de wegelementen zelf in hun rijrichting, en voor de tweerichtingswegen een omgekeerde kopie. Met InterpretAllRoadsAsBidirectional blijft alles zoals voorheen een ongerichte link per wegelement.
- commentaar regel 240-241: De knoopgraad telt wegelementen: niet de OD-koppellinks (die maakten van elk aanhechtpunt een kruispunt met penalty voor het doorgaande verkeer) en niet de omgekeerde kopie van een tweerichtingsweg (audit 5, 2026-09-25).
- commentaar regel 243-245: NrConnectedLinks_withSlowTrafficRoad en Crossroad_could_result_in_lower_speed_penalty zijn per 2026-09-25 weg (audit 3.9): ze lazen LinkSet/IsSlowTrafficRoad, dat het TomTom-net niet heeft, en de lagere penalty voor knopen met alleen langzame wegen is voor TomTom nooit aangezet (zie de uitgecommentarieerde regels in CorrectImpedanceForCrossroads).
- commentaar regel 254-256: hiermee wordt voor ieder begin en eind node het aantal geconnecte links bepaald dit bepaalt of het een bocht (2 links), zijweg (3 links), kruising (4 links) of complexe kruising (meer dan 4 links) is afhankelijk van dit aantal wordt een aantal seconden opgeteld bij de totale impedance
- commentaar regel 258-260: Een route die een knoop passeert, rijdt over een link die er eindigt en een die er begint; elke link krijgt daarom de helft van de penalty van zijn begin- en eindknoop, zodat een gepasseerd kruispunt zijn waarde een keer kost. Tot 2026-09-25 telde de volle waarde aan beide uiteinden, dus dubbel (audit 5).
- commentaar regel 294-301: Tijdafhankelijke linktijden (ModelParameters/Impl/CarTimeDependent, sinds 2026-10-09, NetworkModel_PBL#132, GeoDMS#1304). Elke link is een wegvak in een richting of een OD-koppellink, zonder samenvoeging, dus een link kan een eigen profiel krijgen: alleen als zijn snelheid in het venster (CarTD_WindowStart, CarTD_NrSlots tijdvakken van 300 s) verandert. De factor per tijdvak is T_ref / T: T is de linktijd zoals de momentopname van dat tijdvak hem rekent, met dezelfde bewerkingen als TomTom.dms (Roads_selection/CalcTimes: SP_freeflow x relatieve snelheid, MINUTES zonder snelheid, het plafond MaxSpeed) en LinkSet/Impedance_per_ImpedanceType hierboven (CarDefaultSpeed_low, de kruispuntcorrecties); T_ref is de momentopname van het congestiemoment van het PartOfDay (07:30). De zoektocht neemt T_ref als vaste linktijd en deelt hem per tijdvak door de factor, dus binnen een tijdvak is de linktijd precies die van de momentopname van dat tijdvak; een rit over de grens van een tijdvak rijdt het deel van de link daarna met de snelheid van het volgende (de integraal van GeoDMS#1304).
- commentaar regel 350-350: Toetsen: in het tijdvak van het congestiemoment is T gelijk aan T_ref (dezelfde bewerkingen); alle factoren positief en eindig.

## cfg/main/Templates/CreateNetwork_Efficient_T.dms

- `CreateNetwork_Efficient_T` (regel 1): (geen Descr)
- commentaar regel 77-77: lowercase: de autonetten worden met 'car' aangeroepen; zonder lowercase viel de terugval op CarSpeed_kmhr (130 km/u) in plaats van CarDefaultSpeed_low (audit 3.3/4.7)
- commentaar regel 117-118: De knoopgraad telt de weglinks, niet de OD-koppellinks: die splitsen een weg op het aanhechtpunt en maakten daar een kruispunt van drie links met penalty voor het doorgaande verkeer (audit 5, 2026-09-25).
- commentaar regel 126-128: hiermee wordt voor ieder begin en eind node het aantal geconnecte links bepaald dit bepaalt of het een bocht (2 links), zijweg (3 links), kruising (4 links) of complexe kruising (meer dan 4 links) is afhankelijk van dit aantal wordt een aantal seconden opgeteld bij de totale impedance
- commentaar regel 130-132: Een route die een knoop passeert, rijdt over een link die er eindigt en een die er begint; elke link krijgt daarom de helft van de penalty van zijn begin- en eindknoop, zodat een gepasseerd kruispunt zijn waarde een keer kost. Tot 2026-09-25 telde de volle waarde aan beide uiteinden, dus dubbel (audit 5).
- commentaar regel 570-570: Verwijder links naar dead ends (if F1 or F2 occurs only once in all F1/F2, and not being OD-location)

## cfg/main/Classifications.dms

- `ToBeCalculated` (regel 65): Alle Chains die nodig zijn om langere Chains mee te maken of om reizen uit te kiezen.
- `Allowed` (regel 66): Zonder Chains waaruit geen reizen samengesteld kunnen worden
- `NeedsOwnBike` (regel 85): Vraagt dit been een eigen fiets (NetworkModel_PBL#117)? Fietsen wel, ook in het PostTransport (een eigen fiets bij de laatste halte), behalve met een gehuurde OV-fiets. Sinds 2026-10-19 ook RMT_Stops2Dest_Cycling, dat tot dan met UseOVFietsPriceForAllCyclingPostTransport als OV-fiets telde.
- `NeedsBike` (regel 143): Vraagt een voor- of natransportbeen van deze klasse een eigen fiets (NetworkModel_PBL#117)?
- `AnyNeedsBike` (regel 145): Vraagt een van de voor- of PostTransportTypes een eigen fiets? Zo niet, dan heeft geen OV-keten een fiets nodig.
- `OD_Tellingen_Soort` (regel 150): Rijen van de OV-uitvoer per soort optie: alle, een OV-keten (met voor- en PostTransport), en de directe ritten lopen (WW), fiets (CC) en auto (AA).
- `OD_Tellingen_Groep` (regel 156): Unieke HB-paren met minstens een optie van deze soort, of met een optie voor deze groep reizigers: zonder auto (NeedsCar 0), en zonder auto en fiets (NeedsCar en NeedsBike 0).
- `IsLnet` (regel 211): Vervoerders van het NS-net (L-net, NS-tarief): NS, en sinds 2026-10-02 (#3) NS International voor binnenlandse reizen (ModelParameters/Advanced/IsNSInternationalInLnet). Eurostar en Nightjet doen binnenlands toch niet mee: zie ModelParameters/Advanced/TrainsWithoutNSTicket (en pickup_type/drop_off_type in de GTFS). European Sleeper hoort er niet bij (alleen met reservering, geen NS-kaartjes).
- `EpsilonExpr` (regel 284): Per criterium de relatieve epsilon voor pareto_optimal_eps (GeoDMS #1282, relatief sinds 2026-10-05). Price of Price_augm staat voorop, en op het eerste criterium werkt een epsilon niet: 0. De resttijden zijn een afstand tot het einde van het analysevenster en geen reisduur, dus exact (tot 2026-10-05 bakken van 60 s); de tiebreak Price_augm 1.0: een criterium dat alleen de volgorde geeft (tot dan bakken van 1e9).
- `ParetoArgs` (regel 294): De argumenten van dit criterium voor pareto_optimal_eps(part, crit1, crit2, eps2, ...): het eerste criterium geeft alleen de volgorde en krijgt geen epsilon, een bool ook niet (GeoDMS #1282, dcba9d9e0; tot dan een epsilon na elk getal, ook het eerste, waar hij niet werkte).
- `EpsilonExpr` (regel 305): Per criterium de relatieve epsilon voor pareto_optimal_eps (GeoDMS #1282, relatief sinds 2026-10-05; tot dan een bakbreedte in de eenheid van het criterium). De prijs staat voorop, en op het eerste criterium werkt een epsilon niet: 0.
- `IsCriteriaInLijst` (regel 306): Sinds 2026-09-25 ongeacht hoofdletters (audit 3.7): tot dan viel 'Price_Augm', zoals de Descr van MinimiseCriteria het schrijft, stil terug op Price.
- `ParetoArgs` (regel 322): De argumenten van dit criterium voor pareto_optimal_eps(part, crit1, crit2, eps2, ...): het eerste criterium geeft alleen de volgorde en krijgt geen epsilon, een bool ook niet (GeoDMS #1282, dcba9d9e0; tot dan een epsilon na elk getal, ook het eerste, waar hij niet werkte).
- `CriteriaName` (regel 332): Het element in MinimiseCriteria.
- `FileNameElement` (regel 333): Het element in de handtekening van de uitvoer (PT_Output_ParamTag, tot 2026-10-03 in de uitvoernamen): de letter van auto en fiets in ModeUsed. Kort, want het langste uitvoerpad was toen al 252 van de 259 tekens (NetworkModel_PBL#118).
- `EpsilonExpr` (regel 334): Leeg: een bool-criterium heeft geen epsilon in pareto_optimal_eps.
- `IsCriteriaInLijst` (regel 335): Noemt MinimiseCriteria het criterium, bij het samenvoegen (MergeOutput) MergeCriteria? Tot 2026-10-20 bij het samenvoegen altijd: daar horen autobezit en fietsbezit bij.
- `IsRelevant` (regel 336): Kan een optie een auto of fiets vragen? Een auto alleen de directe autorit (er is geen P+R-PreTransport), een fiets de directe fietsroute en voor- of PostTransport met een eigen fiets. Een criterium dat voor alle opties gelijk is, verandert het front niet en blijft weg, ook uit de uitvoernamen.
- `OutputParetoAttr` (regel 342): De criteria van de eindafweging per vertrekmoment: FinalParetoAttr plus de geselecteerde bezitscriteria.
- `ParetoArgs` (regel 348): De argumenten van dit criterium voor pareto_optimal_eps(part, crit1, crit2, eps2, ...): het eerste criterium geeft alleen de volgorde en krijgt geen epsilon, een bool ook niet (GeoDMS #1282, dcba9d9e0; tot dan een epsilon na elk getal, ook het eerste, waar hij niet werkte).
- commentaar regel 148-149: De regels van de tellingen naast de OV-uitvoer (sinds 2026-10-04): <OutputDir>/od_tellingen.csv en unieke_od_tellingen.csv, zie NetworkSetup/ConfigurationPerBlock/Generate_Output/OD_Tellingen.
- commentaar regel 205-206: vervoerders die wel in GTFS zitten maar niet in deze lijst zijn niet opgenomen omdat ze in het buitenland opereren (De Lijn, DB, Eurobahn, NIAG, NMBS, VIAS, TCS OV, GoVolta) let op feed-drift: 'NS International' heet vanaf feed 20251008 'NS Int'; 'Eu Sleeper' heet vanaf feed 20260316 'European Sleeper'. Beide varianten staan er daarom in.
- commentaar regel 264-277: De criteria van de ketenrijger. Een groep van de ketenrijger heeft dezelfde instap- en uitstaptijdhalte en, sinds audit 6.3, hetzelfde eerste NS-station van de lopende NS-reis (ChainJoiner_T, Part_rel). De ketenrijger kiest op de prijs van het eindfront (Price, of Price_augm als MinimiseCriteria die noemt) en op de resttijden die bepalen of een keten nog tegen een doorgaand tarief verlengd kan worden. Bij een eindfront op Price beslist Price_augm (prijs plus tijdkosten van overstappen) alleen tussen ketens die verder gelijk zijn (relatieve epsilon 1, tot 2026-10-05 bakken van 1e9: geen extra frontrijen); dat kan alleen pareto_optimal_eps. De reistijd is binnen een groep gelijk, behalve met een tijdpenalty (GradeSeparatedTransferPenalty, of FlexExtraWaitingTime voor flexbenen): dan is TravelTime ook een criterium (audit 6.2). De volgorde: prijs eerst (het rapportagethema is bereikbaarheidsarmoede). Met de relatieve epsilon van pareto_optimal_eps (GeoDMS #1282, sinds 2026-10-05) geeft het eerste criterium de volgorde en blijft de goedkoopste keten van een groep altijd staan; een duurdere blijft alleen als ze op een ander criterium beter is dan elke goedkopere die blijft, op de reistijd met meer dan ChainParetoTimeEpsilon. Een epsilon op de prijs werkt daardoor niet en is 0. Geschiedenis: tot 2026-09-25 alleen Price_augm, zodat de goedkoopste keten van een groep kon sneuvelen tegen een duurdere met minder overstaptijd (audit 6.1); op 2026-09-25 Price_augm en Price samen (_r3), wat de ketenrijging ruim twee keer zo traag maakte zonder het eindfront te verbeteren; sinds 2026-09-26 (_r4) deze opzet.
- commentaar regel 299-302: Prijs eerst, dan de reistijd (bereikbaarheidsarmoede): met de relatieve epsilon (GeoDMS #1282, sinds 2026-10-05) blijft de goedkoopste optie van een HB-paar altijd staan, en een duurdere alleen als ze meer dan ChainParetoTimeEpsilon sneller is dan de snelste goedkopere optie die blijft. Elke optie die afvalt, heeft zo een goedkopere die blijft en hoogstens ChainParetoTimeEpsilon trager is. Daarna de bezitscriteria (OwnershipParetoAttr), exact.
- commentaar regel 325-328: Autobezit en fietsbezit als criteria in de eindafweging (NetworkModel_PBL#117, sinds 2026-10-01): een optie die geen auto of fiets vraagt, blijft naast een goedkopere en snellere optie die dat wel doet. Alleen in de condensaties per vertrekmoment (NetworkSetup/PublicTransport/PerDepartureMoment_T); de ketenrijger rekent alleen OV en houdt FinalParetoAttr, zodat de ketenstore dezelfde blijft. Bool-criteria, geminimaliseerd (false voor true) en zonder epsilon: GeoDMS #1287, vanaf e04ad20f0.

## cfg/main/Classifications/Modes.dms

- `IsGelijkvloers` (regel 13): (geen Descr)
- `IsGelijkvloers` (regel 123): (geen Descr)
- `Route_type` (regel 124): relateert aan route_type in routes.txt
- `abbr` (regel 155): De letter van het been met dit cijfer van ModeCode (mode-id + 1); leeg voor 0, geen been.
- commentaar regel 148-152: ModeCode (sinds 2026-10-06): de modes van de benen van een OV-keten in een uint32, 4 bits per been met het mode-id + 1 (0 = geen been), het eerste been in de hoogste bits; vijf benen (Max_transfers hoogstens 4) passen in 20 bits. De ketenrijger plakt links en rechts aan elkaar met links x ModeFactor van rechts + rechts; ModeFactor is 16 bij een been (OD_R/Result, OD_L/Result) en het product van links en rechts bij een samengestelde keten (ChainJoiner_T). Tot dan was ModeUsed een string van een letter per been (name_abbr), ongeveer 420 bytes geheugen per rij. CodeDigits geeft per cijfer de letter terug, voor de uitvoer.

## cfg/main/Classifications/OSM.dms

- commentaar regel 4-4: Configuratie voor project: Open Data Analyse                 //
- commentaar regel 10-10: Configuratiebestand met attributen voor OSM roadTypen              //
- commentaar regel 124-128: Sinds 2026-09-25 (audit 4.8). Deze fclasses van Geofabrik stonden niet in de tabel en werden via de terugval in NetworkPreperation een connectlink, in het auto-, fiets- en loopnet (620.107 features, 197.104 km in OSM 20260601). Een track (landbouw- of bosweg) hoort niet in het autonet, net als 'track' zonder grade; grade1 (verhard) en grade2 (halfverhard, grind) zijn fietsbaar, grade3 tot 5 (onverhard) alleen beloopbaar. busway is als bus_guideway, unknown (een highway-waarde die Geofabrik niet kent) als FIXME; unknown is ook de terugval voor een fclass die hier niet staat.

## cfg/main/Geography/ngr_layer_lea.dms

- commentaar regel 4-5: Configuratie voor WMS lagen, gedefineerd vanuit een opgevraagd              // GetCapabilities Request in xml format.                                      //
- commentaar regel 74-74: Werkende: https://tiles.geoservice.dlr.de/service/wmts?SERVICE=WMTS&VERSION=1.0.0&REQUEST=GetTile&FORMAT=image%2Fpng&LAYER=eoc%3Abasemap&TILECOL=1&TILEROW=2&STYLE=_empty&TileMatrixSet=EU%3A3035&TileMatrix=EU%3A3035%3A3

## cfg/main/Geography.dms

- `gridgrootte` (regel 129): (geen Descr)
- `afkapstraal` (regel 130): (geen Descr)
- `straal` (regel 131): (geen Descr)
- commentaar regel 14-17: fpoint-variant van rdc, UITSLUITEND om stores te lezen die geschreven zijn toen rdc float32 was: de oude TomTom-fss (TomTom/FromFss) en adres.fss in de BAG-snapshots. Zulke bytes worden door een dpoint-declaratie stil verkeerd gelezen (extent 1e41, geen melding), dus lees ze als rdc_f32 en cast daarna met [rdc]. Nieuwe stores zijn mmd en dragen hun waardetype zelf, dus dit is alleen voor oud materiaal.

## cfg/main/SourceData/OVprijzen.dms

- `FareTable` (regel 13): (geen Descr)
- `Read_DOVA_kmtarieven` (regel 15): (geen Descr)
- `Read_DOVA_basistarieven` (regel 26): (geen Descr)
- `name` (regel 38): Mode-klassen voor DOVA-prijzen: BTM=bus/tram/metro, Rail=regionale trein, Ferry=veer. NS-trein loopt via het L-net (NS-tariefstructuur), niet via deze FareTable.
- `VariablePrice_landelijk` (regel 39): Landelijk gemiddeld km-tarief per mode-klasse (volgt het gekozen jaar); fallback voor concessies zonder DOVA-rij en voor het Buitenland-vangnet.
- `Vervoerder` (regel 303): /SourceData/Infrastructure/GTFS/LoadFeeds/ReadFSS/agency/Data/agency_name
- `Vervoerder` (regel 483): /SourceData/Infrastructure/GTFS/LoadFeeds/ReadFSS/agency/Data/agency_name
- `Vervoerder` (regel 659): /SourceData/Infrastructure/GTFS/LoadFeeds/ReadFSS/agency/Data/agency_name
- `Vervoerder` (regel 836): /SourceData/Infrastructure/GTFS/LoadFeeds/ReadFSS/agency/Data/agency_name
- `NS_PricePerTariffUnit` (regel 860): csv per jaar 2013-2026: 2013-2019 uit officiele NS-tarievenlijst-pdfs (wayback) en NDOV-xls; 2020-2022 uit officiele HRN-prijstabellen; 2023+ uit NS-tarievenlijst. Kolomkoppen zonder btw-percentage (6% t/m 2018, 9% vanaf 2019). Kortingen 2013-2018 berekend als exact 0,8x/0,6x voltarief (NS-regel).
- `Tariefnet_UitgeslotenKanten` (regel 880): Kanten van NS_tariefnet_<jaar>.csv die NS voor het tarief niet meetelt: de HSL-Zuid (beide richtingen). Zie NS_TariffUnits_matrix/IsUitgesloten.
- `PerJaar` (regel 897): NS-toeslag ICE / IC direct per enkele rit, per tariefjaar.
- `Toeslag_ICE_ICD` (regel 920): De toeslag van NS_prijzen_year.
- `Opslag` (regel 923): Opslag per enkele rit; beide producten volgen de NS-toeslag ICE / IC direct.
- `ExtraTijd` (regel 924): (geen Descr)
- `HeeftTraject` (regel 925): (geen Descr)
- `Check_Stations` (regel 928): De stations van elk traject in TripSurchargeTrains bestaan in NS_stations.
- `NS_TariffUnits_matrix` (regel 943): NS-tariefnet van NS_tariefnet_year: 2013 = NDOV tariefnet.dat (https://data.ndovloket.nl/ns/ns-latest.zip) met een header erboven, met de gezamenlijke tariefpunten van voor 2016; 2016 = idem met de 69 kanten van de tariefeenhedenkaart van NS (rijdendetreinen.nl, 2026-10-04). Beide met ut,utm (#120).
- `IsUitgesloten` (regel 958): Kant die NS voor het tarief niet meetelt (Tariefnet_UitgeslotenKanten); doet niet mee in ConnectedNetwork.
- `NS_stations` (regel 1028): stations.dat downloaden, csv van maken, en headers toevoegen.
- commentaar regel 42-43: Eén canonieke DOVA-rij per (concessie, mode-klasse) (kolom use_for_price=1 in de xlsx). Harmonisatie DOVA->shape-concessie via kolom Concessiegebied_model (byte-exact), mode-klasse via kolom Mode_klasse.
- commentaar regel 50-52: FareTable uit DOVA-overzicht, gekeyd op (concessie x mode-klasse); geselecteerd wanneer ModelParameters/Advanced/PriceMethod == 'DOVA'. BTM (bus/tram/metro) krijgt het concessie-km-tarief; Rail (regionale trein) krijgt DOVA's aparte rail-km-tarief; Ferry idem waar beschikbaar. Ontbrekende (concessie,klasse)-combinaties vallen terug op het BTM-tarief van dezelfde concessie (MakeDefined).
- commentaar regel 61-61: laatste fallback: landelijk klassegemiddelde, voor shape-concessies zonder DOVA-rij (bv. Stadsvervoer Lelystad in de 2023-shape).
- commentaar regel 65-68: Vangnet voor legs buiten alle concessie-polygonen (buitenlandse trajectdelen De Lijn/DB/Eurobahn/NIAG en eventuele rand-artefacten): 1 rij per mode-klasse, key '<klasse>_Buitenland' (zie MC_CG_key_DOVA in OD_extra_attributen). km-tarief = landelijk DOVA-gemiddelde van de klasse (volgt het gekozen jaar), opstap = landelijk basistarief. Zonder dit vangnet faalt Price_IntegrityCheck in DOVA-modus op die legs.
- commentaar regel 74-74: dummy-identifiers voor compatibiliteit met FareTable_rel_initial/augmented in OD_extra_attributen (niet gebruikt in DOVA-modus).
- commentaar regel 81-88: ---- Pre-flight prijsdekking (zie /ChecksBeforeRunning/PT_CheckPriceCoverage) ---- Goedkoop te evalueren VOOR de netwerkbouw: leest alleen agency/routes van de geladen feed plus de actieve prijstabel. De match-cascade in OD_extra_attributen eindigt op Mode_Agency, dus een (mode,agency)-combinatie zonder enkele FareTable-rij krijgt gegarandeerd geen prijs op OD-niveau; dat wordt hier per feed-route gecontroleerd zonder eerst uren OD's te rekenen. NB iets strenger dan de OD-check: ook routes zonder ritten op de gekozen Analysis_date tellen mee. DOVA-modus: dekking is by construction (combine over alle concessies + Buitenland-vangnet + landelijke fallback); daar wordt gecheckt dat alle prijzen van het gekozen jaar gevuld en plausibel zijn.
- commentaar regel 91-92: R-net-routes van de feed; NS/L-net prijst via de NS-tariefstructuur en walking/cycling-pseudoroutes hebben geen agency. Bron is RelevantSelection/Routes (de unit met de attribuut-subitems; select_with_attr_by_cond op een alias-unit kopieert geen attributen).
- commentaar regel 109-110: Audit-trail: schrijft de dekking per (mode,agency)-combinatie weg als csv, zodat per feed/prijsjaar gedocumenteerd is wat gecheckt is (genereer door dit item bij te werken).
- commentaar regel 120-121: Tabel-sanity: alle niet-NS-rijen hebben gevulde, plausibele prijzen (NS-rijen prijzen via TariffUnits en zijn bewust leeg). MakeDefined ipv IsDefined zodat een null-prijs niet als null door de all() propageert maar hard als FALSE telt.
- commentaar regel 298-298: vervoerders die wel in GTFS zitten maar niet in deze lijst zijn niet opgenomen omdat ze in het buitenland opereren (De Lijn, DB, Eurobahn, NIAG, NMBS, VIAS)
- commentaar regel 874-879: NS rekent de tariefeenheden van een stationspaar over de klassieke route; wie over de HSL reist betaalt daarbovenop de rit-opslag (RitOpslag hieronder). Het tariefnet van NDOV (tariefnet.dat) bevat ook de HSL-kanten, en de kortste route daarover gaf tot 2026-10-02 te weinig eenheden voor 2.880 van de 80.200 stationsparen, tot 18 te weinig (ObjectVision/NetworkModel_PBL#3). Steekproef tegen NS (rijdendetreinen.nl, 2026): Schiphol-Rotterdam C 67 (was 55), Amsterdam C-Rotterdam C 86 (74), Amsterdam Zuid-Rotterdam C 78 (66), Rotterdam C-Breda 50 (44), Breda-Schiphol 117 (99); zonder deze kanten komen alle vijf exact uit.
- commentaar regel 889-892: Rit-opslag voor speciale treinen (ObjectVision/NetworkModel_PBL#3): de NS-toeslag 'ICE / IC direct' per enkele rit, voor de producten in ModelParameters/Advanced/TripSurchargeTrains (HSL Schiphol-Rotterdam en ICE binnenland). Het bedrag is dat van NS_prijzen_year, vol tarief: de dalkorting aan de toeslagpaal (40%, alleen met OV-chipkaart; 2024 1,74 en 2026 1,92) zit er niet in.
- commentaar regel 932-942: Het tariefnet per jaargang (ModelParameters/Impl/NS_tariefnet_year, ObjectVision/NetworkModel_PBL#121): - 2013 (voor NS_prijzen_year 2013-2015): tariefnet.dat van NDOV, uit ns-latest.zip tot ten minste 2024-10-09 (2023 en 2024 identiek; nu niet meer in de zip). Het heeft de gezamenlijke tariefpunten van NS: 35 kanten van 0 TE tussen stations dicht bij elkaar, zoals Hilversum - Hilversum Sportpark en Den Haag HS - Den Haag Centraal. - 2016: NS schafte die punten af per de tarieven van 2016 (aangekondigd september 2015, rover.nl): elk stationspaar is minstens 1 TE, de 0 werd 1 (Den Haag HS - Laan v NOI 2) en een kant ernaast 1 lager. Het 2013-net met 69 kanten aangepast naar de tariefeenhedenkaart van NS (rijdendetreinen.nl/tickets/tariefafstanden, opgehaald 2026-10-04, alle 439 kanten; de 5 grenspunten bhg, ehai, fvsg, vlgr en wrg staan er niet in en zijn ongewijzigd). Het 2013-net wijkt daarvan af voor 12.532 van de 78.606 stationsparen, 1 of 2 TE; dit net geeft alle 26 gecontroleerde NS-afstanden goed (9292 en rijdendetreinen, zie /SourceData/Infrastructure/OVprijzen/TripSurchargeReport/TE). Alleen paren met de Valleilijn-stations wijken nog af (apd,hvl 37 hier, NS heeft amf,apd 43); die rekenen het RRReis-tarief, niet het NS-tarief.
- commentaar regel 1022-1022: voor visuaisatie

## cfg/main/SourceData/OVprijzen/TripSurchargeReport.dms

- `TripSurchargeReport` (regel 1): Rapport voor ObjectVision/NetworkModel_PBL#3: NS-tariefeenheden zonder HSL-kanten, rit-opslag (HSL Schiphol-Rotterdam, ICE binnenland), NS International in het L-net en in- en uitstappen volgens de GTFS (pickup_type/drop_off_type). Draai /SourceData/Infrastructure/OVprijzen/TripSurchargeReport/Report (goedkoop: tariefnet, routes, trips en stop_times) en /SourceData/Infrastructure/OVprijzen/TripSurchargeReport/Net/Report (duur: trekt OD_L en OD_R). Uitvoer in %LocalDataProjDir%/Output/ritopslag_*.
- `Steekproef` (regel 22): (geen Descr)
- `AlleJaren` (regel 27): Paar zonder voormalig gezamenlijk tariefpunt op de route: TE_NS geldt voor beide tariefnetten.
- `FirstBoardSeq` (regel 55): Alleen zinvol als HasBoard: zonder instaphalte geeft min() een grote waarde, geen null.
- `LastAlightSeq` (regel 56): Alleen zinvol als HasAlight.
- `IsBinnenlands` (regel 57): (geen Descr)
- commentaar regel 7-15: Steekproef van tariefeenheden tegen NS (rijdendetreinen.nl, 2026-10-01). Tot 2026-10-02 gaf de kortste route over de HSL-kanten 55, 74, 66, 44, 99 en 74 eenheden. De paren vanaf asdz-hvsp (9292, 2026-10-04, #121) gaan langs een voormalig gezamenlijk tariefpunt van NS: ze gelden voor het tariefnet van 2016, en het net van 2013 (de NS-afstanden van voor 2016) gaf 28, 28, 15, 15, 18, 16, 35, 60, 80, 70, 56 en 26. De paren vanaf asd-gvc (rijdendetreinen.nl, 9292 en ns.nl, 2026-10-23, #53): Amsterdam C - Den Haag C en - Rotterdam C via Schiphol en via Haarlem. Beide routes zijn even lang in TE, en Schiphol ligt even ver van Amsterdam C, Leiden C, Den Haag C en Rotterdam C als Haarlem, al is de route via Haarlem ongeveer 3 km langer (47 tegen 44 km tot Leiden). De paren vanaf gv-gvc (rijdendetreinen.nl, 2026-10-23, #53): rond het voormalige gezamenlijke tariefpunt Den Haag HS - Den Haag C - Laan v NOI. Het net van 2013 gaf 0, 0, 0, 15, 15, 23, 23, 9 en 9 (en asd-gv 63): HS even ver als C.
- commentaar regel 40-41: Per rit: kan je binnen Nederland in- en verderop weer uitstappen? Eerste NL-halte met instappen voor de laatste NL-halte met uitstappen (protoStopTimes/PickupAllowed en DropOffAllowed). Zo niet, dan rijdt de rit binnenlands niet mee.
- commentaar regel 62-63: Treinen buiten NS die binnenlands interessant zijn: alles van het L-net met een opslagproduct, alle NS International, en de vervoerders die binnenlands niet mogen (European Sleeper, GoVolta).
- commentaar regel 79-79: De ritten van vandaag op de Treinroutes, met de eerste NL-halte met instappen en de laatste met uitstappen.
- commentaar regel 105-106: De ketenrijger op het eerste haltenblok (~0,5 min): telt de opslag mee in de prijs van ketens met NS, ook als het doorgaande NS-tarief Price_L herberekent? Price is daar Price_O + Price_I + Price_L (+ Price_F na NS links) + Price_S (ChainJoiner_T).
- commentaar regel 123-123: Het duurdere deel: de benen van het L- en R-net (trekt het OV-net, Set_L/Set_R en OD_L/OD_R).
- commentaar regel 134-134: Benen die alleen door de in- en uitstapregel (pickup_type/drop_off_type 1) afvallen: de andere filters van Result laten ze door.
- commentaar regel 146-146: Benen die alleen door de in- en uitstapregel afvallen, voor een controle met de hand.
- commentaar regel 169-169: Voorbeeldbenen van het L-net tussen een paar stations rond de HSL, voor een controle met de hand.

## cfg/main/Output/Validation.dms

- `Validation` (regel 1): Validation van de OV-ketens tegen 9292.nl, halte tot halte (ObjectVision/NetworkModel_PBL#53, skill .claude/skills/model-Validation). Schrijft voor de haltenparen in Paren de ketens uit de ketenstore die tussen VertrekVan en VertrekTot vertrekken, met vertrek, aankomst, reistijd, prijs, rit-opslag (Price_S, de ICD/ICE-toeslag die 9292 niet in de prijs telt) en ModeUsed: bereken /Output/Validation/Rows; csv in %LocalDataProjDir%/Output/validatie_*. Leest alleen de blokstores waarin de vertrekhaltes vallen; met LeesStore = FALSE rekent het die blokken zelf (zonder te schrijven), om te testen zonder ketenstore. Bereken /Output/Validation/Schrijf om alle kolommen weg te schrijven.
- `FileStem` (regel 5): (geen Descr)
- `LeesStore` (regel 6): TRUE: lees de blokken uit de ketenstore (PublicTransport_Prep/PT_Chains_Blocks); FALSE: reken ze in het geheugen (ChainGeneration_PerBlock/<blok>/BlockResultContainer/Result; via Fence/Result faalt de engine op een interne check).
- `VertrekVan` (regel 7): (geen Descr)
- `VertrekTot` (regel 8): Een uur na VertrekVan.
- `Check_Namen` (regel 25): Elke van- en naarnaam van Paren bestaat als haltenaam in de feed.
- `Blok_rel` (regel 32): Het haltenblok van de ketenstap, zoals ChainGeneration_PerBlock_T kiest.
- `ModeUsed` (regel 58): De letters per been, uit ModeCode van de ketenstore (sinds 2026-10-06).
- `reistijd` (regel 80): Traveltime van de keten in minuten (inclusief eventuele overstappenalty's).
- `prijs` (regel 81): Price in euro, inclusief de rit-opslag.
- `rit_opslag` (regel 82): Price_S in euro: de ICD/ICE-toeslag, die 9292 niet in de prijs telt.
- `Schrijf` (regel 86): Bereken dit item om Rows met alle kolommen naar FileStem.csv te schrijven.
- commentaar regel 13-13: Haltenparen op GTFS-naam (Stops/name); alle haltes met die naam tellen mee (perrons, beide richtingen).
- commentaar regel 20-20: join_equal_values kent geen strings: koppel via het nummer van de haltenaam.
- commentaar regel 65-65: Ketens van een vertrekhalte van een paar naar een aankomsthalte van hetzelfde paar, binnen het vertrekvenster.

## cfg/main/Output/FlexLines.dms

- `FlexLines` (regel 1): Rapport voor ObjectVision/NetworkModel_PBL#113: welke GTFS-routes gelden als flex-/belbuslijn (Routes/IsFlex, zoektermen ModelParameters/Advanced/FlexRouteTerms) en welke bijna-treffers bewust niet. Draai /Output/FlexLines/Report (goedkoop: alleen routes/trips/stop_times) en per flexinstelling /Output/FlexLines/Net/Report (duur: trekt het OV-net en OD_R/OD_L). Uitvoer in %LocalDataProjDir%/Output/flex_*.
- `FileStem` (regel 17): (geen Descr)
- `NrTrips_feed` (regel 19): (geen Descr)
- `NrTrips_today` (regel 20): (geen Descr)
- `uq_Route_Stop` (regel 23): Stop_rel is null voor stop_times van ritten buiten de analysedagen (Stops = gebruikte haltes); die ene null-sleutel telt in pcount niet mee.
- `NrStops` (regel 28): (geen Descr)
- `FirstStop_rel` (regel 30): (geen Descr)
- `Concessie_rel` (regel 31): (geen Descr)
- `RouteList_T` (regel 33): (geen Descr)
- `FlexSettings` (regel 56): (geen Descr)
- `Flagged` (regel 57): (geen Descr)
- `NearMiss` (regel 58): (geen Descr)
- `Report` (regel 60): (geen Descr)
- `Net` (regel 71): Netwerk-kentallen; draai /Output/FlexLines/Net/Report met verschillende flexinstellingen (IncludeFlex, FlexMinInterval, FlexExtraWaitingTime) en vergelijk (verificatie #113, #116).
- `n_flexlegs_over_cut` (regel 83): voorspelt zonder extra wachttijd hoeveel Result-rijen er met FlexExtraWaitingTime afvallen: flex-benen die met de wachttijd boven MaxPTTime uitkomen
- `Report` (regel 89): (geen Descr)
- `Block1` (regel 97): Ketenrijen van haltenblok 1 per flexinstelling: ca. 4 min en ~70 GB als het blok niet in de CalcCache staat. De asis-referentie is het aantal block==0-rijen in de steekproef-csv van #115 (pareto_chains_sample_<arm>_n20.csv). Draai /Output/FlexLines/Net/Block1/Report.
- `Report` (regel 104): (geen Descr)
- commentaar regel 5-9: Waarom een apart rapport en niet alleen Routes/IsFlex: de modelkeuze (uitsluiten, toeslag of laten) is aan PBL, en die vraagt per feed een lijst van wat de heuristiek raakt, met ritten per dag, haltes en concessie, plus de bijna-treffers die er bewust buiten blijven (Buurtbus, Wijkbus, Spijkhopper/Maasvlaktehopper, Vlinder, taxibus i.p.v. trein). Net/Report levert daarnaast de kentallen om de drie modi tegen elkaar te controleren (zie de verificatie in #113).

## cfg/main/Output/PT_NetworkExport.dms

- `PT_NetworkExport` (regel 5): Het OV-net in een tijdvenster (#57): de ritten van Dag die het venster Begin-Eind overlappen (Kaart/Ritten), per lijnvoering (Kaart/Lijnvoeringen), per segment tussen knopen van haltes (Kaart/Segmenten) en de knopen zelf (Kaart/Knopen). Bekijk de tabellen in de GUI, of schrijf ze met Generate naar %LocalDataProjDir%/Output/ptwindow_<feed>_<dag>_<venster>_<laag>.<ExportFormaat>, met het rapport ernaast.
- `Dag` (regel 10): De dag (jjjjmmdd) waarvan de ritten worden gezocht: elke dag die de geladen feed dekt. De feed is die van de peildatum van het model (ModelParameters/AnalysisMoment, ModelParameters/Impl/GTFS_file_date); het rapport noemt de eerste en laatste datum ervan. Standaard de peildatum zelf.
- `Begin` (regel 13): Begin van het venster, HH:MM op de tijdas van Dag (seconden sinds 00:00; na 24:00 de nacht erna, tot 47:59).
- `Eind` (regel 16): Einde van het venster, HH:MM, na Begin.
- `HalteClusterAfstand` (regel 19): Haltes binnen deze afstand van elkaar, en zo verder (single linkage), vormen een knoop: de perrons van een station, de haltes aan weerszijden van een straat. Bij 0 m alleen haltes op dezelfde plek.
- `MaxAfstandHalteShape` (regel 21): Een halte verder dan dit van de shape van zijn rit wordt niet op de shape geprojecteerd; het segment wordt dan een rechte lijn.
- `SegmentenOngericht` (regel 23): Heen en terug tussen dezelfde knopen zijn een segment (met nr_heen en nr_terug, heen van de knoop met het laagste nummer af), of een segment per richting.
- `ExportFormaat` (regel 25): Het formaat van Generate: gpkg, parquet (zstd) of csv (de geometrie als WKT).
- `BeginMoment` (regel 30): (geen Descr)
- `EindMoment` (regel 31): (geen Descr)
- `VensterUren` (regel 33): (geen Descr)
- `Venster` (regel 34): (geen Descr)
- `FileStem` (regel 35): (geen Descr)
- `Klassen` (regel 40): (geen Descr)
- `KlasseModaliteit` (regel 42): De modaliteiten van het model, met de kleuren van GTFS_Modes/List voor de kaart.
- `PenWidth` (regel 46): Lijndikte in pixels, in de volgorde van GTFS_Modes/Selection: tram, metro, trein en veerboot dikker dan bus.
- `KlasseFlex` (regel 48): (geen Descr)
- `Dagen` (regel 67): D-1, D en D+1 rond Dag, op de tijdas van D: van D-1 de stop_times na middernacht (GTFS-tijd 24:00 en later, min 24 uur), van D alle, van D+1 de ritten die helemaal voor 24:00 GTFS-tijd liggen (plus 24 uur). Van elke dag alleen de ritten die het venster overlappen.
- `MinVertrekDag` (regel 74): De GTFS-dag (Time/Day) van het vertrek van een stop_time is minstens dit.
- `MaxAankomstDag` (regel 75): De GTFS-dag van de aankomst van een stop_time is hoogstens dit.
- `TeltZomertijd` (regel 76): Een zomertijdwissel op deze dag verschuift de tijden; op D-1 niet, want van D-1 doen alleen de tijden na middernacht mee.
- `IsNodig` (regel 82): D altijd; D-1 als het venster voor ModelParameters/Impl/PrevServiceDayTailEnd begint; D+1 als het na middernacht doorloopt.
- `IsCompleet` (regel 88): (geen Descr)
- `Check_DagenCompleet` (regel 95): Elke dag die het venster nodig heeft, staat in de feed met minstens ModelParameters/Advanced/MinServiceDayTripShare van de ritten van de drukste dag met dezelfde weekdag; zie DagenReport.
- `Check_GeenZomertijdwissel` (regel 98): Geen dag die het venster nodig heeft (D-1 uitgezonderd), is een dag van een zomertijdwissel.
- `RitEinde` (regel 105): De laatste aankomst van de rit, in GTFS-tijd; protoTrips/StartTime is het eerste vertrek.
- `PartOfDay_T` (regel 109): (geen Descr)
- `Dienst` (regel 116): Rijdt de dienst op Datum? Zoals LoadFeeds/Services/Today_exc voor Analysis_date.
- `Rit` (regel 118): Rijdt de rit op Datum, en overlapt hij dan het venster?
- `Links` (regel 126): De links (van halte naar halte) van alle ritten van de drie dagen die het venster overlappen.
- `VLinks` (regel 149): De links die in het venster rijden.
- `Hoofdhalte` (regel 200): De halte van het cluster met de meeste vertrekken en aankomsten in het venster; geeft de naam en het punt.
- `KnoopBezoeken` (regel 203): Vertrek en aankomst van elke link in het venster.
- `NrBinnenKnoop` (regel 222): Links in het venster binnen een knoop (tussen perrons van een station, bijvoorbeeld); die vormen geen segment.
- `NrZonderModaliteit` (regel 223): (geen Descr)
- `BeginSegA` (regel 287): Het eerste hoekpunt van het segment van de boog waar A op valt.
- `Knipbaar` (regel 290): (geen Descr)
- `Bogen` (regel 293): De shapes van de representatieve links.
- `MaxAfstand2` (regel 299): connect_info_eq neemt de maximale afstand in het kwadraat (probe 2026-10-21: bij 5 vond hij haltes op 1 en 2 m van de boog wel, op 3 en 4 m niet).
- `NrPunten` (regel 308): sub_or_null: de engine rekent beide takken, ook waar B voor A ligt.
- `Ritten` (regel 328): De ritinstanties (een rit op een dag van Dagen) die het venster overlappen, met de shape van de rit of een lijn langs zijn haltes. Een rit met maar een halte heeft geen link en doet niet mee (in de feed van 20260925 in het venster 07:00-09:00 vier ritten van lijn Z132 naar Zierikzee).
- `in_ovnet` (regel 358): Doet de rit mee in het OV-net van het model? Alleen gedunde flexopties niet (LoadFeeds/FlexOptions).
- `Lijnvoeringen` (regel 368): De ritten in het venster, ontdubbeld per lijn en shape (zonder shape: per lijn en haltepatroon). De vaste kenmerken zijn die van de eerste rit.
- `Knopen` (regel 396): Knopen van haltes binnen HalteClusterAfstand met vertrekken of aankomsten in het venster, op de plek van hun drukste halte.
- `nr_haltes` (regel 402): Haltes van de knoop met vertrekken of aankomsten in het venster.
- `Segmenten` (regel 409): De links in het venster tussen twee knopen, ontdubbeld per knopenpaar (SegmentenOngericht: in beide richtingen samen) en modaliteit, met de kenmerken van hun ritten. De lijn volgt de shape van de eerste rit met een shape (SegGeom).
- `Agency_rel` (regel 415): De aanbieder van de meeste passages.
- `CheckRitten` (regel 537): (geen Descr)
- `CheckSegmenten` (regel 538): (geen Descr)
- `Report` (regel 539): (geen Descr)
- `Generate` (regel 555): Schrijft de vier lagen in ExportFormaat en het rapport, in een opvraging.
- commentaar regel 1-4: Het OV-net in een tijdvenster, voor GIS (ObjectVision/NetworkModel_PBL#57, sinds 2026-10-21). Alle ritten van Dag die het venster Begin-Eind overlappen, met hun lijn en kenmerken, ontdubbeld op twee manieren: per lijnvoering (lijn + shape) en per segment tussen twee knopen van haltes (per modaliteit), met de kenmerken van de ritten geaggregeerd. De tabellen in Kaart zijn voor de GUI (kleur naar Mode_rel, FlexKlasse_rel of een getal); Generate schrijft ze als gpkg, parquet of csv.
- commentaar regel 9-9: INSTELLINGEN
- commentaar regel 29-29: AFGELEID
- commentaar regel 60-60: DE DAG: D-1, D en D+1 rond Dag, zoals LoadFeeds/ServiceDays voor Analysis_date, maar met de eigen dag en het eigen venster.
- commentaar regel 104-104: DE LINKS VAN DE RITTEN OP DE TIJDAS VAN DAG
- commentaar regel 151-151: RITINSTANTIES: een rit op een dag; dezelfde trip_id rijdt vaak op meer dagen.
- commentaar regel 169-169: Ritten zonder shape (in de feed van 20260925 2,4 %): een lijn langs hun haltes.
- commentaar regel 184-185: LIJNVOERINGEN: per lijn en shape, voor ritten zonder shape per lijn en haltepatroon (eerste en laatste halte, aantal haltes, zoals LoadFeeds/FlexOptions/PatternKey).
- commentaar regel 193-194: KNOPEN: haltes binnen HalteClusterAfstand, zoals SourceData/Infrastructure/GTFS/OV_Knooppunten/Knopen, over alle haltes van de feed, zodat de nummers niet van de dag of het venster afhangen.
- commentaar regel 221-221: SEGMENTEN: de links in het venster tussen twee verschillende knopen, per knopenpaar en modaliteit.
- commentaar regel 258-262: De lijn van een segment: het stuk van de shape van een representatieve link, de eerste in het venster met een shape. Zijn haltes A en B worden op de shape geprojecteerd met connect_info_eq, dezelfde projectie als connect, maar alleen op de eigen shape; de lijn loopt van A naar de projectie van A, langs de hoekpunten van de shape tot de projectie van B, en naar B. Zonder shape, met een halte verder dan MaxAfstandHalteShape of met B niet na A op de shape (een lus): de rechte lijn van A naar B.
- commentaar regel 304-305: De punten van alle segmenten achter elkaar: per segment A, de projectie van A, de hoekpunten SegA+1 tot en met SegB, de projectie van B en B; of alleen A en B.
- commentaar regel 445-446: DE EXPORT: per laag een bestand FileStem_<laag>.<ExportFormaat>, met de kenmerken als tekst en getal. Een unit schrijft alleen de attributen die hij zelf heeft (probe 2026-10-21), dus hier staan ze nog eens.
- commentaar regel 536-536: HET RAPPORT, in dezelfde opvraging als de export (Generate).

## cfg/main/Output/OD_PairRoutes.dms

- `Map` (regel 17): De uitvoermap van het paar zonder het achtervoegsel van de component: Output_<O>_<D>/<datum>_<label>.
- `Comps` (regel 23): De Components in MergeComponents; elk moet uitvoer voor het paar hebben (batch/WriteODResults.ps1), anders noemt de foutmelding het ontbrekende bestand.
- `OptieNrs` (regel 24): De nummers van de opties per vertrekmoment, voor de sleutel (moment, optie).
- `Volgnrs` (regel 26): De volgnummers van de onderdelen van een optie, voor de volgorde van de reis.
- `PenColor` (regel 33): In de volgorde van GTFS_Modes/Selection: tram, metro, trein, bus, veerboot, lopen, wachten, fietsen, auto.
- `PenWidth` (regel 35): Lijndikte in pixels: trein en metro dikker, lopen en fietsen dunner.
- `Gebruik` (regel 41): De groepen van opties naar het gebruik van een auto en een fiets, met hun kleur in de grafiek.
- `SymbolColor` (regel 45): Als op de kaart: oranje voor lopen en OV, paars voor de fiets, blauw voor de auto.
- `MomentGroep` (regel 48): De reeksen van de grafiek van Samen, een per vertrekmoment en groep; die van een moment staan naast elkaar.
- `Punten` (regel 66): De opties van de groep Groep en het vertrekmoment Moment, op reistijd.
- `Reistijd` (regel 69): In minuten, de X-as van de Scatter Chart van Prijs.
- `Prijs` (regel 70): In euro, in de kleur van de groep; open de Scatter Chart van dit attribuut en sleep de Prijs van de andere groepen erop.
- `Reistijd` (regel 139): In minuten.
- `Prijs` (regel 140): In euro.
- `Onderdelen_Bron` (regel 148): De onderdelen in de volgorde van de gpkg: per vertrekmoment eerst de voortransportbenen, dan de OV-benen, de overstappen en het PostTransport.
- `Onderdelen` (regel 167): De reisbeschrijving: per vertrekmoment en optie de onderdelen in de volgorde van de reis (Volgnr).
- `Optie` (regel 199): De links van ModelParameters/OD_Option (0: alle).
- `PerComponent` (regel 208): (geen Descr)
- `Samen` (regel 211): (geen Descr)
- `Optie` (regel 241): De optie in de uitvoer van de component.
- commentaar regel 1-14: DE ROUTES VAN EEN HB-PAAR OP KAART, IN TABEL EN GRAFIEK (sinds 2026-10-21, #129). Met OD_Origin en OD_Destination (ModelParameters, groep 6) rekent het model alleen dat paar en schrijft de uitvoerstap per component en vertrekmoment, naast de gewone uitvoer, <OutputDir>/PerBlock/od_<moment>.gpkg met drie lagen: od_opties, od_onderdelen en od_links (NetworkSetup/ PublicTransport/PerDepartureMoment_T/OD_Uitvoer). Deze container leest ze terug, per component in MergeComponents en voor Samen: - <component>/Opties en Samen/Opties: een rij per optie en vertrekmoment (tabel); - <component>/Onderdelen: de reisbeschrijving per optie, in de volgorde van de reis (tabel); - <component>/Links en Samen/Links: de links van de routes (kaart), gekleurd per modaliteit (Modes); met Optie en Modaliteit_rel om op te kleuren of te filteren; Kaart/Optie toont alleen ModelParameters/OD_Option; - Grafiek: Prijs tegen Reistijd, een reeks per vertrekmoment en groep van Gebruik (auto, fiets), een front, in de kleur van de groep; open de Scatter Chart van Grafiek/<moment>_<groep>/Punten/Prijs en sleep de Prijs van de andere groepen erop. Samen voegt de opties van de Components per vertrekmoment samen zoals ComponentMerge: niet gedomineerd op prijs en reistijd (met ChainParetoTimeEpsilon) en op autobezit en fietsbezit als MergeCriteria die noemt. Een component zonder uitvoer telt niet mee; Ontbreekt noemt hem.
- commentaar regel 29-30: De kaart: kleur en lijndikte per modaliteit. Links/geometry krijgt ze per link (PenColor en PenWidth van de links); Links/Modaliteit_rel toont ze als thema, met legenda.
- commentaar regel 38-40: De grafiek: een reeks per groep van opties naar wat ze vragen, een auto (NeedsCar) en een fiets (NeedsBike), de criteria Car en Bike van MergeCriteria. Een Scatter Chart kleurt een punt naar de klasse van zijn Y-waarde, niet naar een ander attribuut; daarom heeft elke groep een eigen reeks, waarvan Prijs een classificatie van een klasse in de kleur van de groep heeft (Reeks_T).
- commentaar regel 54-55: Een reeks is een front: de opties van een groep en een vertrekmoment, op reistijd, zodat de lijn van de grafiek (Points + Line, in de volgorde van de rijen) ze van snel en duur naar langzaam en goedkoop verbindt.
- commentaar regel 81-81: Een gpkg van een component en een vertrekmoment
- commentaar regel 126-126: Een component: de vertrekmomenten samen, met een nummer per optie over de momenten (Nr) en de optie per moment (Optie)
- commentaar regel 225-225: de criteria van het samenvoegen (MergeCriteria), zoals NetworkSetup/ComponentMerge: prijs en tijd in Ct en s
- commentaar regel 232-232: pareto_optimal_eps(groep, crit1, crit2, eps2, ...): het eerste criterium en een bool zonder epsilon (Classifications/OutputParetoAttr/ParetoArgs)
- commentaar regel 251-251: de links van de gekozen opties, uit de links van hun component
- commentaar regel 268-268: een link hoort bij een gekozen optie als die van deze component is, met hetzelfde vertrekmoment en nummer

## cfg/main/Output/PostAnalysis/UAI.dms

- `UAI` (regel 25): Netwerk-gebaseerde Urban Attractivity Index per BAG-jaar, over het OSM-voetgangersnetwerk (issue RSopen#38).
- `Afkapstraal` (regel 28): Maximale loopafstand waarbinnen voorzieningen meetellen. Gewicht op 1.5km = (0.1/1.5)^4 = 2e-5, dus verhogen voegt vrijwel niets toe maar maakt de OD-matrix veel groter.
- `CelMaat` (regel 29): Binnen deze afstand geldt gewicht 1, conform de AbsWeight-kernel in RSopen (eigen cel en direct aangrenzende afstand 1 cel hebben daar gewicht 1).
- `DecayMacht` (regel 30): AbsWeight in RSopen = 1/distMatr^2 met distMatr = kwadratische celafstand, ofwel gewicht = d^-4.
- `SnapshotBaseDir` (regel 32): Ruimtescanner-BAG-snapshots (vbo.fss + pand.fss + adres.fss) per kwartaal, 2012 t/m 2025.
- `Jaren` (regel 34): Jaren waarvoor een 1-januari-snapshot met pand.fss beschikbaar is in SnapshotBaseDir.
- `Generate_Alle_Jaren` (regel 43): Genereert de tifs voor alle jaren. Voor een enkel jaar: PerJaar/Y<jaar>/Export/Generate.
- `UAI_Jaar_T` (regel 46): (geen Descr)
- `SnapshotDir` (regel 50): (geen Descr)
- `BAG` (regel 55): Leest per jaar de benodigde BAG-onderdelen rechtstreeks uit de RS-snapshot (zelfde schema als SourceData/Vastgoed/BAG in RSopen).
- `InVoorraad` (regel 83): Zelfde statusselectie als VBO_selection in SourceData/BAG.
- `nr_vbo` (regel 105): Aantal vbo's (in voorraad) in het pand; conform pand/met_vbo in RSopen.
- `IsMonumentaal` (regel 106): Monumentaal = pand met vbo en bouwjaar <= 1900, conform Monumentaal_Per_AllocDomain in RSopen (SourceData/Vastgoed/BAG.dms).
- `Tellingen` (regel 115): Aantal voorzienings-objecten per 100m-cel, per UAI-component.
- `VoorzieningCellen` (regel 123): Bestemmingen voor de dijkstra: alle 100m-cellen met minstens een voorzienings-object, met de tellingen als gewicht.
- `Diagnostiek` (regel 132): Sanity-checks per jaar; goedkoop te berekenen, zonder netwerk of dijkstra.
- `Log` (regel 142): Schrijft de sanity-checks weg als csv, als audit-trail bij iedere generatie.
- `Herkomsten` (regel 157): Alle 100m-celmiddens binnen Nederland (incl. cellen zonder bebouwing: RSopen heeft op elke AllocDomain-cel een UAI-waarde nodig).
- `Netwerk` (regel 160): Voetgangersnetwerk (OSM, incl. ponten en veren; excl. snelwegen) waaraan herkomsten en voorzieningcellen zijn geknoopt.
- `OD` (regel 169): Alle herkomst-voorzieningcel-paren binnen de afkapstraal, met de loopafstand over het netwerk.
- `gewicht` (regel 184): Afstandsverval conform AbsWeight in RSopen: gewicht 1 binnen de eigen cel, daarbuiten (100m/d)^4.
- `Potentialen` (regel 188): Netwerk-potentiaal per herkomstcel: som over voorzieningcellen van aantal objecten maal afstandsgewicht.
- `Max_Detailhandel` (regel 195): Maximum binnen Nederland, voor de normalisatie.
- `UAI` (regel 199): Som van de drie genormaliseerde potentialen, gelijk gewogen; 0..1, conform R_5000m_AbsWeight in RSopen.
- `UAI_geschaald` (regel 203): UAI herschaald naar landelijk max = 1, conform de conventie van de bestaande UAI_2021.tif (ongedempte som, gedeeld door max). Let op bij tijdreeks-gebruik: het max verschilt per jaar, dus jaren zijn in deze geschaalde vorm niet absoluut vergelijkbaar; gebruik daarvoor de ongeschaalde UAI of de ruwe potentialen.
- `PerGrid` (regel 207): (geen Descr)
- `Export` (regel 218): (geen Descr)
- `Generate` (regel 228): (geen Descr)
- commentaar regel 2-22:  Netwerk-gebaseerde Urban Attractivity Index (UAI), t.b.v. RSopen. N.a.v. https://github.com/pbl-nl/model-RSopen/issues/38 : "UAI gaat nu hemelsbreed ipv via netwerk afstand".  De UAI in RSopen (BaseData/Suitabilities/Wonen/UrbanAttractivityIndex/R_5000m_AbsWeight) is de som van de genormaliseerde potentialen van detailhandel, bijeenkomst/logies en monumentaal vastgoed (pand met bouwjaar <= 1900), met kernel AbsWeight = 1/distMatr^2 waarbij distMatr de KWADRATISCHE celafstand is; het gewicht is dus d^-4 met d in cellen van 100m. Voorzieningen aan de overkant van een kanaal/spoor/snelweg tellen daarin hemelsbreed mee. Hier wordt dezelfde vervalfunctie toegepast op LOOPAFSTAND over het OSM-voetgangersnetwerk (incl. veerponten), zodat barrieres realistisch doorwerken.  - Herkomsten: alle 100m-celmiddens binnen Nederland (perGridsize/size_100m/points). - Bestemmingen: 100m-cellen met >= 1 voorzienings-object, uit de BAG-snapshots %SourceDataDir%/BAG/snapshots.ext/<jaar>0101_RS (die bevatten - anders dan de uitgeklede kopieen onder RegioIndelingen/BAG - ook pand.fss met bouwjaar, voor alle jaren 2012-2025). - Gewicht per OD-paar: 1 binnen de eigen cel (<= 100m), daarbuiten (100m/d_netwerk)^4, afgekapt op Afkapstraal. Op 1500m is het gewicht (0.1/1.5)^4 = 2e-5; wat verder weg ligt draagt niet meer bij, vandaar de afkap. - Het gebruikte loopnetwerk volgt ModelParameters/AnalysisMoment (OSM-vintage). Bewust EEN netwerk voor alle BAG-jaren, zodat verschillen tussen jaren puur BAG-gedreven zijn (van 2012 bestaat toch geen bruikbare OSM-extract). - Output per jaar: 3 ruwe potentiaal-tifs (zodat RSopen zelf kan normaliseren over het eigen studiegebied) plus de samengestelde, genormaliseerde UAI (0..1, conform R_5000m_AbsWeight). 

## cfg/main/Output/PostAnalysis.dms

- `Halte_analyse_RuimteScanner` (regel 5): (geen Descr)
- `Afstand_Halte_clustering` (regel 7): (geen Descr)
- `MaxReistijd` (regel 8): (geen Descr)
- `Generate_tiffs` (regel 39): (geen Descr)
- `Create_Optimised_Network` (regel 89): Network for pre- and post-transport.
- `VertrekMomenten_3K` (regel 243): (geen Descr)
- `SearchLimit` (regel 313): Paren met een mediane reistijd tot en met deze waarde komen in Result.
- `ExcludedModes` (regel 314): ModeUsed-waarden, kommagescheiden, die niet meetellen. Standaard de directe autorit (AA), zodat de mediaan de bereikbaarheid zonder auto beschrijft; leeg telt alle rijen mee.
- `filename` (regel 344): De samengevoegde uitvoer over de vertrekmomenten (Merge_Times), sinds 2026-10-03 in ModelParameters/Impl/OutputDir en alleen als de handtekening van die map klopt (NetworkModel_PBL#118).
- `PerMoment` (regel 367): Een element per herkomst, bestemming en vertrekmoment met een verbinding.
- commentaar regel 307-312: Mediane reistijd per herkomst en bestemming: per vertrekmoment de snelste frontrij, dan de mediaan over de vertrekmomenten met een verbinding (NrMoments). Uit de samengevoegde OV-uitvoer (NetworkSetup/ConfigurationPerBlock/Merge_Output/MergeTimes). Sinds 2026-09-25 (audit 6.5) met de herkomsten en bestemmingen van de run (tot dan buurten), de naamstaart van de schrijver en via GDAL. Sinds 2026-09-27 (audit 6.7) per vertrekmoment de snelste rij en zonder de modaliteiten in ExcludedModes: tot dan de mediaan over alle frontrijen van alle vertrekmomenten en modaliteiten samen, dus ook over de tragere goedkope ketens van het front en over de directe autorit, en alleen over rijen tot SearchLimit.

## batch/UpdateAll.cmd

- lines 3-49:
  REM ---------------------------------------------------------------------------------------------
  REM UpdateAll.cmd: werkt de stores van NetworkModel_PBL bij met GeoDmsRun, in de volgorde waarin
  REM ze elkaar nodig hebben. Elke stap is een eigen GeoDmsRun-aanroep, zodat het geheugen tussen
  REM de stappen vrijkomt, en stopt bij een fout. Logs in batch\log\UpdateAll_<stap>.log.
  REM
  REM   UpdateAll.cmd                 alle secties (bronnen, autoritten, ketens, uitvoer); reken op meer dan een nacht
  REM   UpdateAll.cmd all -nosources  alles behalve de genoemde secties: -nosources, -nocars, -nochains, -nolegs, -nooutput
  REM   UpdateAll.cmd sources         OSM-netwerk, TomTom-stores, GTFS-store (alleen bij een
  REM                                 nieuwe editie nodig; ca. 15 min)
  REM   UpdateAll.cmd cars [moment..] de stores van de directe autorit per vertrekmoment
  REM                                 (PublicTransport_Prep/Direct/CarPerMoment/<moment>/Write_Car);
  REM                                 zonder momenten die het model leest (MakeUnlinkedData/Step4_CarStores/Moments);
  REM                                 met momenten bijvoorbeeld MorningRush NoonRush LateEveningRush
  REM                                 en Freeflow (TomTom) of MaxSpeed (OSM); 40 min scalair per
  REM                                 moment, langer met ParetoLegs_Car
  REM   UpdateAll.cmd chains          de OV-ketenstore per haltenblok (WriteChainBlocks.ps1; met de omgevingsvariabele
  REM                                 CHAINSTORE_SINGLE de ene store van PublicTransport_Prep/ChainGeneration_Single/Write), na de
  REM                                 voorcheck op haltenblokken en prijsdekking; uren, veel geheugen
  REM   UpdateAll.cmd legs            de stores van de benen van het voor- en PostTransport (sinds 2026-10-19): de vier
  REM                                 basissets, lopen en fietsen naar en van elke halte (PublicTransport_Prep/LegStores_Write);
  REM                                 schrijft alleen iets met ModelParameters/Advanced/LegsDecoupled
  REM   UpdateAll.cmd output          de OV-uitvoer: een csv per herkomstblok en vertrekmoment in
  REM                                 %LocalDataProjDir%\Output\<Analysis_date>_<OutputLabel><_component>[_fb]\PerBlock
  REM                                 (_fb: een component over het fietsnet met CyclingNetwork 'Fietsersbond')
  REM                                 (ConfigurationPerBlock/Generate_Output), met de ketenstore van de vertrekmomenten in
  REM                                 PT_DepartureHours/Minutes. Maakt die map eerst leeg (sinds 2026-10-03, #118): alleen de
  REM                                 bestanden van het model (tt_*.csv, tt_*.xml, signature.txt/.xml), ook de samengevoegde,
  REM                                 en sinds 2026-10-04 de tellingen od_tellingen.csv en unieke_od_tellingen.csv (met .xml).
  REM                                 Sinds 2026-10-16 met ModelParameters/OutputFormat 'parquet' parquet in plaats van
  REM                                 csv (tt_*.parquet), en de tellingen per blok in Tellingen (tellingen_*.csv).
  REM                                 Sinds 2026-10-07 in porties van blokken (WriteOutputBlocks.ps1, een GeoDmsRun per
  REM                                 portie, daarna de tellingen met OdTellingen.py); blokken per portie per component in
  REM                                 ModelParameters/Advanced/Components/BlocksPerPortion of met OUTPUT_BATCHSIZE; met
  REM                                 OUTPUT_SINGLE een opvraging.
  REM Sinds 2026-10-05 (#117) rekent een run een component (ModelParameters/Component): cars slaat de autostores over als
  REM de component geen directe autorit heeft (alles behalve Car), chains de ketenstore als het OV niet meedoet (WW, CC, Car, MergeOutput),
  REM en output voegt bij MergeOutput de uitvoer van de Components in MergeComponents samen.
  REM Draai de uitvoerstappen (output) van de Components na elkaar, niet tegelijk: op 2026-10-06/07 (Y2023, Buurt2023 naar
  REM Buurt2023, 128 GB RAM) groeide het vastgelegde geheugen van de uitvoer van Auto met ongeveer 0,7 GB per herkomstblok tot
  REM 386 GB na blok 450 (779 miljoen autoroutes; tot 2026-10-07 filterde elk blok de hele autotabel, PublicTransport/Direct_OD_all). Naast de
  REM uitvoer van Fiets (ongeveer 110 GB) swapte de machine (109 GB gewijzigde pagina's) en vorderde Fiets nauwelijks; het
  REM afsluiten van Auto na het laatste bestand duurde zo meer dan een uur. Lopen en Fiets blijven alleen rond 100 GB.
  REM Sindsdien rekent output in porties (WriteOutputBlocks.ps1), zodat het geheugen tussen de porties vrijkomt.
  REM
  REM De oude RunAll.cmd, RunKetens*.cmd, RunPrepare.cmd, RunDayGroups.cmd en RunCongestionSpeeds.cmd
  REM wezen naar itempaden van voor 2025 en zijn op 2026-09-23 verwijderd.
  REM ---------------------------------------------------------------------------------------------
- lines 50-54:
  REM Engine. Het model vraagt de pareto-epsilon en de bool-criteria van pareto_optimal_eps, die oudere versies van
  REM GeoDMS niet kennen; GEODMS_VERSION is de versie waarmee het getoetst is. GeoDmsRun.exe komt uit, in deze volgorde:
  REM de omgevingsvariabele GEODMS_EXE (een andere engine, bijvoorbeeld een proefbuild); de lokale build in
  REM C:\dev\GeoDMS_2026; de geinstalleerde GEODMS_VERSION, flavor m of c, in de map die de installer in het register
  REM zet (standaard C:\Program Files\ObjectVision\GeoDms<versie>.<flavor>).
- line 64:
    echo ABORT: geen GeoDmsRun.exe gevonden. Installeer GeoDMS %GEODMS_VERSION%, of zet GEODMS_EXE op het volledige pad van GeoDmsRun.exe.
- lines 67-68:
  REM De volledige padnaam zonder "..": GeoDMS leidt %LocalDataProjDir% af uit de naam van de map boven cfg, en
  REM met batch\..\cfg\main.dms werd dat "..", zodat de stores in c:\LocalData\..\IntermediateResults (= C:\) kwamen.
- line 70:
  REM De batchmap vastleggen voor het argumentenlusje: na shift wijst %~dp0 niet meer naar deze map.
- lines 78-79:
  REM De argumenten na de sectie: -no<sectie> slaat een sectie over, de rest zijn momenten voor cars.
  REM (shift laat %* ongemoeid, dus zelf verzamelen.)
- line 93:
  echo UpdateAll %SECTION%%MOMENTS% gestart %DATE% %TIME%
- line 102:
  echo Onbekende sectie "%SECTION%": kies all, sources, cars, chains, legs of output.
- line 107:
  echo === bronnen: OSM-netwerkstore ===
- line 110:
  echo === bronnen: TomTom-stores (wegen, knopen, speedprofile-net, speedprofiles) ===
- line 119:
  echo === bronnen: GTFS-store van de feed GTFS_file_date ===
- line 127:
  REM Zonder directe autorit (AllowDirectCar FALSE: elke component behalve Car, #117) geen autostores.
- line 132:
    echo === directe autorit: AllowDirectCar is FALSE voor deze component, geen autostores ===
- line 141:
    echo === directe autorit: store voor %%M ===
- line 150:
  REM Zonder OV (ModelParameters/Impl/WithPT FALSE: de directe ritten WW, CC en Car en MergeOutput, #117) geen ketenstore.
- line 155:
    echo === ketens: het OV doet niet mee in deze component, geen ketenstore ===
- line 158:
  echo === ketens: voorcheck haltenblokken en prijsdekking ===
- line 163:
    echo ABORT: de prijsdekking is niet OK, zie %LOGDIR%\UpdateAll_chains_precheck.txt
- line 167:
  echo === ketens: de haltenblokken zonder store, in porties (WriteChainBlocks.ps1) ===
- line 174:
  echo === ketens: ChainGeneration_Single/Write, de ene store van voor 2026-09-29 (CHAINSTORE_SINGLE; zet ook PT_Chains_PerBlock op FALSE) ===
- line 182:
  REM Zonder OV (ModelParameters/Impl/WithPT FALSE) geen benen nodig.
- line 187:
    echo === benen: het OV doet niet mee in deze component, geen stores van de benen ===
- line 190:
  echo === benen: de stores (parquet in IntermediateResults) ===
- lines 198-199:
  REM Pauze voor de uitvoerstap (sinds 2026-09-29): zolang batch\pause_before_output.flag bestaat, wacht de uitvoerstap
  REM zonder rekenproces, bijvoorbeeld om de machine vrij te geven voor prestatietests; weghalen van de vlag laat hem starten.
- line 202:
  echo %DATE% %TIME% pauze voor de uitvoerstap: wacht tot %PAUSEFLAG% weg is
- line 206:
  echo %DATE% %TIME% pauze voorbij, de uitvoerstap start
- lines 208-212:
  REM De uitvoermap leegmaken (sinds 2026-10-03, NetworkModel_PBL#118): de bestandsnamen dragen alleen datum, moment en blok, de
  REM parameters staan in signature.txt in de map. Zonder leegmaken zou een run na een codewijziging zijn blokken naast die van de
  REM vorige run zetten. Het model geeft de map (NetworkSetup/GenerateOutput/OutputDir_ForBatch, naar batch\log\output_dir.txt); alleen de
  REM bestanden die het model daar schrijft gaan weg, en alleen als de map onder een map Output ligt. Output_Sig/PathGate faalt
  REM vooraf als het langste uitvoerpad te lang is.
- line 218:
    echo ABORT: geen uitvoermap in %LOGDIR%\output_dir.txt
- lines 222-223:
  REM Bevat het pad \Output\, of \Output_ van een HB-paar (Output_<O>_<D>, sinds 2026-10-21, #129)? (vervangen door niets laat het
  REM dan korter; cmd vervangt hoofdletterongevoelig)
- line 228:
    echo ABORT: de uitvoermap !OUTDIR! ligt niet onder een map Output of Output_^<O^>_^<D^>
- line 233:
    echo %DATE% %TIME% uitvoermap leegmaken: !OUTDIR!
- lines 236-241:
  REM Sinds 2026-10-07 in porties van herkomstblokken, elk een eigen GeoDmsRun, en daarna de tellingen met OdTellingen.py
  REM (WriteOutputBlocks.ps1). Blokken per portie: ModelParameters/Advanced/Components/BlocksPerPortion van de component
  REM (standaard 50), of de omgevingsvariabele OUTPUT_BATCHSIZE; OUTPUT_MAXBLOCKS rekent hooguit zoveel blokken (om te
  REM testen). Met de omgevingsvariabele OUTPUT_SINGLE een
  REM opvraging voor alle blokken, met de tellingen erin (NetworkSetup/GenerateOutput/Generate_Output), zoals tot dan. Bij MergeOutput
  REM (sinds 2026-10-05, #117) het samenvoegen van de Components, sinds 2026-10-07 ook per blok in porties (ComponentMerge/PerBlock).
- line 243:
  echo === uitvoer: csv per herkomstblok en vertrekmoment, in porties (WriteOutputBlocks.ps1; uren) ===
- line 253:
  echo === uitvoer: csv per herkomstblok en vertrekmoment, een opvraging (OUTPUT_SINGLE; uren) ===
- lines 259-261:
  REM %1 = stapnaam, %2.. = items; elke GeoDmsRun-aanroep vraagt de items op via @statistics, wat
  REM voor een store-holder de hele store schrijft. RC houdt de exitcode (ook negatief, bij een
  REM afgebroken proces; "if errorlevel 1" ziet die niet).
- line 277:
  echo UpdateAll %SECTION% MISLUKT bij stap %STEP% (exit %RC%) %DATE% %TIME%
- line 281:
  echo UpdateAll %SECTION% klaar %DATE% %TIME%

## batch/ScheduleUpdateAll.cmd

- lines 3-11:
  REM ScheduleUpdateAll.cmd <sectie> [argumenten]: start batch\UpdateAll.cmd met die argumenten als eenmalige
  REM geplande taak NM_PBL_UpdateAll, in een zichtbaar consolevenster van de aangemelde gebruiker, en keert meteen
  REM terug. Zo overleeft een run van uren het sluiten van het venster of de sessie waaruit hij gestart is.
  REM De taak voert batch\UpdateAllTask.cmd uit, dat het verloop in batch\log\UpdateAll_status.txt schrijft en de
  REM taak na afloop verwijdert. Er loopt hoogstens een zo'n taak tegelijk.
  REM
  REM   ScheduleUpdateAll.cmd cars                     de vier autostores
  REM   ScheduleUpdateAll.cmd all -nosources           autostores, ketenstore en uitvoer
  REM   set GEODMS_EXE=C:\...\GeoDmsRun.exe            vooraf: een andere engine voor deze run
- line 16:
    echo Gebruik: ScheduleUpdateAll.cmd ^<sectie^> [argumenten], zie UpdateAll.cmd voor de secties.
- line 21:
    echo De taak %TASK% bestaat al: er loopt nog een UpdateAll-run, of een vorige is afgebroken.
- line 22:
    echo Zie %~dp0log\UpdateAll_status.txt; verwijderen met: schtasks /Delete /TN %TASK% /F
- line 26:
  if not errorlevel 1 echo Let op: er draait al een GeoDmsRun; de twee runs delen geheugen en processor.
- line 32:
  REM /SC ONCE zonder /SD op 00:00 ligt in het verleden, dus de trigger vuurt nooit vanzelf; /Run start de taak nu.
- line 35:
    echo Aanmaken van de taak %TASK% mislukt.
- line 40:
    echo Starten van de taak %TASK% mislukt.
- line 43:
  echo Taak %TASK% gestart: UpdateAll %*
- line 44:
  echo Verloop in %~dp0log\UpdateAll_status.txt, logs per stap in %~dp0log\UpdateAll_^<stap^>.log en .txt

## batch/UpdateAllTask.cmd

- lines 3-6:
  REM UpdateAllTask.cmd <sectie> [argumenten]: draait UpdateAll.cmd in dit venster, schrijft het verloop naar
  REM batch\log\UpdateAll_status.txt ("start ...", "engine ...", "updateall exit=<code> ...") en verwijdert na afloop
  REM de geplande taak NM_PBL_UpdateAll als die bestaat. De opdracht van de taak die ScheduleUpdateAll.cmd aanmaakt;
  REM ook met de hand te starten. Het venster blijft 60 s open, zodat de laatste regels te lezen zijn.
- line 20:
  echo === UpdateAll %* klaar met exit %RC%; venster sluit over 60 s ===

## batch/WriteChainBlocks.ps1

- lines 1-14:
  # WriteChainBlocks.ps1: de ketenstap per haltenblok, met hervatten (sinds 2026-09-29).
  #
  # Vraagt eerst de lijst op van de blokken waarvan de store nog ontbreekt (PublicTransport_Prep/PT_Chains_Blocks/ToDo_List,
  # geschreven naar batch\log\chain_blocks_todo.txt; een blok telt als klaar als zijn 0Dictionary.dms bestaat, dat de MMD-writer
  # als laatste schrijft) en rekent die dan in porties van BatchSize blokken per GeoDmsRun. Elke portie is een eigen proces,
  # zodat het geheugen tussen de porties vrijkomt; een onderbroken of mislukte ketenstap gaat bij een volgende aanroep verder
  # bij het eerste blok zonder store.
  #
  # Aanroep (door UpdateAll.cmd chains): WriteChainBlocks.ps1 -Exe <GeoDmsRun.exe> -Cfg <cfg\main.dms> -LogDir <batch\log>
  #   -BatchSize  blokken per GeoDmsRun (standaard 20, tot 2026-09-29 40). Een portie deelt alleen de opstart van ~25 s, dus de
  #               grootte maakt voor de rekentijd weinig uit. De trage blokken (~2%, 3 tot 7 minuten) hebben zelf 150-200 GB aan
  #               levende data nodig en pagineren daardoor op een machine met 128 GB, ook in een vers proces.
  #   -MaxBlocks  hooguit zoveel blokken in deze aanroep (0 = alle; om te testen)
  # Exitcode 0 als alle blokken een store hebben (of MaxBlocks bereikt is), anders 1.
- line 30:
  	if ($p.ExitCode -ne 0 -or -not (Test-Path $todoFile)) { throw "de lijst van ontbrekende blokken is niet gemaakt (exit $($p.ExitCode)), zie $LogDir\UpdateAll_chains_todo.log" }
- line 34:
  $todo = @(Get-ToDo)   # @(): een lijst met een regel (de HB-paarmodus, #129) wordt anders een string, en $todo[0..0] zijn eerste teken
- line 35:
  Say ("ketenstap per blok: {0} blokken zonder store" -f $todo.Count)
- line 44:
  	Say ("portie {0}/{1}: {2} blokken, exit {3}, {4:N0} s" -f ($b + 1), $nb, $part.Count, $p.ExitCode, $sw.Elapsed.TotalSeconds)
- line 45:
  	if ($p.ExitCode -ne 0) { Say "MISLUKT, zie $out en $LogDir\UpdateAll_chains.log"; exit 1 }
- line 48:
  Say ("klaar: {0} blokken nog zonder store" -f $rest.Count)

## batch/WriteOutputBlocks.ps1

- lines 1-19:
  # WriteOutputBlocks.ps1: de uitvoerstap per herkomstblok in porties (sinds 2026-10-07), zoals WriteChainBlocks.ps1 de ketenstap.
  #
  # Vraagt eerst de lijst van de blokken op (NetworkSetup/ConfigurationPerBlock/Generate_Output/OutputBlocks_List, geschreven naar
  # batch\log\output_blocks.txt; dat schrijft of controleert ook de handtekening van de uitvoermap en het langste pad) en rekent die
  # dan in porties van BatchSize blokken per GeoDmsRun. Elke portie is een eigen proces, zodat het geheugen tussen de porties
  # vrijkomt: in een opvraging voor alle blokken (NetworkSetup/GenerateOutput/Generate_Output) groeide het vastgelegde geheugen van de uitvoer van
  # Auto voor Buurt2023 naar Buurt2023 (450 blokken, 779 miljoen autoroutes) met ongeveer 0,7 GB per blok tot 386 GB (2026-10-06/07).
  # Daarna maakt batch\OdTellingen.py de tellingen (od_tellingen.csv, unieke_od_tellingen.csv) uit de csv's; in de ene opvraging deed
  # het model dat zelf (OD_Tellingen), met dezelfde regels, maar dat vraagt de resultaten van alle blokken in hetzelfde proces.
  # Bij MergeOutput noemt de lijst het samenvoegen per blok (ComponentMerge/PerBlock; sinds 2026-10-07, in een opvraging groeide
  # dat met ongeveer 7 GB per blok). Is de lijst leeg, dan een opvraging van NetworkSetup/GenerateOutput/Generate_Output.
  #
  # Aanroep (door UpdateAll.cmd output): WriteOutputBlocks.ps1 -Exe <GeoDmsRun.exe> -Cfg <cfg\main.dms> -LogDir <batch\log> -OutDir <uitvoermap>
  #   -BatchSize  blokken per GeoDmsRun; zonder deze parameter die van de component, ModelParameters/Advanced/Components/
  #               BlocksPerPortion (standaard 50; het model schrijft hem naar batch\log\output_blocks_per_portion.txt); 0 = alle
  #               blokken in een portie. Elke portie betaalt de opstart opnieuw; tot het eerste blokbestand duurde die voor Y2023,
  #               Buurt2023 naar Buurt2023, 2,5 min bij Auto, 5 bij Fiets en 6 bij Lopen.
  #   -MaxBlocks  hooguit zoveel blokken (0 = alle; om te testen)
  # Exitcode 0 als alle porties en de tellingen gelukt zijn, anders 1.
- line 37:
  if ($p.ExitCode -ne 0 -or -not (Test-Path $listFile) -or -not (Test-Path $sizeFile)) { Say "MISLUKT: de lijst van de blokken is niet gemaakt (exit $($p.ExitCode)), zie $LogDir\UpdateAll_output_blocks.log"; exit 1 }
- line 43:
  	Say 'uitvoer: geen blokken (Samen), een opvraging van /NetworkSetup/GenerateOutput/Generate_Output'
- line 45:
  	Say "uitvoer: exit $($p.ExitCode)"
- line 49:
  Say ("uitvoer per blok: {0} blokken, porties van {1}" -f $blocks.Count, $BatchSize)
- line 58:
  	Say ("portie {0}/{1}: {2} blokken, exit {3}, {4:N0} s" -f ($b + 1), $nb, $part.Count, $p.ExitCode, $sw.Elapsed.TotalSeconds)
- line 59:
  	if ($p.ExitCode -ne 0) { Say "MISLUKT, zie $out en $LogDir\UpdateAll_output.log"; exit 1 }
- line 63:
  if (-not $py) { Say 'MISLUKT: geen python voor de tellingen (batch\OdTellingen.py)'; exit 1 }
- line 66:
  Say ("tellingen (OdTellingen.py): exit {0}; {1}" -f $rc, (($o | ForEach-Object { "$_" }) -join ' | '))

## batch/WriteODResults.ps1

- lines 1-18:
  # WriteODResults.ps1 (sinds 2026-10-21, #129): de routes van een HB-paar, voor elke component in MergeComponents en samengevoegd.
  #
  # Maakt per component een runkopie van HEAD (git archive, zoals make_y2025.ps1) met OD_Origin, OD_Destination en OD_DepartureTime, en
  # rekent daarmee na elkaar, elk met batch\UpdateAll.cmd van de kopie:
  #   1. de benen van voor- en PostTransport, met hun links (legs), en
  #   2. de ketens van het paar met hun benen (chains), beide een keer, in de kopie van de eerste OV-component;
  #   3. per component de autostore van het vertrekmoment (cars, alleen Car) en de uitvoer (output): PerBlock/tt_<moment>_1of1.parquet en
  #      PerBlock/od_<moment>.gpkg met opties, onderdelen en links;
  #   4. het samenvoegen (een kopie met MergeOutput TRUE, output).
  # Tussenresultaten in %LocalDataProjDir%\IntermediateResults_<O>_<D>, uitvoer in Output_<O>_<D>; /Output/OD_PairRoutes in de GUI leest ze, met
  # dezelfde instellingen in ModelParameters (groep 1 en 6).
  #
  # Aanroep, bijvoorbeeld de rit Laapersweg 1 Hilversum -> De Boelelaan 1085 om 07:30 (de wiki, Routes of an OD pair):
  #   powershell -ExecutionPolicy Bypass -File batch\WriteODResults.ps1 -Org BU04020501 -Dest BU0363KP03 -Moment 07:30
  # De engine moet pareto met LinkSet kennen (GeoDMS#1325) voor de autoroutes: GeoDMS 20.26.0 of later.
  # -AlleenUitvoer slaat de benen en de ketens over, als hun stores er al zijn (een herhaling van de uitvoer na een wijziging daarin).
  # Lange runs als eenmalige geplande taak (zie de wiki, How to run the model). -WaitForMemoryGB wacht tot er zoveel geheugen beschikbaar is
  # voordat een stap begint, zodat het paar andere runs niet laat pagineren; de ketenstap rekent alle OV-benen van het net (20-30 GB).
- line 43:
  	if (([regex]::Matches($t, $re)).Count -ne 1) { throw "parameter $name niet eenmaal in $file" }
- line 49:
  	if (([regex]::Matches($t, $re)).Count -ne 1) { throw "$name niet gevonden in $file" }
- line 57:
  		Say ("wacht op geheugen: {0:N1} GB beschikbaar, {1} GB nodig" -f $free, $WaitForMemoryGB)
- line 61:
  # De onderdelen van een component, zoals RunFrontValidation.ps1: WW, CC, Car, of <PreTransport>_PT_<PostTransport>.
- line 74:
  Say "HB-paar $Org -> $Dest, moment '$Moment', $AnalysisMoment $PartOfDay, $Orgset/$Destset, Components $($comps -join ','), commit $commit, engine $Exe"
- line 82:
  	# ConfigSettings.dms zit sinds 23-10-2026 in git (paden die afwijken in het register, zie dat bestand); config.ini is machine-lokaal
- line 84:
  	Set-Content -Path (Join-Path $dst 'COMMIT.txt') -Value "$commit (git archive, plus config.ini uit de working copy)"
- line 107:
  	# de uitvoer van UpdateAll.cmd, ook stderr, naar een bestand in de log van de kopie: zo wordt een melding van cmd geen fout van dit script
- line 111:
  	if ($rc -ne 0) { throw "$section in $dst mislukt, zie $dst\batch\log" }
- line 114:
  # Benen en ketens in de kopie van de eerste OV-component: UpdateAll.cmd legs en chains slaan een component zonder OV over.
- line 132:
  Say "klaar: de uitvoer staat in Output_$($Org)_$($Dest); open /Output/OD_PairRoutes in GeoDmsGui met dezelfde instellingen"

## batch/RunFrontValidation.ps1

- lines 1-33:
  # RunFrontValidation.ps1: twee runs naast elkaar en de vergelijking van hun fronten (ObjectVision/NetworkModel_PBL#53, stap 2).
  #
  #   powershell -ExecutionPolicy Bypass -File batch\RunFrontValidation.ps1 -Label <label> [-CritA Time,Car,Bike]
  #        [-BaseRun <runkopie>\NetworkModel_PBL]                          B = een bestaande run met uitvoer, alleen A rekenen
  #        [-CritB 'Price,Time,Car,Bike'] [-AnalysisMoment Y2026] [-PartOfDay Ochtendspits] [-Component W_PT_W]
  #                                                                          zonder -BaseRun: A en B rekenen
  #        [-Blocks (1..10)] [-NrOrgBlocks 450] [-WaitFor others|base|none] [-MinFreeRamGB 24] [-Exe <GeoDmsRun.exe>]
  #        [-RunsDir C:\LocalData\NM_PBL_runs] [-OutRoot C:\LocalData\NetworkModel_PBL\Output] [-DryRun]
  #
  # Run A krijgt MinimiseCriteria CritA, run B CritB; verder zijn ze gelijk. De peildatum (AnalysisMoment, met de dag en de feed
  # uit de presettabel) en het PartOfDay (PartOfDay) zijn sinds 2026-10-05 parameters van het model (#125); tot dan zette dit script
  # GTFS_file_date en Analysis_date (-GtfsDate, -AnalysisDate). Ook de component (#117) is een parameter van het model: sinds
  # 2026-10-19 WW, CC, Car of <PreTransport>_PT_<PostTransport>, zoals W_PT_W (Component 'PT' met PreTransport en PostTransport,
  # die dit script uit de naam zet); standaard W_PT_W. Tot dan was de standaard Alles, lopen + OV + lopen naast alle directe ritten. Elke run die gerekend wordt, is een runkopie in
  # <RunsDir>\<Label>\{A,B}\NetworkModel_PBL met OutputLabel <Label>_A of <Label>_B, zodat de uitvoer in
  # <OutRoot>\<Analysis_date>_<Label>_{A,B}<_component> komt (sinds #118 een map per variant, sinds #117 met de component
  # erachter: sinds 2026-10-19 _ en de naam van de component, tot dan _lopen, _fiets, _auto, niets bij All of Alles). Daarna: de ketenstap (batch\UpdateAll.cmd chains
  # in de kopie), de uitvoer voor de herkomstblokken -Blocks en batch\ValidateFronts.py. Voortgang in <RunsDir>\<Label>\status.txt,
  # verslag in <RunsDir>\<Label>\verslag.md.
  #
  # Met -BaseRun is B een bestaande runkopie waarvan de uitvoer er al is, bijvoorbeeld de basisrun C:\LocalData\NM_PBL_runs\20261006\
  # NetworkModel_PBL. A is dan een kopie van diens cfg, data en batch (dus dezelfde commit, feed, dag en ConfigSettings.dms), met
  # alleen MinimiseCriteria en OutputLabel anders; CritB, AnalysisMoment en PartOfDay tellen dan niet. De uitvoer van B voor -Blocks
  # en zijn signature.txt worden aan het begin gekopieerd naar <RunsDir>\<Label>\B_uitvoer, zodat een latere run onder hetzelfde
  # label de vergelijking niet verstoort. Na de uitvoer van A vergelijkt het de handtekeningen van A en B zonder de criteria: een
  # ander verschil wordt gemeld.
  #
  # Wachten: -WaitFor others (standaard zonder -BaseRun) wacht voor elke zware stap tot er geen GeoDmsRun van een andere
  # NetworkModel_PBL-run loopt; base (standaard met -BaseRun) alleen tot de basisrun klaar is; none niet. Daarnaast wacht het
  # zolang er minder dan -MinFreeRamGB werkgeheugen vrij is, en stopt het als C: onder 15 GB vrij komt.
  #
  # Een ketenstap duurt uren (op 2026-10-02/03 voor 500 haltenblokken: 'Time' 4,0 uur, 'Price,Time' 4,2 uur; de uitvoer voor 10
  # herkomstblokken daarna 10 en 13 minuten). Met -DryRun maakt het alleen de runkopieen en toont het de gezette parameters.
- line 52:
  if ($Label -notmatch '^[A-Za-z0-9_-]{1,18}$') { throw "Label '$Label': alleen letters, cijfers, - en _, hoogstens 18 tekens (OutputLabel <Label>_A)" }
- line 61:
  # Draait er buiten deze Validation een GeoDmsRun, of een UpdateAll.cmd, waarvan de opdrachtregel op $pattern past?
- line 77:
  	# Twee keer na elkaar vrij, 30 s uit elkaar: tussen twee stappen van een andere run draait even geen GeoDmsRun.
- line 80:
  		if (Busy) { $free = 0; Say "wacht: er draait een andere run ($WaitFor)"; Start-Sleep -Seconds 300; continue }
- line 82:
  		if ($ram -lt $MinFreeRamGB) { $free = 0; Say ('wacht: {0:N0} GB werkgeheugen vrij, minder dan {1}' -f $ram, $MinFreeRamGB); Start-Sleep -Seconds 300; continue }
- line 86:
  	if ($disk -lt 15) { Say ('STOP: C: heeft nog {0:N0} GB vrij' -f $disk); exit 2 }
- line 90:
  	if (-not $m.Success) { Say "STOP: parameter $name niet gevonden in $file"; exit 3 }
- line 93:
  # Zet de waarde van een parameter in ModelParameters.dms: "parameter<type>   Naam   := <waarde>", waarde 'tekst', TRUE of FALSE.
- line 98:
  	if ($n -ne 1) { Say "STOP: parameter $name komt $n keer voor in $file"; exit 3 }
- line 102:
  # De dag en de feed bij AnalysisMoment $moment in de presettabel van ModelParameters.dms (de tekst $t), sinds 2026-10-05 (#125).
- line 105:
  	if (-not $row.Success) { Say "STOP: AnalysisMoment $moment staat niet in de presettabel"; exit 3 }
- line 108:
  	if ($f[6] -notmatch '^\d{8}$' -or $f[7] -notmatch '^\d{8}$') { Say "STOP: AnalysisMoment $moment heeft geen peildatum of feed ('$($f[6])', '$($f[7])')"; exit 3 }
- lines 111-114:
  # Het achtervoegsel van de uitvoermap bij een component (ModelParameters/Advanced/Components/OutputSuffix, #117).
  # Ook de namen van voor 2026-10-19 (Lopen, Fiets, Auto), voor een basisrun van toen.
  # sinds 2026-10-19 _ en de naam (OutputSuffix); tot dan _lopen, _fiets, _auto; niets bij All en Alles
  # De onderdelen van een OV-component (sinds 2026-10-19): de code in de naam en het type in Classifications/TimeInvariantTypes.
- line 117:
  # Zet de component in een ModelParameters.dms: WW, CC of Car in Component, anders Component 'PT' met PreTransport en PostTransport.
- lines 126-127:
  # De naam van de component van een runkopie: van voor 2026-10-05 All (geen Component), tot 2026-10-19 Component zelf, daarna bij
  # Component 'PT' de codes van PreTransport en PostTransport.
- line 136:
  # De handtekening zonder de criteria: MinCrit-..._MaxPT van de uitvoer en _min-..._maxtransf van de ketenstore.
- line 146:
  		# een runkopie van voor 2026-10-05: de dag en de feed staan er letterlijk
- line 154:
  	# een runkopie van voor 2026-10-05 kent Component niet: die rekende alles in een run, zonder achtervoegsel
- line 158:
  	Say "start: B = basisrun $BaseRun (commit $commit, '$CritB', component $Component, uitvoer $bOut), A '$CritA', feed $GtfsDate, dag $AnalysisDate, blokken $($Blocks -join ','), wacht op $WaitFor"
- line 162:
  	Say "start: commit $head, A '$CritA', B '$CritB', peildatum $AnalysisMoment (feed $GtfsDate, dag $AnalysisDate), PartOfDay $PartOfDay, component $Component, blokken $($Blocks -join ','), wacht op $WaitFor, engine $Exe"
- line 174:
  				if ($LASTEXITCODE -ge 8) { Say "STOP: kopieren van $d uit $($r.From) mislukt (robocopy $LASTEXITCODE)"; exit 6 }
- line 190:
  		Say "runkopie $($r.Name): MinimiseCriteria '$($r.Crit)', uitvoer in $OutRoot\$($AnalysisDate)_$($Label)_$($r.Name)$(ComponentSuffix $Component)"
- line 201:
  	# De uitvoer van de basisrun: wachten tot die er is voor alle blokken, dan een kopie, zodat B niet meer kan veranderen.
- line 208:
  		if ($DryRun -or -not $baseBusy) { Say "STOP: de basisrun loopt nog ($baseBusy) of zijn uitvoer ontbreekt in $bOut (blokken $($missing -join ','); signature.txt $sigOk)"; exit 7 }
- line 209:
  		Say "wacht tot de basisrun klaar is (uitvoer in $bOut, ontbrekende blokken $($missing -join ','))"; Start-Sleep -Seconds 600
- line 215:
  		Say "uitvoer van B gekopieerd naar $bSnap"
- line 218:
  if ($DryRun) { Say 'DryRun: alleen de runkopieen gemaakt'; exit 0 }
- line 222:
  	Say "ketenstap $($r.Name) start"
- line 224:
  	Say "ketenstap $($r.Name) klaar, exit $($p.ExitCode)"
- line 225:
  	if ($p.ExitCode -ne 0) { Say "STOP: ketenstap $($r.Name) mislukt, zie $($r.Dst)\batch\log"; exit 4 }
- line 233:
  	Say "uitvoer $($r.Name) start"
- line 235:
  	Say "uitvoer $($r.Name) klaar, exit $($p.ExitCode)"
- line 236:
  	if ($p.ExitCode -ne 0) { Say "STOP: uitvoer $($r.Name) mislukt, zie $log\frontval_output.txt"; exit 5 }
- line 242:
  if ($sa -eq $sb) { Say 'handtekeningen van A en B gelijk op de criteria na' } else { Say "LET OP: handtekeningen van A en B verschillen ook buiten de criteria:`r`n  A $sa`r`n  B $sb" }
- line 245:
  Say "vergelijking klaar (exit $LASTEXITCODE): $md"
- line 246:
  Say 'KLAAR'

## batch/ReportUpdateAll.py

- lines 1-12:
  # ReportUpdateAll.py [--localdata <map>] [stap ...]
  #
  # Overzicht per stap van batch\UpdateAll.cmd: begin, einde, duur, omvang van het resultaat, piekgeheugen en fouten.
  # Leest batch\log\UpdateAll_<stap>.log (alleen de laatste sessie, want GeoDmsRun voegt aan een log toe) en kijkt naar
  # de store of de uitvoerbestanden op schijf. Zonder stappen: de vier autostores, de ketenstore en de uitvoer.
  #
  #   stap        car_<moment>, chains_precheck, chains, output, osm_network, tomtom_roads, ... (zie UpdateAll.cmd)
  #   --localdata de LocalDataProjDir van het model (default: C:\LocalData\NetworkModel_PBL, of NM_PBL_LOCALDATA)
  #
  # Kolommen: min = duur van de GeoDmsRun-aanroep; rijen = "Filling all ... resulted in N pareto od-pairs" van de laatste
  # pareto-matrix (autostores), of het aantal klaar gemelde herkomstblokken (uitvoer); commit MB = "Highest CommitCharge"
  # en live MB = "PeakLiveLarge" uit de geheugensamenvatting aan het eind van het log; store MB = de store of de csv's.
- lines 44-45:
      # Het ontbrekende bevolkingsraster (SourceData/Locaties/Inwoners, cbs_vk100_<jaar>.gpkg) meldt zich in elke run maar
      # raakt de stores niet; die regels tellen niet als fout.
- lines 49-52:
      # Sinds 2026-10-03 (#118) PT_Chains_<datum>_<venster>_<hash> (een map met een store per blok) en
      # DirectCar_<net>_<moment>_<herkomst>_<bestemming>_<hash>.mmd (sinds 2026-10-21 met het net, TT2025-12; tot dan zonder), met de
      # handtekening in signature.txt in de map (tot 2026-10-06
      # <naam>.signature.txt ernaast).
- line 62:
          # De uitvoermap (Output/<datum>_<label>, sinds #118) staat in batch\log\output_dir.txt, die UpdateAll.cmd output schrijft.
- line 66:
          r["store"] = "%d csv-bestanden in %s sinds de start" % (len(csv), os.path.join(outdir, "PerBlock"))
- line 69:
          r["rows"] = "%d blokken" % len(re.findall(r"Results for all departure times in Block_\d+of\d+ are finished", s))
- line 75:
  print("%-20s %-19s %-19s %8s %14s %10s %10s %10s %8s" % ("stap", "start", "einde", "min", "rijen", "commit MB", "live MB", "store MB", "fouten"))
- line 79:
          print("%-20s (geen log)" % st)
- line 84:
          print("%-20s   telpas %s .. %s, vulpas tot %s" % ("", r["count_first"], fmt(r["count_last"]), fmt(r["fill_last"])))
- line 88:
          print("%-20s   FOUT exit %s: %s" % ("", r["failed"], r["first_error"]))

## batch/OdTellingen.py

- lines 1-19:
  # Tellingen naast de OV-uitvoer, uit de csv's per blok: od_tellingen.csv en unieke_od_tellingen.csv in de uitvoermap.
  #
  #   python batch\OdTellingen.py <uitvoermap> [--force]
  #
  # <uitvoermap> is Output\<Analysis_date>_<OutputLabel> (met PerBlock\tt_<moment>_<n>of<N>.csv, sinds 2026-10-20; van #118 tot dan tt_<datum>_<moment>_<n>of<N>.csv). Sinds
  # 2026-10-04 maakt de uitvoerstap deze twee bestanden zelf (NetworkSetup/ConfigurationPerBlock/Generate_Output/OD_Tellingen,
  # commit f55636e); dit script doet hetzelfde voor uitvoer van daarvoor, met dezelfde regels en hetzelfde formaat:
  # - od_tellingen.csv: de rijen per soort optie (alle, OV-keten = ModeUsed met een '_', en de directe ritten WW, CC en AA), per
  #   vertrekmoment en in totaal;
  # - unieke_od_tellingen.csv: de unieke HB-paren (OrgName, DestName) met minstens een optie van die soort, of met een optie
  #   zonder auto (NeedsCar 0) of zonder auto en fiets (NeedsCar en NeedsBike 0), per vertrekmoment en over de momenten samen.
  # De herkomstblokken hebben elk hun eigen herkomsten, dus de tellingen per blok worden opgeteld; per blok worden de paren over
  # de momenten verenigd. Bestaat een van de twee bestanden al, dan stopt het script, tenzij --force.
  #
  # Sinds 2026-10-16 schrijft het model de tellingen per blok zelf, in dezelfde opvraging als de uitvoer, naar
  # Tellingen\tellingen_<n>of<N>.csv (PublicTransport/Generate_Output/Traveltime_ForEachDepTime/Tellingen/File). Staan die er, dan
  # telt dit script alleen die op en leest het de uitvoer niet: die kan parquet zijn (ModelParameters/OutputFormat), en de
  # csv van Auto voor Buurt2023 is 284 GB. Het optellen gebeurt hier en niet in het model, omdat de blokken in aparte GeoDmsRuns
  # gerekend worden (WriteOutputBlocks.ps1) en een opvraging voor de som de configuratie opnieuw zou laden.
- line 26:
  # sinds 2026-10-20 zonder de datum (tt_<moment>_<n>of<N>.csv); leest ook de oude namen met de datum, en die met de component na de datum (tt_<datum>_<component>_<moment>_<n>of<N>.csv), die het model op 2026-10-19 even schreef
- line 30:
  	"""Tellingen van een herkomstblok: rijen per (moment, soort), paren per (moment, groep) en per groep over de momenten."""
- line 61:
  	"""Telt de tellingen per blok van het model op (Tellingen/tellingen_<n>of<N>.csv: tabel;naam;<momenten>;totaal)."""
- line 67:
  		sys.exit(f'onvolledige tellingen: {len(blokken)} blokken in {uitvoermap}\\Tellingen, verwacht {sorted(n_blokken)}')
- line 76:
  				sys.exit(f'{p}: kop {h} wijkt af van {kop}')
- line 90:
  	print(f'{len(files)} tellingbestanden van het model (Tellingen), momenten {", ".join(momenten)}')
- line 95:
  	ap.add_argument('uitvoermap', help=r'Output\<Analysis_date>_<OutputLabel>')
- line 96:
  	ap.add_argument('--force', action='store_true', help='bestaande tellingbestanden overschrijven')
- line 101:
  		sys.exit(f'{args.uitvoermap} heeft al tellingbestanden; gebruik --force om ze te overschrijven')
- line 114:
  		sys.exit(f'geen bestanden PerBlock/tt_<moment>_<n>of<N>.csv in {args.uitvoermap}')
- line 116:
  		sys.exit(f'onvolledige uitvoer: {len(per_blok)} blokken gevonden, verwacht {sorted(n_blokken)}')
- line 119:
  		sys.exit(f'onvolledige uitvoer: {len(ontbrekend)} combinaties van blok en moment ontbreken, bijv. {ontbrekend[:3]}')
- line 133:
  	print(f'{len(files)} bestanden, {len(per_blok)} blokken, momenten {", ".join(momenten)}')

## batch/ExtractTomTomEdition.py

- lines 1-27:
  # Richt een TomTom-editiemap in zoals cfg/main/SourceData/TomTom.dms die leest:
  #
  #   %NetworkModel_PrivDir%/TomTom/<file_date>/multinet/*.shp       (MultiNet-tegels, plat)
  #   %NetworkModel_PrivDir%/TomTom/<file_date>/speedprofiles/*.dbf  (speed profiles, plat)
  #   %NetworkModel_PrivDir%/TomTom/<file_date>/doc/                 (documentatie, ongewijzigd)
  #
  # uit een TomTom-levering als zip van .7z.001-volumes. Drie eigenaardigheden dwingen tot een
  # eigen writer in plaats van een kaal py7zr.extractall():
  #   1. de archiefnamen beginnen met een '/' ('/eur2025_12_000/shpa/mn/nld/ax/...'); de gewone
  #      schrijfroute van py7zr 1.1 struikelt daarover in zijn padcontrole ("Specified path is
  #      bad"), de factory-route niet (de sanitizer stript de slash en MemIO slaat de controle over);
  #   2. elk shapefile-onderdeel is apart gegzipt ('..._a7.shp.gz'); de reader wil .shp/.dbf;
  #   3. de reader wil multinet/ en speedprofiles/ PLAT: de shape-type-sniff in TomTom.dms
  #      (`file_str_values`, StorageType "strfiles", StorageName "=first(FolderName)") plakt de map
  #      van het EERSTE bestand voor elke bestandsnaam, dus bestanden in submappen worden niet
  #      gevonden (_fsopen faalt). Submappen per archief zijn ook niet nodig: TomTom-namen dragen
  #      de tegelcode (belbe210000______nw.shp), dus ze botsen niet; dat wordt wel gecontroleerd.
  # Dus: extractall() met een WriterFactory die per lid in het geheugen ontvangt, gunzipt en
  # als kale bestandsnaam in multinet/ resp. speedprofiles/ wegschrijft. py7zr < 1.1 kende nog
  # read()/readall(); die zijn weg.
  #
  #   python batch\ExtractTomTomEdition.py <levering.zip> <file_date> [--countries nld,bel] [--dry-run]
  #
  # Voorbeeld (PBL, editie 2025.12.000, NL en BE):
  #   python batch\ExtractTomTomEdition.py "F:\SourceData\NetworkModel_PBL_priv\TomtomMultinet_2025_copyright.zip" yr2025_12 --countries nld,bel
  #
  # Vereist py7zr (pip install --user py7zr).
- lines 34-36:
      """Ontvangt een archieflid in het geheugen en schrijft het bij close() gunzipt naar schijf.
      py7zr's MemIO roept seek(0) en close() aan als het lid compleet is; de data staat dan in
      de buffer. Een ander lid dan .gz wordt ongewijzigd weggeschreven."""
- line 55:
                  raise RuntimeError(f"naamconflict: {out} bestaat al met een andere inhoud")
- lines 63-65:
      """De factory-haak van py7zr >= 1.1: per lid een writer. fname is het gesaneerde volledige
      pad (leading '/' gestript) inclusief de archief-interne mappen; daarvan blijft alleen de
      bestandsnaam over, PLAT in de doelmap (zie punt 3 in de kop)."""
- line 74:
      """Een .7z.001-volume uit de zip PLAT naar flat_dir, gegunzipt. Geeft #bestanden."""
- line 97:
      ap.add_argument("file_date", help="mapnaam zoals de preset hem noemt, bv. yr2025_12")
- line 98:
      ap.add_argument("--countries", default="nld", help="komma-lijst van landcodes in de archiefnamen (nld, bel)")
- line 122:
          print(f"{len(jobs)} data-archieven ({total/1e6:,.0f} MB gecomprimeerd) + {len(docs)} documentatiebestanden -> {root}")
- line 130:
              print(f"[{i}/{len(jobs)}] {os.path.basename(e.filename)} -> {n} bestanden  ({time.time()-t0:,.0f} s)", flush=True)
- line 131:
          # documentatie ongewijzigd meenemen (7z-volumes en pdf's), net als de yr2021_12/doc van Object Vision
- line 142:
          print(f"documentatie: {len(docs)} bestanden -> {docdir}")
- line 146:
          print(f"klaar: {shp} .shp onder multinet/, {dbf} .dbf onder speedprofiles/, {gz} .gz achtergebleven (hoort 0)")

## batch/ValidateFronts.py

- lines 1-27:
  # Vergelijk de OV-uitvoer van twee runs per HB-paar: de consistentiechecks van ObjectVision/NetworkModel_PBL#53.
  #
  #   python batch\ValidateFronts.py --a "<glob run A>" --b "<glob run B>" [--blocks 1-10] [--moments 07h00m,07h15m]
  #                                  [--eps-time 1.0] [--eps-price 0.10] [--md rapport.md]
  #
  # A is de referentie (bijv. MinimiseCriteria 'Time', het oude model), B de nieuwe opzet (bijv. 'Price,Time'). Invoer: de
  # csv's per herkomstblok en vertrekmoment, gekoppeld op (datum, vertrekmoment, blok): sinds 2026-10-03 (#118)
  # Output/<datum>_<label>/PerBlock/tt_<hhmm>_<i>of<n>.csv (tot 2026-10-20 tt_<datum>_<hhmm>_<i>of<n>.csv), met de parameters in signature.txt in Output/<datum>_<label>;
  # tot dan Output/PerBlock/tt_<datum>_<hhmm>_ORG-...-Block_<i>of<n>_...csv, met de parameters in de naam. Beide worden gelezen.
  # Kolommen op naam: OrgName, DestName, Traveltime_<t> (min), Price_<t> (euro, alleen met Export_PriceInformation),
  # ModeUsed_<t>, NeedsCar_<t> en NeedsBike_<t> (sinds 70eec9d).
  #
  # Checks per HB-paar en vertrekmoment, over alle opties en apart over alleen OV-ketens (ModeUsed V_PT_N):
  #   1. kortste reistijd B = kortste reistijd A, binnen --eps-time minuten (ChainParetoTimeEpsilon is 60 s);
  #   2. prijs bij de kortste reistijd B <= die bij de kortste reistijd A (+ --eps-price). Gelijkheid is niet te eisen: een
  #      run op alleen tijd kiest bij gelijke reistijd een willekeurige prijs;
  #   3. kortste reistijd B <= reistijd bij de laagste prijs B, en 4. prijs bij de kortste reistijd B >= laagste prijs B.
  #      Per definitie waar; een schending wijst op ontbrekende of onleesbare waarden;
  #   5. het front van B: geen rij die door een andere rij van hetzelfde paar wordt gedomineerd op reistijd, prijs en de
  #      bezitscriteria die de handtekening (of de oude bestandsnaam) van B noemt (MinCrit-..._A = NeedsCar, _C = NeedsBike). Geteld als strikt en als
  #      voorbij de epsilons (beter met meer dan --eps-time of --eps-price);
  #   6. bereikbaarheid: paren die alleen in A of alleen in B voorkomen.
  # Prijschecks vallen weg als een run geen Price-kolom heeft.
  # Noemen A en B allebei autobezit (_A) of fietsbezit (_C), dan gelden checks 1, 2 en 6 ook per groep reizigers: zonder auto
  # (NeedsCar 0), zonder fiets (NeedsBike 0) en zonder beide. Een bool-criterium heeft geen epsilon, dus de snelste optie van zo'n
  # groep in A moet in B terugkomen; "6 alleen in A" is daar een fout. Zonder bezitscriteria in A is de snelste optie per groep
  # niet bekend: A geeft dan alleen de snelste optie overall, meestal de auto.
- line 31:
  NAME_RE = re.compile(r'tt_(?:(\d{8})_)?(?:[A-Za-z][A-Za-z0-9_]*?_)?(\d\dh\d\dm)_(\d+)of(\d+)\.csv$', re.I)  # sinds 2026-10-20 zonder de datum; ook met de datum, en met de component na de datum, zoals het model op 2026-10-19 even schreef
- line 46:
  		out[(moment, blk)] = p  # zonder de datum: die staat sinds 2026-10-20 alleen in de naam van de uitvoermap
- line 50:
  	"""De criteria van de run: uit signature.txt in de uitvoermap (boven PerBlock), of uit de oude bestandsnaam."""
- line 68:
  	"""Per HB-paar de rijen (tijd, prijs, auto, fiets, ModeUsed)."""
- line 80:
  			raise ValueError(f'{path}: geen Traveltime_{moment} of ModeUsed_{moment}')
- line 91:
  	"""Kortste tijd, prijs daarbij, laagste prijs, tijd daarbij."""
- line 107:
  	"""Aantal rijen dat strikt, en voorbij de epsilons, door een andere rij wordt gedomineerd."""
- line 164:
  	ap.add_argument('--a', required=True, help='glob van de csv-bestanden van run A (referentie)')
- line 165:
  	ap.add_argument('--b', required=True, help='glob van de csv-bestanden van run B')
- line 166:
  	ap.add_argument('--blocks', help='herkomstblokken, bijv. 1-10 of 1,5,9')
- line 167:
  	ap.add_argument('--moments', help='vertrekmomenten, bijv. 07h00m,07h15m')
- line 168:
  	ap.add_argument('--eps-time', type=float, default=1.0, help='tolerantie reistijd in minuten (standaard 1, ChainParetoTimeEpsilon)')
- line 169:
  	ap.add_argument('--eps-price', type=float, default=0.10, help='tolerantie prijs in euro (standaard 0,10, ChainParetoPriceEpsilon)')
- line 170:
  	ap.add_argument('--md', help='schrijf het verslag ook naar dit markdown-bestand')
- line 179:
  		sys.exit(f'geen gekoppelde bestanden: A {len(fa)}, B {len(fb)}')
- line 184:
  	# Per groep: (sleutel, titel, filter op een rij (tijd, prijs, auto, fiets, ModeUsed)).
- line 185:
  	scopes = [('alle', 'Alle opties', None), ('ov', 'Alleen OV-ketens', lambda x: is_pt(x[4]))]
- line 189:
  		scopes.append(('zonder auto', 'Reizigers zonder auto (NeedsCar 0)', lambda x: not x[2]))
- line 191:
  		scopes.append(('zonder fiets', 'Reizigers zonder fiets (NeedsBike 0)', lambda x: x[3] is False))
- line 193:
  		scopes.append(('zonder auto en fiets', 'Reizigers zonder auto en fiets', lambda x: not x[2] and x[3] is False))
- line 212:
  				where = f'{moment} blok {blk} {od[0]} -> {od[1]}'
- line 214:
  					t.add('6 alleen in B', where); continue
- line 216:
  					t.add('6 alleen in A', where); continue
- line 217:
  				t.add('paren')
- line 220:
  					t.add('1 kortste tijd gelijk')
- line 222:
  					t.add('1 B trager', f'{where}: A {sa[0]:.1f} min, B {sb[0]:.1f} min', dt)
- line 224:
  					t.add('1 B sneller', f'{where}: A {sa[0]:.1f} min, B {sb[0]:.1f} min', -dt)
- line 227:
  						t.add('2 prijs bij kortste tijd ok')
- line 229:
  						t.add('2 prijs bij kortste tijd B hoger', f'{where}: A {sa[1]:.2f}, B {sb[1]:.2f}', sb[1] - sa[1])
- line 232:
  						t.add('3/4 ontbrekende prijs in B', where)
- line 234:
  						if not (sb[0] <= sb[3]): t.add('3 geschonden', where)
- line 235:
  						if not (sb[1] >= sb[2]): t.add('4 geschonden', where)
- line 236:
  				# Zonder prijs is het front niet te toetsen: opties met verschillende prijs lijken dan gedomineerd op tijd.
- line 240:
  						t.add('5 paren met gedomineerde rijen in B (strikt)')
- line 241:
  						t.n['5 gedomineerde rijen in B (strikt)'] += strict
- line 244:
  						t.add('5 paren met gedomineerde rijen in B (voorbij epsilon)', f'{where}: {r[4]} {r[0]:.1f} min {r[1]} door {s[4]} {s[0]:.1f} min {s[1]}', worst[0] + worst[1])
- line 245:
  						t.n['5 gedomineerde rijen in B (voorbij epsilon)'] += beyond
- line 249:
  	lines.append(f'- A: `{args.a}` ({len(fa)} bestanden), B: `{args.b}` ({len(fb)} bestanden), gekoppeld: {len(keys)}')
- line 250:
  	lines.append(f'- MinCrit A: {"_".join(crit_a) or "?"}, B: {"_".join(crit_b) or "?"}; frontcheck op reistijd' + (', prijs' if has_price_b else '') + (', NeedsCar' if use_car else '') + (', NeedsBike' if use_bike else ''))
- line 251:
  	lines.append(f'- prijs in A: {"ja" if has_price_a else "nee"}, in B: {"ja" if has_price_b else "nee"}; eps-time {args.eps_time} min, eps-price {args.eps_price} euro')
- line 252:
  	lines.append(f'- HB-paren x vertrekmoment: {pairs}\n')
- line 256:
  		lines.append('| check | aantal |')
- line 263:
  				lines.append(f'\n### {key}: grootste gevallen\n')

## batch/OVFiets2025_Geocode.dms

- `L23` (regel 44): (geen Descr)
- `Src` (regel 45): (geen Descr)
- `L` (regel 47): De locaties van 2025 zonder de rijen die precies dubbel staan.
- `nr` (regel 53): Het huisnummer: het eerste getal na een spatie (dus 190 in '1e Stationsstraat 190'); leeg zonder.
- `st_rel` (regel 59): Een GTFS-halte met precies deze naam (station of perron).
- `d23` (regel 66): Afstand tot de locatie met dezelfde naam in 2023, in m.
- `dstop` (regel 71): Afstand tot de dichtstbijzijnde GTFS-halte (feed 20250930), in m; het model koppelt binnen DistanceOVFietsStops (200 m).
- commentaar regel 1-8: OVFiets2025_Geocode (batch/OVFiets2025_Geocode.dms, losse config; draai met GeoDmsRun <dit bestand> /Generate): de OV-fietslocaties van 2025 (PBL, mail van PBL van 13-10-2026, '20261013 - Locaties OVF tbv PBL v2.xlsx', tabblad 2025) gegeocodeerd, in de vorm van het bestand van 2023 dat het model leest (Infrastructuur/20260408_Locaties.OVF_2023_Geocoded.csv). Per locatie, in deze volgorde: 1 dezelfde naam, postcode en huisnummer als in 2023: de coordinaten van 2023; 2 anders het adres in de BAG van 1-1-2025 (postcode en huisnummer); 3 anders, bij een naam die in 2023 bestond, de coordinaten van 2023 (een adres dat de BAG niet kent, of een fout in de lijst); 4 anders het zwaartepunt van de adressen met die postcode. Een rij die precies dubbel staat, telt een keer.
- commentaar regel 62-62: Een nieuw of gewijzigd adres verder dan 200 m van elke halte (DistanceOVFietsStops) koppelt het model aan geen station; dan de halte met dezelfde naam.
