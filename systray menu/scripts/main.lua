window = Window{title="Input Dialogs - Limekit", icon = route('app_icon'), size={350, 170}}

mainLay = VLayout()

trayMenu = SysTray(route("app_icon"))
menu = Menu()
menu:buildFromTemplate({
	{label = 'File',
		submenu={
			{label='New Database...',
			icon=images('database_add.png'),
			shortcut="Ctrl+N"},

			{label='New Database...',
			icon=images('database_add.png'),
			}
		}
	},
	{label = 'Edit',click=function()print('Clicked Edit') end, icon=route('app_icon')},
	{label = 'View',
		submenu={
			{label='New Database...',
			icon=images('database_add.png'),
			shortcut="Ctrl+N"},

			{label='New Database...',
			icon=images('database_add.png'),
			}
		}
	}
})

combo = ComboBox({'Zebra','Elephant',"Cheeta",'Tiger'})
mainLay:addChild(combo)

trayMenu:setMenu(menu)
window:setLayout(mainLay)
window:show()