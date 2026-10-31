# ReportUpdateAll.py [--localdata <folder>] [--since "yyyy-mm-dd hh:mm"] [step ...]
#
# Overview per step of batch\UpdateAll.cmd: start, end, duration, size of the result, peak memory and errors.
# Reads batch\log\UpdateAll_<step>.log and looks at the cache or the output files on disk. A step of a component has the
# component in its name, UpdateAll_<step>_<component>.log (#117). GeoDmsRun appends to a log, so a step reads only its last
# session; the output of a component reads every portion since its list of blocks (WriteOutputBlocks.ps1).
# Without steps: the steps of the last run in batch\log\UpdateAll_status.txt, in the order in which their logs were last
# written. Those are the logs written since it started, and the logs of the components and car moments that the run
# skipped because their output or cache was already there.
#
#   step        car_<moment>, chains_precheck, chains, legs, output, with _<component> after it, or osm_network, gtfs,
#               checks, ... (see UpdateAll.cmd)
#   --since     the logs written since this moment instead, for a run that was stopped and started again (the status file
#               then begins at the restart)
#   --localdata the LocalDataProjDir of the model (default: NM_PBL_LOCALDATA, else localDataProjDir in the machine-local
#               cfg\main\config.ini, else C:\LocalData\NetworkModel_PBL)
#
# Columns: min = duration of the GeoDmsRun calls; rows = "Filling all ... resulted in N pareto od-pairs" of the last
# pareto matrix (car caches), or the number of origin blocks reported as finished (output); commit MB = "Highest CommitCharge"
# and live MB = "PeakLiveLarge" from the memory summary at the end of the log, the highest over the calls; cache MB = the
# cache or the output files.
import re, os, glob, sys, datetime, configparser

HERE = os.path.dirname(os.path.abspath(__file__))
LOG = os.path.join(HERE, "log")
STATUS = os.path.join(LOG, "UpdateAll_status.txt")
CFGINI = os.path.join(HERE, "..", "cfg", "main", "config.ini")
TS = "%Y-%m-%d %H:%M:%S"
args = sys.argv[1:]

def option(name):
    if name not in args:
        return None
    i = args.index(name); v = args[i + 1]; del args[i:i + 2]
    return v

LOCAL = option("--localdata") or os.environ.get("NM_PBL_LOCALDATA")
if not LOCAL and os.path.exists(CFGINI):
    ini = configparser.ConfigParser(); ini.read(CFGINI)
    LOCAL = ini.get("directories", "localDataProjDir", fallback=None)
LOCAL = os.path.normpath(LOCAL or r"C:\LocalData\NetworkModel_PBL")
CACHES = os.path.join(LOCAL, "IntermediateResults")
since = option("--since")

# The components of the variant (batch\log\components.txt, written by the checks of UpdateAll.cmd), to split a step name
# into the step and the component.
cf = os.path.join(LOG, "components.txt")
COMPONENTS = [l.split(";")[0] for l in open(cf).read().split("\n") if l.strip()] if os.path.exists(cf) else []

def split(step):
    for c in sorted(COMPONENTS, key=len, reverse=True):
        if step.endswith("_" + c):
            return step[:-len(c) - 1], c
    return step, None

# The run: the last "UpdateAll ... started" in the status file (UpdateAll.cmd appends to it; only UpdateAllTask.cmd starts
# it anew), with the time as cmd writes %date% here (dd/mm/yyyy h:mm:ss), and what that run skipped.
status = open(STATUS, "rb").read().decode("latin-1") if os.path.exists(STATUS) else ""
runs = list(re.finditer(r"(\d\d)/(\d\d)/(\d{4})\s+(\d{1,2}):(\d\d):(\d\d) UpdateAll .* started", status))
if runs:
    status = status[runs[-1].start():]
