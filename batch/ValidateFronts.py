# Compares the public transport output of two runs per OD pair: the consistency checks of ObjectVision/NetworkModel_PBL#53.
#
#   python batch\ValidateFronts.py --a "<glob run A>" --b "<glob run B>" [--blocks 1-10] [--moments 07h00m,07h15m]
#                                  [--eps-time 1.0] [--eps-price 0.10] [--md report.md]
#
# A is the reference (for example MinimiseCriteria 'Time', the old model), B the new set-up (for example 'Price,Time').
# Input: the csv files per origin block and departure moment, matched on (departure moment, block):
# Output/<date>_<label>/PerBlock/tt_<hhmm>_<i>of<n>.csv with the parameters in signature.txt in Output/<date>_<label>
# (#118; older output has tt_<date>_<hhmm>_<i>of<n>.csv), or the oldest form
# Output/PerBlock/tt_<date>_<hhmm>_ORG-...-Block_<i>of<n>_...csv with the parameters in the name. All of these are read.
# Columns by name: OrgName, DestName, Traveltime_<t> (min), Price_<t> (euro, only with Export_PriceInformation),
# ModeUsed_<t>, NeedsCar_<t> and NeedsBike_<t>.
#
# Checks per OD pair and departure moment, over all options and separately over public transport chains only (ModeUsed V_PT_N):
#   1. shortest travel time B = shortest travel time A, within --eps-time minutes;
#   2. price at the shortest travel time B <= that at the shortest travel time A (+ --eps-price). Equality cannot be
#      required: a run on time only picks an arbitrary price among equal travel times;
#   3. shortest travel time B <= travel time at the lowest price B, and 4. price at the shortest travel time B >= lowest
#      price B. Both hold by definition; a violation points to missing or unreadable values;
#   5. the front of B: no row is dominated by another row of the same pair on travel time, price and the ownership
#      criteria that the signature (or the old file name) of B names (MinCrit-..._A = NeedsCar, _C = NeedsBike). Counted
#      strictly and beyond the epsilons (better by more than --eps-time or --eps-price);
#   6. reachability: pairs that occur only in A or only in B.
# The price checks drop out when a run has no Price column.
# When A and B both name car ownership (_A) or bike ownership (_C), checks 1, 2 and 6 also apply per group of travellers:
# without a car (NeedsCar 0), without a bike (NeedsBike 0) and without both. A bool criterion has no epsilon, so the
# fastest option of such a group in A must come back in B; "6 only in A" is an error there. Without ownership criteria in
# A the fastest option per group is not known: A then gives only the fastest option overall, usually the car.
import argparse, csv, glob, os, re, sys
from collections import defaultdict

NAME_RE = re.compile(r'tt_(?:(\d{8})_)?(?:[A-Za-z][A-Za-z0-9_]*?_)?(\d\dh\d\dm)_(\d+)of(\d+)\.csv$', re.I)  # names without the date; also reads names with the date, and with the component after the date
OLD_NAME_RE = re.compile(r'tt_(\d{8})_(\d\dh\d\dm)_ORG-.*?Block_(\d+)of(\d+)(_.*)\.csv$', re.I)
MINCRIT_RE = re.compile(r'MinCrit-([A-Za-z_]+?)_MaxPT', re.I)

def index_files(pattern, blocks, moments):
	out = {}
	for p in glob.glob(pattern):
		m = NAME_RE.search(os.path.basename(p)) or OLD_NAME_RE.search(os.path.basename(p))
		if not m:
			continue
		moment, blk = m.group(2), int(m.group(3))
		if blocks and blk not in blocks:
			continue
		if moments and moment not in moments:
			continue
		out[(moment, blk)] = p  # without the date, which is only in the name of the output folder
	return out

def mincrit(paths):
	"""The criteria of the run: from signature.txt in the output folder (above PerBlock), or from the old file name."""
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
	"""The rows per OD pair (time, price, car, bike, ModeUsed)."""
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
			raise ValueError(f'{path}: no Traveltime_{moment} or ModeUsed_{moment}')
		for r in rd:
			if not r:
				continue
			mode = r[cm]
			car = (r[cc] == '1') if cc is not None else (mode == 'AA')
			bike = (r[cb] == '1') if cb is not None else None
			per[(r[0], r[1])].append((to_float(r[ct]), to_float(r[cp]) if cp is not None else None, car, bike, mode))
	return per, cp is not None

