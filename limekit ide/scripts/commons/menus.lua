appMenubarItems = {{
    label = 'File',
    submenu = {{
        name = 'create_project',
        label = 'New Project',
        icon = images('toolbar/new_project.png'),
        shortcut = "Ctrl+N",
        click = projectCreator
    }, {
        label = 'Open Project',
        icon = images('toolbar/open_project.png')
        -- shortcut = "Ctrl+N"
    }, {
        label = '-'
    }, {
        label = 'New Database...',
        icon = images('database_add.png')
        -- shortcut = "Ctrl+N"
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
            name = 'light_theme',
            label = 'Light'
            -- click = changeTheme,

        }, {
            name = 'dark_theme',
            label = 'Dark',
            click = function(o)
                print('Its not dark')
            end
        }}
    }}
}, {
    label = "App",
    submenu = {{
        label = "Run"
    }, {
        label = "-"
    }, {
        label = "Stop",
        shortcut = "Ctrl+X",
        click = function(obj)
            if projectRunnerProcess then
                projectRunnerProcess:stop()
            end
        end

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
}, {
    label = 'Final'
}}