skipped_comps = re.findall(r"--- output of (\S+) is complete in .*, skipped", status)
skipped_moments = re.findall(r"the cache for (\S+) exists with the current signature, skipped", status)
if since:
    t_since = datetime.datetime.strptime(since, TS if since.count(":") == 2 else "%Y-%m-%d %H:%M").timestamp()
else:
    m = runs[-1] if runs else None
    t_since = datetime.datetime(int(m[3]), int(m[2]), int(m[1]), int(m[4]), int(m[5]), int(m[6])).timestamp() if m else 0

def name(f):
    return os.path.basename(f)[len("UpdateAll_"):-len(".log")]

def of_run(f):
    if os.path.getmtime(f) >= t_since:
        return True
    base, comp = split(name(f))
    return comp in skipped_comps or any(base == "car_" + m for m in skipped_moments)

logs = sorted(glob.glob(os.path.join(LOG, "UpdateAll_*.log")), key=os.path.getmtime)
steps = args or [name(f) for f in logs if of_run(f)]

def sessions(p):
    s = open(p, "rb").read().decode("latin-1")
    starts = [m.start() for m in re.finditer(r"@@@@@ Logging started", s)] or [0]
    return [s[a:b] for a, b in zip(starts, starts[1:] + [len(s)])]

def stamp(kind, s):
    m = re.search(r"Logging %s for .* at (\d{4}-\d\d-\d\d \d\d:\d\d:\d\d)" % kind, s)
    return m.group(1) if m else None

def output_dir(comp):
    # The output folder of a component is Output/<date>_<label>_<component>[_fb] (#118); batch\log\output_dir.txt has the
    # folder of the component that UpdateAll was at last, and so the date and label of the run.
    od = os.path.join(LOG, "output_dir.txt")
    if not os.path.exists(od):
        return None
    cur = open(od).read().strip()
    for c in sorted(COMPONENTS, key=len, reverse=True):
        m = re.match(r"(.*)_%s\d*(_fb)?$" % re.escape(c), os.path.basename(cur))
        if m:
            found = [d for d in glob.glob(os.path.join(os.path.dirname(cur), "%s_%s*" % (m.group(1), comp)))
                     if re.match(r"_%s\d*(_fb)?$" % re.escape(comp), os.path.basename(d)[len(m.group(1)):])]
            return found[0] if found else None
    return None

