# Limekit 2.0 examples

Four small apps written against the **2.0 API**. Every one boots headless in
Limekit's own test suite (`tests/test_demo_smoke.py::test_modern_demo_boots_clean`),
so if the framework regresses, these break in CI rather than in your hands.

| Example | Shows |
|---|---|
| `hello-window` | The smallest complete app: `require`, a window, a layout, chained setters |
| `counter` | Events, state, and the error guard containing a handler that always raises |
| `calculator` | `GridLayout` (1-indexed), `TextField`, and the sandboxed expression evaluator |
| `list-manager` | Collections, 1-indexed rows, and uniform argument handling |

Run one with:

```
python -m limekit "2.0-examples/hello-window"
```

## What changed from 1.x

**Modules, not globals.** 1.x injected ~138 bare names into every Lua script —
plus Python's own `eval`, `str`, `int`, `dict`, `tuple` and `print`. That `eval`
was `builtins.eval`, so any string reaching it was arbitrary Python. 2.0 gives
you module tables you ask for:

```lua
local ui  = require("limekit.ui")
local sys = require("limekit.sys")
```

**One indexing convention.** Everything Lua-facing is 1-indexed. 1.x was
inconsistent *within itself*: layouts subtracted one from the index, item
widgets did not, and `GridLayout` took raw 0-based Qt coordinates.
`getCurrentRow()` now returns `0` for "nothing selected" rather than leaking
Qt's `-1`.

**One calling convention.** Always use `:`. Qt-native methods are re-exposed as
Python methods on the shared base so `window:show()` works the same way
`window:getTitle()` does.

**Every handler is guarded.** In 1.x only `Button` wrapped its callbacks;
`ComboBox`, `ListBox`, `Label` and `Window` let an error escape into the Qt
event loop and take the app down. `counter`'s "Break on purpose" button proves
the difference — it raises on every click and the app keeps running.

**Arithmetic instead of `eval`.** `sys.Expr.evalExpression` parses the
expression and permits only arithmetic — no attribute access, no calls, no
names, no comprehensions. It also bounds `**`, so `9**9**9` is refused in under
a millisecond instead of hanging the process. Try typing either into
`calculator` and pressing `=`.

**Setters chain.** Generated setters return the widget:

```lua
local button = ui.Button("Save"):setToolTip("Writes to disk"):setEnabled(true)
```

## What is not here yet

These examples use only what the 2.0 API actually provides today:
`Window`, `VLayout`, `HLayout`, `GridLayout`, `Button`, `Label`, `CheckBox`,
`ComboBox`, `ListBox`, `TextField`, and `sys.Expr`.

The ~52 demos in the parent directory are **not** ported, and deliberately so.
They depend on things that do not exist yet: theming (`app.Theme`), dialogs
(`app.alert`, `app.textInputDialog`), file utilities, resource routing
(`images()`, `route()`), and roughly twenty more widgets — menus, toolbars,
docks, tables, tabs, pickers and charts. Porting them before those land would
produce examples that do not run.

They are tracked as xfails in Limekit's smoke suite, so the count is visible
rather than hidden. See `docs/superpowers/P1-BACKLOG.md` in the Limekit repo.
