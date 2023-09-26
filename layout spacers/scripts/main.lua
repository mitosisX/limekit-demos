window = Window("Layout Stretch - Limekit")
window:setIcon(route('app_icon'))
-- window:setSize(200, 200)

mainLayout = HLayout()

vLayout1 = VLayout()
vLayout1:addChild(Button("Top"))
vLayout1:addChild(Button("Center"))
vLayout1:addChild(Button("Bottom"))

vLayout2 = VLayout()

vLayout2:addChild(Button("Top"))
vLayout2:addChild(Button("Center"))
vLayout2:addChild(Button("Bottom"))
vLayout2.addElasticity()

mainLayout:addLayout(vLayout1)
mainLayout:addLayout(vLayout2)

window:setLayout(mainLayout)
window:show()