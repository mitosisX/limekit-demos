-- A pixel-art editor.
--
-- The picture is a table of colours, `pixels[row][column]`, and the grid
-- of labels on screen is a view of it -- the same shape as minesweeper,
-- with a different thing in the cells. Four tools act on that table:
-- pencil, fill (a flood fill over same-coloured neighbours), eraser (sets
-- a cell to transparent) and pick (reads a colour back into the palette).
--
-- Undo is a stack of snapshots taken before each change. A 32x32 image is
-- a thousand short strings, so copying it is cheaper than describing the
-- change, and it can never be undone wrongly.
--
-- Two exports. SVG is text: one rect per pixel, written with writeFile.
-- PNG is bytes, which a Lua string cannot carry across to Python, so the
-- encoder in png.lua produces base64 and fs.FileSystem.writeBase64 turns
-- it back into bytes on the way to disk. That encoder -- CRC32, Adler-32,
-- a zlib stream of stored blocks -- is the hard part of this example, and
-- it is all in png.lua.
--
-- Painting is click by click: Limekit labels report clicks, not drags.
-- Mirror mode halves the clicking for symmetrical sprites.

local ui = require("limekit.ui")
local fs = require("limekit.fs")
local sys = require("limekit.sys")

local PNG = require("png")

local FS = fs.FileSystem
local window = ui.Window { title = "Pixel editor - Limekit 2.0" }

local SIZES = { 8, 16, 32 }
local BOARD = 512                       -- the canvas is always this wide, in px

local PALETTE = {
    "#000000", "#1D2B53", "#7E2553", "#008751", "#AB5236", "#5F574F", "#C2C3C7", "#FFF1E8",
    "#FF004D", "#FFA300", "#FFEC27", "#00E436", "#29ADFF", "#83769C", "#FF77A8", "#FFCCAA",
}

-- STATE ----------------------------------------------------------------------

local size = 16
local pixels = {}           -- [row][column] = "#rrggbb" or false (transparent)
local cells = {}            -- [row][column] = ui.Label
local colour = "#FF004D"
local tool = "pencil"
local mirror = false
local undoStack, redoStack = {}, {}
local path = nil            -- the open .json, if any
local dirty = false

local function blank(n)
    local image = {}
    for r = 1, n do
        image[r] = {}
        for c = 1, n do image[r][c] = false end
    end
    return image
end

local function copyOf(image)
    local out = {}
    for r, row in ipairs(image) do
        out[r] = {}
        for c, value in ipairs(row) do out[r][c] = value end
    end
    return out
end

-- CHROME ---------------------------------------------------------------------

local status = ui.StatusBar()
window:setStatusbar(status)
local info = ui.Label("")
status:addPermanentChild(info)

local swatch = ui.Label("")
swatch:setFixedSize(40, 24)
local hexLabel = ui.Label(colour)
hexLabel:setMinWidth(70)

local function describe()
    local painted = 0
    for r = 1, size do for c = 1, size do if pixels[r][c] then painted = painted + 1 end end end
    info:setText(string.format("%dx%d   %s   %d painted%s", size, size, tool, painted, dirty and "   *" or ""))
end

local function setColour(hex)
    colour = hex
    swatch:setStyleSheet("background: " .. hex .. "; border: 1px solid #555;")
    hexLabel:setText(hex)
end

-- THE CANVAS -------------------------------------------------------------------

local grid = ui.GridLayout()
grid:setSpacing(0)
local board = ui.Container()
board:setLayout(grid)

-- Transparent cells show a checkerboard, so transparent and white differ.
local function paintCell(r, c)
    local hex = pixels[r][c]
    if not hex then hex = ((r + c) % 2 == 0) and "#E5E7EB" or "#F3F4F6" end
    cells[r][c]:setStyleSheet("background: " .. hex .. "; border: 1px solid #D1D5DB;")
end

local function paintAll()
    for r = 1, size do for c = 1, size do paintCell(r, c) end end
    describe()
end

