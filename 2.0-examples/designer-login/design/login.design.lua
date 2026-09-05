return {
    root = {
        children = {
            {
                class = "ui.LineEdit",
                form = {
                    label = "Name",
                },
                name = "name",
                props = {
                    hint = "Your name",
                },
            },
            {
                class = "ui.LineEdit",
                form = {
                    label = "Password",
                },
                name = "password",
                props = {
                    hint = "Password",
                    inputMode = "password",
                },
            },
            {
                children = {
                    {
                        kind = "stretch",
                        stretch = 1,
                    },
                    {
                        class = "ui.Button",
                        name = "cancel",
                        props = {
                            text = "Cancel",
                        },
                        stretch = 0,
                    },
                    {
                        class = "ui.Button",
                        name = "ok",
                        props = {
                            text = "OK",
                        },
                        stretch = 0,
                    },
                },
                class = "ui.Container",
                form = {
                    label = "",
                },
                layout = "ui.HLayout",
                name = "buttons",
                props = {
                },
            },
            {
                class = "ui.Label",
                form = {
                    label = "",
                },
                name = "status",
                props = {
                    text = "",
                },
            },
        },
        class = "ui.Container",
        layout = "ui.FormLayout",
        name = "root",
        props = {
        },
    },
    version = 1,
    window = {
        height = 200,
        title = "Login",
        width = 360,
    },
}
