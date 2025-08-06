-- Welcome to the new era for modern lua gui development
-- Omega Msiska (12 April, 2025)

function createDockWidgets()
	-- Create all dock widgets with advanced features

	-- 1. Explorer dock
	fileExplorerDock = Dockable("File Explorer")
	fileExplorer = TreeView()
	fileExplorer:setHeaderHidden(true)

	-- simulate file structure
	local root = TreeViewItem("Project")
	local file1 = TreeViewItem("main.lua")
	local file2 = TreeViewItem("utils.lua")
	local dir1 = TreeViewItem("modules")
	dir1:addRow(TreeViewItem('module1.lua'))
	dir1:addRow(TreeViewItem('module2.lua'))
	root:addRow(file1)
	root:addRow(file2)
	root:addRow(dir1)
	fileExplorer:addRow(root)
	fileExplorer:expandAll()

	fileExplorerDock:setChild(fileExplorer)

	window:addDockable(fileExplorerDock, 'left')
	fileExplorer:setMinWidth(250)

	-- 2. Output console dock
	consoleDock = Dockable("Output Console")
	console = TextField()
	console:setReadOnly(true)
	console:setPlainText("Application started...\n")
	consoleDock:setChild(console)
	window:addDockable(consoleDock,'bottom')

	-- 3. Properties dock (with tabs)
	propertiesDock = Dockable('Properties')
	propertiesTab = Tab()

	-- Properties tab
	local propertiesContainer = Container()
	local propertiesLayout = VLayout()
	propertiesLayout:addChild(Label("Current File Properties"))
	propertiesLayout:addChild(Label("Size: 0 KB"))
	propertiesLayout:addChild(Label("Modified: Just now"))
	propertiesLayout:addStretch()
	propertiesContainer:setLayout(propertiesLayout)

	-- Bookmark tab
	bookmarkWidget = ListBox()
	bookmarkWidget:setItems({"main.lua:32", "utils.lua:15"})

	propertiesTab:addTab(propertiesContainer, "Properties")
	propertiesTab:addTab(bookmarkWidget, "Bookmarks")

	propertiesDock:setChild(propertiesTab)
	window:addDockable(propertiesDock, 'right')

	-- 4. Toolbox dock (with custom title bar)
	toolBoxDock = Dockable("Toolbox")

	toolBoxContainer = Container()
	toolBoxLayout = VLayout()

	-- Add some tool buttons
	for i = 1, 5 do
		local btn = Button(string.format("Tool %s", i))
		btn:setToolTip(string.format('This is tool number %s', i))
		toolBoxLayout:addChild(btn)
	end

	toolBoxLayout:addStretch()
	toolBoxContainer:setLayout(toolBoxLayout)
	toolBoxDock:setChild(toolBoxContainer)

	-- Custom titlebar
	titleContainer = Container()
	titleLayout= HLayout()
	titleLayout:setMargins(0, 0, 0, 0)
	titleLabel = Label("Custom Toolbox")
	titleLayout:addChild(titleLabel)
	titleLayout:addStretch()
	closeBtn = Button("X")
	closeBtn:setFixedSize(20, 20)
	closeBtn:setOnClick(function (  )
		toolBoxDock:setVisible(false)
	end)
	titleLayout:addChild(closeBtn)
	titleContainer:setLayout(titleLayout)
	toolBoxDock:setTitleBarChild(titleContainer)

	window:addDockable(toolBoxDock, 'left')

	-- 5. Terminal Dock (simulated)
	terminalDock = Dockable("Terminal")
	terminal = TextField()
	terminal:setHint("Terminal emulator - type commands here...")
	terminalDock:setChild(terminal)
	window:addDockable(terminalDock, 'bottom')

	-- 6. Search Results Rock
	searchDock = Dockable("Search Results")
	searchResults = TreeView()
	searchResults:setHeaders({"FIle","Line","Match"})
	searchDock:setChild(searchResults)
	window:addDockable(searchDock, 'right')

	-- 7. Dynamic Panel Dock
	dynamicPanelDock = Dockable("Dynamic Panel")
	dynamicPanel = Container()
	local dLayout = VLayout()
	dynamicPanel:setLayout(dLayout)
	dLayout:addChild(Label("Dynamic content will appear here"))
	dynamicPanelDock:setChild(dynamicPanel)
	window:addDockable(dynamicPanelDock, 'left')

	-- Tabify some docks
	window:tabifyDock(fileExplorerDock, toolBoxDock)
	window:tabifyDock(fileExplorerDock, dynamicPanelDock)

	-- Connect to events


end

function createActions()
	local appMenubarItems = {{
	    label = '&File', -- Accelerator for letter F
	    submenu = {{
	        name = 'create_project',
	        label = 'New Project',
	        icon = images('toolbar/new_project.png'),
	        shortcut = "Ctrl+N",
	        click = projectCreator
	    }, {
	        label = 'Open Project',
	        icon = images('toolbar/open_project.png'),
	        shortcut = "Ctrl+O",
	        click = projectOpener
	    }, {
	        label = '-'
	    },
	    {
	        label = 'Exit',
	        icon = images('exit.png'),
	        click = function()
	            app.exit()
	        end
	    }}
	}, {
	    label = '&View',
	    name = 'view',
	    submenu = {{
	        label = "Home Page",
	        click = returnHomePage,
	        shortcut = "Ctrl+H"
	    }, {
	        label = "Application Log"
	    }, {
	        label = "Theme",
	        submenu = {{
	            name = 'light_theme',
	            label = 'Dark',
	            icon = images('app/dark.png'),
	            click = changeTheme
	        }}
	    }}
	}, {
	    label = "&App",
	    submenu = {{
	        label = "Run",
	        shortcut = "Ctrl+R",
	        click = runApp
	    }, {
	        label = "Stop",
	        shortcut = "Ctrl+X",
	        click = function(obj)
	            if projectRunnerProcess then
	                projectRunnerProcess:stop()
	            end
	        end
	    }, {
	        label = "-"
	    }, {
	        label = "Build",
	        shortcut = 'Ctrl+B'
	    }}
	}, {
	    label = "&Help",
	    submenu = {{
	        label = 'Register'
	    }, {
	        label = "About Limekit",
	        click = aboutPage
	    }}
	}}

	local menubar = Menubar()
	menubar:buildFromTemplate(appMenubarItems)
	window:setMenubar(menubar)
end

function createMenus()
end

function createToolbar()
end

function createStatusBar()
end

function addNewEditorTab()
end

function updateWindowTitle()
end

window = Window{title='Advanced Docking - Limekit', icon = images('app.png'), size={1200, 800}}
-- window:setAlwaysOnTop(true)

centralTabs = Tab()
window:setMainChild(centralTabs)

createDockWidgets()
createActions()
createMenus()
createToolbar()
createStatusBar()

addNewEditorTab("Untitled")
updateWindowTitle()

app.setStyle('fusion')
window:show()