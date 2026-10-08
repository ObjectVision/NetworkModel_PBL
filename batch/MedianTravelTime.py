# Mediane reistijd per HB-paar over de vertrekmomenten, uit de csv's per blok van een uitvoermap (sinds 2026-10-08, voor de
# autoreistijden buurt naar buurt van #53).
#
#   python batch\MedianTravelTime.py <uitvoermap> [--modes AA] [--blocks 1-20] [--workers N] [--force]
#
# <uitvoermap> is Output\<Analysis_date>_<OutputLabel>_<component> met PerBlock\tt_<datum>_<moment>_<n>of<N>.csv. Per HB-paar en
# vertrekmoment de snelste optie (de laagste Traveltime, bij gelijke tijd de laagste Price), met --modes alleen de opties met die
# ModeUsed (kommagescheiden, bijvoorbeeld AA voor de directe autorit). Daarover per HB-paar de mediaan over de vertrekmomenten met
# een optie: bij een even aantal het gemiddelde van de twee middelste. Zo ook de afstand en de prijs van die snelste opties, elk
# apart; bij de auto verschillen de momenten nauwelijks, want de autostore heeft een congestiemoment (Car_CongestionMoment_ForDirect).
# Schrijft <uitvoermap>\tt_<datum>_mediaan.csv met per HB-paar:
#   OrgName, DestName                  de herkomst en de bestemming, zoals in de uitvoer
#   Traveltime_median, _min, _max      reistijd in minuten: de mediaan, de snelste en de traagste over de momenten
#   TravelDist_median                  afstand in meters (TravelDist_V + TravelDist_PT + TravelDist_N van de snelste optie)
#   Price_median                       prijs in euro van de snelste optie
#   NrMoments                          het aantal vertrekmomenten met een optie
# UpdateAll.cmd output ruimt het bestand op met de andere tt_*.csv in de uitvoermap. Bestaat het al, dan stopt het script, tenzij
# --force.
import argparse, glob, os, re, sys, tempfile, shutil
from collections import defaultdict
from multiprocessing import Pool

NAME_RE = re.compile(r'tt_(\d{8})_(\d\dh\d\dm)_(\d+)of(\d+)\.csv$')


def num(s):
	return float(s) if s != '' else 0.0


def median(v):
	v = sorted(v)
	n = len(v)
	return v[n // 2] if n % 2 else (v[n // 2 - 1] + v[n // 2]) / 2


def blok(args):
	"""De mediaan per HB-paar van een herkomstblok, naar een tijdelijk bestand; geeft (blok, bestand, paren) terug."""
	nr, files, modes, tmpdir = args
	best = defaultdict(dict)  # (org, dest) -> moment -> (tijd, prijs, afstand)
	for p in files:
		m = NAME_RE.search(os.path.basename(p)).group(2)
		with open(p, encoding='utf-8') as fh:
			h = fh.readline().rstrip('\r\n').split(';')
			it, ip, im = h.index('Traveltime_' + m), h.index('Price_' + m), h.index('ModeUsed_' + m)
			idist = [h.index(c + '_' + m) for c in ('TravelDist_V', 'TravelDist_PT', 'TravelDist_N') if c + '_' + m in h]
			for line in fh:
				row = line.rstrip('\r\n').split(';')
				if len(row) < len(h) or row[it] == '':
					continue
				if modes and row[im] not in modes:
					continue
				t, pr = float(row[it]), num(row[ip])
				od = (row[0], row[1])
				cur = best[od].get(m)
				if cur is None or t < cur[0] or (t == cur[0] and pr < cur[1]):
					best[od][m] = (t, pr, sum(num(row[i]) for i in idist))
	out = os.path.join(tmpdir, '%04d.csv' % nr)
	with open(out, 'w', encoding='utf-8', newline='') as fo:
		for (o, d), per in best.items():
			ts = [x[0] for x in per.values()]
			fo.write('%s;%s;%.2f;%.2f;%.2f;%d;%.2f;%d\n' % (o, d, median(ts), min(ts), max(ts),
				round(median([x[2] for x in per.values()])), median([x[1] for x in per.values()]), len(per)))
	return nr, out, len(best)


def main():
	ap = argparse.ArgumentParser(description=__doc__)
	ap.add_argument('outdir')
	ap.add_argument('--modes', default='', help='alleen deze ModeUsed, kommagescheiden (bijv. AA)')
	ap.add_argument('--blocks', default='', help='alleen deze blokken, bijv. 1-20 (om te testen)')
	ap.add_argument('--workers', type=int, default=max(1, (os.cpu_count() or 2) - 2))
	ap.add_argument('--force', action='store_true')
	a = ap.parse_args()

	perblock = defaultdict(list)
	date = None
	for p in glob.glob(os.path.join(a.outdir, 'PerBlock', 'tt_*.csv')):
		mm = NAME_RE.search(os.path.basename(p))
		if mm:
			date = mm.group(1)
			perblock[int(mm.group(3))].append(p)
	if not perblock:
		sys.exit('geen tt_<datum>_<moment>_<n>of<N>.csv in %s\\PerBlock' % a.outdir)
	if a.blocks:
		lo, _, hi = a.blocks.partition('-')
		keep = set(range(int(lo), int(hi or lo) + 1))
		perblock = {k: v for k, v in perblock.items() if k in keep}
	target = os.path.join(a.outdir, 'tt_%s_mediaan.csv' % date)
	if os.path.exists(target) and not a.force:
		sys.exit('%s bestaat al; gebruik --force om hem te overschrijven' % target)
	modes = set(x for x in a.modes.split(',') if x)
	tmpdir = tempfile.mkdtemp(prefix='mediaan_', dir=a.outdir)
	try:
		jobs = [(k, sorted(perblock[k]), modes, tmpdir) for k in sorted(perblock)]
		with Pool(a.workers) as pool:
			done = sorted(pool.imap_unordered(blok, jobs))
		with open(target + '.tmp', 'w', encoding='utf-8', newline='') as fo:
			fo.write('OrgName;DestName;Traveltime_median;Traveltime_min;Traveltime_max;TravelDist_median;Price_median;NrMoments\n')
			for _, f, _ in done:
				with open(f, encoding='utf-8') as fi:
					shutil.copyfileobj(fi, fo, 1 << 24)
		os.replace(target + '.tmp', target)
	finally:
		shutil.rmtree(tmpdir, ignore_errors=True)
	nf = sum(len(v) for v in perblock.values())
	print('%d bestanden, %d blokken, %d HB-paren%s -> %s' % (nf, len(perblock), sum(x[2] for x in done),
		(', modes ' + ','.join(sorted(modes))) if modes else '', target))


if __name__ == '__main__':
	main()
