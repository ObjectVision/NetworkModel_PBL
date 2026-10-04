# Tellingen naast de OV-uitvoer, uit de csv's per blok: od_tellingen.csv en unieke_od_tellingen.csv in de uitvoermap.
#
#   python batch\OdTellingen.py <uitvoermap> [--force]
#
# <uitvoermap> is Output\<Analysis_date>_<OutputLabel> (met PerBlock\tt_<datum>_<moment>_<n>of<N>.csv, sinds #118). Sinds
# 2026-10-04 maakt de uitvoerstap deze twee bestanden zelf (NetworkSetup/ConfigurationPerBlock/Generate_Output/OD_Tellingen,
# commit f55636e); dit script doet hetzelfde voor uitvoer van daarvoor, met dezelfde regels en hetzelfde formaat:
# - od_tellingen.csv: de rijen per soort optie (alle, OV-keten = ModeUsed met een '_', en de directe ritten WW, CC en AA), per
#   vertrekmoment en in totaal;
# - unieke_od_tellingen.csv: de unieke HB-paren (OrgName, DestName) met minstens een optie van die soort, of met een optie
#   zonder auto (NeedsCar 0) of zonder auto en fiets (NeedsCar en NeedsBike 0), per vertrekmoment en over de momenten samen.
# De herkomstblokken hebben elk hun eigen herkomsten, dus de tellingen per blok worden opgeteld; per blok worden de paren over
# de momenten verenigd. Bestaat een van de twee bestanden al, dan stopt het script, tenzij --force.
import argparse, csv, glob, os, re, sys
from collections import Counter, defaultdict
from multiprocessing import Pool

SOORTEN = ['alle', 'OV-keten', 'WW', 'CC', 'AA']
GROEPEN = ['alle', 'OV-keten', 'WW', 'CC', 'AA', 'zonder auto', 'zonder auto en fiets']
NAME_RE = re.compile(r'tt_\d{8}_(\d\dh\d\dm)_(\d+)of(\d+)\.csv$')

def blok(files):
	"""Tellingen van een herkomstblok: rijen per (moment, soort), paren per (moment, groep) en per groep over de momenten."""
	rijen, paren, samen = Counter(), Counter(), defaultdict(set)
	for p in files:
		m = NAME_RE.search(os.path.basename(p)).group(1)
		per = defaultdict(set)
		with open(p, newline='', encoding='utf-8') as fh:
			r = csv.reader(fh, delimiter=';')
			h = next(r)
			im, ic, ib = h.index('ModeUsed_' + m), h.index('NeedsCar_' + m), h.index('NeedsBike_' + m)
			for row in r:
				if not row:
					continue
				od = (row[0], row[1])
				mode = row[im]
				soort = 'OV-keten' if '_' in mode else mode
				rijen[(m, 'alle')] += 1
				rijen[(m, soort)] += 1
				per['alle'].add(od)
				per[soort].add(od)
				if row[ic] == '0':
					per['zonder auto'].add(od)
					if row[ib] == '0':
						per['zonder auto en fiets'].add(od)
		for g, s in per.items():
			paren[(m, g)] += len(s)
			samen[g] |= s
	return rijen, paren, Counter({g: len(s) for g, s in samen.items()})

def main():
	ap = argparse.ArgumentParser()
	ap.add_argument('uitvoermap', help=r'Output\<Analysis_date>_<OutputLabel>')
	ap.add_argument('--force', action='store_true', help='bestaande tellingbestanden overschrijven')
	args = ap.parse_args()
	uit_rijen = os.path.join(args.uitvoermap, 'od_tellingen.csv')
	uit_paren = os.path.join(args.uitvoermap, 'unieke_od_tellingen.csv')
	if not args.force and (os.path.exists(uit_rijen) or os.path.exists(uit_paren)):
		sys.exit(f'{args.uitvoermap} heeft al tellingbestanden; gebruik --force om ze te overschrijven')
	files = sorted(glob.glob(os.path.join(args.uitvoermap, 'PerBlock', 'tt_*.csv')))
	per_blok, momenten, n_blokken = defaultdict(list), set(), set()
	for p in files:
		mt = NAME_RE.search(os.path.basename(p))
		if not mt:
			continue
		per_blok[mt.group(2)].append(p)
		momenten.add(mt.group(1))
		n_blokken.add(mt.group(3))
	if not per_blok:
		sys.exit(f'geen bestanden PerBlock/tt_<datum>_<moment>_<n>of<N>.csv in {args.uitvoermap}')
	if len(n_blokken) != 1 or len(per_blok) != int(next(iter(n_blokken))):
		sys.exit(f'onvolledige uitvoer: {len(per_blok)} blokken gevonden, verwacht {sorted(n_blokken)}')
	ontbrekend = [(b, m) for b, fs in per_blok.items() for m in momenten if not any(f'_{m}_' in os.path.basename(f) for f in fs)]
	if ontbrekend:
		sys.exit(f'onvolledige uitvoer: {len(ontbrekend)} combinaties van blok en moment ontbreken, bijv. {ontbrekend[:3]}')
	momenten = sorted(momenten)
	R, P, S = Counter(), Counter(), Counter()
	with Pool(min(8, os.cpu_count() or 1)) as pool:
		for r, p, s in pool.imap_unordered(blok, per_blok.values()):
			R.update(r); P.update(p); S.update(s)
	with open(uit_rijen, 'w', newline='\n', encoding='utf-8') as f:
		f.write('soort;' + ';'.join(momenten) + ';totaal\n')
		for k in SOORTEN:
			f.write(k + ''.join(f';{R[(m, k)]}' for m in momenten) + f';{sum(R[(m, k)] for m in momenten)}\n')
	with open(uit_paren, 'w', newline='\n', encoding='utf-8') as f:
		f.write('groep;' + ';'.join(momenten) + ';samen\n')
		for k in GROEPEN:
			f.write(k + ''.join(f';{P[(m, k)]}' for m in momenten) + f';{S[k]}\n')
	print(f'{len(files)} bestanden, {len(per_blok)} blokken, momenten {", ".join(momenten)}')
	print(open(uit_rijen, encoding='utf-8').read() + open(uit_paren, encoding='utf-8').read(), end='')

if __name__ == '__main__':
	main()
