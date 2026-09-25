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