local function snapshot()
    undoStack[#undoStack + 1] = copyOf(pixels)
    if #undoStack > 100 then table.remove(undoStack, 1) end
    redoStack = {}
    dirty = true
end

local function setPixel(r, c, hex)
    pixels[r][c] = hex
    paintCell(r, c)
    if mirror then
        local m = size - c + 1
        pixels[r][m] = hex
        paintCell(r, m)
    end
end

-- Breadth first over the four neighbours, replacing one colour with
-- another. `false` (transparent) is a colour too, so filling the
-- background works.
local function fill(r0, c0, hex)
    local target = pixels[r0][c0]
    if target == hex then return end
    local queue, head = { { r0, c0 } }, 1
    while head <= #queue do
        local r, c = queue[head][1], queue[head][2]
        head = head + 1
        if r >= 1 and r <= size and c >= 1 and c <= size and pixels[r][c] == target then
            pixels[r][c] = hex
            paintCell(r, c)
            queue[#queue + 1] = { r + 1, c }
            queue[#queue + 1] = { r - 1, c }
            queue[#queue + 1] = { r, c + 1 }
            queue[#queue + 1] = { r, c - 1 }
        end
    end
end

local function click(r, c)
    if tool == "pick" then
        if pixels[r][c] then setColour(pixels[r][c]) end
        status:setText(pixels[r][c] and ("Picked " .. pixels[r][c]) or "That cell is transparent.", 2000)
        return
    end
    if tool == "pencil" then
        if pixels[r][c] == colour then return end
        snapshot()
        setPixel(r, c, colour)
    elseif tool == "eraser" then
        if not pixels[r][c] then return end
        snapshot()
        setPixel(r, c, false)
    elseif tool == "fill" then
        if pixels[r][c] == colour then return end
        snapshot()
        fill(r, c, colour)
        if mirror then fill(r, size - c + 1, colour) end
    end
    describe()
end

local function buildGrid()
    grid:clear()
    cells = {}
    local cell = BOARD // size
    for r = 1, size do
        cells[r] = {}
        for c = 1, size do
            local label = ui.Label("")
            label:setFixedSize(cell, cell)
            label:setOnClick(function() click(r, c) end)
            grid:addChild(label, r, c)
            cells[r][c] = label
        end
    end
    paintAll()
end

-- EDITING COMMANDS ---------------------------------------------------------------

local function undo()
    local previous = table.remove(undoStack)
    if not previous then status:setText("Nothing to undo.", 2000); return end
    redoStack[#redoStack + 1] = copyOf(pixels)
    pixels = previous
    paintAll()
end

local function redo()
    local next_ = table.remove(redoStack)
    if not next_ then status:setText("Nothing to redo.", 2000); return end
    undoStack[#undoStack + 1] = copyOf(pixels)
    pixels = next_
    paintAll()
end

local function clearAll()
    snapshot()
    pixels = blank(size)
    paintAll()
end

-- FILES ----------------------------------------------------------------------------

local function newImage(n)
    if dirty and not ui.Dialogs.question(window, "New image", "Discard the current image?") then return end
    size = n
    pixels = blank(size)
    undoStack, redoStack = {}, {}
    path, dirty = nil, false
    window:setTitle("Pixel editor - Limekit 2.0")
    buildGrid()
end

local function save(as)
    if as or not path then
        local chosen = ui.Dialogs.saveFile(window, "Save image", path or
            FS.joinPaths(sys.System.getStandardPath("documents"), "pixels.json"), { ["Pixel image"] = { "json" } })
        if not chosen then return end
        path = chosen
    end
    local rows = {}
    for r = 1, size do
        rows[r] = {}
        for c = 1, size do rows[r][c] = pixels[r][c] or "" end
    end
    FS.writeJSON(path, { size = size, pixels = rows }, 0)
    dirty = false
    window:setTitle(FS.getFileName(path) .. " - Pixel editor - Limekit 2.0")
    status:setText("Saved " .. path, 4000)
    describe()
end

local function open()
    if dirty and not ui.Dialogs.question(window, "Open", "Discard the current image?") then return end
    local chosen = ui.Dialogs.openFile(window, "Open image", nil, { ["Pixel image"] = { "json" } })
    if not chosen then return end
    local ok, saved = pcall(function() return FS.readJSON(chosen) end)
    if not ok or type(saved) ~= "table" or type(saved.pixels) ~= "table" then
        ui.Dialogs.warning(window, "Open", "That is not a pixel image file.")
        return
    end
    size = tonumber(saved.size) or #saved.pixels
    pixels = blank(size)
    for r = 1, size do
        for c = 1, size do
            local hex = saved.pixels[r] and saved.pixels[r][c]
            if type(hex) == "string" and hex:match("^#%x%x%x%x%x%x$") then pixels[r][c] = hex end
        end
    end
    undoStack, redoStack = {}, {}
    path, dirty = chosen, false
    window:setTitle(FS.getFileName(path) .. " - Pixel editor - Limekit 2.0")
    buildGrid()
end

local function exportPNG()
    local chosen = ui.Dialogs.saveFile(window, "Export PNG",
        FS.joinPaths(sys.System.getStandardPath("documents"), "pixels.png"), { ["PNG image"] = { "png" } })
    if not chosen then return end
    local bytes = PNG.encode(size, size, function(r, c)
        local hex = pixels[r][c]
        if not hex then return 0, 0, 0, 0 end
        local red, green, blue = PNG.rgb(hex)
        return red, green, blue, 255
    end)
    FS.writeBase64(chosen, PNG.base64(bytes))
    status:setText(string.format("Wrote %s (%d bytes, %dx%d)", chosen, #bytes, size, size), 6000)
end

local function exportSVG()
    local chosen = ui.Dialogs.saveFile(window, "Export SVG",
        FS.joinPaths(sys.System.getStandardPath("documents"), "pixels.svg"), { ["SVG image"] = { "svg" } })
    if not chosen then return end
    local out = { string.format('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" '
        .. 'viewBox="0 0 %d %d" shape-rendering="crispEdges">', size * 8, size * 8, size, size) }
    for r = 1, size do
        for c = 1, size do
            if pixels[r][c] then
                out[#out + 1] = string.format('<rect x="%d" y="%d" width="1" height="1" fill="%s"/>', c - 1, r - 1, pixels[r][c])
            end
        end
    end
    out[#out + 1] = "</svg>"
    FS.writeFile(chosen, table.concat(out, "\n"))
    status:setText("Wrote " .. chosen, 6000)
end

-- TOOLS AND PALETTE ----------------------------------------------------------------

local toolbar = ui.Toolbar()
toolbar:setToolButtonStyle("textbesideicon")
local toolButtons = {}
local function setTool(name)
    tool = name
    for key, button in pairs(toolButtons) do button:setChecked(key == name) end
    describe()
end
for _, spec in ipairs({ { "pencil", "Pencil", "P" }, { "fill", "Fill", "F" }, { "eraser", "Eraser", "E" }, { "pick", "Pick", "K" } }) do
    local button = ui.ToolbarButton(spec[2])
    button:setCheckable(true)
    button:setToolTip(spec[2] .. "  (" .. spec[3] .. ")")
    button:setOnClick(function() setTool(spec[1]) end)
    toolbar:addButton(button)
    toolButtons[spec[1]] = button
end
toolbar:addSeparator()
local mirrorButton = ui.ToolbarButton("Mirror")
mirrorButton:setCheckable(true)
mirrorButton:setToolTip("Paint both halves at once  (M)")
mirrorButton:setOnClick(function() mirror = mirrorButton:isChecked() end)
toolbar:addButton(mirrorButton)
toolbar:addSeparator()
for _, spec in ipairs({ { "Undo", undo }, { "Redo", redo }, { "Clear", clearAll } }) do
    local button = ui.ToolbarButton(spec[1])
    button:setOnClick(spec[2])
    toolbar:addButton(button)
end
window:addToolbar(toolbar)

local palette = ui.GridLayout()
palette:setSpacing(3)
for index, hex in ipairs(PALETTE) do
    local button = ui.Button("")
    button:setFixedSize(26, 26)
    button:setStyleSheet("QPushButton { background: " .. hex .. "; border: 1px solid #444; } "
        .. "QPushButton:hover { border: 2px solid #fff; }")
    button:setToolTip(hex)
    button:setOnClick(function() setColour(hex) end)
    palette:addChild(button, (index - 1) // 8 + 1, (index - 1) % 8 + 1)
end
local customButton = ui.Button("Custom...")
customButton:setOnClick(function()
    local picked = ui.Dialogs.pickColour(window, colour)
    if picked and tostring(picked):match("^#%x%x%x%x%x%x$") then setColour(tostring(picked):upper()) end
end)

-- MENU -------------------------------------------------------------------------------

local function item(text, shortcut, handler)
    local entry = ui.MenuItem(text)
    if shortcut then entry:setShortcut(shortcut) end
    entry:setOnClick(handler)
    return entry
end
local menubar = ui.Menubar()
local fileMenu = ui.Menu("&File")
local newMenu = ui.Menu("New")
for _, n in ipairs(SIZES) do
    newMenu:addMenuItem(item(string.format("%d x %d", n, n), nil, function() newImage(n) end))
end
fileMenu:addMenu(newMenu)
fileMenu:addMenuItem(item("Open...", "Ctrl+O", open))
fileMenu:addMenuItem(item("Save", "Ctrl+S", function() save(false) end))
fileMenu:addMenuItem(item("Save as...", "Ctrl+Shift+S", function() save(true) end))
fileMenu:addSeparator()
fileMenu:addMenuItem(item("Export PNG...", "Ctrl+E", exportPNG))
fileMenu:addMenuItem(item("Export SVG...", nil, exportSVG))
fileMenu:addSeparator()
fileMenu:addMenuItem(item("Quit", "Ctrl+Q", function() window:close() end))
local editMenu = ui.Menu("&Edit")
editMenu:addMenuItem(item("Undo", "Ctrl+Z", undo))
editMenu:addMenuItem(item("Redo", "Ctrl+Y", redo))
editMenu:addMenuItem(item("Clear", nil, clearAll))
editMenu:addSeparator()
editMenu:addMenuItem(item("Pencil", "P", function() setTool("pencil") end))
editMenu:addMenuItem(item("Fill", "F", function() setTool("fill") end))
editMenu:addMenuItem(item("Eraser", "E", function() setTool("eraser") end))
editMenu:addMenuItem(item("Pick colour", "K", function() setTool("pick") end))
editMenu:addMenuItem(item("Mirror", "M", function()
    mirror = not mirror
    mirrorButton:setChecked(mirror)
end))
menubar:addMenu(fileMenu)
menubar:addMenu(editMenu)
window:setMenubar(menubar)

-- LAYOUT ------------------------------------------------------------------------------

local side = ui.VLayout()
side:setSpacing(8)
local current = ui.HLayout()
current:addChild(swatch)
current:addChild(hexLabel)
current:addStretch()
side:addLayout(current)
side:addLayout(palette)
side:addChild(customButton)
side:addStretch()

local main = ui.HLayout()
main:setMargins(12, 12, 12, 12)
main:setSpacing(16)
main:addChild(board)
main:addLayout(side)
window:setLayout(main)
window:setFixedSize(BOARD + 24 + 16 + 240, BOARD + 120)

-- A STARTER SPRITE -------------------------------------------------------------------

local INK = { Y = "#FFEC27", D = "#FFA300", G = "#00E436", W = "#FFF1E8", B = "#AB5236" }
local LEMON = {
    "................",
    "..........GG....",
    ".........GG.....",
    "......BBBB......",
    "....BBYYYYBB....",
    "...BYYWWYYYYB...",
    "..BYYWWYYYYYYB..",
    "..BYYYYYYYYYDB..",
    "..BYYYYYYYYYDB..",
    "..BYYYYYYYYDDB..",
    "...BYYYYYYDDB...",
    "....BBYYDDBB....",
    "......BBBB......",
    "................",
    "................",
    "................",
}
pixels = blank(size)
for r, row in ipairs(LEMON) do
    for c = 1, #row do
        local ink = INK[row:sub(c, c)]
        if ink then pixels[r][c] = ink end
    end
end
setColour(colour)
setTool("pencil")
buildGrid()
window:show()
