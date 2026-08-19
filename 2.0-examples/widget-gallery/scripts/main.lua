-- The widget gallery -- every class in limekit.ui, on one page.
--
-- The whole thing is generated from CATALOGUE below. Adding a widget to the
-- gallery means adding one line to a table, not writing another tab: the
-- code that turns the table into an interface is about forty lines and never
-- changes.
--
-- That matters beyond this example. Limekit's registry knows every class it
-- has, and anything that lists them -- documentation, an IDE's widget dock,
-- a smoke test -- should read from one source rather than keep its own copy
-- that quietly rots. Limekit's test suite checks this file against the live
-- registry, so a widget added to the framework and forgotten here fails CI
-- rather than going unnoticed.

local ui = require("limekit.ui")
local res = require("limekit.res")

local window = ui.Window { title = "Widget Gallery - Limekit 2.0", size = { 1020, 720 } }

-- Sample data reused by several of the collection widgets below.
local FRUIT = { "Apple", "Banana", "Cherry", "Date", "Elderberry" }

-- THE CATALOGUE ------------------------------------------------------------
-- Each entry is { ClassName, one line about it, builder }. The builder
-- returns a live widget -- nothing here is a screenshot. An entry with no
-- builder is a class that only makes sense inside another one, and its
-- description says which.

local CATALOGUE = {}

local function section(title, entries)
    table.insert(CATALOGUE, { title = title, entries = entries })
end

section("Buttons and commands", {
    { "Button", "The ordinary push button.",
        function() return ui.Button("Save") end },

    { "CommandButton", "A button with a second line of explanation under it.",
        function()
            local button = ui.CommandButton("Export")
            button:setDescription("Writes a copy to disk")
            return button
        end },

    { "CheckBox", "Independent on or off.",
        function() return ui.CheckBox("Remember me") end },

    { "RadioButton", "One of a set. Radios sharing a parent are exclusive.",
        function() return ui.RadioButton("Second class") end },

    { "ButtonGroup", "Makes a set exclusive and reports as one. Not a widget itself.",
        function()
            local row = ui.Container()
            local layout = ui.HLayout()
            local group = ui.ButtonGroup()

            for _, name in ipairs({ "Low", "Medium", "High" }) do
                local radio = ui.RadioButton(name)
                group:addButton(radio)
                layout:addChild(radio)
            end

            row:setLayout(layout)
            -- Held on the container so the group is not collected while the
            -- radios it governs are still on screen.
            row.group = group
            return row
        end },
})

section("Text", {
    { "Label", "Static text, or a picture.",
        function()
            local label = ui.Label("Plain text -- and a Label can hold an image too.")
            label:setWordWrap(true)
            return label
        end },

    { "LineEdit", "One line of editable text.",
        function()
            local field = ui.LineEdit()
            field:setHint("type here")
            return field
        end },

    { "TextField", "Many lines. setPlainText and setHtml, never a guess.",
        function()
            local field = ui.TextField()
            field:setHtml("<b>Rich</b> or <i>plain</i> -- you say which.")
            field:setMaxHeight(64)
            return field
        end },

    { "AutoComplete", "A word list a LineEdit borrows. Not a widget; the field is.",
        function()
            local field = ui.LineEdit()
            field:setHint("try 'ba'")
            field:setAutoComplete(ui.AutoComplete(FRUIT))
            return field
        end },

    { "FontComboBox", "Picks from the fonts actually installed here.",
        function() return ui.FontComboBox() end },
})

section("Numbers", {
    { "Slider", "Drag along a track.",
        function()
            local slider = ui.Slider()
            slider:setOrientation("horizontal")
            slider:setRange(0, 100)
            slider:setValue(40)
            return slider
        end },

    { "AdvancedSlider", "The styled one: draws its own value, takes a prefix and suffix.",
        function()
            local slider = ui.AdvancedSlider()
            slider:setRange(0, 100)
            slider:setValue(64)
            slider:showValue(true)
            slider:setSuffix(" %")
            slider:setAccentColor("#2d7d46")
            return slider
        end },

    { "Knob", "The same idea, round.",
        function()
            local knob = ui.Knob()
            knob:setRange(0, 100)
            knob:setValue(30)
            knob:setNotchesVisible(true)
            return knob
        end },

    { "Spinner", "A whole number with arrows.",
        function()
            local spinner = ui.Spinner()
            spinner:setRange(0, 100)
            spinner:setValue(7)
            spinner:setSuffix(" items")
            return spinner
        end },
})

