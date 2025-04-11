window = Window {
    title = "Tree Widget - Limekit",
    size = {500, 300},
    icon = images('app.png')
}

mainLay = VLayout()

tree = TreeWidget()
-- tree:setMaxColumns(2)
tree:setColumnWidth(0, 160)
tree:setHeaders({"Fruit Type", "Description"})
tree:addData()

mainLay:addChild(tree)

window:setLayout(mainLay)
window:show()
