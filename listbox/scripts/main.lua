window = Window("Listbox - Limekit")
window:setIcon(route('app_icon'))
window:setSize(400, 200)

main_lay = HLayout()

list_widget = ListBox()

grocery_list = {"cheese", "bacon", "eggs","rice", "soda"}

for index = 1, #grocery_list do
	item = grocery_list[index]
	list_widget:addItem(item)
end

add_button = Button("Add")
add_button:setOnClick(function()
	if text ~= "" then
		text = app.textInput(window, "New Item", "Add item:")
		
		list_widget:addItem(text)
	end
end)

insert_button = Button("Insert")
insert_button:setOnClick(function()
	text = app.textInput(window, "Insert Item", "Insert item:")
	
	if text ~= "" then
		row = list_widget:getCurrentRow()
		row = row + 1

		list_widget:insertItemAt(row, text)
	end
end)

remove_button = Button("Remove")
remove_button:setOnClick(function()
	row = list_widget:getCurrentRow()
	list_widget:removeItem(row)
end)

clear_button = Button("Clear")
clear_button:setOnClick(function()
	list_widget:clearItems()
end)


right_v_box = VLayout()

right_v_box:addChild(add_button)
right_v_box:addChild(insert_button)
right_v_box:addChild(remove_button)
right_v_box:addChild(clear_button)

main_lay:addChild(list_widget)
main_lay.addLayout(right_v_box)

window:setLayout(main_lay)
window:show()