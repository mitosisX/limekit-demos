# Limekit 2.0 examples

Thirty-nine apps written against the **2.0 API**. Every one boots headless in
Limekit's own test suite (`tests/test_demo_smoke.py::test_modern_demo_boots_clean`),
so if the framework regresses, these break in CI rather than in your hands.

Run one with:

```
python -m limekit "2.0-examples/hello-window"
```

## Start here

| Example | Shows |
|---|---|
| `hello-window` | The smallest complete app: `require`, a window, a layout, chained setters |
| `counter` | Events, state, and the error guard containing a handler that always raises |
| `calculator` | `GridLayout`, `TextField`, and the sandboxed expression evaluator |
| `list-manager` | Collections, 1-indexed rows, and uniform argument handling |

## Arranging things

| Example | Shows |
|---|---|
| `layouts` | Nesting, spacing, margins, stretch factors and spacers |
| `grid-layout` | Rows and columns, spanning cells, row and column stretch |
| `form-layout` | Label-and-field rows, the layout built for data entry |
| `splitter-and-scroller` | Panes the user resizes, and content larger than its window |
| `tabs` | Tab pages, closable tabs, and reacting to the current one |
| `accordion` | Collapsible sections stacked in a column |
| `sliding-stack` | One page at a time, with an animated transition |
| `docking` | Dock panels the user can float, move and close |

## Chrome

| Example | Shows |
|---|---|
| `menus-and-toolbars` | Menubar, submenus, checkable items, toolbar, status bar |
| `context-menu` | Right-click menus, and a table-driven builder in nine lines |
| `keyboard-shortcuts` | Window-wide key sequences, and raw key presses |
| `window-events` | Resize, mouse, context menu, shown and close |
| `theming` | Qt styles, theme families, stylesheets and standard icons |
| `dialogs` | Every built-in dialog, and what each returns when cancelled |
| `system-tray` | A tray icon with a menu, and desktop notifications |

## Input

| Example | Shows |
|---|---|
| `text-inputs` | Single and multi-line text, selection, passwords, rich text |
| `autocomplete` | Suggestions as you type, shared between fields |
| `choices` | Check boxes, radio buttons, button groups, combo boxes |
| `sliders-and-gauges` | Sliders, dials, spinners, progress bars, an LCD readout |
| `date-and-time` | Calendars, date and time pickers, and timers |

## Data

| Example | Shows |
|---|---|
| `tree-view` | A hierarchy: columns, nesting, editing and selection |
| `table` | A grid of cells: headers, editing, widgets in cells, colours |
| `charts` | Six charts: four bar arrangements, lines, an area band, live data |
| `sqlite` | Create, insert, query and display -- with real parameters |
| `files` | Reading, writing, walking and inspecting the file system |
| `system-info` | Hashes, clipboard, base64, and what the machine is |
| `threads` | Background work, the GUI-thread guard, and its real limits |

## Whole applications

| Example | Shows |
|---|---|
| `notepad` | A text editor: menus, toolbar, files, find, and a dirty flag |
| `tic-tac-toe` | A game: grid, state kept in Lua, and an opponent |
| `image-viewer` | Images, GIFs, resource paths and project routes |
| `file-explorer` | Tree, listing and preview kept in step through one `navigate` |
| `csv-explorer` | A file becomes a table becomes a chart -- `fs`, `sys`, `ui` and `chart` in one flow |
| `log-viewer` | Tailing a growing file with a timer, filtered and coloured by severity |
| `kanban` | A board of cards: modal editing, moving columns, saved as JSON |
| `widget-gallery` | Every `ui` class, live, generated from one table |

`widget-gallery` is worth opening first if you are new: it shows all 63
classes at once, and Limekit's test suite checks it against the live registry,
so it cannot quietly fall behind the framework the way a hand-written list
would.

`dialogs` and `notepad` open modal dialogs, so they wait for a human. Every
other example can be driven start to finish without one.

## What changed from 1.x

**Modules, not globals.** 1.x injected ~138 bare names into every Lua script --
plus Python's own `eval`, `str`, `int`, `dict`, `tuple` and `print`. That `eval`
was `builtins.eval`, so any string reaching it was arbitrary Python. 2.0 gives
you module tables you ask for:

```lua
local ui  = require("limekit.ui")
local sys = require("limekit.sys")
```

**The `app` table was split up.** Its contents moved to classes grouped by what
they do: `fs.FileSystem` for files, `res.Resources` for project paths,
`sys.System` for the machine, `ui.Dialogs` for dialogs, `ui.Theme` for looks.

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
the difference -- it raises on every click and the app keeps running.

**Arithmetic instead of `eval`.** `sys.Expr.evalExpression` parses the
expression and permits only arithmetic -- no attribute access, no calls, no
names, no comprehensions. It also bounds `**`, so `9**9**9` is refused in under
a millisecond instead of hanging the process. Try typing either into
`calculator` and pressing `=`.

**Setters chain.** Generated setters return the widget:

```lua
local button = ui.Button("Save"):setToolTip("Writes to disk"):setEnabled(true)
```

**Widgets may only be touched on the GUI thread, and Limekit now checks.**
Once a `sys.Thread` has started, a setter called from a worker raises with the
property and widget named, instead of corrupting Qt's state and crashing
somewhere else later. `threads` demonstrates it, along with the limit that
comes from sharing one Lua state between threads.

## The 1.x demos

The 52 projects in the parent directory are the originals, kept as they were.
They still run: Limekit ships both engines and picks one per project from
`app.json`, so nothing there needed changing.

They are not a one-to-one map onto this folder. Several were scratch files,
several were duplicates of each other, and three were written against a Fluent
widget set that 2.0 does not include. What they *demonstrated* is all here,
rewritten rather than translated.

See `migrating.rst` in the documentation for moving an app of your own across.
