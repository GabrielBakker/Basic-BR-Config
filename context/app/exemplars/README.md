# Exemplars — ScreenIO archetypes

These blessed exemplars were carried over from an earlier production app built on the same toolset
(Lexi + FileIO + ScreenIO). They are kept because they show **how ScreenIO programs are written**,
and that hasn't changed. The business entities they mention (customers, invoices, airlines, the P&L
report) and the libraries they call (`invclib`, `report`, `readany`, ...) **do not exist in this
app**. Copy the shape, not the names.

| File | Archetype |
|---|---|
| `screenio_airlinesedit.brs` | Generated Helper Library: minimal file-maintenance **edit** form. Its header explains the `function/` → `screenio/` rule (conventions §7) |
| `screenio_airlineslist.brs` | Generated Helper Library: **list/browse** screen, paired with the edit form above |
| `screenio_custedit.brs` | Generated Helper Library: full-scale edit form for a real business entity |
| `screenio_reportpl.brs` | Generated Helper Library: a **report** driven through a ScreenIO prompt screen |
| `function_addanemail.brs` | `function/` unit: the smallest form, a button that opens another screen and passes `ParentKey$` |
| `function_initializeunique.brs` | `function/` unit: auto-key generation (also present in this app's own `function/`) |
| `function_addadjustmenttoinvoice.brs` | `function/` unit: calling a function from another library inline |
| `function_printprofitandloss.brs` | `function/` unit: validating inputs with `Msgbox` before doing work (the report button behind `screenio_reportpl`) |

The `screenio_*` files are **generated**. In a real app you never hand-edit them; you edit the
`function/<name>.brs` source and recompile the screen. Add this app's own exemplars here as
they're written (ONBOARDING STEP 5).