def parse(step):
    p = os.path.join(LOG, "UpdateAll_%s.log" % step)
    if not os.path.exists(p):
        return None
    base, comp = split(step)
    ss = sessions(p)
    if base == "output":
        # The output of a component runs in portions of blocks, a GeoDmsRun each, that append to the same log.
        bl = os.path.join(LOG, "UpdateAll_output_blocks%s.log" % ("_" + comp if comp else ""))
        t0 = stamp("started", sessions(bl)[-1]) if os.path.exists(bl) else None
        ss = [x for x in ss if t0 and (stamp("started", x) or "") >= t0] or ss[-1:]
    else:
        ss = ss[-1:]
    s = "".join(ss)
    st = [stamp("started", x) for x in ss]; en = [stamp("ended", x) for x in ss]
    r = {"step": step, "calls": len(ss), "start": st[0], "end": en[-1]}
    if all(st) and all(en):
        r["dur_min"] = sum((datetime.datetime.strptime(e, TS) - datetime.datetime.strptime(b, TS)).total_seconds() for b, e in zip(st, en)) / 60
    m = re.findall(r"Filling all (\S+) sources: resulted in ([\d,]+) pareto od-pairs", s); r["rows"] = m[-1][1] if m else None
    cnt = re.findall(r"(\d{4}-\d\d-\d\d \d\d:\d\d:\d\d).*impedance_matrix Counting", s)
    fil = re.findall(r"(\d{4}-\d\d-\d\d \d\d:\d\d:\d\d).*impedance_matrix Filling", s)
    r["count_first"] = cnt[0] if cnt else None; r["count_last"] = cnt[-1] if cnt else None; r["fill_last"] = fil[-1] if fil else None
    m = re.findall(r"Highest CommitCharge: (\d+)\[MB\]", s); r["commit_mb"] = max(map(int, m)) if m else None
    m = re.findall(r"PeakLiveLarge: (\d+)\[MB\]", s); r["live_mb"] = max(map(int, m)) if m else None
    # The missing population grid (SourceData/Locaties/Inwoners, cbs_vk100_<year>.gpkg) reports an error in every run but
    # does not affect the caches; those lines do not count as errors.
    errs = [l for l in s.splitlines() if "[E]" in l and not any(x in l for x in ("Inwoners", "aantal_inwoners", "cbs_vk100"))]
    r["errors"] = len(errs); r["first_error"] = errs[0][:200] if errs else None
    m = re.search(r"GeoDmsRun failed with code (\d+)", s); r["failed"] = m.group(1) if m else None
    # The caches are PT_Chains_<date>_<window>_<hash> (a folder with a cache per block, #118) and
    # DirectCar_<network>_<moment>_<origin>_<destination>_<revision>_<hash>.mmd, each with its signature in signature.txt
    # in the folder.
    pat = "PT_Chains_*" if base == "chains" else ("DirectCar_*%s_*.mmd" % base.split("_", 1)[1] if base.startswith("car_") else None)
    caches = sorted([d for d in glob.glob(os.path.join(CACHES, pat)) if os.path.isdir(d)], key=os.path.getmtime) if pat else []
    if caches:
        d = caches[-1]
        r["cache"] = os.path.basename(d)
        r["cache_mb"] = sum(os.path.getsize(os.path.join(w, f)) for w, _, fs in os.walk(d) for f in fs) / 1e6
        r["cache_time"] = datetime.datetime.fromtimestamp(os.path.getmtime(d)).strftime(TS)
    if base == "output" and r["start"]:
        t0 = datetime.datetime.strptime(r["start"], TS).timestamp()
        outdir = output_dir(comp) if comp else None
        files = [f for ext in ("csv", "parquet") for f in glob.glob(os.path.join(outdir, "PerBlock", "*." + ext)) if os.path.getmtime(f) >= t0] if outdir else []
        r["cache"] = "%d files in %s since the start, %d GeoDmsRun calls" % (len(files), os.path.join(outdir or "?", "PerBlock"), len(ss))
        r["cache_mb"] = sum(os.path.getsize(f) for f in files) / 1e6
        r["cache_time"] = datetime.datetime.fromtimestamp(max(os.path.getmtime(f) for f in files)).strftime(TS) if files else "-"
        r["rows"] = "%d blocks" % len(re.findall(r"Results for all departure times in Block_\d+of\d+ are finished", s))
    return r

def fmt(v, f="%s"):
    return "-" if v is None else (f % v)

print("%-30s %-19s %-19s %8s %14s %10s %10s %10s %8s" % ("step", "start", "end", "min", "rows", "commit MB", "live MB", "cache MB", "errors"))
for st in steps:
    r = parse(st)
    if r is None:
        print("%-30s (no log)" % st)
        continue
    print("%-30s %-19s %-19s %8s %14s %10s %10s %10s %8s" % (st, fmt(r["start"]), fmt(r["end"]), fmt(r.get("dur_min"), "%.1f"), fmt(r["rows"]),
          fmt(r["commit_mb"]), fmt(r["live_mb"]), fmt(r.get("cache_mb"), "%.0f"), r["errors"]))
    if r.get("count_first"):
        print("%-30s   counting pass %s .. %s, filling pass until %s" % ("", r["count_first"], fmt(r["count_last"]), fmt(r["fill_last"])))
    if r.get("cache"):
        print("%-30s   %s (%s)" % ("", r["cache"], r["cache_time"]))
    if r["failed"] or r["first_error"]:
        print("%-30s   ERROR exit %s: %s" % ("", r["failed"], r["first_error"]))
