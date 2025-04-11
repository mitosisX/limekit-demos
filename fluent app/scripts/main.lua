window = FluentWindow{title="Fluent UI - Limekit",icon=images("app.png") ,size={750, 600}}
-- window:setMargins(0, 32, 0, 0)

homeLay = VLayout()
homeLay:setContentAlignment('top')
homeLay:setMargins(10,10,10,0)

emojiLay = HLayout()
homeLay:addLayout(emojiLay)

card1 = FEmojiCard(images('emoji/wrapped gift.png'), 'Gift')
emojiLay:addChild(card1)

card2 = FEmojiCard(images('emoji/love_hotel_3d.png'), 'Hotel')
emojiLay:addChild(card2)

card3 = FEmojiCard(images('emoji/Chicken.png'), 'Chicken')
emojiLay:addChild(card3)

card4 = FEmojiCard(images('emoji/woman_blonde_hair_3d_medium-dark.png'), 'Woman')
emojiLay:addChild(card4)

hLay = HLayout()

function showFlyOut(sender)

    sn = SnackBar(window, "Hello","content here man",images('teleg.png'),3000)
    sn:show('info')
    -- pop=ImagePopup('Title here','Some random content goes here', images('0.png'))
    -- pop:show(sender, window)
end

button =Button("Flyout")
button:setResizeRule('fixed','fixed')
button:setOnClick(function(sender)
    showFlyOut(sender)
end)
homeLay:addChild(button)

fluentButton = FButton()
-- fluentButton.setIcon()
-- homeLay:addChild(fluentButton)

b = FComboBox()
b:addItems({"Lua","JavaScript","Java","PHP","C#","Python",'C','C++'})
-- b:setResizeRule('fixed','fixed')

-- flyout = Flyout(window, b)
-- flyout:show(b, 'dropdown')

c = FComboBox()
c:addItems({"Lua","JavaScript","Java","PHP","C#","Python",'C','C++'})
-- c:setResizeRule('fixed','fixed')

hLay:addChild(b)
hLay:addChild(c)

homeLay:addLayout(hLay)

g = FElevatedCard()

themeBox = FComboBox()
themeBox:addItems({"Light","Dark"})
themeBox:setOnItemSelect(function(sender, theme)
    window:setTheme(theme)
    print(theme)
end)

g:addChild(themeBox)

wi = Widget()
wi.setSize(100,100)
g:addChild(wi)

homeLay:addChild(g)

window:addNavInterface(homeLay, FluentIcon.HOME,'Home')

musicLay = VLayout()

window:addNavInterface(musicLay, FluentIcon.MUSIC,'Music Library')

window:addNavInterfaceSeparator()

videoLay = HLayout()
b = Button()
b:setText('Hello from Video')
videoLay:addChild(b)

window:addNavInterface(videoLay, FluentIcon.VIDEO,'Video Library')



window:show()