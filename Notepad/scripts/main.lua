-- Welcome to the new era for modern lua gui development
function style()
	s = [[
	/* Tab Widget */
            Tab {
                background: white;
                border: none;
            }
            
            /* Tab Bar */
            QTabBar {
                background: transparent;
                border: none;
            }
            
            /* Individual Tabs */
            QTabBar::tab {
                background: #f5f5f5;
                color: #555;
                padding: 8px 16px;
                border-top-left-radius: 4px;
                border-top-right-radius: 4px;
                margin-right: 4px;
                font-size: 12px;
                min-width: 120px;
                border: 1px solid #e0e0e0;
                border-bottom: none;
            }
            
            /* Selected Tab */
            QTabBar::tab:selected {
                background: white;
                color: #0066cc;
                border-bottom: 2px solid #0066cc;
                font-weight: 500;
            }
            
            /* Hovered Tab */
            QTabBar::tab:hover {
                background: #e8e8e8;
            }
            
            /* Tab Widget Pane (content area) */
            Tab::pane {
                border-top: 1px solid #e0e0e0;
                background: white;
                margin-top: -1px;  /* Align with tab bar */
            }
	]]

	s2 = [[
/* Main tab widget styling */
            Tab {
                background: white;
                border: none;
            }
            
            /* Tab bar styling */
            QTabBar {
                background: #f5f5f5;
                border-bottom: 1px solid #e0e0e0;
            }
            
            /* Individual tabs */
            QTabBar::tab {
                background: #f5f5f5;
                border: 1px solid #e0e0e0;
                border-bottom: none;
                border-top-left-radius: 4px;
                border-top-right-radius: 4px;
                padding: 8px 16px;
                margin-right: 2px;
                color: #555;
            }
            
            QTabBar::tab:selected {
                background: white;
                border-color: #e0e0e0;
                border-bottom-color: white; /* Connect with content area */
                color: #222;
                font-weight: 500;
            }
            
            QTabBar::tab:hover {
                background: #e9e9e9;
            }
            
            QTabBar::close-button:hover {
                background: #e81123;
                border-radius: 2px;
            }
            
            /* Stylish corner button */
            Button {
                background: #4285f4;
                border: none;
                border-radius: 4px;
                padding: 0;
                margin: 3px;
                min-width: 24px;
                min-height: 24px;
            }
            
            Button:hover {
                background: #3367d6;
            }
            
            Button:pressed {
                background: #2a56c6;
            }
            
            Button:disabled {
                background: #cccccc;
            }
            
            /* Icon coloring */
            Button {
                qproperty-iconSize: 16px;
            }
            
            Button {
                color: white;
            }
	]]

	window:setStyle(s)
end

function handleTabClose()
	local item = stateLogic[currentTabIndex]

	if item.hasUnsavedChanges == true then
		local tabText = tab:getTabText(currentTabIndex)
		local reply = app.questionAlertDialog(window, 'Unsaved Changes',string.format('Do you want to save changes to %s?', tabText))

		if reply then
			print('Pressed Yes')
		else
			print('Pressed No')
		end

		tab:removeTab(currentTabIndex)
	end

end

-- function handleEditorTextChange(s, text)
-- 	local item = stateLogic[currentTabIndex]

-- 	if stateLogic[currentTabIndex].hasUnsavedChanges then
-- 		text = tab:getTabText(currentTabIndex)
-- 		showUnsavedIcon()
-- 	else
-- 		stateLogic[currentTabIndex].hasUnsavedChanges = true
-- 	end
-- end

-- Sets content from file to the editor
function setTabContent(content)
	stateLogic[currentTabIndex].editor:setText(content)
end

-- Deals with reading the file and populating content in editor
function loadFileContent(path)
	local fileContent = app.readFile(path)

	stateLogic[currentTabIndex].hasUnsavedChanges = false
	setTabContent(fileContent)
end

-- Only called from menu or shortcut (Ctrl+O)
function openFile()
	local fileName = app.openFileDialog(window, 'Open File','F:\\research area\\side6\\side6 api\\watch',{['lua files']={'.lua'}})
	
	if fileName ~= nil then
		fileOpener(fileName)		
	end
end

-- Can be called from anywhere to open a file
function fileOpener(path)
	-- Let's check if the particular is already open in the editor
	for i, item in ipairs(stateLogic) do
		if item.filePath ~= nil then
			-- Check if the file's path equals to that being opened
			if item.filePath == path then

				tab:setCurrentIndex(i)
				return
			end
		end
	end

	local editor, index, _path = addNewTab(app.getFileName(path), '', path)

	-- setTabIndex(index)
	setState(index, editor, false, _path)

	loadFileContent(path)
end

-- Sets the current tab index, for tracking tabs
function setTabIndex(index)
	currentTabIndex = index
end

-- Switches icon from red to blue
function showSavedIcon()
	tab:setTabIcon(currentTabIndex, images('normal.png'))
end

function showUnsavedIcon()
	tab:setTabIcon(currentTabIndex, images('modified.png'))
end

function setTabFileName(index, name)
	stateLogic[currentTabIndex].filePath = name
end

