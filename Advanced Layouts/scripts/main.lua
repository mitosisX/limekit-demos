-- Welcome to the new era for modern lua gui development

-- Advanced Layouts

function addNestedLayoutTab()
	local tab = TabItem()
	tabWidget:addTab(tab, "Nested Layouts")

	local mainLayout = VLayout()
	tab:setLayout(mainLayout)

	local topLayout = HLayout()

	local leftLayout = VLayout()
	leftLayout:addChild(Label("Left Section"))
	leftLayout:addChild(Button("Button 1"))
	leftLayout:addChild(Button("Button 2"))
	leftLayout:addStretch()

	rightLayout = VLayout()
	rightLayout:addChild(Label("Right Section"))
	rightLayout:addChild(LineEdit("Right Section"))
	rightLayout:addChild(TextField("Multi-line\ntext\narea"))
	rightLayout:addStretch()

	topLayout:addLayout(leftLayout)
	topLayout:addLayout(rightLayout)

	bottomLayout = HLayout()


	local advSlider = AdvancedSlider()
	advSlider:setRange(0, 100)
	advSlider:setValue(10)
	bottomLayout:addChild(advSlider)

	bottomLayout:addChild(Button("Bottom Left"))
	bottomLayout:addStretch()
	bottomLayout:addChild(Button("Bottom Middle"))
	bottomLayout:addStretch()
	bottomLayout:addChild(Button("Bottom Right"))

	mainLayout:addLayout(topLayout)
	mainLayout:addLayout(bottomLayout)
end

function addGridFormMixedTab()
	local tab = TabItem()
	tabWidget:addTab(tab, "Grid & Form")

	local mainLayout = VLayout()
	tab:setLayout(mainLayout)

	local formGroup = GroupBox("Form Layout Example")
	local formLayout = FormLayout()

	formLayout:addChild("Name", LineEdit())
	formLayout:addChild("Email:", LineEdit())
	formLayout:addChild("Age", Spinner())
	formLayout:addChild("Birthday:", DatePicker())
	formLayout:addChild("Membership:", ComboBox())

	formGroup:setLayout(formLayout)
	mainLayout:addChild(formGroup)

	gridGroup = GroupBox("Grid Layout Example")
	gridLayout = GridLayout()

	gridLayout:addChild(Label("Top Left"), 0, 0)
	gridLayout:addChild(Button("Top Right"), 0, 1)
	gridLayout:addChild(CheckBox("Check me"), 1, 0)
	gridLayout:addChild(RadioButton("Option 1"), 1, 1)
	gridLayout:addChild(RadioButton("Option 2"), 2, 1)
	gridLayout:addChild(TextField("Grid\nText\nArea"), 2, 0, 2, 1)
	gridLayout:addChild(Button("Bottom Right"), 3, 1)

	gridGroup:setLayout(gridLayout)
	mainLayout:addChild(gridGroup)
end

