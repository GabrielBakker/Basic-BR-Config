# Examples — ScreenIO technique scripts (not house style)

These are throwaway scripts that show **how a technique was done**, mainly writing ScreenIO screens
from code (no Designer UI), as described in [`../../dev/screenio-guide.md`](../../dev/screenio-guide.md)
§9. They were verified against an earlier production app. They are **not** house style: don't
imitate them the way you would `../exemplars/`.

## Safe to run in this app

| Script | What it does |
|---|---|
| `runscreen.brs` | Opens any screen by name interactively (`RUN PROC`, one line: the screen code). Use `$BR_AI_USER`, not headless. |
| `screenpreview.brs` | Renders an ASCII sketch of a screen's control layout from `screenio.dat`/`screenfld.dat`, with an overlap check (`RUN PROC`, two lines: screen code, output file). |

## Reference only — do not run here

These were written against the earlier app's data files (`customer.dat`, `timelogs.dat`,
`project.dat`) and its `CLAUDE*` screens, none of which exist in this app. Read them for the
technique and adapt the file, field and screen names before reusing any of it.

| Script | Technique |
|---|---|
| `makeclaudecustomertest.brs` | Write a bare listview screen's records, then compile it with `fnCompileScreen` |
| `makeclaudecustomeredit.brs` | Write a minimal add/edit form (no custom event functions); its header lists the mistakes to avoid |
| `makeclaudeviewtimelogs.brs` + `function/claudetimelogfilter.brs` | Listview scoped to a parent key through a custom Filter function |
| `addbuttons_claudecustomertest.brs` | Add Add/Edit buttons to an existing screen, guarded against adding them twice |
| `addviewtimelogsbutton.brs` + `function/viewtimelogsforcustomer.brs` | Add a button that opens another screen, passing the selected row's key |
| `updateprojectcolumn.brs` | Turn a bound listview column into a free-floating `S$` lookup column |
