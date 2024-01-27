-- Limekit framework
-- Developer:  Omega Msiska
-- By:				 Take bytes
-- 
-- 
app.Theme('darklight'):setTheme('light')

app.execute(scripts('modals/table.lua'))
app.execute(scripts('toolbars/toolbar.lua'))
app.execute(scripts('toolbars/formatbar.lua'))

window = Window {
    title = "RichTextEditor - Limekit",
    size = {1030, 500},
    icon = images('app.png')
}

mainLay = VLayout()
statusBar = StatusBar()

textEditor = TextField()
textEditor:setTabSpacing(8)
textEditor:setTextSize(8)
textEditor:setOnCursorPositionChange(function()
    line = textEditor:getBlockNumber() + 1
    col = textEditor:getColumnNumber()

    statusBar:setText("Line: " .. line .. " | Column: " .. col)
end)

mainLay:addChild(textEditor)

window:addToolbar(toolbar)
window:addToolbarBreak()
window:addToolbar(formatbar)

mainLay:addChild(statusBar)
window:setLayout(mainLay)
window:show()
