# Vergelijk de OV-uitvoer van twee runs per HB-paar: de consistentiechecks van ObjectVision/NetworkModel_PBL#53.
#
#   python batch\ValidateFronts.py --a "<glob run A>" --b "<glob run B>" [--blocks 1-10] [--moments 07h00m,07h15m]
#                                  [--eps-time 1.0] [--eps-price 0.10] [--md rapport.md]
#
# A is de referentie (bijv. MinimiseCriteria 'Time', het oude model), B de nieuwe opzet (bijv. 'Price,Time'). Invoer: de
# csv's per herkomstblok en vertrekmoment, gekoppeld op (datum, vertrekmoment, blok): sinds 2026-10-03 (#118)
# Output/<datum>_<label>/PerBlock/tt_<datum>_<hhmm>_<i>of<n>.csv, met de parameters in signature.txt in Output/<datum>_<label>;
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
import argparse, csv, glob, os, re, sys
from collections import defaultdict

NAME_RE = re.compile(r'tt_(\d{8})_(\d\dh\d\dm)_(\d+)of(\d+)\.csv$', re.I)
OLD_NAME_RE = re.compile(r'tt_(\d{8})_(\d\dh\d\dm)_ORG-.*?Block_(\d+)of(\d+)(_.*)\.csv$', re.I)
MINCRIT_RE = re.compile(r'MinCrit-([A-Za-z_]+?)_MaxPT', re.I)

def index_files(pattern, blocks, moments):
	out = {}
	for p in glob.glob(pattern):
		m = NAME_RE.search(os.path.basename(p)) or OLD_NAME_RE.search(os.path.basename(p))
		if not m:
			continue
		date, moment, blk = m.group(1), m.group(2), int(m.group(3))
		if blocks and blk not in blocks:
			continue
		if moments and moment not in moments:
			continue
		out[(date, moment, blk)] = p
	return out

def mincrit(paths):
	"""De criteria van de run: uit signature.txt in de uitvoermap (boven PerBlock), of uit de oude bestandsnaam."""
	for p in paths:
		sig = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(p))), 'signature.txt')
		text = open(sig, encoding='utf-8').read() if os.path.exists(sig) else os.path.basename(p)
		m = MINCRIT_RE.search(text)
		if m:
			return m.group(1).split('_')
	return []

def is_pt(mode):
	return mode.count('_') >= 2

def to_float(s):
	if s is None or s == '' or s == 'null':
		return None
	return float(s.replace(',', '.'))

def read_rows(path, moment):
	"""Per HB-paar de rijen (tijd, prijs, auto, fiets, ModeUsed)."""
	per = defaultdict(list)
	with open(path, newline='', encoding='utf-8') as f:
		rd = csv.reader(f, delimiter=';')
		hdr = next(rd)
		ix = {h: i for i, h in enumerate(hdr)}
		ct = ix.get('Traveltime_' + moment)
		cp = ix.get('Price_' + moment)
		cm = ix.get('ModeUsed_' + moment)
		cc = ix.get('NeedsCar_' + moment)
		cb = ix.get('NeedsBike_' + moment)
		if ct is None or cm is None:
			raise ValueError(f'{path}: geen Traveltime_{moment} of ModeUsed_{moment}')
		for r in rd:
			if not r:
				continue
			mode = r[cm]
			car = (r[cc] == '1') if cc is not None else (mode == 'AA')
			bike = (r[cb] == '1') if cb is not None else None
			per[(r[0], r[1])].append((to_float(r[ct]), to_float(r[cp]) if cp is not None else None, car, bike, mode))
	return per, cp is not None

def stats(rows):
	"""Kortste tijd, prijs daarbij, laagste prijs, tijd daarbij."""
	rows = [x for x in rows if x[0] is not None]
	if not rows:
		return None
	tmin = min(x[0] for x in rows)
	at_tmin = [x[1] for x in rows if x[0] == tmin and x[1] is not None]
	c_tmin = min(at_tmin) if at_tmin else None
	priced = [x for x in rows if x[1] is not None]
	if priced:
		cmin = min(x[1] for x in priced)
		t_cmin = min(x[0] for x in priced if x[1] == cmin)
	else:
		cmin = t_cmin = None
	return tmin, c_tmin, cmin, t_cmin

