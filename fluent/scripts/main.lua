window = FluentWindow("Fluent UI - Limekit")
window:setIcon(images("lua.png"))
window:setOnShown(function()
end)
window:setSize(580, 680)

-- theme = Theme("material")
-- theme:setTheme("light_blue")


mainLay = FlowLayout()
mainLay.setContentsMargins(30, 60, 30, 30)
-- mainLay:setContentAlignment('vcenter')
mainLay.setSpacing(6)
mainLay.setContentsMargins(30, 60, 30, 30)

function addCard(icon, title, content)
    card = Card(icon,title,title)
    card:onClick(function(sender)
        makeFlyout(sender)
    end)
    mainLay.addChild(card)
end

function addEmojiCard(icon, title, content)
    card = EmojiCard(icon,title)
    card:onClick(function()
        print(title)
    end)
    mainLay.addChild(card)
end

emojis = {
    ['Woman'] = 'woman_blonde_hair_3d_medium-dark.png',
    ['Chicken'] = 'Chicken.png',
    ['World'] = 'globe_showing_americas_3d.png',
    ['Smilling'] = 'smiling_face_with_heart-eyes_3d.png',
    ['Hotel'] = 'love_hotel_3d.png',
    ['Hot face'] = 'sunrise_3d.png',
    ['Files'] = 'card_index_dividers_3d.png',
    ['Hearts'] = 'Smiling face with hearts.png',
    ['Gift'] = 'wrapped gift.png',
}


for key, value in pairs(emojis) do
    addEmojiCard(images("emoji/"..value),key,key)
end

f = Button('Tooltip')
f:onClick(function(sender)
    tip= PopupTooltip(f, 'Title', 'Content goes here', images('tooltip.jpg'))
    tip:show()
end)
mainLay:addChild(f)

local anim = "pullup"

b = Button('Hello')
b:onClick(function(sender)
    makeFlyout(sender)
end)
mainLay:addChild(b)

function makeFlyout(sender)
    command = CommandBar(window)

    laptop = MenuItem('Developer')
    laptop.setImage(images('laptop.png'))

    windows = MenuItem('Windows')
    windows.setImage(images('windows.png'))

    linux = MenuItem('Linux')
    linux.setImage(images('bash.png'))

    apple = MenuItem('MacOS')
    apple.setImage(images('apple.png'))

    command.addAction(laptop)
    command.addAction(windows)
    command.addAction(linux)
    command.addAction(apple)

    hid1 = MenuItem('WhatsApp')
    hid1.setImage(images('whatsapp.png'))

    hid2 = MenuItem('FaceBook')
    hid2.setImage(images('faceb.png'))

    hid3 = MenuItem('Telegram')
    hid3.setImage(images('teleg.png'))

    hid4 = MenuItem('Instagram')
    hid4.setImage(images('insta.png'))

    command.addExtraMenus(hid1, hid2, hid3, hid4)

    command:setFitWidth()

    fly = Flyout(window, command)
    fly:show(sender, anim)
end

co = ComboBox({"dropdown", "fadein", "pullup", "slideleft", "slideright"})
co:onItemSelected(function(sender, item)
    anim = item
    print(anim)
end)


mainLay:addChild(co)

window.setLayout(mainLay)
window.show()