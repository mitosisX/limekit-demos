formatbar = Toolbar("Format")

fontBox = FontComboBox()
fontBox:setOnItemSelect(function(self, font)
    textEditor:setFont(font)
end)

fontSize = ComboBox({'6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '18', '20', '22', '24', '26', '28',
                     '32', '36', '40', '44', '48', '54', '60', '66', '72', '80', '88', '96'})

fontSize:setEditable(true)
fontSize:setMinContentLength(3) -- only displays 3 chars on the combobox
fontSize:setOnItemSelect(function(self, size)
    textEditor:setTextSize(size)
end)

fontColor = ToolbarButton("Change font color")
fontColor:setIcon(images("text_color.png"))
fontColor:setOnClick(function()
    color = app.colorPickerDialog(window, 'hex')
    if color ~= "" then
        textEditor:setTextColor(color)
    end
end)

backColor = ToolbarButton("Change background color")
backColor:setIcon(images("fill_color.png"))
backColor:setOnClick(function()
    color = app.colorPickerDialog(window, 'hex')
    if color ~= "" then
        textEditor:setTextBgColor(color)
    end
end)

formatbar:addChild(fontBox)
formatbar:addChild(fontSize)

formatbar.addSeparator()

formatbar:addButton(fontColor)
formatbar:addButton(backColor)

formatbar:addSeparator()

boldAction = ToolbarButton("Bold")
boldAction:setIcon(images("bold.png"))

italicAction = ToolbarButton("Italic")
italicAction:setIcon(images("italic.png"))
italicAction:setOnClick(function()
    local italic = textEditor:isTextItalic()
    textEditor:setTextItalic(not italic)
end)

underlAction = ToolbarButton("Underline")
underlAction:setIcon(images("underline.png"))

strikeAction = ToolbarButton("Strike-out")
strikeAction:setIcon(images("strike.png"))

superAction = ToolbarButton("Superscript")
superAction:setIcon(images("superscript.png"))

subAction = ToolbarButton("Subscript")
subAction:setIcon(images("subscript.png"))

formatbar:addButton(boldAction)
formatbar:addButton(italicAction)
formatbar:addButton(underlAction)
formatbar:addButton(strikeAction)
formatbar:addButton(superAction)
formatbar:addButton(subAction)

formatbar:addSeparator()

alignLeft = ToolbarButton("Align left")
alignLeft:setIcon(images("align_left.png"))
alignLeft:setOnClick(function()
    textEditor:setTextAlign('left')
end)

alignCenter = ToolbarButton("Align center")
alignCenter:setIcon(images("align_center.png"))
alignCenter:setOnClick(function()
    textEditor:setTextAlign('center')
end)

alignRight = ToolbarButton("Align right")
alignRight:setIcon(images("align_right.png"))
alignRight:setOnClick(function()
    textEditor:setTextAlign('right')
end)

alignJustify = ToolbarButton("Align justify")
alignJustify:setIcon(images("align_justify.png"))
alignJustify:setOnClick(function()
    textEditor:setTextAlign('justify')
end)

formatbar:addButton(alignLeft)
formatbar:addButton(alignCenter)
formatbar:addButton(alignRight)
formatbar:addButton(alignJustify)

formatbar:addSeparator()

indentAction = ToolbarButton("Indent Area")
indentAction.setShortcut("Ctrl+Tab")
indentAction:setIcon(images("indent.png"))

dedentAction = ToolbarButton("Dedent Area")
dedentAction.setShortcut("Shift+Tab")
dedentAction:setIcon(images("outdent.png"))

formatbar:addButton(indentAction)
formatbar:addButton(dedentAction)
