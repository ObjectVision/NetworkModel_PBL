# MoveSignaturesIntoStores.ps1 (2026-10-06): zet de handtekening van de stores in IntermediateResults in de map van de store.
# Van 2026-10-03 (NetworkModel_PBL#118) tot 2026-10-06 stond hij ernaast, als <naam>.signature.txt en <naam>.signature.xml; sinds
# 2026-10-06 zoekt de configuratie hem als signature.txt in de map: PT_Chains_<datum>_<venster>_<hash>\ (een store per blok),
# PT_Chains_..._<hash>.mmd\ of DirectCar_..._<hash>.mmd\. Zonder dit weigert het model een oudere store te lezen (geen handtekening).
# Slaat een handtekening over waarvan de store (nog) niet bestaat, bijvoorbeeld een autostore die nog rekent, en een map waarin al
# een signature.txt staat.
#   powershell -ExecutionPolicy Bypass -File batch\MoveSignaturesIntoStores.ps1 [-Dir <IntermediateResults>] [-WhatIf]
param(
	[string]$Dir = 'C:\LocalData\NetworkModel_PBL\IntermediateResults',
	[switch]$WhatIf
)
$ErrorActionPreference = 'Stop'
foreach ($f in Get-ChildItem -Path $Dir -Filter '*.signature.txt' -File) {
	$base = $f.Name.Substring(0, $f.Name.Length - '.signature.txt'.Length)
	$store = @("$base", "$base.mmd") | ForEach-Object { Join-Path $Dir $_ } | Where-Object { Test-Path $_ -PathType Container } | Select-Object -First 1
	if (-not $store) { "overgeslagen, geen store: $($f.Name)"; continue }
	if (Test-Path (Join-Path $store 'signature.txt')) { "overgeslagen, er staat al een signature.txt in $(Split-Path $store -Leaf)"; continue }
	foreach ($ext in 'txt', 'xml') {
		$src = Join-Path $Dir "$base.signature.$ext"
		if (Test-Path $src) {
			if ($WhatIf) { "zou verplaatsen: $base.signature.$ext -> $(Split-Path $store -Leaf)\signature.$ext" }
			else { Move-Item $src (Join-Path $store "signature.$ext"); "verplaatst: $base.signature.$ext -> $(Split-Path $store -Leaf)\signature.$ext" }
		}
	}
}
