# Old (blue) brand version

Read this only when a user **explicitly** wants the old look — e.g. to match an existing blue
document. The default is always the current indigo brand (see SKILL.md); don't come here
otherwise.

The old generation is Swiss TPH *blue* with Microsoft Sans Serif. Unlike the current indigo
templates, **the old templates do not use Aptos** — there is no font detection or font path to
handle here, so the Aptos flow in `references/aptos-font.md` does not apply.

## Files and format keys

| User wants (old) | Format `key` for the YAML | Extension folder | Template file |
|---|---|---|---|
| PDF report (LaTeX) | `old-report-pdf` | `_extensions/old-report/` | — |
| PDF report (Typst) | `old-report-typst` | `_extensions/old-report/` | — |
| PDF letter (LaTeX) | `old-letter-pdf` | `_extensions/old-letter/` | — |
| PowerPoint | `pptx` (normal bundle) | — | point `reference-doc` at `ppt_template1.pptx` |
| Word | `docx` (normal bundle) | — | point `reference-doc` at `_extensions/word-report/report_template1.docx` |

## How to wire it

- **Old PDF (report or letter):** set the YAML `format:` to `old-report-pdf`,
  `old-report-typst`, or `old-letter-pdf`, and run the fetch script (Step 3) with that **same
  key** so it pulls the matching `_extensions/old-*/` folder.
- **Old PowerPoint / Word:** fetch the normal `pptx` or `docx` bundle, then point the
  `reference-doc` at the `*_template1` file shown above (the current versions are `*_template2`).

The bundled skeletons in `assets/skeletons/` target the **current** versions only — there are no
old-brand skeletons. For an old build, start from the upstream demo for that key (fetch with
`--demo`) or hand-edit a current skeleton's `format:` key and `reference-doc`.