-- Handles all the saving file logic
function saveFile()
	local item = stateLogic[currentTabIndex]

	if not item.filePath then

		local savedName = app.saveFileDialog(window, 'Save your file', '',
			{['lua file'] = {'.lua'}})


		if savedName ~= nil then
			app.writeFile(savedName, item.editor:getText())

			local fileName = app.getFileName(savedName)

			setTabFileName(currentTabIndex, fileName)

			tab:setTabText(currentTabIndex, fileName)
			item.editor:setModified(false)

			showSavedIcon()
		end
	else
		local savePath = stateLogic[currentTabIndex].filePath
		local saveContent = item.editor:getText()

		app.writeFile(savePath, saveContent)
		item.editor:setModified(false)
		item.hasUnsavedChanges = false	

		showSavedIcon()
	end
end

function createMenu()
	menuStruct = 
	{
    {
        label = '&File', -- Accelerator for letter F
        submenu = {
            {
                name = 'new',
                label = 'New',
                -- icon = images('toolbar/new_project.png'),
                shortcut = "Ctrl+N",
                click = newFile
            }, 
            {
                name = 'open',
                label = 'Open',
                -- icon = images('toolbar/open_project.png'),
                shortcut = "Ctrl+O",
                click = openFile
            },
            {
                name = 'save',
                label = 'Save',
                shortcut = 'Ctrl+S',
                -- icon = images('exit.png'),
                click = saveFile
            },
            {
                name = 'close_tab',
                label = 'Close Tab',
                -- icon = images('exit.png'),
                -- click = function()
                --     app.exit()
                -- end
            },
            {
                name = 'exit',
                label = 'Exit',
                -- icon = images('exit.png'),
                click = function()
                    app.exit()
                end
            }
        }
    }, 
    {
        label = '&Edit',
        name = 'edit_menu',
        submenu = {
            {
                name = 'undo',
                label = "Undo",
                -- click = returnHomePage,
                -- shortcut = "Ctrl+H"
            }, 
            {
                name = 'redo',
                label = "Redo",
                -- click = showAppLog -- Added missing click handler
            }, 
            {
                label = "-",
            }, 
            {
                name = 'cut',
                label = "Cut",
            }, 
            {
                name = 'copy',
                label = "Copy",
            }, 
            {
                name = 'Paste',
                label = "Paste",
            },
        }
    }}

	menubar= Menubar()
	menubar:buildFromTemplate(menuStruct)
	window:setMenubar(menubar)
end

function updateTabIcon(editor)
	local index = tab:getIndexOf(editor)

	if index >= 1 then
		-- Check if the document content have indeed been modified
		if editor:isModified() then
			showUnsavedIcon()
		else
			showSavedIcon()
		end
	end
end

function handleContentChange(s, position, chars_removed, chars_added)
	-- Handle actual content change
	if chars_removed > 0 or chars_added > 0 then
		stateLogic[currentTabIndex].hasUnsavedChanges = true
		-- print('###### Qt thinks really changed')
    end
end

-- Handles creation of a new tab
function addNewTab(title, content, path)

	local editor = TextField()
	editor:setWrapMode('nowrap')
	editor:setPlainText(content)
	editor:setModified(false)

	-- editor:setOnKeyPress(function(s, event)
	-- end)

	editor:setOnModificationChanged(function()
		updateTabIcon(editor)
	end)

	index = tab:addTab(editor, title, images('normal.png'))
	tab:setCurrentIndex(index)
	editor:setFocus()

	return editor, index, path
end

-- Appends to the logic state
function setState(index, editor, filePath)
	stateLogic[index] = {
		editor = editor,
		filePath = filePath
	}
end

function newFile()
	local editor, index, path = addNewTab('Untitled', '', nil)

	setState(index, editor, path)
end

function applyStyles()
	 window:setStyle([[
	 	Window {
		        background-color: #2d2d2d;
		    }
		    QTabWidget::pane {
		        border: 1px solid #444;
		        background: #2d2d2d;
		    }
		    QTabBar::tab {
		        background: #3d3d3d;
		        color: #ddd;
		        padding: 8px;
		        border: 1px solid #444;
		        border-bottom: none;
		        border-top-left-radius: 4px;
		        border-top-right-radius: 4px;
		    }
		    QTabBar::tab:selected {
		        background: #1d1d1d;
		        border-color: #555;
		    }
		    QTabBar::tab:hover {
		        background: #4d4d4d;
		    }
		    QTextEdit {
		        background-color: #1d1d1d;
		        color: #e0e0e0;
		        selection-background-color: #3a3a3a;
		        border: none;
		    }
		    QMenuBar {
		        background-color: #2d2d2d;
		        color: #e0e0e0;
		    }
		    QMenuBar::item:selected {
		        background-color: #3d3d3d;
		    }
		    QMenu {
		        background-color: #2d2d2d;
		        color: #e0e0e0;
		        border: 1px solid #444;
		    }
		    QMenu::item:selected {
		        background-color: #3d3d3d;
		    }
	 ]])
end

currentTabIndex = 1
stateLogic = {}

window = Window{title='New app - Limekit', icon = images('app.png'), size={800, 600}}

mainContainer = Container()
window:setMainChild(mainContainer)

layout = VLayout()
mainContainer:setLayout(layout)

c =  Container()

l = HLayout()
add = Button('+')
add:setFixedSize(30,30)
add:setOnClick(newFile)
l:addChild(add)

c:setLayout(l)

tab = Tab()
tab:setCornerChild(c)
tab:setMovable(true)
tab:setOnTabChange(function(s, index)
	setTabIndex(index)
end)
tab:setOnTabClose(handleTabClose)
tab:setTabsCloseable(true)
layout:addChild(tab)

createMenu()
newFile()

-- applyStyles()
style()

window:show()