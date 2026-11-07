"""Compare the options of an OD pair between two output folders of one component (skill od-paar-beelden), for instance before and after a
change: per departure moment the travel time, the price and ModeUsed of each option, and its public transport legs with their price.
Options are matched on their legs (line, agency, stops, departure). Reads the gpkg files read-only (immutable), so it leaves no lock files.

    python -I od_compare.py <Output_<O>_<D>\\<date>_od_<comp>_<hash> before> <... after>
"""
import glob
import os
import sqlite3
import sys


def read(folder, moment):
    path = os.path.join(folder, 'PerBlock', f'od_{moment}.gpkg').replace('\\', '/')
    con = sqlite3.connect('file:' + path + '?mode=ro&immutable=1', uri=True)
    opts = {r[0]: r[1:] for r in con.execute('select Optie, Reistijd, Prijs, ModeUsed from od_opties')}
    legs = {}
    for o, soort, mod, lijn, verv, van, naar, vert, prijs in con.execute(
            'select Optie, Soort, Modaliteit, lijn, Vervoerder, van, naar, vertrek, Prijs from od_onderdelen order by Optie, VolgNr'):
        if soort == 'OV':
            legs.setdefault(o, []).append((f'{mod} {lijn} ({verv}) {van} {vert} -> {naar}', prijs))
    return opts, legs


def journey(legs):
    return ' | '.join(text for text, _ in legs)


before_dir, after_dir = sys.argv[1], sys.argv[2]
moments = sorted(os.path.basename(p)[3:-5] for p in glob.glob(os.path.join(after_dir, 'PerBlock', 'od_*.gpkg')))
for m in moments:
    b_opts, b_rides = read(before_dir, m)
    a_opts, a_rides = read(after_dir, m)
    print(f'=== {m}: {len(b_opts)} options before, {len(a_opts)} after')
    b_key = {journey(v): k for k, v in b_rides.items()}
    a_key = {journey(v): k for k, v in a_rides.items()}
    for key in sorted(set(b_key) | set(a_key), key=lambda j: a_opts.get(a_key.get(j), b_opts.get(b_key.get(j)))[0]):
        bi, ai = b_key.get(key), a_key.get(key)
        bt = f'{b_opts[bi][0]:.1f} min {b_opts[bi][1]:.2f}' if bi else '-'
        at = f'{a_opts[ai][0]:.1f} min {a_opts[ai][1]:.2f}' if ai else '-'
        print(f'  before {bt:>18} | after {at:>18} | {(a_opts[ai] if ai else b_opts[bi])[2]}')
        for text, prijs in (a_rides.get(ai) or b_rides.get(bi)):
            print(f'        {text} {prijs:.2f}')
