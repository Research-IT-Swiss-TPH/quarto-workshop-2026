# Aptos font setup (LaTeX PDF formats only)

Read this when scaffolding or adapting into **`report-pdf`** or **`letter-pdf`**. These are the
only formats where you handle the font. The flow below may need updating if the upstream demos or
the Microsoft download change, which is why it lives here rather than in `SKILL.md`.

## How each format handles Aptos

The indigo templates are designed for **Aptos**, which is **not installed by default on Swiss TPH
laptops**. How it's wired depends on the format:

- **Typst** (`report-typst`, `letter-typst`): the font is set inside the extension and substitutes
  a default with a warning when Aptos is absent. Nothing to do — just mention the warning so it
  doesn't surprise the user.
- **Word / PowerPoint** (`docx`, `pptx`): the font lives in the bundled template. Nothing to do.
- **LaTeX PDF** (`report-pdf`, `letter-pdf`): the xelatex demos pin `mainfont: Aptos` and add a
  `mainfontoptions:` block whose `Path = …` line points at **the demo author's own font folder on
  their own machine**. That path is meaningless on anyone else's computer.

## The rule about that hardcoded path

**Do not copy the demo's `Path = …` line into the user's `.qmd`, and do not quote it back to
them.** It exposes a stranger's directory layout and tells the user nothing useful. A curious user
can open the upstream demo in the repo themselves — that's fine — but the skill never volunteers
it. Instead, figure out where Aptos actually is on *this* machine, or fall back cleanly.

## The flow

### 1. Ask permission to scan, then detect

Scanning someone's font directories is a small thing, but it's their machine — ask first, e.g.
*"May I scan your system for the Aptos font so the PDF matches the TPH brand exactly?"* On yes:

```bash
bash "<this-skill-dir>/scripts/find_aptos.sh"
```

It is read-only (never installs or edits anything) and prints exactly one of:

- `REGISTERED` — the OS font system already knows Aptos.
- `DIR<tab><posix-path>` — Aptos `.ttf` files found in that directory. A `WIN<tab><C:/…>` line
  follows when the directory is a Windows mount (`/mnt/c/…`).
- `NOTFOUND` — not found anywhere scanned.

### 2. Wire the YAML to the result

Keep `mainfont: Aptos`, and:

- **`REGISTERED`** → xelatex resolves Aptos on its own. **Drop the `mainfontoptions:` block
  entirely.** Simplest and most portable.
- **`DIR`** → set the `Path =` line to the detected directory, keeping the `Extension`,
  `BoldFont`, `ItalicFont`, and `BoldItalicFont` lines from the demo. The path form must match
  **where `quarto render` actually runs**, which can differ from where Claude is running: a
  Windows-mounted hit returns both a `WIN` (`C:/…`) and a POSIX (`/mnt/…`) form. Use the `WIN`
  form for a Windows-side render, the POSIX form for a WSL/Linux render. If the detector returned
  both forms and you can't tell which applies, **ask the user whether they render in WSL or in
  Windows** (some run Claude in WSL but render from RStudio/VS Code on Windows). A purely
  Linux/macOS path (`/usr/…`, `~/…`) has only one form — no need to ask. Don't announce the literal
  path you chose unless the user asks — just say Aptos was found and wired up.
- **`NOTFOUND`** → don't guess a path. Offer the three choices below.

### 3. If Aptos is not found, offer three choices

Never install silently — it changes their machine.

- **Let me install it for you.** State the source out loud — the official Microsoft download
  `https://download.microsoft.com/download/8/6/0/860a94fa-7feb-44ef-ac79-c072d9113d69/Microsoft%20Aptos%20Fonts.zip`
  — even when installing on their behalf, so they know exactly what's being fetched and from
  where. If that link is dead/expired, **search for the current Aptos download and use only a URL
  on an official `microsoft.com` host** (e.g. `download.microsoft.com`, or an `aka.ms` link that
  redirects to microsoft.com); confirm the URL with the user before downloading. On yes: download
  the zip, extract the `Aptos*.ttf` files into the user's font directory (`~/.local/share/fonts`
  on Linux, then `fc-cache -f`; the per-user Windows Fonts folder on Windows/WSL), re-run
  `find_aptos.sh`, and wire the YAML per step 2. Report exactly what you downloaded and ran.
- **I'll install it myself.** Give them the same Microsoft URL and a one-line *"unzip and install
  the .ttf files, then tell me when done"* — then re-scan and wire per step 2.
- **Just use the fallback.** Set `mainfont: Arial` (drop the `mainfontoptions:` block) and tell
  them the PDF will render fine but won't be an exact brand match. Never block the render on a
  font.
