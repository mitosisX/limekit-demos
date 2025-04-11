-- Welcome to the new era for modern lua gui development
window = Window{title='Context Menu - Limekit', icon = images('app.png'), size={400, 400}}
window:setOnContextMenu(function(sender, event)
	local struct = {
    {
        label = "File",
        submenu = {
            {
                label = "New",
                name = 'new_item',
                accelerator = "Ctrl+N",
                click = function()
                    print('New clicked')
                end,
                icon = images('paste.png')
            },
            {label = '-'},
            {
                label = "Open",
                accelerator = "Ctrl+O",
                icon = images('paste.png')
            },
            {
                label = "Save",
                accelerator = "Ctrl+S",
            }
        }
    },
    {
        label = "Edit",
        submenu = {
            {
                label = "Cut",
                accelerator = "Ctrl+X",
                click = function()
                    child = menu:findChild('new_item')
                    child:setText('Changed')
                end
            },
            {
                label = "Copy",
                accelerator = "Ctrl+C",
            },
            {
                label = "Paste",
                submenu = {
                    {
                        label = "Formatted",
                        submenu = {
                            {
                                label = "Why?",
                                submenu = {
	                                {label = 'Just do it!'},
	                                {label = 'Not answering!'}
                                }
                            },
                            {
                                label = "No",
                            }
                        }
                    },
                    {
                        label = "Not Formatted",
                    }
                }
            }
        }
    },
    {
        label = 'Help',
        submenu= {
            {label ='Documentation'},
            {label ='About Limekit'}
        }
    }
}


    menu = Menu()
    menu.buildFromTemplate(struct)
    menu.show(event)

end)
window:show()