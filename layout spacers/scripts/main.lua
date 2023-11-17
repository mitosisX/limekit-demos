window = Window{title="Layout Stretch - Limekit", icon=route('app_icon')}
-- window:setSize(200, 200)

mainLayout = HLayout()

vLayout1 = VLayout()
vLayout1:addChild(Button("Top (left)"))
vLayout1:addChild(Button("Center (left)"))
vLayout1:addChild(Button("Bottom (left)"))

vLayout2 = VLayout()

vLayout2:addChild(Button("Top (right)"))
vLayout2:addChild(Button("Center (right)"))
vLayout2:addChild(Button("Bottom (right)"))
vLayout1.addExpansion()
vLayout2.addExpansion()

mainLayout:addLayout(vLayout1)
mainLayout:addLayout(vLayout2)

window:setLayout(mainLayout)
window:show()