section("Readouts", {
    { "DoubleSpinner", "A number with decimals.",
        function()
            local spinner = ui.DoubleSpinner()
            spinner:setRange(0, 100)
            spinner:setValue(9.99)
            spinner:setPrefix("$ ")
            return spinner
        end },

    { "ProgressBar", "Read-only: how far along something is.",
        function()
            local bar = ui.ProgressBar()
            bar:setRange(0, 100)
            bar:setValue(62)
            return bar
        end },

    { "LCDNumber", "A seven-segment readout.",
        function()
            local lcd = ui.LCDNumber()
            lcd:setDigitCount(4)
            lcd:setValue(2026)
            return lcd
        end },
})

section("Dates and times", {
    { "Calendar", "A full month view.",
        function()
            local calendar = ui.Calendar()
            calendar:setGridVisible(true)
            return calendar
        end },

    { "DatePicker", "The compact version, for a form.",
        function() return ui.DatePicker() end },

    { "TimePicker", "Hours, minutes, seconds -- a time picker holds a time.",
        function()
            local picker = ui.TimePicker()
            picker:setTime(14, 30, 0)
            return picker
        end },
})

section("Pictures", {
    { "Image", "A picture that can also be clicked.",
        function()
            local image = ui.Image(res.Resources.images("heart.png"))
            image:setImageSize(64, 64)
            return image
        end },

    { "GifPlayer", "An animation, with play, pause and a frame count.",
        function()
            local gif = ui.GifPlayer(res.Resources.images("catbot.gif"))
            gif:setSize(96, 96)
            gif:start()
            return gif
        end },

    { "DropShadow", "An effect applied to a widget, not a widget itself.",
        function()
            local label = ui.Label("This label has a drop shadow.")
            local shadow = ui.DropShadow(label)
            shadow:setBlurRadius(12)
            shadow:setOffset(2, 2)
            label.shadow = shadow
            return label
        end },
})

section("Collections", {
    { "ComboBox", "One of several, from a drop-down.",
        function() return ui.ComboBox(FRUIT) end },

    { "ListBox", "A list of rows, with optional thumbnails.",
        function()
            local list = ui.ListBox(FRUIT)
            list:setMaxHeight(104)
            return list
        end },

    { "Table", "A grid of cells.",
        function()
            local grid = ui.Table(3, 3)
            grid:setColumnHeaders({ "Name", "Colour", "Stock" })
            local rows = { { "Apple", "red", "12" }, { "Banana", "yellow", "40" }, { "Cherry", "red", "8" } }
            for row = 1, 3 do
                for column = 1, 3 do
                    grid:setCellText(row, column, rows[row][column])
                end
            end
            grid:setMaxHeight(128)
            return grid
        end },

    { "TableItem", "One cell of a Table -- where a cell's own colours live.",
        function()
            local grid = ui.Table(1, 2)
            grid:setColumnHeaders({ "Normal", "Coloured" })
            grid:setCellText(1, 1, "plain")
            grid:setCellText(1, 2, "coloured")

            local item = grid:getCellItem(1, 2)
            item:setBackgroundColour("#2d7d46")
            item:setTextColour("white")

            grid:setMaxHeight(80)
            return grid
        end },

    { "TreeView", "A hierarchy that expands and collapses.",
        function()
            local tree = ui.TreeView()
            tree:setHeaderLabels({ "Name", "Kind" })

            local folder = ui.TreeViewItem({ "Fruit", "folder" })
            for _, name in ipairs({ "Apple", "Banana" }) do
                folder:addChild(ui.TreeViewItem({ name, "file" }))
            end
            folder:setExpanded(true)

            tree:addTopItem(folder)
            tree:setMaxHeight(132)
            return tree
        end },

    { "TreeViewItem", "One row of a TreeView. Shown inside the tree above.", nil },

    { "TreeWidget", "The 1.x name for TreeView -- the same class, still registered so old code runs.", nil },
})

