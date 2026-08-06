---
name: swisstph-quarto-starter
description: >
  Use whenever someone — especially a Quarto beginner — wants a Swiss TPH branded
  document (Word, PowerPoint, PDF via LaTeX or Typst, or letter), or needs the Swiss
  TPH Quarto template files installed or updated. Works in any project: missing
  template plumbing is fetched from the official stphtoolbox GitHub repo. Three jobs:
  (1) scaffold a new .qmd with the correct TPH YAML; (2) adapt an existing
  .qmd/.Rmd/.ipynb/.md into a TPH .qmd without changing its content; (3) install or
  update the template files (_extensions/, PowerPoint template, metadata,
  references.bib). Triggers: "make a Swiss TPH report/letter/slides", "turn my
  Rmd/notebook into a TPH PDF/Word/PPTX", "install/update the TPH template", or any
  beginner asking for branded output. After building the .qmd, offers to render it
  (renders only if the user agrees). Contact: Zhihan Zhu (zhihan.zhu@swisstph.ch)
---

# Swiss TPH Quarto Starter

Help a Quarto beginner go from "I want a branded TPH document" to a rendered file, with as
little friction as possible. Decide which scheme applies from the user's request, then
follow it below.

- **Scheme 1 — Scaffold from scratch:** the user has no source file (or only an idea) and
  wants a fresh document. → Generate a new `.qmd` from the right skeleton.
- **Scheme 2 — Adapt an existing file:** the user already has content in a `.qmd`, `.Rmd`,
  `.ipynb`, `.md`, etc. → Move their content into a TPH `.qmd` **without rewriting it**.
- **Scheme 3 — Set up or update the template only:** the user just wants the TPH template
  files installed in their project, or refreshed to the latest version. → Jump straight to
  **Step 3** with the format they care about.

Schemes 1 and 2 both end the same way: ensure template dependencies are in place
(**Step 3**), then **offer to render** (**Step 4**).

## Official source of truth

Treat the live Swiss TPH guide as authoritative:
<https://github.com/Research-IT-Swiss-TPH/stphtoolbox/blob/main/inst/quarto/README.md>.
The current extension files live under:
<https://github.com/Research-IT-Swiss-TPH/stphtoolbox/tree/main/inst/quarto>.

At the start of template work, read the current README when network access is available.
Use it to confirm required files, current-vs-old template guidance, and caveats. Do not
encode new extension asset names in this skill: extension contents are allowed to change
upstream. Use the bundled fetch script in Step 3 to mirror the current upstream folder
contents.

For scaffolding, prefer the current official demo `.qmd` for the selected format as the
YAML source. The bundled skeletons in `assets/skeletons/` are fallbacks for offline work or
for a very small starter body; they are not the authority if upstream has changed.

## The content-preservation rule (Scheme 2 — read this first)

The user's words and code are theirs. When adapting a file you are a *plumber*, not an
editor. Do **not** change titles, prose, code, results, ordering, or wording. Your job is
to wrap their content in the correct YAML header and template plumbing so it renders under
the TPH brand.

Sometimes formatting genuinely must change — an Rmd uses a YAML key the TPH format doesn't
understand, an HTML-only construct won't survive in PDF, a notebook's raw cell needs to
become a markdown cell. When that happens, **stop and ask the user before touching it**,
explaining what must change and why. Never silently "improve" their text. The reason this
matters: beginners trust the output to be *their* document; a surprise edit erodes that
trust and can quietly alter meaning in a report that goes out under their name.

## Step 1 — Pick the output format

If the user already named the output (e.g. "a Word report", "a PDF letter"), use it. If
not, ask. Map the choice to a skeleton and to the template files it needs:

| User wants | Format key | Official demo `.qmd` | Fallback skeleton | Template files needed | LaTeX needed? |
|---|---|---|---|---|---|
| PowerPoint slides | `pptx` | `ppt_report_demo.qmd` | `pptx.qmd` | `_ppt_metadata.yml` + the `reference-doc` named inside it | no |
| Word report | `docx` | `word_report_demo.qmd` | `docx.qmd` | `_extensions/word-report/` | no |
| PDF report (LaTeX) | `report-pdf` | `report_simple_demo.qmd` | `report-pdf.qmd` | `_extensions/report/` (+ optional `references.bib`) | **yes** |
| PDF report (Typst) | `report-typst` | `report_simple_demo_typst.qmd` | `report-typst.qmd` | `_extensions/report/` (+ optional `references.bib`) | no |
| PDF letter (LaTeX) | `letter-pdf` | `letter_demo.qmd` | `letter-pdf.qmd` | `_extensions/letter/` | **yes** |
| PDF letter (Typst) | `letter-typst` | `letter_demo_typst.qmd` | `letter-typst.qmd` | `_extensions/letter/` | no |

