---
name: geodms-dms-style
description: Regels voor het schrijven en reviewen van GeoDMS-configuratiecode (.dms) in NetworkModel_PBL - typeconversies alleen waar de typen verschillen (#U, sum_uint64, geen automatische verbreding), union_data per element in plaats van switch op id, tellen per klasse, unieke combinaties op een integer-sleutel, samenvattingen van werk achter een hek in dezelfde opvraging, en een herschrijving bewijzen op een probe. Gebruik bij elke wijziging of review van .dms-code.
---

# .dms-code schrijven

De regels staan in de GeoDMS-skill `geodms-dms-style`, in de engine-repository. Lees die voordat je .dms-code schrijft, herschrijft of reviewt:

- lokaal: `C:\dev\GeoDMS_2026\.claude\skills\geodms-dms-style\SKILL.md`
- op GitHub: https://github.com/ObjectVision/GeoDMS/blob/main/.claude/skills/geodms-dms-style/SKILL.md

Houd hier geen kopie bij: de regels worden daar bijgewerkt.

Voorbeelden in dit model: de tellingen naast de OV-uitvoer.
- Per vertrekmoment: `Tellingen` in `cfg/main/NetworkSetup/PublicTransport/PerDepartureMoment_T.dms`.
- Per blok: `Tellingen` in `cfg/main/NetworkSetup/PublicTransport.dms`.
- Over alle blokken: `OD_Tellingen` in `cfg/main/NetworkSetup.dms`.

De herschrijving staat in commits ec53e1d en bee7f55.
