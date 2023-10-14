window = Window{title='Simple - Limekit', size={280, 170}}
window:setIcon(route('app_icon'))
window:setSize(280, 170)

mainLay = VLayout()

menu = Menubar()
struct = {
    {
        label = "File",
        submenu = {
            {
                label = "New",
                accelerator = "Ctrl+N",
                click = "self.new_file"
            },
            {
                label = "Open",
                accelerator = "Ctrl+O",
                click = "self.open_file"
            },
            {
                label = "Save",
                accelerator = "Ctrl+S",
                click = "self.save_file"
            }
        }
    },
    {
        label = "Edit",
        submenu = {
            {
                label = "Cut",
                accelerator = "Ctrl+X",
                click = "self.cut"
            },
            {
                label = "Copy",
                accelerator = "Ctrl+C",
                click = "self.copy"
            },
            {
                label = "Paste",
                submenu = {
                    {
                        label = "Formatted",
                        submenu = {
                            {
                                label = "Yes",
                                click = "elf.paste_formatted_yes",
                                submenu = {
                                    {label = 'Gender',
                                        submenu = {
                                            {label = 'Male'},
                                            {label = 'Female'}
                                        }}
                                }
                            },
                            {
                                label = "No",
                                click = "self.paste_formatted_no"
                            }
                        }
                    },
                    {
                        label = "Not Formatted",
                        click = "self.paste_not_formatted"
                    }
                }
            }
        }
    },
    {
        label = 'Help'
    }
}

menu:buildFromTemplate(struct)

-- file = Menu('File')
--     newFile = DropMenu('New File')
--         sub = MenuItem("Hello there")
--         newFile:addMenuItem(sub)
--     file:addDropMenu(newFile)

-- menu:addMenuItem(file)
b= Button('Find')
b.setOnClick(function()
    print(Button)
end)
mainLay:addChild(b)

window:setMenubar(menu)

window:setLayout(mainLay)
window:show()