Beginner guidance to offer when they're unsure:
- **Report vs letter:** a report is a multi-section document; a letter is correspondence to a named recipient.
- **LaTeX vs Typst** (PDF only): both produce a PDF. **Prefer Typst** for beginners — it needs no TeX install and renders faster. Choose LaTeX only if they specifically need LaTeX features or already have a TeX setup.

### Brand version: current (indigo) vs old (blue)

The repo ships two generations of every template. **Default to the current one** — Swiss TPH
*indigo* corporate identity, **Aptos** font. These are the format keys / files this skill uses by
default: `report-pdf`, `report-typst`, `letter-pdf`, `letter-typst`, `ppt_template2.pptx`,
`report_template2.docx`.

Only when a user **explicitly** asks for the old blue look (Swiss TPH *blue*, Microsoft Sans
Serif — e.g. to match an existing blue document), **read `references/old-brand.md`** for the
format keys and wiring. The old templates don't use Aptos, so the font flow below doesn't apply
to them.

**Aptos font (current templates):** the indigo templates are designed for Aptos, which is **not
installed by default on Swiss TPH laptops**. Typst, Word, and PowerPoint handle this on their own
(Typst warns and substitutes; Word/PPTX carry the font in the template) — just mention any font
warning so it doesn't surprise the user. The **LaTeX PDF formats** (`report-pdf`, `letter-pdf`)
need real handling: their demos hardcode a personal font path that must not leak into the user's
file. When you scaffold or adapt into either LaTeX PDF format, **read
`references/aptos-font.md`** and follow its detect → install/fallback flow.

## Step 2a — Scheme 1: scaffold from scratch

1. When network is available, fetch/read the current official demo for the chosen format
   and use its YAML header as the authority. A convenient pattern is:

   ```bash
   tmpdir="$(mktemp -d)"
   bash "<this-skill-dir>/scripts/fetch_stph_template.sh" <format> --dest "$tmpdir" --demo --update
   ```

   Use the matching file from that temp directory. If network is unavailable, read the
   matching fallback skeleton from `assets/skeletons/<key>.qmd` and tell the user you could
   not verify the latest upstream demo.
2. Write it to the user's working directory under a sensible name (ask, or default to
   something like `my_report.qmd`).
3. Keep the official/fallback YAML wiring, then fill in only the obvious placeholders you
   *know* (title, author/email if given). Leave the rest as clearly-marked placeholders.
   Do not invent content, and do not copy long demo lorem/example analysis into a user's
   starter unless they explicitly asked for a full example document.
   - **For `report-pdf` / `letter-pdf`:** the LaTeX demo's `mainfontoptions: Path = …` line is
     the demo author's personal font folder — do not carry it over. Follow
     `references/aptos-font.md` to detect Aptos and wire the font block correctly.
4. For the report formats (`report-pdf`, `report-typst`), ask whether the user needs
   citations. If yes, keep the `bibliography: references.bib` line and let Step 3 fetch
   `references.bib`; if no, delete that line from the YAML and skip the file. Don't
   guess — an unused bibliography confuses beginners, and a missing one breaks citations.
5. Go to **Step 3** (dependencies) then **Step 4** (offer to render).

## Step 2b — Scheme 2: adapt an existing file

1. Read the user's source file.
2. Start from the current official demo's **YAML header** (preferred) or the matching
   fallback skeleton's YAML header (offline fallback). It carries the TPH template wiring.
   Carry over the user's real metadata (title, author, date, bibliography) into that
   header — verbatim. Drop only source-format-specific keys that don't apply, and tell the
   user which ones you dropped. **For `report-pdf` / `letter-pdf`,** also drop the demo's
   `mainfontoptions: Path = …` line (it's the demo author's personal folder) and follow
   `references/aptos-font.md` to wire the font instead.
3. Append the user's **body content unchanged** below the header.
   - `.Rmd` → the body is already Quarto-compatible markdown + code chunks; copy it as-is.
     Convert `{r, echo=FALSE}`-style chunk options to Quarto `#|` options **only if needed
     to render**, and flag the change.
   - `.ipynb` → convert cells to markdown/code blocks preserving content and order. Do not
     re-run, re-summarize, or reword anything.
   - `.md` → copy the prose as-is.
4. If anything in the body cannot be carried over faithfully, **ask first** (content rule).
5. Go to **Step 3** then **Step 4**.

## Step 3 — Make template dependencies present