function addSplitterLayoutTab()
	local tab = TabItem()
	tabWidget:addTab(tab, "Splitter")

	local mainLayout = VLayout()
	tab:setLayout(mainLayout)

	local hSPlitter = Splitter('horizontal')

	local vSplitterLeft = Splitter('vertical')
	vSplitterLeft:addChild(TextField("Top\nLeft\nText"))

	local listWidget = ListBox()
	listWidget:addItems({"Item 1","Item 2","Item 3", "Item 4"})
	vSplitterLeft:addChild(listWidget)

	local treeWidget = TreeView()
	treeWidget:setHeaders({"Tree View"})

	local root = TreeViewItem("Root")
	local child1 = TreeViewItem("Child 1")
	child1:addRow({TreeViewItem("SubChild 1"), TreeViewItem('Subchild 2')})

	local child2 = TreeViewItem("Child 2")

	root:addRow(child1)
	root:addRow(child2)

	treeWidget:addRow(root)
	treeWidget:expandAll()

	local tableWidget = Table(5, 3)
	tableWidget:setColumnHeaders({"Col 1","Col 2","Col 3"})


	hSPlitter:addChild(vSplitterLeft)
	hSPlitter:addChild(treeWidget)
	hSPlitter:addChild(tableWidget)
	hSPlitter:setSizes({200, 300, 200})

	mainLayout:addChild(hSPlitter)

	local controls = HLayout()
	controls:addChild(Button("Refresh"))
	controls:addStretch()
	controls:addChild(Label("Splitter Position:"))

	local posSlider = Spinner()
	posSlider:setRange(0, 700)
	posSlider:setValue(200)
	posSlider:setOnValueChange(function(sender, v)
		hSPlitter:setSizes({v, 700-v-v//2, v//2})
	end)

	controls:addChild(posSlider)
	mainLayout:addLayout(controls)
end

function addScrollableLayoutTab()
	local tab = TabItem()
	tabWidget:addTab(tab, "Scrollable")

	local mainLayout = VLayout()
	tab:setLayout(mainLayout)

	local scroll= Scroller()
	scroll:setResizable(true)

	local content = Container()
	scroll:setChild(content)

	local contentLayout = VLayout()
	content:setLayout(contentLayout)

	for i = 1, 20 do
		local group = GroupBox(string.format("Section %s", i))
		local layout = HLayout()

		layout:addChild(Label(string.format("Label %s:", i)))
		layout:addChild(LineEdit(string.format("Input for section %s", i)))
		layout:addChild(Button(string.format("Button %s", i)))

		group:setLayout(layout)
		contentLayout:addChild(group)
	end

	contentLayout:addStretch()

	mainLayout:addChild(scroll)

	local controls = HLayout()
	controls:addChild(Label("Scroll Area Example"))
	controls:addStretch()
	controls:addChild(Button("Add Item"))
	controls:addChild(Button("Remove Item"))

	mainLayout:addLayout(controls)
end

function addStackedWidgetTab()
	local tab = TabItem()
	tabWidget:addTab(tab, "Stacked")

	local mainLayout = VLayout()
	tab:setLayout(mainLayout)

	stackedWidget = SlidingStackedWidget()

	formLayout = FormLayout()
	formLayout:addChild("Username:", LineEdit())
	formLayout:addChild("Password:", LineEdit())
	formLayout:addChild(Button("Login"))
	stackedWidget:addLayout(formLayout)

	local gridLayout = GridLayout()
	gridLayout:addChild(Label("Settings"), 0, 0, 1, 2)
	gridLayout:addChild(CheckBox("Option 1"), 1, 0)
	gridLayout:addChild(CheckBox("Option 2"), 1, 1)
	gridLayout:addChild(Button("Save"), 2, 0, 1, 2)
	stackedWidget:addLayout(gridLayout)

	local complexLayout = VLayout()
	local splitter = Splitter('vertical')
	splitter:addChild(TextField("Text Area"))

	local table1 = Table(3, 2) -- well, table is a keyword, so :-D
	table1:setColumnHeaders({"Key","Value"})
	splitter:addChild(table1)

	complexLayout:addChild(splitter)
	complexLayout:addChild(Button("Process Data"))
	stackedWidget:addLayout(complexLayout)

	-- Handle updating current page index
	local function updateStackIndex()
		stackIndexLabel:setText(string.format("Page %s of %s",stackedWidget:getCurrentIndex(), stackedWidget:getCount()))
	end

	-- navigation controls
	local navLayout = HLayout()
	local prevButton = Button("Previous")
	prevButton:setOnClick(function(  )
		stackedWidget:slidePrev()
		updateStackIndex()
	end)
	navLayout:addChild(prevButton)
	navLayout:addStretch()

	stackIndexLabel = Label(string.format("Page %s of %s",stackedWidget:getCurrentIndex(), stackedWidget:getCount()))
	navLayout:addChild(stackIndexLabel)
	navLayout:addStretch()

	local nextButton = Button("Next")
	nextButton:setOnClick(function()
		stackedWidget:slideNext()
		updateStackIndex()
	end)
	navLayout:addChild(nextButton)

	mainLayout:addChild(stackedWidget)

	mainLayout:addLayout(navLayout)

end

function addAdvancedControlsTab()
	local tab = TabItem()
	tabWidget:addTab(tab, "Advanced")

	local mainLayout = VLayout()
	tab:setLayout(mainLayout)

	local function addDynamicField()
		local rowLayout = HLayout()

		local fieldType = ComboBox()
		fieldType:setItems({"Text", "Number", "Date", "Checkbox"})

		local label = LineEdit(string.format("Field %s",dynamicLayout:getCount() + 1))
		local valueWidget = LineEdit()

		rowLayout:addChild(fieldType)
		rowLayout:addChild(label)
		rowLayout:addChild(valueWidget)

		local removeButton = Button('X')
		rowLayout:addChild(removeButton)

		dynamicLayout:addLayout(rowLayout)
	end

	local function addGridItem()
		local row = responsiveItems // 3
		local col = responsiveItems % 3

		local group = GroupBox(string.format("Item %s", responsiveItems + 1))
		local layout = VLayout()

		layout:addChild(Label(string.format("Content for item %s", responsiveItems + 1)))
		layout:addChild(Button("Action"))

		group:setLayout(layout)

		responsiveGrid:addChild(group, row, col)
		responsiveItems = responsiveItems + 1
	end

	local dynamicGroup = GroupBox("Dynamic Form")
	dynamicLayout = VLayout()

	local addButton = Button("Add Field")
	addButton:setOnClick(app.partial(addDynamicField))
	local clearButton = Button("Clear Fields")

	local buttonLayout = HLayout()
	buttonLayout:addChild(addButton)
	buttonLayout:addChild(clearButton)

	local nestedDLayout = VLayout()
	nestedDLayout:addLayout(dynamicLayout)
	nestedDLayout:addLayout(buttonLayout)
	
	dynamicGroup:setLayout(nestedDLayout)

	mainLayout:addChild(dynamicGroup)

	local responsiveGroup = GroupBox("Responsive Grid")
	responsiveGrid = GridLayout()

	responsiveItems = 0
	local addGridButton = Button("Add Grid Item")
	addGridButton:setOnClick(app.partial(addGridItem))

	local resVLayout = VLayout()
	resVLayout:addLayout(responsiveGrid)
	resVLayout:addChild(addGridButton)
	responsiveGroup:setLayout(resVLayout)

	mainLayout:addChild(responsiveGroup)

	for i = 1, 3 do
		addDynamicField()
		addGridItem()
	end
end

window = Window{title='Advanced Layouts - Limekit', icon = images('app.png'), size={800, 600}}

tabWidget = Tab()

addNestedLayoutTab()
addGridFormMixedTab()
addSplitterLayoutTab()
addScrollableLayoutTab()
addStackedWidgetTab()
addAdvancedControlsTab()

window:setMainWidget(tabWidget)


window:show()