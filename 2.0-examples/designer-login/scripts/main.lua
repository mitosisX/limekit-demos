-- A window designed in Limer, wired up here.
--
-- design/login.design.lua is the design; scripts/designed/login.lua is what
-- the designer generated from it. This file is the only one written by
-- hand: it requires the module and puts behaviour on the widgets by name.
local login = require("designed.login")

login.ok:setOnClick(function()
    login.status:setText("Hello, " .. login.name:getText() .. "!")
end)
login.cancel:setOnClick(function()
    login.window:close()
end)

login.window:show()
