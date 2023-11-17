appMenubarItems = {{
    label = 'File',
    submenu = {{
        label = 'New Project',
        icon = images('toolbar/new_project.png'),
        shortcut = "Ctrl+N"
    }, {
        label = 'Open Project',
        icon = images('toolbar/open_project.png'),
        shortcut = "Ctrl+N"
    }, {
        label = '-'
    }, {
        label = 'New Database...',
        icon = images('database_add.png'),
        shortcut = "Ctrl+N"
    }, {
        label = 'Exit',
        icon = images('exit.png')
    }}
}, {
    label = 'View',
    name = 'view',
    submenu = {{
        label = "Welcome Message"
    }, {
        label = "Application Log"
    }, {
        label = "Themes",
        submenu = {{
            label = 'Light',
            click = changeTheme
        }, {
            label = 'Dark',
            click = function(o)
                print(o)
            end
        }}
    }}
}, {
    label = "App",
    submenu = {{
        label = "Run"
    }, {
        label = "Stop"
    }, {
        label = "-"
    }, {
        label = "Run"
    }}
}, {
    label = "Tools",
    submenu = {{
        label = "Many"
    }}
}, {
    label = "Help",
    submenu = {{
        label = 'Register'
    }, {
        label = "About Limekit"
    }}
}}
