# ReportUpdateAll.py [--localdata <folder>] [step ...]
#
# Overview per step of batch\UpdateAll.cmd: start, end, duration, size of the result, peak memory and errors.
# Reads batch\log\UpdateAll_<step>.log (only the last session, because GeoDmsRun appends to a log) and looks at
# the cache or the output files on disk. Without steps: the four car caches, the chain cache and the output.
#
#   step        car_<moment>, chains_precheck, chains, output, osm_network, gtfs, ... (see UpdateAll.cmd)
#   --localdata the LocalDataProjDir of the model (default: C:\LocalData\NetworkModel_PBL, or NM_PBL_LOCALDATA)
#
# Columns: min = duration of the GeoDmsRun call; rows = "Filling all ... resulted in N pareto od-pairs" of the last
# pareto matrix (car caches), or the number of origin blocks reported as finished (output); commit MB = "Highest CommitCharge"
# and live MB = "PeakLiveLarge" from the memory summary at the end of the log; cache MB = the cache or the csv files.
import re, os, glob, sys, datetime

HERE = os.path.dirname(os.path.abspath(__file__))
LOG = os.path.join(HERE, "log")
args = sys.argv[1:]
LOCAL = os.environ.get("NM_PBL_LOCALDATA", r"C:\LocalData\NetworkModel_PBL")
if "--localdata" in args:
    i = args.index("--localdata"); LOCAL = args[i + 1]; del args[i:i + 2]
CACHES = os.path.join(LOCAL, "IntermediateResults")
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
    # The missing population grid (SourceData/Locaties/Inwoners, cbs_vk100_<year>.gpkg) reports an error in every run but
    # does not affect the caches; those lines do not count as errors.
    errs = [l for l in s.splitlines() if "[E]" in l and not any(x in l for x in ("Inwoners", "aantal_inwoners", "cbs_vk100"))]
    r["errors"] = len(errs); r["first_error"] = errs[0][:200] if errs else None
    m = re.search(r"GeoDmsRun failed with code (\d+)", s); r["failed"] = m.group(1) if m else None
    # The caches are PT_Chains_<date>_<window>_<hash> (a folder with a cache per block, #118) and
    # DirectCar_<network>_<moment>_<origin>_<destination>_<hash>.mmd (the network as in TT2025-12), each with its signature
    # in signature.txt in the folder.
    pat = "PT_Chains_*" if step == "chains" else ("DirectCar_*%s_*.mmd" % step.split("_", 1)[1] if step.startswith("car_") else None)
    caches = sorted([d for d in glob.glob(os.path.join(CACHES, pat)) if os.path.isdir(d)], key=os.path.getmtime) if pat else []
    if caches:
        d = caches[-1]
        r["cache"] = os.path.basename(d)
        r["cache_mb"] = sum(os.path.getsize(os.path.join(w, f)) for w, _, fs in os.walk(d) for f in fs) / 1e6
        r["cache_time"] = datetime.datetime.fromtimestamp(os.path.getmtime(d)).strftime(TS)
    if step == "output" and r["start"]:
        t0 = datetime.datetime.strptime(r["start"], TS).timestamp()
        # The output folder (Output/<date>_<label>, #118) is in batch\log\output_dir.txt, which UpdateAll.cmd output writes.
        od = os.path.join(LOG, "output_dir.txt")
        outdir = open(od).read().strip() if os.path.exists(od) else os.path.join(LOCAL, "Output", "*")
        csv = [f for f in glob.glob(os.path.join(outdir, "PerBlock", "*.csv")) if os.path.getmtime(f) >= t0]
        r["cache"] = "%d csv files in %s since the start" % (len(csv), os.path.join(outdir, "PerBlock"))
        r["cache_mb"] = sum(os.path.getsize(f) for f in csv) / 1e6
        r["cache_time"] = datetime.datetime.fromtimestamp(max(os.path.getmtime(f) for f in csv)).strftime(TS) if csv else "-"
        r["rows"] = "%d blocks" % len(re.findall(r"Results for all departure times in Block_\d+of\d+ are finished", s))
    return r

def fmt(v, f="%s"):
    return "-" if v is None else (f % v)

print("%-20s %-19s %-19s %8s %14s %10s %10s %10s %8s" % ("step", "start", "end", "min", "rows", "commit MB", "live MB", "cache MB", "errors"))
for st in steps:
    r = parse(st)
    if r is None:
        print("%-20s (no log)" % st)
        continue
    print("%-20s %-19s %-19s %8s %14s %10s %10s %10s %8s" % (st, fmt(r["start"]), fmt(r["end"]), fmt(r.get("dur_min"), "%.1f"), fmt(r["rows"]),
          fmt(r["commit_mb"]), fmt(r["live_mb"]), fmt(r.get("cache_mb"), "%.0f"), r["errors"]))
    if r.get("count_first"):
        print("%-20s   counting pass %s .. %s, filling pass until %s" % ("", r["count_first"], fmt(r["count_last"]), fmt(r["fill_last"])))
    if r.get("cache"):
        print("%-20s   %s (%s)" % ("", r["cache"], r["cache_time"]))
    if r["failed"] or r["first_error"]:
        print("%-20s   ERROR exit %s: %s" % ("", r["failed"], r["first_error"]))