section("Grouping and paging", {
    { "GroupBox", "A titled border round a cluster of controls.",
        function()
            local box = ui.GroupBox("Options")
            local layout = ui.VLayout()
            layout:addChild(ui.CheckBox("First"))
            layout:addChild(ui.CheckBox("Second"))
            box:setLayout(layout)
            return box
        end },

    { "Container", "A blank widget that owns a layout. The building block.",
        function()
            local panel = ui.Container()
            local layout = ui.HLayout()
            layout:addChild(ui.Label("A Container holding"))
            layout:addChild(ui.Button("a button"))
            panel:setLayout(layout)
            return panel
        end },

    { "Tab", "Pages behind a strip of tabs.",
        function()
            local tabs = ui.Tab()
            for _, name in ipairs({ "One", "Two" }) do
                local page = ui.TabItem()
                local layout = ui.VLayout()
                layout:addChild(ui.Label("Page " .. name))
                page:setLayout(layout)
                tabs:addTab(page, name)
            end
            tabs:setMaxHeight(96)
            return tabs
        end },

    { "TabItem", "One page of a Tab. Both pages above are TabItems.", nil },

    { "Accordion", "Collapsible sections stacked in a column.",
        function()
            local accordion = ui.Accordion()
            accordion:addChild(ui.Label("Opened section."), "First")

            local second = ui.VLayout()
            second:addChild(ui.CheckBox("Something"))
            accordion:addLayout(second, "Second")

            accordion:setCurrentIndex(1)
            accordion:setMaxHeight(150)
            return accordion
        end },

    { "SlidingStackedWidget", "One page at a time, animated between them.",
        function()
            local stack = ui.SlidingStackedWidget()
            stack:setSpeed(400)

            for _, text in ipairs({ "Press Next", "Second page", "Third page" }) do
                local page = ui.Container()
                local layout = ui.VLayout()
                layout:addChild(ui.Label(text))
                page:setLayout(layout)
                stack:addChild(page)
            end

            local wrapper = ui.Container()
            local layout = ui.VLayout()
            layout:addChild(stack)

            local next_ = ui.Button("Next")
            next_:setOnClick(function() stack:slideNext() end)
            layout:addChild(next_)

            wrapper:setLayout(layout)
            return wrapper
        end },

    { "Scroller", "A viewport over content larger than the space for it.",
        function()
            local scroller = ui.Scroller()
            scroller:setResizable(true)

            local tall = ui.VLayout()
            for row = 1, 12 do
                tall:addChild(ui.Label("Row " .. row))
            end

            scroller:setLayout(tall)
            scroller:setMaxHeight(110)
            return scroller
        end },

    { "Splitter", "Panes with a divider the user drags.",
        function()
            local splitter = ui.Splitter("horizontal")
            splitter:addChild(ui.ListBox({ "Left", "pane" }))
            splitter:addChild(ui.ListBox({ "Right", "pane" }))
            splitter:setSizes({ 120, 120 })
            splitter:setMaxHeight(96)
            return splitter
        end },
})

