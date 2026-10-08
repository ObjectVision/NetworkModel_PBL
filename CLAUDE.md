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
