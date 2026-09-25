# ReportUpdateAll.py [--localdata <map>] [stap ...]
#
# Overzicht per stap van batch\UpdateAll.cmd: begin, einde, duur, omvang van het resultaat, piekgeheugen en fouten.
# Leest batch\log\UpdateAll_<stap>.log (alleen de laatste sessie, want GeoDmsRun voegt aan een log toe) en kijkt naar
# de store of de uitvoerbestanden op schijf. Zonder stappen: de vier autostores, de ketenstore en de uitvoer.
#
#   stap        car_<moment>, chains_precheck, chains, output, osm_network, tomtom_roads, ... (zie UpdateAll.cmd)
#   --localdata de LocalDataProjDir van het model (default: C:\LocalData\NetworkModel_PBL, of NM_PBL_LOCALDATA)
#
# Kolommen: min = duur van de GeoDmsRun-aanroep; rijen = "Filling all ... resulted in N pareto od-pairs" van de laatste
# pareto-matrix (autostores), of het aantal klaar gemelde herkomstblokken (uitvoer); commit MB = "Highest CommitCharge"
# en live MB = "PeakLiveLarge" uit de geheugensamenvatting aan het eind van het log; store MB = de store of de csv's.
import re, os, glob, sys, datetime

HERE = os.path.dirname(os.path.abspath(__file__))
LOG = os.path.join(HERE, "log")
args = sys.argv[1:]
LOCAL = os.environ.get("NM_PBL_LOCALDATA", r"C:\LocalData\NetworkModel_PBL")
if "--localdata" in args:
    i = args.index("--localdata"); LOCAL = args[i + 1]; del args[i:i + 2]
STORES = os.path.join(LOCAL, "IntermediateResults")
steps = args or ["car_MorningRush", "car_NoonRush", "car_LateEveningRush", "car_Freeflow", "chains_precheck", "chains", "output"]
TS = "%Y-%m-%d %H:%M:%S"

def parse(step):
    p = os.path.join(LOG, "UpdateAll_%s.log" % step)
    if not os.path.exists(p):
        return None
    s = open(p, "rb").read().decode("latin-1")
    starts = [m.start() for m in re.finditer(r"@@@@@ Logging started", s)]
    if starts:
        s = s[starts[-1]:]
    r = {"step": step}
    m = re.search(r"Logging started for .* at (\d{4}-\d\d-\d\d \d\d:\d\d:\d\d)", s); r["start"] = m.group(1) if m else None
    m = re.search(r"Logging ended for .* at (\d{4}-\d\d-\d\d \d\d:\d\d:\d\d)", s); r["end"] = m.group(1) if m else None
    if r["start"] and r["end"]:
        r["dur_min"] = (datetime.datetime.strptime(r["end"], TS) - datetime.datetime.strptime(r["start"], TS)).total_seconds() / 60
    m = re.findall(r"Filling all (\S+) sources: resulted in ([\d,]+) pareto od-pairs", s); r["rows"] = m[-1][1] if m else None
    cnt = re.findall(r"(\d{4}-\d\d-\d\d \d\d:\d\d:\d\d).*impedance_matrix Counting", s)
    fil = re.findall(r"(\d{4}-\d\d-\d\d \d\d:\d\d:\d\d).*impedance_matrix Filling", s)
    r["count_first"] = cnt[0] if cnt else None; r["count_last"] = cnt[-1] if cnt else None; r["fill_last"] = fil[-1] if fil else None
    m = re.search(r"Highest CommitCharge: (\d+)\[MB\]", s); r["commit_mb"] = int(m.group(1)) if m else None
    m = re.search(r"PeakLiveLarge: (\d+)\[MB\]", s); r["live_mb"] = int(m.group(1)) if m else None
    # Het ontbrekende bevolkingsraster (SourceData/Locaties/Inwoners, cbs_vk100_<jaar>.gpkg) meldt zich in elke run maar
    # raakt de stores niet; die regels tellen niet als fout.
    errs = [l for l in s.splitlines() if "[E]" in l and not any(x in l for x in ("Inwoners", "aantal_inwoners", "cbs_vk100"))]
    r["errors"] = len(errs); r["first_error"] = errs[0][:200] if errs else None
    m = re.search(r"GeoDmsRun failed with code (\d+)", s); r["failed"] = m.group(1) if m else None
    pat = "PT_Chains_*.mmd" if step == "chains" else ("DirectCar_%s_*.mmd" % step.split("_", 1)[1] if step.startswith("car_") else None)
    stores = sorted(glob.glob(os.path.join(STORES, pat)), key=os.path.getmtime) if pat else []
    if stores:
        d = stores[-1]
        r["store"] = os.path.basename(d)
        r["store_mb"] = sum(os.path.getsize(os.path.join(d, f)) for f in os.listdir(d)) / 1e6
        r["store_time"] = datetime.datetime.fromtimestamp(os.path.getmtime(d)).strftime(TS)
    if step == "output" and r["start"]:
        t0 = datetime.datetime.strptime(r["start"], TS).timestamp()
        csv = [f for f in glob.glob(os.path.join(LOCAL, "Output", "PerBlock", "*.csv")) if os.path.getmtime(f) >= t0]
        r["store"] = "%d csv-bestanden in Output\\PerBlock sinds de start" % len(csv)
        r["store_mb"] = sum(os.path.getsize(f) for f in csv) / 1e6
        r["store_time"] = datetime.datetime.fromtimestamp(max(os.path.getmtime(f) for f in csv)).strftime(TS) if csv else "-"
        r["rows"] = "%d blokken" % len(re.findall(r"Results for all departure times in Block_\d+of\d+ are finished", s))
    return r

def fmt(v, f="%s"):
    return "-" if v is None else (f % v)

print("%-20s %-19s %-19s %8s %14s %10s %10s %10s %8s" % ("stap", "start", "einde", "min", "rijen", "commit MB", "live MB", "store MB", "fouten"))
for st in steps:
    r = parse(st)
    if r is None:
        print("%-20s (geen log)" % st)
        continue
    print("%-20s %-19s %-19s %8s %14s %10s %10s %10s %8s" % (st, fmt(r["start"]), fmt(r["end"]), fmt(r.get("dur_min"), "%.1f"), fmt(r["rows"]),
          fmt(r["commit_mb"]), fmt(r["live_mb"]), fmt(r.get("store_mb"), "%.0f"), r["errors"]))
    if r.get("count_first"):
        print("%-20s   telpas %s .. %s, vulpas tot %s" % ("", r["count_first"], fmt(r["count_last"]), fmt(r["fill_last"])))
    if r.get("store"):
        print("%-20s   %s (%s)" % ("", r["store"], r["store_time"]))
    if r["failed"] or r["first_error"]:
        print("%-20s   FOUT exit %s: %s" % ("", r["failed"], r["first_error"]))