section("Dividers and chrome", {
    { "HLine", "A horizontal rule.",
        function() return ui.HLine() end },

    { "VLine", "A vertical rule, for separating columns.",
        function()
            local row = ui.Container()
            local layout = ui.HLayout()
            layout:addChild(ui.Label("left"))
            layout:addChild(ui.VLine())
            layout:addChild(ui.Label("right"))
            row:setLayout(layout)
            return row
        end },

    { "Separator", "A rule where you pick the direction.",
        function() return ui.Separator("horizontal") end },

    { "Spacer", "A fixed gap. A layout item, so it goes in with addSpacer.",
        function()
            local row = ui.Container()
            local layout = ui.HLayout()
            layout:addChild(ui.Label("40px"))
            layout:addSpacer(ui.Spacer(40, 1))
            layout:addChild(ui.Label("apart"))
            layout:addStretch(1)
            row:setLayout(layout)
            return row
        end },

    { "StatusBar", "The strip along the bottom of a window. This one is loose.",
        function()
            local bar = ui.StatusBar()
            bar:setText("Ready")
            bar:addPermanentChild(ui.Label("62%"))
            return bar
        end },

    { "Toolbar", "A strip of commands. Normally on a Window; here it is inline.",
        function()
            local toolbar = ui.Toolbar("Demo")
            for _, name in ipairs({ "New", "Open", "Save" }) do
                toolbar:addButton(ui.ToolbarButton(name))
            end
            return toolbar
        end },

    { "ToolbarButton", "One command on a Toolbar. Three of them are above.", nil },

    { "Menubar", "The bar of menus at the top of a window.",
        function()
            local menubar = ui.Menubar()

            local file = ui.Menu("&File")
            file:addMenuItem(ui.MenuItem("New"))
            file:addSeparator()
            file:addMenuItem(ui.MenuItem("Quit"))
            menubar:addMenu(file)

            local edit = ui.Menu("&Edit")
            edit:addMenuItem(ui.MenuItem("Copy"))
            menubar:addMenu(edit)

            return menubar
        end },

    { "Menu", "A menu of commands. Two of them hang off the bar above.", nil },

    { "MenuItem", "One command in a Menu. Wraps a Qt action, not a widget.", nil },

    { "DropMenu", "A Menu attached to a ToolbarButton.",
        function()
            local toolbar = ui.Toolbar("Export")

            local menu = ui.DropMenu("Export")
            menu:addMenuItem(ui.MenuItem("As PDF"))
            menu:addMenuItem(ui.MenuItem("As HTML"))

            local button = ui.ToolbarButton("Export")
            button:setMenu(menu)
            toolbar:addButton(button)

            toolbar.menu = menu
            return toolbar
        end },
})

-- NOT ON A PAGE ------------------------------------------------------------
-- Some classes cannot be shown as a row in a list, because they *are* the
-- window, or they interrupt it, or they have no appearance at all. Every one
-- of them is still accounted for here, with where to look instead -- an
-- unlisted class is a hole in the documentation, so the test suite treats it
-- as one.

local ELSEWHERE = {
    { "Window", "The frame the rest lives in. This gallery is one.", "hello-window" },
    { "Modal", "A second window that interrupts. Open one from the toolbar above.", "dialogs" },
    { "Dialogs", "File, message and input dialogs. All static; all block.", "dialogs" },
    { "Dock", "A panel round the edge of a window -- the one on the left is a Dock.", "docking" },
    { "Dockable", "The 1.x name for Dock. Same class.", "docking" },
    { "Theme", "Styles and palettes. Change one from the toolbar above.", "theming" },
    { "KeyboardShortcut", "A key sequence. Ctrl+F focuses the filter box.", "keyboard-shortcuts" },
    { "SysTray", "An icon in the system tray, with its own menu.", "system-tray" },
    { "SysNotification", "A desktop balloon notification.", "system-tray" },
    { "VLayout", "A column. Every section on this page is one.", "layouts" },
    { "HLayout", "A row. The toolbar row above is one.", "layouts" },
    { "GridLayout", "Rows and columns, 1-based.", "grid-layout" },
    { "FormLayout", "Label on the left, widget on the right -- as used for every entry here.", "form-layout" },
    { "StackedLayout", "One child visible at a time, with no animation. SlidingStackedWidget is the animated version.", "sliding-stack" },
}

-- BUILDING THE PAGE --------------------------------------------------------
-- Everything below is generic: it knows about CATALOGUE and ELSEWHERE and
-- nothing else. This is the part that does not grow when the framework does.

