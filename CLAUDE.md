# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

SageLive ("SageAX Accounting") is a Business Rules! (BR) application — a time/expense/travel
billing and business-management app the owner (Gabriel Bakker) built and runs his own BR/Business
Rules consulting practice on. It is not a web or npm/node project: there is no `package.json`,
build script, or conventional test runner. Source is `.brs` (BR Business BASIC), compiled to
tokenized `.br`, run inside the BR runtime.

**Read `context/README.md` before making any changes** — it is the entry point for a full context
kit covering BR language semantics, this app's data model, coding conventions, and architecture.
Everything below is a quick-reference summary; the kit has the depth and the authoritative detail.

## Development commands

There is no build/lint/test command in the conventional sense. BR's equivalents:

```powershell
# Environment (see context/dev/BR_launch.md for the full picture)
$env:BR_EXE     = "context\dev\tools\brserver-433c-Win32-Debug-2026-08-27.exe"
$env:BR_AI_UTIL = "context\dev\tools\brconfig.ai_util"   # headless/unattended
$env:BRLS_EXE   = "context\dev\tools\brls.exe"            # standalone syntax checker, no BR needed

# Fast syntax pre-check (does not catch Lexi-only syntax — see below)
& $env:BRLS_EXE -check somefile.brs

# Authoritative compile-check (parses, reports first error + line)
& $env:BR_EXE "LOAD somefile.brs source" -$env:BR_AI_UTIL
```

**This app is written for Lexi**, a BR preprocessor (written by the app owner) that adds syntax
base BR/`brls` don't understand (`/* */` comments, `X$&=`, `#Select#/#Case#/#End Select#`). A
`brls`/`LOAD` failure on that syntax is not a real bug — see `context/dev/BR_launch.md`'s "The
Lexi preprocessor" section before assuming otherwise. Saving a `.brs` in VS Code with the "BR
Language Server" extension (`crs-dev.vslang-br`) installed runs Lexi automatically.

## Architecture — quick orientation

Full detail: `context/app/architecture.md` (data flows) and `context/app/conventions.md` (house
style). The short version:

- **Entry point:** `start.brs` (login gate) → `CHAIN`s into `panel.brs` (main tabbed menu). Every
  screen from there goes through ScreenIO.
- **`function/`** holds the real, hand-edited source for ScreenIO event code and shared helpers —
  one function per file. **`screenio/`** holds *generated* ScreenIO Helper Libraries stitched from
  `function/` at screen-compile time (through Lexi) — never hand-edit files there; edit the
  `function/` source and recompile the screen in ScreenIO instead.
- **`FileLay/`** is the data dictionary (one `.lay` file per data file); **`Data/`** holds the
  actual runtime data. Always check `context/app/data-model.md` (generated from `FileLay/`) for a
  file's real fields/keys before writing `OPEN`/`READ`/`KEY=` code — never guess a layout.
- File access goes through the **FileIO** library (`fnopen`/`fnOpenFile`) almost universally — raw
  keyed `OPEN`/`KFNAME=` is reserved for the rare case FileIO itself can't cover.
- `Extras/`, `TOOLS/`, and `Notes/` are **not part of the live app** (other developers' reference
  code and old dev notes) — ignore them.
- The web portal (`www/`, `login.brs`, `datatables.brs`) and the invoice-billing side of
  `subscriptions.dat` are **not implemented** — stubs/data-tracking only, not working features.

@context/README.md