def stats(rows):
	"""Shortest time, the price at that time, lowest price, the time at that price."""
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
	"""Number of rows dominated by another row, strictly and beyond the epsilons, and the worst case."""
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
	ap.add_argument('--a', required=True, help='glob of the csv files of run A (reference)')
	ap.add_argument('--b', required=True, help='glob of the csv files of run B')
	ap.add_argument('--blocks', help='origin blocks, for example 1-10 or 1,5,9')
	ap.add_argument('--moments', help='departure moments, for example 07h00m,07h15m')
	ap.add_argument('--eps-time', type=float, default=1.0, help='tolerance on the travel time in minutes (default 1)')
	ap.add_argument('--eps-price', type=float, default=0.10, help='tolerance on the price in euro (default 0.10)')
	ap.add_argument('--md', help='also write the report to this markdown file')
	args = ap.parse_args()

	blocks = parse_blocks(args.blocks)
	moments = set(args.moments.split(',')) if args.moments else None
	fa = index_files(args.a, blocks, moments)
	fb = index_files(args.b, blocks, moments)
	keys = sorted(set(fa) & set(fb))
	if not keys:
		sys.exit(f'no matched files: A {len(fa)}, B {len(fb)}')
	crit_a = mincrit(fa.values())
	crit_b = mincrit(fb.values())
	use_car, use_bike = 'A' in crit_b, 'C' in crit_b

	# Per group: (key, title, filter on a row (time, price, car, bike, ModeUsed)).
	scopes = [('alle', 'All options', None), ('ov', 'Public transport chains only', lambda x: is_pt(x[4]))]
	car_groups = use_car and 'A' in crit_a
	bike_groups = use_bike and 'C' in crit_a
	if car_groups:
		scopes.append(('zonder auto', 'Travellers without a car (NeedsCar 0)', lambda x: not x[2]))
	if bike_groups:
		scopes.append(('zonder fiets', 'Travellers without a bike (NeedsBike 0)', lambda x: x[3] is False))
	if car_groups and bike_groups:
		scopes.append(('zonder auto en fiets', 'Travellers without a car and without a bike', lambda x: not x[2] and x[3] is False))

	T = {s[0]: Tally() for s in scopes}
	has_price_a = has_price_b = True
	pairs = 0
	for k in keys:
		moment, blk = k
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
				where = f'{moment} block {blk} {od[0]} -> {od[1]}'
				if sa is None:
					t.add('6 only in B', where); continue
				if sb is None:
					t.add('6 only in A', where); continue
				t.add('pairs')
				dt = sb[0] - sa[0]
				if abs(dt) <= args.eps_time:
					t.add('1 shortest time equal')
				elif dt > 0:
					t.add('1 B slower', f'{where}: A {sa[0]:.1f} min, B {sb[0]:.1f} min', dt)
				else:
					t.add('1 B faster', f'{where}: A {sa[0]:.1f} min, B {sb[0]:.1f} min', -dt)
				if pa and pb and sa[1] is not None and sb[1] is not None:
					if sb[1] <= sa[1] + args.eps_price:
						t.add('2 price at shortest time ok')
					else:
						t.add('2 price at shortest time B higher', f'{where}: A {sa[1]:.2f}, B {sb[1]:.2f}', sb[1] - sa[1])
				if pb:
					if sb[2] is None or sb[3] is None or sb[1] is None:
						t.add('3/4 missing price in B', where)
					else:
						if not (sb[0] <= sb[3]): t.add('3 violated', where)
						if not (sb[1] >= sb[2]): t.add('4 violated', where)
				# Without a price the front cannot be tested: options with different prices then look dominated on time.
				if scope == 'alle' and pb:
					strict, beyond, worst = dominated(rows_b, pb, use_car, use_bike, args.eps_time, args.eps_price)
					if strict:
						t.add('5 pairs with dominated rows in B (strict)')
						t.n['5 dominated rows in B (strict)'] += strict
					if beyond:
						r, s = worst[2], worst[3]
						t.add('5 pairs with dominated rows in B (beyond epsilon)', f'{where}: {r[4]} {r[0]:.1f} min {r[1]} by {s[4]} {s[0]:.1f} min {s[1]}', worst[0] + worst[1])
						t.n['5 dominated rows in B (beyond epsilon)'] += beyond

	lines = []
	lines.append(f'# Front-Validation (#53)\n')
	lines.append(f'- A: `{args.a}` ({len(fa)} files), B: `{args.b}` ({len(fb)} files), matched: {len(keys)}')
	lines.append(f'- MinCrit A: {"_".join(crit_a) or "?"}, B: {"_".join(crit_b) or "?"}; front check on travel time' + (', price' if has_price_b else '') + (', NeedsCar' if use_car else '') + (', NeedsBike' if use_bike else ''))
	lines.append(f'- price in A: {"yes" if has_price_a else "no"}, in B: {"yes" if has_price_b else "no"}; eps-time {args.eps_time} min, eps-price {args.eps_price} euro')
	lines.append(f'- OD pairs x departure moment: {pairs}\n')
	for scope, title, _ in scopes:
		t = T[scope]
		lines.append(f'## {title}\n')
		lines.append('| check | count |')
		lines.append('|---|---|')
		for key in sorted(t.n):
			lines.append(f'| {key} | {t.n[key]} |')
		for key in sorted(t.examples):
			ex = sorted(t.examples[key], key=lambda x: -x[0])[:20]
			if ex:
				lines.append(f'\n### {key}: largest cases\n')
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
