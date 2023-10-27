window = Window{title="Input Dialogs - Limekit", icon = route('app_icon'), size={350, 170}}

mainLay = VLayout()

coll = Collapsible()
coll.addChild(Label("Hello"), 'Label')

lay = VLayout()
lay:addChild(Button('Click me'))
lay:addChild(Slider())
coll.addLayout(lay, 'Labels', images('lua.png'))

mainLay:addChild(coll)
window:setLayout(mainLay)
window:show()