# NetworkModel_PBL

Omgaan met wachttijden via parameter instellingen:
- WegingWachttijdThuisVoortransport: getal tussen 0 en 1. Hoe zwaar wil je de wachttijd laten wegen? 1=volledige wachttijd bij de duration optellen, 0=wachttijd telt niet helemaal niet mee.
- OmitMaxWachttijdThuisVoortransportLinks: TURE or FALSE. Wil je links uit de analyse laten afvallen als je te lang moet wachten voor vertrek?
- MaxWachttijdThuisVoortransport: getal in seconden. Hoelang mag iemand thuis wachten voor hij/zij vertrekt?

  case( W=1, O=1, M=1, D+WT+24u )
  case( W=1, O=1, M=0, D+WT )
  case( W=1, O=0, M=0, D+WT )
  case( W=0, O=1, M=1, D+24u )
  case( W=0, O=0, M=1, D )
  case( W=0, O=0, M=0, D )