def dominated(rows, use_price, use_car, use_bike, eps_t, eps_p):
	"""Aantal rijen dat strikt, en voorbij de epsilons, door een andere rij wordt gedomineerd."""
	strict = beyond = 0
	worst = None
	for i, r in enumerate(rows):
		for j, s in enumerate(rows):
			if i == j:
				continue
			le = s[0] <= r[0]
			lt = s[0] < r[0]
			gap_t = r[0] - s[0]
			gap_p = 0.0
			if use_price:
				if s[1] is None or r[1] is None:
					continue
				le = le and s[1] <= r[1]
				lt = lt or s[1] < r[1]
				gap_p = r[1] - s[1]
			if use_car:
				le = le and (s[2] <= r[2])
				lt = lt or (s[2] < r[2])
			if use_bike and r[3] is not None and s[3] is not None:
				le = le and (s[3] <= r[3])
				lt = lt or (s[3] < r[3])
			if le and lt:
				strict += 1
				if gap_t > eps_t or gap_p > eps_p:
					beyond += 1
					if worst is None or (gap_t, gap_p) > (worst[0], worst[1]):
						worst = (gap_t, gap_p, r, s)
				break
	return strict, beyond, worst

class Tally:
	def __init__(self):
		self.n = defaultdict(int)
		self.examples = defaultdict(list)
	def add(self, key, ex=None, score=0.0):
		self.n[key] += 1
		if ex is not None:
			lst = self.examples[key]
			lst.append((score, ex))
			if len(lst) > 200:
				lst.sort(key=lambda x: -x[0]); del lst[20:]

def parse_blocks(s):
	if not s:
		return None
	out = set()
	for part in s.split(','):
		if '-' in part:
			a, b = part.split('-'); out.update(range(int(a), int(b) + 1))
		else:
			out.add(int(part))
	return out

