---
name: werkafspraken
description: Wat waar thuishoort in NetworkModel_PBL (Descr en Source, commentaar, parameters, commits, issues, wiki, memory, werkdocumenten, SourceData), met de redenen. Gebruik bij elke Descr die je schrijft of herschrijft, bij een commit, bij een issue of comment, bij een wikiwijziging, bij data die je downloadt of wegschrijft, en als je twijfelt of iets in code, issue of memory hoort.
---

# Werkafspraken

De korte regels staan in `CLAUDE.md`; hier staan ze uitgewerkt, met waarom.

## 1. Elke soort kennis heeft een plek

| Plek | Wat er hoort | Waarom daar |
|---|---|---|
| `CLAUDE.md` | korte regels die in elke sessie gelden | wordt elke sessie geladen, dus kort houden |
| skill in `.claude/skills/` | een procedure met stappen en een volgorde, met de referentiewaarden die je nodig hebt om te oordelen | laadt alleen bij die taak, staat in git en vertakt mee |
| issue op GitHub | het verhaal van een stuk werk: aanleiding, metingen, afweging, besluit, welke organisatie wat vroeg | daar kijken anderen mee en daar hoort de discussie |
| wiki | hoe het model werkt: methode, aannames, beperkingen | daar zoeken gebruikers van het model |
| code (Descr, Source) | wat een item doet, in een zin, en waar de data vandaan komt | wie het item opent, moet het meteen begrijpen |
| memory | alleen wat nergens anders past: hoe de gebruiker wil werken, mondelinge afspraken, dure metingen die je anders opnieuw draait | alleen zichtbaar voor Claude op die machine, dus laatste keus |

Schrijf iets op een plek, niet op twee. Staat een afweging al in een issue, verwijs dan met het nummer. Een procedure die terugkomt gaat naar een skill, niet naar memory: een skill staat in git en is ook voor collega's en voor een tweede machine.

## 2. Een Descr is geen logboek

Een Descr zegt wat het item doet of betekent, in een zin; waar nodig waarom het er is, en bij een instelling wat de consequentie van de waarde is. Een verwijzing met hekje naar het issue waar de afweging staat blijft erin. De bron van een kental of dataset staat in de property `Source`, met jaargang of leveringsdatum.

Eruit blijven:
- meetuitkomsten en de datum ervan ("gemeten op 2026-10-05: 86.626 rijen");
- de geschiedenis van wat er eerder stond ("tot 2026-10-19 een naam uit een tabel", "eerder 60 s");
- de weg waarlangs een fout is gevonden;
- lessen over GeoDMS zelf (die horen in de GeoDMS-skills of op de GeoDMS-wiki);
- instructies aan de volgende lezer (die horen in een skill);
- versienummers en exitcodes.

Vorm: een aaneengesloten tekst zonder witregels. Richtpunt: parameters en attributen onder de 300 tekens, containers en sjablonen onder de 800.

Waarom: de Descr is wat iemand in de GUI ziet als hij een item opent. Een Descr van 2000 tekens met een revisiegeschiedenis verbergt de ene zin die hij nodig heeft, en de geschiedenis staat al in git en in het issue. Een revisieteller (zoals de ketenrevisie `_rN`) zegt in zijn Descr wanneer je hem verhoogt; wat er per revisie veranderde staat in de commit en het issue.

Geschiedenis of een meting die nu alleen in een Descr staat, gaat eerst als comment naar het issue waar hij bij hoort (concept aan de gebruiker), en pas daarna uit de Descr.

## 3. Geen persoonsnamen in de repo

De repo is openbaar. Geen namen van personen in Descr, Source, commentaar, commits, issues of de wiki: noem de organisatie (PBL, Deltares, Object Vision, VU). Is het nodig te weten wie iets aanleverde of vroeg, gebruik dan organisatie plus volgnummer (`PBL-3`) en houd de koppeling naar de persoon in een lijst buiten de repo. Wat wel mag: auteurs van gepubliceerd werk met titel of DOI, contactpersonen in de header van een geleverd bestand, en organisatienamen. Een gebruikersnaam in een pad telt ook als naam.

## 4. Commentaar in de code

Commentaar legt uit waarom iets er staat, niet wat er vroeger stond. Uitgecommentarieerde code gaat weg: git bewaart de oude toestand. Een tijdelijk probeersel of meetharnas verdwijnt zodra de vraag beantwoord is; de meting staat dan in het issue. Een harnas dat blijft, staat in een vaste diagnosecontainer onder een naam die zegt wat het meet, met een norm als controlewaarde, en niet onder een issuenummer.

## 5. Geen kale getallen

Een waarde die iemand zou willen verzetten, staat in `ModelParameters`, met een Descr die zegt wat de waarde doet. Niet als literal midden in een berekening.

## 6. Werkdocumenten horen niet in de repo

De repo staat bij Object Vision, maar het is een PBL-project, en in de repo van een opdrachtgever horen geen werkdocumenten van Claude: plannen, audits, doorlichtingen, bevindingennotities, sessienotities. Bevindingen gaan als issue (een per bevinding die werk vraagt), de methode die eruit volgt op de wiki. Het document zelf staat buiten de repo, bijvoorbeeld in `C:\LocalData\NetworkModel_PBL\Plannen`, of als bijlage bij het issue.

## 7. SourceData op de Nextcloud-share is alleen-lezen

De SourceData-mappen die met de Nextcloud-share van PBL synchroniseren, delen alle gebruikers van het model. Wat Claude daar schrijft, staat meteen voor iedereen op de share, en vaak kan het account het daarna niet meer verwijderen of wijzigen. Niemand weet later wat zo'n bestand is, of het gebruikt wordt en of het weg kan.

