# Frontvalidatie 2026-10-03 (#53, stap 2)

Vergelijking van de paretofronten van twee runs die alleen in `MinimiseCriteria` verschillen. Run A minimaliseert op reistijd (`'Time'`), run B op prijs en reistijd (`'Price,Time'`). Als B klopt, moet het front van B de snelste optie van A bevatten, en mag B daar niet duurder zijn.

## Opzet

- Commit 6290684 (de rit-opslag van #3 en Price_S in de ketenstore zitten erin), engine 20.22.1_e04ad20f0.
- Feed `GTFS_file_date` 20260925, dag `Analysis_date` 20261006 (dinsdag), `Export_PriceInformation` TRUE, verder de standaardparameters van die commit (MaxPT 90 min, 3 overstappen, `chaineps` 10 ct / 60 s).
- Ketenstap voor alle 500 haltenblokken: A 4,0 uur, B 4,2 uur. Uitvoer voor herkomstblokken 1-10 van 450, vier vertrekmomenten (07h00m-07h45m): A 10 min, B 13 min.
- Vergelijking met `batch\ValidateFronts.py`, eps-time 1,0 min, eps-price 0,10 euro: 40 bestanden per run, 1.306.535 HB-paren x vertrekmoment.

De runs draaiden vóór #118, dus met de oude bestandsnamen. #118 heeft alleen de namen veranderd, niet de modellogica, en `ValidateFronts.py` leest beide naamgevingen.

## Uitkomst

### Alle opties

| check | aantal | van |
|---|---|---|
| 1 kortste reistijd van B gelijk aan die van A | 1.306.535 | 1.306.535 |
| 2 prijs bij kortste reistijd van B niet hoger dan in A | 1.306.535 | 1.306.535 |
| 5 gedomineerde rijen in het front van B | 0 | |

Checks 3 en 4 zijn tautologisch en zijn niet apart geteld.

### Alleen OV-ketens

| check | aantal |
|---|---|
| paren met een OV-keten in A en B, kortste tijd en prijs ok | 7.953 |
| 6 OV-keten alleen in A | 25 |
| 6 OV-keten alleen in B | 118.095 |

## Duiding

1. Checks 1, 2 en 5 slagen voor alle paren: met prijs als criterium verdwijnt geen snelste optie en wordt die niet duurder, en het front van B bevat geen gedomineerde rijen.
2. De 25 paren met een OV-keten alleen in A zijn alle 25 nagegaan: het is epsilondominantie. In B staat steeds een fiets- of autorit die hoogstens 60 s langzamer en minstens 10 ct goedkoper is dan de OV-keten van A, en daardoor valt de OV-keten in B af. Voorbeeld: PandBlok_14754 → Joure, Busstation (Perron A), 07h00m. A: lopen-bus-lopen in 6,12 min voor 1,39 euro. B: fietsen in 6,88 min voor 0,14 euro. De kortste reistijden verschillen 0,77 min, binnen eps-time. Met de auto: PandBlok_36892 → Rotterdam, Kralingse Zoom, 07h00m, trein en metro in 21,48 min voor 4,75 euro tegen de auto in 21,68 min voor 4,44 euro.
3. De 118.095 paren met een OV-keten alleen in B zijn de bedoeling van prijs als criterium: in A valt de OV-keten weg tegen een snellere auto- of fietsrit, in B blijft hij als goedkoper alternatief in het front.

### Beperking: geen bezitscriteria

Geen van beide runs noemde `Car` of `Bike`, terwijl de standaard `'Price,Time,Car,Bike'` is. Met alleen `'Time'` is de uitvoer per paar de ene snelste optie, alsof iedereen een auto en een fiets heeft: in run A de auto bij 1.297.174 van de 1.306.535 paren (99,3%), een OV-keten bij 7.978 en de fiets bij 1.383. De 25 OV-ketens van punt 2 vallen alleen in deze opzet af; met `Car,Bike` als criterium blijven ze staan voor reizigers zonder auto of fiets. De vergelijking die bij de standaard past, is `'Time,Car,Bike'` tegen `'Price,Time,Car,Bike'`; die is op 2026-10-04 gestart tegen de basisrun (label `val53_tcb`, zie `batch\RunFrontValidation.ps1 -BaseRun`).

## Opnieuw draaien

```
powershell -ExecutionPolicy Bypass -File batch\RunFrontValidation.ps1 -Label val53 -CritA Time -CritB Price,Time
```

Dit maakt twee runkopieën van HEAD met `OutputLabel` `val53_A` en `val53_B`, draait de ketenstap, de uitvoer van blokken 1-10 en de vergelijking. Het verslag komt in `C:\LocalData\NM_PBL_runs\val53\verslag.md`. Met `-BaseRun` wordt alleen A gerekend en is B de uitvoer van een bestaande run. Zie ook de skill `model-validatie` en de wiki, How to run the model, Validating the Pareto front.
