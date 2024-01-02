window = Window("list drag-drop - Limekit")
window:setIcon(route('app_icon'))
window:setSize(500, 400)

main_grid = GridLayout()


-- theme = Theme("material")
-- theme:setTheme("light_blue")

icon_label = Label("ICONS")

icon_widget = ListBox()
icon_widget.setIconSizes(50,50)
icon_widget:setAllowDragDrop(true)
icon_widget:setDragEnabled(true)
icon_widget:setItemViewMode("icons")

items = {alarm=images('alarm.png'), avocado=images('avocado.png'),face=images("face.png")
,files=images('files.png'), flower=images('flower.png'), medal=images('medal.png')}

for name, path in pairs(items) do
	icon_widget:addImageItem(name, path)
end

list_label = Label("LIST")

list_widget = ListBox()
list_widget:setAltRowColors(true)
list_widget:setAllowDragDrop(true)
list_widget:setDragEnabled(true)

main_grid:addChild(icon_label, 0, 0)
main_grid:addChild(list_label, 0, 1)
main_grid:addChild(icon_widget, 1, 0)
main_grid:addChild(list_widget, 1, 1)

window:setLayout(main_grid)
window:show()