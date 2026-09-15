# Vergelijk per OD-paar de keten-uitkomsten van twee meet-armen van #115.
#
#   python batch\CompareParetoChains.py <scalar.csv> <pareto.csv> [--md rapport.md]
#
# Invoer: de csv's die /ParetoBenchmark/ChainSample/Rows per arm schrijft (een rij per
# ketenresultaat na de ketenrijger, met absolute from_code/to_code = c_Time_Stops-codes, die
# over runs heen gelijk zijn -- de uq_c_*_rel-indices zijn dat niet).
#
# Per (from_code, to_code) in beide armen: minimum prijs, minimum reistijd, aantal rijen. Dan
# de vergelijking die het pareto-been moet waarmaken:
#   - de minimum-reistijd per OD-paar hoort GELIJK te zijn (de operator garandeert dat de eerste
#     rij per paar de scalaire min-tijd draagt; de ketenrijger rijgt dezelfde tijden);
#   - de minimum-prijs mag alleen OMLAAG (kortere R-benen bij gelijke tijd zijn goedkoper);
#   - het aantal OD-paren hoort gelijk te zijn (pareto voegt routes toe, geen paren).
# Elke afwijking daarvan is een bevinding, geen ruis, en wordt apart geteld en gestaafd.
import sys, csv, argparse
from collections import defaultdict

def load(path):
    per = {}
    n = 0
    with open(path, newline="", encoding="utf-8") as f:
        rd = csv.DictReader(f)
        cols = {c.lower(): c for c in rd.fieldnames}
        cf, ct, cp, ctt = cols["from_code"], cols["to_code"], cols["price"], cols["traveltime"]
        for r in rd:
            n += 1
            key = (int(r[cf]), int(r[ct]))
            p = float(r[cp]) if r[cp] not in ("", "null") else None
            t = float(r[ctt]) if r[ctt] not in ("", "null") else None
            e = per.get(key)
            if e is None:
                per[key] = [p, t, 1]
            else:
                if p is not None and (e[0] is None or p < e[0]): e[0] = p
                if t is not None and (e[1] is None or t < e[1]): e[1] = t
                e[2] += 1
    return per, n

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("scalar"); ap.add_argument("pareto")
    ap.add_argument("--md", help="schrijf het rapport ook als markdown naar dit bestand")
    a = ap.parse_args()

    S, nS = load(a.scalar)
    P, nP = load(a.pareto)
    keys_S, keys_P = set(S), set(P)
    both = keys_S & keys_P

    price_lower = price_higher = price_equal = 0
    saved_ct = 0.0
    time_lower = time_higher = 0
    only_S, only_P = len(keys_S - keys_P), len(keys_P - keys_S)
    for k in both:
        ps, ts, _ = S[k]; pp, tp, _ = P[k]
        if ps is not None and pp is not None:
            d = pp - ps
            if d < -0.5:   price_lower += 1;  saved_ct += -d
            elif d > 0.5:  price_higher += 1
            else:          price_equal += 1
        if ts is not None and tp is not None:
            if tp < ts - 0.5:   time_lower += 1
            elif tp > ts + 0.5: time_higher += 1

    sum_min_price_S = sum(v[0] for k, v in S.items() if k in both and v[0] is not None)
    sum_min_price_P = sum(v[0] for k, v in P.items() if k in both and v[0] is not None)

    lines = []
    w = lines.append
    w(f"| | scalair | pareto |")
    w(f"|---|---:|---:|")
    w(f"| ketenrijen in de steekproef | {nS:,} | {nP:,} |")
    w(f"| OD-paren | {len(keys_S):,} | {len(keys_P):,} |")
    w(f"| OD-paren in beide armen | {len(both):,} | |")
    w(f"| OD-paren alleen in deze arm | {only_S:,} | {only_P:,} |")
    w(f"| som van de minimumprijs over de gedeelde paren (ct) | {sum_min_price_S:,.0f} | {sum_min_price_P:,.0f} |")
    w("")
    w(f"| per OD-paar, pareto t.o.v. scalair | aantal |")
    w(f"|---|---:|")
    w(f"| minimumprijs LAGER | {price_lower:,} |")
    w(f"| minimumprijs gelijk | {price_equal:,} |")
    w(f"| minimumprijs HOGER (hoort 0) | {price_higher:,} |")
    w(f"| totaal bespaard op de minimumprijs (ct) | {saved_ct:,.0f} |")
    w(f"| minimum-reistijd lager (hoort 0) | {time_lower:,} |")
    w(f"| minimum-reistijd hoger (hoort 0) | {time_higher:,} |")
    txt = "\n".join(lines)
    print(txt)
    if a.md:
        open(a.md, "w", encoding="utf-8").write(txt + "\n")

if __name__ == "__main__":
    main()
