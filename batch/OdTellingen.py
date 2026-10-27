# Counts next to the public transport output, from the files per block: od_tellingen.csv and unieke_od_tellingen.csv in
# the output folder.
#
#   python batch\OdTellingen.py <output folder> [--force]
#
# <output folder> is Output\<Analysis_date>_<OutputLabel> (with PerBlock\tt_<moment>_<n>of<N>.csv; older output has
# tt_<date>_<moment>_<n>of<N>.csv). In a single request the output step makes these two files itself
# (NetworkSetup/ConfigurationPerBlock/Generate_Output/OD_Counts); this script does the same for output calculated in
# portions and for older output, with the same rules and the same format:
# - od_tellingen.csv: the rows per kind of option (all, public transport chain = ModeUsed with a '_', and the direct trips
#   WW, CC and AA), per departure moment and in total;
# - unieke_od_tellingen.csv: the unique OD pairs (OrgName, DestName) with at least one option of that kind, or with an
#   option without a car (NeedsCar 0) or without car and bike (NeedsCar and NeedsBike 0), per departure moment and over
#   the moments together.
# The origin blocks each have their own origins, so the counts per block are added up; per block the pairs are united
# over the moments. If one of the two files already exists, the script stops, unless --force is given.
#
# The model writes the counts per block itself, in the same request as the output, to Tellingen\tellingen_<n>of<N>.csv
# (PublicTransport/Generate_Output/Traveltime_ForEachDepTime/Counts/File). If those files exist, this script only adds
# them up and does not read the output, which can be parquet (ModelParameters/OutputFormat) and hundreds of GB. The adding
# up happens here and not in the model, because the blocks are calculated in separate GeoDmsRuns (WriteOutputBlocks.ps1)
# and a request for the sum would load the configuration again.
import argparse, csv, glob, os, re, sys
from collections import Counter, defaultdict
from multiprocessing import Pool

SOORTEN = ['alle', 'OV-keten', 'WW', 'CC', 'AA']
GROEPEN = ['alle', 'OV-keten', 'WW', 'CC', 'AA', 'zonder auto', 'zonder auto en fiets']
# The file names are tt_<moment>_<n>of<N>.csv; the pattern also reads older names with the date, and with the component
# after the date (tt_<date>_<component>_<moment>_<n>of<N>.csv).
NAME_RE = re.compile(r'tt_(?:\d{8}_)?(?:[A-Za-z][A-Za-z0-9_]*?_)?(\d\dh\d\dm)_(\d+)of(\d+)\.csv$')

def blok(files):
	"""Counts of one origin block: rows per (moment, kind), pairs per (moment, group) and per group over the moments."""
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

TELLING_RE = re.compile(r'tellingen_(\d+)of(\d+)\.csv$')

def uit_blokbestanden(uitvoermap, uit_rijen, uit_paren):
	"""Adds up the counts per block of the model (Tellingen/tellingen_<n>of<N>.csv: tabel;naam;<moments>;totaal)."""
	files = sorted(glob.glob(os.path.join(uitvoermap, 'Tellingen', 'tellingen_*.csv')))
	namen = [TELLING_RE.search(os.path.basename(p)) for p in files]
	n_blokken = {int(mt.group(2)) for mt in namen if mt}
	blokken = {int(mt.group(1)) for mt in namen if mt}
	if len(n_blokken) != 1 or blokken != set(range(1, next(iter(n_blokken)) + 1)):
		sys.exit(f'incomplete counts: {len(blokken)} blocks in {uitvoermap}\\Tellingen, expected {sorted(n_blokken)}')
	som, kop = Counter(), None
	for p in files:
		with open(p, newline='', encoding='utf-8') as fh:
			r = csv.reader(fh, delimiter=';')
			h = next(r)
			if kop is None:
				kop = h
			elif h != kop:
				sys.exit(f'{p}: header {h} differs from {kop}')
			for row in r:
				if row:
					for i, v in enumerate(row[2:]):
						som[(row[0], row[1], i)] += int(v)
	momenten = kop[2:-1]
	with open(uit_rijen, 'w', newline='\n', encoding='utf-8') as f:
		f.write('soort;' + ';'.join(momenten) + ';totaal\n')
		for k in SOORTEN:
			f.write(k + ''.join(f";{som[('rijen', k, i)]}" for i in range(len(momenten) + 1)) + '\n')
	with open(uit_paren, 'w', newline='\n', encoding='utf-8') as f:
		f.write('groep;' + ';'.join(momenten) + ';samen\n')
		for k in GROEPEN:
			f.write(k + ''.join(f";{som[('paren', k, i)]}" for i in range(len(momenten) + 1)) + '\n')
	print(f'{len(files)} count files of the model (Tellingen), moments {", ".join(momenten)}')
	print(open(uit_rijen, encoding='utf-8').read() + open(uit_paren, encoding='utf-8').read(), end='')

def main():
	ap = argparse.ArgumentParser()
	ap.add_argument('uitvoermap', help=r'the output folder, Output\<Analysis_date>_<OutputLabel>')
	ap.add_argument('--force', action='store_true', help='overwrite existing count files')
	args = ap.parse_args()
	uit_rijen = os.path.join(args.uitvoermap, 'od_tellingen.csv')
	uit_paren = os.path.join(args.uitvoermap, 'unieke_od_tellingen.csv')
	if not args.force and (os.path.exists(uit_rijen) or os.path.exists(uit_paren)):
		sys.exit(f'{args.uitvoermap} already has count files; use --force to overwrite them')
	if glob.glob(os.path.join(args.uitvoermap, 'Tellingen', 'tellingen_*.csv')):
		return uit_blokbestanden(args.uitvoermap, uit_rijen, uit_paren)
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
		sys.exit(f'no files PerBlock/tt_<moment>_<n>of<N>.csv in {args.uitvoermap}')
	if len(n_blokken) != 1 or len(per_blok) != int(next(iter(n_blokken))):
		sys.exit(f'incomplete output: {len(per_blok)} blocks found, expected {sorted(n_blokken)}')
	ontbrekend = [(b, m) for b, fs in per_blok.items() for m in momenten if not any(f'_{m}_' in os.path.basename(f) for f in fs)]
	if ontbrekend:
		sys.exit(f'incomplete output: {len(ontbrekend)} combinations of block and moment are missing, for example {ontbrekend[:3]}')
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
	print(f'{len(files)} files, {len(per_blok)} blocks, moments {", ".join(momenten)}')
	print(open(uit_rijen, encoding='utf-8').read() + open(uit_paren, encoding='utf-8').read(), end='')

if __name__ == '__main__':
	main()