- Lezen mag. Geen recursieve listings of agents over de hele share: die starten downloads.
- Schrijf er niets: geen download, geen uitgepakt archief, geen kopie, geen afgeleide data, geen uitvoer, ook niet via een `StorageName` of een script.
- Downloads en tussenbestanden gaan naar een werkmap buiten de share, bijvoorbeeld `C:\LocalData\NetworkModel_PBL\Download`, met een notitie waar het vandaan komt. Afgeleide data hoort in `%LocalDataProjDir%`.
- Blijkt de data echt nodig, meld dan: welk bestand, de bron met jaargang of leveringsdatum, waar het in SourceData zou moeten staan en welk item het leest. De gebruiker zet het zelf neer, of vraagt Claude in de sessie om dat ene bestand op die plek te zetten. Een algemene go dekt dat niet.

## 8. Opslag: mmd en parquet, geen fss

Geen nieuwe fss meer. Een grote dataset die alleen GeoDMS terugleest (zoals de ketencache of een groot netwerk), wordt een mmd. Iets kleins wordt een open bestand dat ook QGIS, R, Python of een collega kan lezen: een tif voor een raster (altijd met zijn `.tfw`), een gpkg voor vlakken en punten, een parquet voor een tabel. Een grote csv die elke run opnieuw inleest, wordt parquet: in RSopen las LISA als csv in 17 s per proces en als parquet in 1,2 s. Een bestaande fss zet je om zodra je hem toch opnieuw maakt.

Waarom: een fss is geen uitwisselformaat tussen GeoDMS-versies (een fss uit 14.7 las in 20.23.1 zonder foutmelding met de polygonen als ruis), en niemand anders kan hem openen. Bij een mmd gelden drie valkuilen: een alleen-lezen holder declareert zijn items niet zelf, het bestand past exact op het domein, en een IntegrityCheck hoort op de cache-unit. gpkg en parquet lopen via `gdal.vect`; toets een kleine cache die een run op veel plekken tegelijk leest eerst in een volledige run.

## 9. Commits

- Een commitboodschap is voor een collega die het model kent maar niet weet wat er in de sessie gebeurde. De onderwerpregel blijft onder de 70 tekens, want Visual Studio en GitHub kappen daarna af. De body zegt in een paar volledige zinnen wat er veranderde, waarom, en wat het oplevert, met een verwijzing naar het issue; metingen, tussenstappen en de afweging staan in het issue.
- Geen harde enter binnen een alinea, alleen een witregel tussen alinea's. Het afbreken op 72 tekens is een oude terminalgewoonte; Visual Studio en GitHub breken zelf af op de breedte van het venster.
- Schrijf volledige zinnen, geen telegramstijl ("Weg: X."), geen namen die alleen in de sessie bestaan, en een getal met wat het is en waartegen het staat. Een reeks getallen hoort in het issue, in een tabel met labels.
- De onderwerpregel begint met het issuenummer: `#129 OD_Uitvoer: een OV-onderdeel met de dienstregelingstijden van zijn rit`. Visual Studio toont alleen de eerste regel, en alleen met hekje koppelt GitHub de commit aan het issue. Tussen repo's gekwalificeerd: `ObjectVision/GeoDMS#1282`.
- Altijd `git commit --cleanup=whitespace`, anders gooit git bij een amend, rebase of `-F` een regel die met `#` begint stil weg, en daarmee de hele onderwerpregel.
- Grote thematische commits per afgerond stuk werk, een onderwerp per commit; werk aan hetzelfde issue in een commit zolang er niet gepusht is.
- Geen AI-attributie: geen `Co-Authored-By`, geen "Generated with Claude Code".
- Draaien er meerdere sessies in dezelfde werkkopie: nooit `git add -A` of `commit -a`, alleen eigen bestanden en hunks, `git status` vlak voor de commit en `git show --stat` erna.
- Pushen doet de gebruiker, tenzij hij er in de sessie om vraagt.

## 10. Issues en andere tekst op GitHub

- Niets plaatsen (issue, comment, PR-tekst, sluiten) voordat de gebruiker het concept zag en akkoord gaf. Een opdracht als "leg dat maar voor" is een opdracht om het concept te schrijven, geen akkoord op plaatsen.
- Een goed issue noemt pad en regelnummer, het gemeten getal en waartegen het afgezet is, scheidt waarneming van interpretatie en zegt wat niet getoetst is. Open vragen onderaan, per partij die aan zet is, alleen als ze niet al ergens beantwoord zijn en niet met een meting op te lossen zijn.
- Een issue sluiten is drie handelingen: een afrondende comment (wat, met welke uitkomst, wat blijft liggen), de commit met het nummer, sluiten.
- Geen vet in lopende tekst en geen gedachtenstreepjes: zulke tekst is meteen herkenbaar als door AI geschreven.
- Schrijf voor een mens die er niet bij was: volledige zinnen met een werkwoord, geen eigen namen voor toetsruns of tussenstanden, en bij elk getal wat het is en waartegen het staat. Een regel, knoop of rit is "hij" of "het", niet "zij". Dat geldt ook voor de chat met de gebruiker.

## 11. De wiki is naslag

Een wikipagina beschrijft hoe het nu werkt, in de tegenwoordige tijd. Niet: wanneer iets veranderde, wat er eerder stond, hoe een fout gevonden is. Wel de afweging achter een keuze, als redenering die over een jaar nog klopt. Bijwerken is herschrijven alsof de nieuwe werking er altijd was. Bij een verschil tussen wiki en code is de code leidend.

## 12. Toetsen

Exitcode 0 bewijst niet dat het klopt: lees het log op `[E]` en meet de uitkomst. Elk getal dat je noemt, komt uit een meting of bestand in deze sessie. Wat er gedraaid is, lees je uit configuratie, branch en logs, niet uit een rapport.