local status = ui.StatusBar()
window:setStatusbar(status)

local rows = {}          -- every rendered row, so the filter can hide them

local function buildEntry(name, description, builder)
    -- One row: the class name, the live widget, and a line about it.
    local row = ui.Container()

    local layout = ui.VLayout()
    layout:setSpacing(4)
    layout:setMargins(0, 8, 0, 8)

    local heading = ui.Label(name)
    heading:setBold(true)
    heading:setTextSize(12)

    local caption = ui.Label(description)
    caption:setWordWrap(true)
    caption:setTextColor("#7a7a7a")

    layout:addChild(heading)
    layout:addChild(caption)

    if builder then
        -- pcall so that one broken entry costs you that entry, not the page.
        local ok, widget = pcall(builder)
        if ok and widget then
            layout:addChild(widget)
        else
            local failed = ui.Label("could not be built: " .. tostring(widget))
            failed:setTextColor("#c0392b")
            failed:setWordWrap(true)
            layout:addChild(failed)
        end
    end

    layout:addChild(ui.HLine())
    row:setLayout(layout)

    table.insert(rows, { name = name:lower(), description = description:lower(), widget = row })
    return row
end

local function buildSection(entry)
    local page = ui.Container()

    local layout = ui.VLayout()
    layout:setMargins(16, 12, 16, 12)

    for _, item in ipairs(entry.entries) do
        layout:addChild(buildEntry(item[1], item[2], item[3]))
    end

    layout:addStretch(1)
    page:setLayout(layout)

    -- Sections are taller than the window, so each one gets its own viewport.
    local scroller = ui.Scroller()
    scroller:setResizable(true)
    scroller:setChild(page)
    scroller:setHorizontalScrollBarBehavior("hidden")
    return scroller
end

local tabs = ui.Tab()
tabs:setMovable(true)

local shown = 0
for _, entry in ipairs(CATALOGUE) do
    tabs:addTab(buildSection(entry), entry.title)
    for _, item in ipairs(entry.entries) do
        shown = shown + 1
    end
end