A render fails if the template plumbing isn't in the working directory. This skill does
**not** assume the files are already there — it works in any project and fetches what's
missing from the official repo
(<https://github.com/Research-IT-Swiss-TPH/stphtoolbox/tree/main/inst/quarto>).

The skill bundles a fetch script that already knows the required bundle per format and
pulls the up-to-date copies. Use it rather than hand-curling URLs: it preserves the
required directory structure, derives the current PowerPoint `reference-doc` from upstream
metadata, and enumerates every current file inside extension folders. It needs network
access and `curl`; if the machine is offline, say so plainly instead of pretending the
files are current.

```bash
SCRIPT="<this-skill-dir>/scripts/fetch_stph_template.sh"   # path to the bundled script

# 1. Check first — are all current upstream paths for this format present?
bash "$SCRIPT" <format> --dest <workdir> --check
#    exit 0 = everything present (do nothing); exit 3 = something is missing.

# 2. Install only what's missing (existing files are kept, never overwritten).
#    Add --no-bibliography for report formats when the .qmd has no bibliography key.
bash "$SCRIPT" <format> --dest <workdir>
bash "$SCRIPT" <format> --dest <workdir> --no-bibliography

# 3. Update on request — re-download the latest, overwriting local copies.
#    Use this ONLY when the user explicitly asks to update/refresh the template:
bash "$SCRIPT" <format> --dest <workdir> --update

# 4. Fetch the current official demo as well, when you need it for scaffolding:
bash "$SCRIPT" <format> --dest <workdir> --demo
```

Why check before downloading: the user asked us not to re-pull files a project already
has — it's slower and risks overwriting local tweaks. So the normal create/adapt path is
"check, then fetch only the gaps." Re-fetching the latest is reserved for an explicit
"update the template" request, where overwriting with upstream is the whole point. The
script does not delete extra local files when updating; remove stale extras only when the
user asks for cleanup.

Notes:
- **Never rename or restructure `_extensions/<name>/`.** The templates reference paths
  relatively, and rendering breaks if the structure changes. The script mirrors the folder
  paths from the current upstream tree, including whatever brand images or support files
  live inside it.
- For `report-pdf`/`report-typst` with `references.bib`: if the user has no citations,
  delete the `bibliography:` line from the YAML and skip/remove `references.bib` rather than
  shipping an empty one. Pass `--no-bibliography` to the fetch script in that case.
- The format keys (`report-pdf`, `letter-typst`, …) are provided by these extension
  folders, so they only resolve **after** Step 3 has placed the files. Running a render
  before then yields an "unknown format" error.

## Step 4 — Offer to render (never render unprompted)

Do **not** run the render automatically. Once the `.qmd` and its template files are in
place, ask the user whether they would like you to render it for them. Some users prefer
to render from RStudio/VS Code themselves, keep control over long-running renders, or
aren't ready yet — rendering without asking takes that choice away.

- If they say **yes**, render:

  ```bash
  quarto check                      # diagnose the toolchain first if anything looks off
  quarto render <file>.qmd          # format is read from the YAML
  ```

  Render where the toolchain lives. Some users run Claude in WSL but render from RStudio/VS Code
  on **Windows**, where TeX, fonts, and Quarto may be installed instead of in WSL. If that's
  ambiguous and it affects the result (e.g. a LaTeX PDF whose font path or TeX install differs by
  side), **ask whether the render runs in WSL or in Windows** before rendering — otherwise a WSL
  render can fail or use the wrong fonts even though their Windows setup is fine. Don't ask when it
  doesn't matter (Typst/Word/PPTX, or a single-environment machine).

- If they say **no**, stop there. Tell them the document is ready and show the command
  above so they can render whenever they want. Do not render "just to check".

Quarto's YAML keys and flags drift between releases — if a render fails on a YAML key,
confirm the current spelling against the official docs (<https://quarto.org/docs/>) rather
than guessing from memory.

### Missing tools: ask before installing

If a required tool is not installed (`quarto`, a TeX distribution for the LaTeX formats,
R packages the document needs, …), never install it silently — an install changes the
user's machine, can be large (TeX is gigabytes), and they may prefer their own package
manager or an admin-approved route. Instead:

1. Say plainly what is missing and why the render needs it.
2. Ask whether they want you to install it for them.
3. If **yes**, attempt the install with the most standard method for their platform, and
   report exactly what you ran.
4. If **no**, give short concrete suggestions instead — e.g. Quarto:
   <https://quarto.org/docs/get-started/>; TeX: `quarto install tinytex` or switch to the
   Typst variant of the format (no TeX needed); R packages: `install.packages("...")` in R.

Never pretend a render succeeded when the tooling was missing.

When the render succeeds, tell the user the output path. If they then want to inspect or
post-edit the produced `.pptx`/`.docx`/`.pdf` **binary**, hand off to the matching document
skill (`pptx`, `docx`, `pdf`).

## What this skill does NOT do

- It does not rewrite, summarize, or "polish" user content (see the content rule).
- It does not post-edit rendered binaries — that's the document skills' job (`pptx`,
  `docx`, `pdf`).