def main():
	ap = argparse.ArgumentParser()
	ap.add_argument('--a', required=True, help='glob van de csv-bestanden van run A (referentie)')
	ap.add_argument('--b', required=True, help='glob van de csv-bestanden van run B')
	ap.add_argument('--blocks', help='herkomstblokken, bijv. 1-10 of 1,5,9')
	ap.add_argument('--moments', help='vertrekmomenten, bijv. 07h00m,07h15m')
	ap.add_argument('--eps-time', type=float, default=1.0, help='tolerantie reistijd in minuten (standaard 1, ChainParetoTimeEpsilon)')
	ap.add_argument('--eps-price', type=float, default=0.10, help='tolerantie prijs in euro (standaard 0,10, ChainParetoPriceEpsilon)')
	ap.add_argument('--md', help='schrijf het verslag ook naar dit markdown-bestand')
	args = ap.parse_args()

	blocks = parse_blocks(args.blocks)
	moments = set(args.moments.split(',')) if args.moments else None
	fa = index_files(args.a, blocks, moments)
	fb = index_files(args.b, blocks, moments)
	keys = sorted(set(fa) & set(fb))
	if not keys:
		sys.exit(f'geen gekoppelde bestanden: A {len(fa)}, B {len(fb)}')
	crit_a = mincrit(fa.values())
	crit_b = mincrit(fb.values())
	use_car, use_bike = 'A' in crit_b, 'C' in crit_b

	# Per groep: (sleutel, titel, filter op een rij (tijd, prijs, auto, fiets, ModeUsed)).
	scopes = [('alle', 'Alle opties', None), ('ov', 'Alleen OV-ketens', lambda x: is_pt(x[4]))]
	car_groups = use_car and 'A' in crit_a
	bike_groups = use_bike and 'C' in crit_a
	if car_groups:
		scopes.append(('zonder auto', 'Reizigers zonder auto (NeedsCar 0)', lambda x: not x[2]))
	if bike_groups:
		scopes.append(('zonder fiets', 'Reizigers zonder fiets (NeedsBike 0)', lambda x: x[3] is False))
	if car_groups and bike_groups:
		scopes.append(('zonder auto en fiets', 'Reizigers zonder auto en fiets', lambda x: not x[2] and x[3] is False))

	T = {s[0]: Tally() for s in scopes}
	has_price_a = has_price_b = True
	pairs = 0
	for k in keys:
		date, moment, blk = k
		ra, pa = read_rows(fa[k], moment)
		rb, pb = read_rows(fb[k], moment)
		has_price_a &= pa; has_price_b &= pb
		for od in set(ra) | set(rb):
			pairs += 1
			for scope, _, flt in scopes:
				rows_a = [x for x in ra.get(od, []) if flt is None or flt(x)]
				rows_b = [x for x in rb.get(od, []) if flt is None or flt(x)]
				t = T[scope]
				sa, sb = stats(rows_a), stats(rows_b)
				if sa is None and sb is None:
					continue
				where = f'{date} {moment} blok {blk} {od[0]} -> {od[1]}'
				if sa is None:
					t.add('6 alleen in B', where); continue
				if sb is None:
					t.add('6 alleen in A', where); continue
				t.add('paren')
				dt = sb[0] - sa[0]
				if abs(dt) <= args.eps_time:
					t.add('1 kortste tijd gelijk')
				elif dt > 0:
					t.add('1 B trager', f'{where}: A {sa[0]:.1f} min, B {sb[0]:.1f} min', dt)
				else:
					t.add('1 B sneller', f'{where}: A {sa[0]:.1f} min, B {sb[0]:.1f} min', -dt)
				if pa and pb and sa[1] is not None and sb[1] is not None:
					if sb[1] <= sa[1] + args.eps_price:
						t.add('2 prijs bij kortste tijd ok')
					else:
						t.add('2 prijs bij kortste tijd B hoger', f'{where}: A {sa[1]:.2f}, B {sb[1]:.2f}', sb[1] - sa[1])
				if pb:
					if sb[2] is None or sb[3] is None or sb[1] is None:
						t.add('3/4 ontbrekende prijs in B', where)
					else:
						if not (sb[0] <= sb[3]): t.add('3 geschonden', where)
						if not (sb[1] >= sb[2]): t.add('4 geschonden', where)
				# Zonder prijs is het front niet te toetsen: opties met verschillende prijs lijken dan gedomineerd op tijd.
				if scope == 'alle' and pb:
					strict, beyond, worst = dominated(rows_b, pb, use_car, use_bike, args.eps_time, args.eps_price)
					if strict:
						t.add('5 paren met gedomineerde rijen in B (strikt)')
						t.n['5 gedomineerde rijen in B (strikt)'] += strict
					if beyond:
						r, s = worst[2], worst[3]
						t.add('5 paren met gedomineerde rijen in B (voorbij epsilon)', f'{where}: {r[4]} {r[0]:.1f} min {r[1]} door {s[4]} {s[0]:.1f} min {s[1]}', worst[0] + worst[1])
						t.n['5 gedomineerde rijen in B (voorbij epsilon)'] += beyond

	lines = []
	lines.append(f'# Front-validatie (#53)\n')
	lines.append(f'- A: `{args.a}` ({len(fa)} bestanden), B: `{args.b}` ({len(fb)} bestanden), gekoppeld: {len(keys)}')
	lines.append(f'- MinCrit A: {"_".join(crit_a) or "?"}, B: {"_".join(crit_b) or "?"}; frontcheck op reistijd' + (', prijs' if has_price_b else '') + (', NeedsCar' if use_car else '') + (', NeedsBike' if use_bike else ''))
	lines.append(f'- prijs in A: {"ja" if has_price_a else "nee"}, in B: {"ja" if has_price_b else "nee"}; eps-time {args.eps_time} min, eps-price {args.eps_price} euro')
	lines.append(f'- HB-paren x vertrekmoment: {pairs}\n')
	for scope, title, _ in scopes:
		t = T[scope]
		lines.append(f'## {title}\n')
		lines.append('| check | aantal |')
		lines.append('|---|---|')
		for key in sorted(t.n):
			lines.append(f'| {key} | {t.n[key]} |')
		for key in sorted(t.examples):
			ex = sorted(t.examples[key], key=lambda x: -x[0])[:20]
			if ex:
				lines.append(f'\n### {key}: grootste gevallen\n')
				for score, e in ex:
					lines.append(f'- {e}')
		lines.append('')
	text = '\n'.join(lines)
	print(text)
	if args.md:
		with open(args.md, 'w', encoding='utf-8') as f:
			f.write(text)

if __name__ == '__main__':
	main()
