# Claude Code Guidelines for NetworkModel_PBL

## Markdown formatting in audit documents

When creating markdown documents with numbered lists, subsection headings must use proper markdown heading syntax (`###`) rather than bold text (`**text**`). Bold text between numbered items can break list numbering in GitHub's markdown renderer.

**Example of what breaks list numbering:**
```markdown
## Section X
1. First item
2. Second item

**Subsection**
3. Third item
```

**Correct approach:**
```markdown
## Section X
1. First item
2. Second item

### Subsection

3. Third item
```

This has been applied to `doc/Audit_NetworkModel_PBL_2026-09-23.md` in sections 2, 3, 4, and 5.

## GeoDMS configuration code

Before writing or reviewing `.dms` code, follow the skill `geodms-dms-style` (`.claude/skills/geodms-dms-style/SKILL.md`). It points to the rules in the GeoDMS repository (`C:\dev\GeoDMS_2026\.claude\skills\geodms-dms-style\SKILL.md`).

## A `.dms` solution before a Python one

When a Python script is considered, for model steps and for ad-hoc analyses alike, look for a solution in `.dms` first: in the configuration, on the same domains (`Places`, `OD_code`, the origin blocks, the departure moments), and preferably in the same request as the generation of the data, so that it runs in one pass and reads the results while they are in memory instead of rereading the csv output. A small probe configuration in the style of the GeoDMS skill is also `.dms`. Use Python only where GeoDMS cannot do the job, and say why.

Example (2026-10-08): the median car travel time per origin-destination pair over the departure moments was first written as `batch/MedianTravelTime.py`, which reread 284 GB of csv; the user asked for it in the configuration, next to the counts of the output (`Tellingen` per departure moment and per block).

## A paging GeoDmsRun that takes long to shut down

When a GeoDmsRun of this model that pages (its commit charge above the physical memory) again takes very long to shut down, that is, it is still alive more than 5 minutes after its last requested item finished (`} Updating::[[<item>]]` in its `/L` log), send a message (`SendMessage`) to the session "Afsluiten Versnellen" so that it investigates the shutdown. Find the session with `ListAgents`; the name is the address. Put in the message:

- the pid, the engine (the folder under `C:\LocalData\GeoDMS_engine`), the command line with the log file and the requested items, and which run and step it is;
- when the last item finished and how long the process has been shutting down since;
- the commit charge, the working set and the available memory of the system, then and while it ran (the memory lines at the end of the log);
- the CDB samples: `C:\LocalData\NM_PBL_runs\watch_shutdown.ps1` takes them in `C:\LocalData\NM_PBL_runs\cdb\<pid>_*.txt` when it runs; otherwise attach noninvasively yourself (`cdb -pv -p <pid> -y "<symbol path with the engine folder>" -lines -c "!runaway 7; ~*kn 40; qd" -loga <file>`).

Do not stop the process for it; that is the user's call. Background: on 2026-10-07 the Auto output of Y2023 took more than an hour after its last file, under overcommit; the end phase of `Generate` was fixed in 29a7e0d, and freeing small objects pages swapped-out pages in again (`FreeListAllocator`).
