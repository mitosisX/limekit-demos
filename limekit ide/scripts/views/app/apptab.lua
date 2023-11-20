appTabMainLay = VLayout()
appTabMainLay:setContentAlignment('top', 'center')

appTabGroup = GroupBox()
appTabGroup:setMinWidth(500)

appContentLay = VLayout()

appTabGroup:setLayout(appContentLay)

appTabMainLay:addChild(appTabGroup)
