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

## Where knowledge belongs

- `CLAUDE.md`: short rules that apply in every session.
- A skill in `.claude/skills/`: a procedure with steps, including the reference values needed to judge an outcome.
- A GitHub issue: the story of a piece of work (cause, measurements, trade-offs, decision, which organisation asked). Findings of an audit become issues.
- The wiki: how the model works (method, assumptions, limitations), written as reference in the present tense, not as a log.
- Descr and Source in the code: what an item does, and where its data comes from.
- Memory: only what fits nowhere else (how the user wants to work, verbal agreements, expensive measurements).

Write a thing in one place. If an issue already holds the reasoning, refer to it with its number. Work documents of Claude (plans, audits, findings notes, session notes) do not go into this repo: it is a PBL project. Keep them outside the repo, for example in `C:\LocalData\NetworkModel_PBL\Plannen`. Details and reasons: skill `werkafspraken`.

## Descr and Source

A Descr says what the item does or means, in one sentence; where needed why it exists, and for a setting what the value implies. A reference to the issue with the trade-off stays (`#129`). The source of a constant or dataset goes in the property `Source`, with vintage or delivery date. Keep out: measurement results and their dates, the history of earlier values, how a bug was found, lessons about GeoDMS itself, instructions to the next reader, version numbers. One paragraph without blank lines; aim for under 300 characters for parameters and attributes, under 800 for containers and templates.

## Public repo: no personal names

No names of persons in Descr, Source, comments, commits, issues or the wiki; name the organisation (PBL, Deltares, Object Vision, VU), or organisation plus number (`PBL-3`) with the mapping kept outside the repo. Authors of published work and contact persons in a delivered file's header may stay.

## Code comments and parameters

Comments explain why, not what used to be there. Remove commented-out code; git keeps the old state. A value someone might want to change goes into `ModelParameters`, not as a literal in a calculation. A temporary probe or measurement harness is removed once its question is answered; the result goes into the issue.

## SourceData on the Nextcloud share is read-only

The SourceData folders that synchronise with the PBL Nextcloud share are shared by everyone using the model, and a file written there often cannot be removed or changed afterwards. Read freely, but write nothing there: no downloads, unpacked archives, copies, derived data or output, also not through a `StorageName` or a script. Downloads and intermediate files go to a working folder outside the share, derived data to `%LocalDataProjDir%`. When data turns out to be needed, tell the user which file, its source and vintage, where in SourceData it belongs and which item reads it; the user places it, or asks in the session for that one file to be placed.

## Storage: mmd and parquet, no fss

Write no new fss. A large dataset that only GeoDMS reads back becomes an mmd. Something small becomes an open file that QGIS, R, Python or a colleague can read: a tif for a raster (always with its `.tfw`), a gpkg for polygons and points, a parquet for a table. A large csv that every run reads again becomes parquet. Convert an existing fss when you rebuild it anyway. Why and the mmd pitfalls: skill `werkafspraken`.

## Commits and GitHub

Start the subject line with the issue number (`#129 OD_Uitvoer: ...`), qualified across repos (`ObjectVision/GeoDMS#1282`), and always commit with `--cleanup=whitespace`. Write the message for a colleague who knows the model but was not in the session: a subject line under 70 characters, then a few full sentences on what changed, why, and what it yields, with measurements and details in the issue. No hard line breaks inside a paragraph, only a blank line between paragraphs; Visual Studio and GitHub wrap by themselves. Full sentences and no names that exist only in the session, also in issues, comments and chat. One topic per commit, no AI attribution, only your own files and hunks when other sessions share the working copy. The user pushes. Post nothing on GitHub (issue, comment, PR text, closing) before the user has seen the draft and approved it. No bold in running text and no em or en dashes as punctuation, in commits, issues, comments and Descr alike.