-- The last tab: what is not on a page, and where it is instead.
local elsewhereTable = ui.Table(#ELSEWHERE, 3)
elsewhereTable:setColumnHeaders({ "Class", "What it is", "Example" })
elsewhereTable:setColumnWidth(1, 170)
elsewhereTable:setColumnWidth(2, 500)
elsewhereTable:setAlternatingRowColors(true)

for row, item in ipairs(ELSEWHERE) do
    for column = 1, 3 do
        elsewhereTable:setCellText(row, column, item[column])
    end
end
elsewhereTable:setCellsEditable(false)

local elsewherePage = ui.Container()
local elsewhereLayout = ui.VLayout()
elsewhereLayout:setMargins(16, 12, 16, 12)

local elsewhereNote = ui.Label(
    "These have no sensible inline form: they are the window, or they " ..
    "interrupt it, or they have no appearance at all. Nothing is left out " ..
    "silently -- Limekit's test suite compares both tables in this file " ..
    "against the live registry."
)
elsewhereNote:setWordWrap(true)

elsewhereLayout:addChild(elsewhereNote)
elsewhereLayout:addChild(elsewhereTable, 1)
elsewherePage:setLayout(elsewhereLayout)

tabs:addTab(elsewherePage, "Not on a page")

-- FILTERING ----------------------------------------------------------------

local filter = ui.LineEdit()
filter:setHint("filter by name or description")

filter:setOnTextChange(function(sender, text)
    local needle = text:lower()
    local matches = 0

    for _, row in ipairs(rows) do
        -- plain find, so a filter containing a dash or a bracket is a
        -- literal rather than a pattern that quietly matches nothing.
        local hit = needle == ""
            or row.name:find(needle, 1, true) ~= nil
            or row.description:find(needle, 1, true) ~= nil

        row.widget:setVisible(hit)
        if hit then matches = matches + 1 end
    end

    status:setText(matches .. " of " .. #rows .. " widgets match")
end)

-- Ctrl+F, as promised in the ELSEWHERE table.
local focusFilter = ui.KeyboardShortcut(window, "Ctrl+F")
focusFilter:setOnKeyPress(function()
    filter:setFocus()
    status:setText("Filter focused.")
end)

-- THE WINDOW'S OWN CHROME --------------------------------------------------
-- The classes that cannot be a row in a list are demonstrated by the gallery
-- itself: this Window has a Menubar, a Toolbar, a StatusBar and a Dock, and
-- the toolbar opens a Modal and changes the Theme.

local toolbar = ui.Toolbar("Gallery")
toolbar:setToolButtonStyle("textonly")

local aboutModal = ui.ToolbarButton("Show a Modal")
aboutModal:setOnClick(function()
    local modal = ui.Modal("A Modal", window)
    modal:setSize(360, 180)

    local layout = ui.VLayout()
    layout:setMargins(20, 20, 20, 20)

    local text = ui.Label(
        "A Modal is a second window. show() puts it up without blocking; " ..
        "open() blocks until it is dismissed -- in 1.x show() did the " ..
        "blocking one, which meant it did not mean what it did everywhere else."
    )
    text:setWordWrap(true)

    local close = ui.Button("Close")
    close:setOnClick(function() modal:dismiss() end)

    layout:addChild(text)
    layout:addStretch(1)
    layout:addChild(close)

    modal:setLayout(layout)
    modal:show()

    -- Held on the window so it is not collected the moment this handler ends.
    window.modal = modal
end)
toolbar:addButton(aboutModal)

toolbar:addSeparator()

local themeMenu = ui.DropMenu("Theme")
for _, name in ipairs({ "light", "dark" }) do
    local item = ui.MenuItem(name)
    item:setOnClick(function()
        ui.Theme.setTheme("darklight", name)
        status:setText("Theme: darklight / " .. name)
    end)
    themeMenu:addMenuItem(item)
end

local themeButton = ui.ToolbarButton("Theme")
themeButton:setMenu(themeMenu)
toolbar:addButton(themeButton)
window.themeMenu = themeMenu

window:addToolbar(toolbar, "top")

-- A Menubar, so the class is demonstrated where it actually belongs.
local menubar = ui.Menubar()

local viewMenu = ui.Menu("&View")
for index, entry in ipairs(CATALOGUE) do
    local item = ui.MenuItem(entry.title)
    item:setOnClick(function() tabs:setCurrentIndex(index) end)
    viewMenu:addMenuItem(item)
end
menubar:addMenu(viewMenu)
window:setMenubar(menubar)
window.viewMenu = viewMenu

-- A Dock, holding the section list -- so ui.Dock is demonstrated by being
-- used rather than described.
local sections = ui.ListBox()
for _, entry in ipairs(CATALOGUE) do
    sections:addItem(entry.title)
end
sections:addItem("Not on a page")

sections:setOnItemSelect(function(sender, text, row)
    tabs:setCurrentIndex(row)
end)

tabs:setOnTabChange(function(sender, index)
    sections:setCurrentRow(index)
    status:setText(sender:getTabText(index))
end)

local navigation = ui.Dock("Sections")
navigation:setChild(sections)
navigation:setAllowedAreas("left", "right")
window:addDockable(navigation, "left")

-- LAYOUT -------------------------------------------------------------------

local header = ui.HLayout()
header:addChild(ui.Label("Filter:"))
header:addChild(filter, 1)

local counts = ui.Label(shown .. " widgets live, " .. #ELSEWHERE .. " listed")
counts:setTextColor("#7a7a7a")
header:addChild(counts)

local root = ui.VLayout()
root:setMargins(10, 10, 10, 10)
root:setSpacing(8)
root:addLayout(header)
root:addChild(tabs, 1)

local body = ui.Container()
body:setLayout(root)

status:setText(shown .. " widgets built live from a table of " .. #CATALOGUE .. " sections.")

window:setMainChild(body)
window:show()
