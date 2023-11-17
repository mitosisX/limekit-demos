modal = Modal(window, 'Create a project - Limekit')
v = VLayout()
v:addChild(Label('Hello 1'))
v:addChild(Label('Hello 2'))

buttons = modal:getButtons({'ok', 'discard'})
modal:setLayout(v)
v:addChild(buttons)

modal:show()
