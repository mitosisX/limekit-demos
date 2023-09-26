window = Window("Fluent UI - Limekit")
window:setIcon(images("lua.png"))
window:setSize(750, 600)

-- theme = Theme("material")
-- theme:setTheme("light_blue")


function showImgPop(title,content,image, sender, window)
    pop = ImagePopup(title,content, image)
    pop:show(sender, window)
end


mainLay = FlowLayout()
-- window:addMenu('Search', FluentIcon.VPN, mainLay)
-- mainLay.setContentsMargins(30, 60, 30, 30)
-- -- mainLay:setContentAlignment('vcenter')
-- mainLay.setSpacing(6)
-- mainLay.setContentsMargins(30, 60, 30, 30)

function addCard(icon, title, content)
    card = Card(icon,title,title)
    card:setOnClick(function(sender)
        makeFlyout(sender)
    end)
    mainLay.addChild(card)
end

function addEmojiCard(icon, title, content)
    card = EmojiCard(icon,title)
    card:onClick(function(sender)
        showImgPop(title,'This is the content for '..content,icon,sender)
    end)
    mainLay.addChild(card)
end

emojis = {
    ['Woman'] = 'woman_blonde_hair_3d_medium-dark.png',
    ['Chicken'] = 'Chicken.png',
    ['World'] = 'globe_showing_americas_3d.png',
    ['Smilling'] = 'smiling_face_with_heart-eyes_3d.png',
    ['Hotel'] = 'love_hotel_3d.png',
    ['Sunrise'] = 'sunrise_3d.png',
    ['Files'] = 'card_index_dividers_3d.png',
    ['Camping'] = 'camping_3d.png',
    ['Gift'] = 'wrapped gift.png',
}


-- p=InfoCard(images('emoji/Chicken.png'),'Chicken','Chickens are a perfect source of proteins')
-- mainLay:addChild(p)

for key, value in pairs(emojis) do
    addEmojiCard(images("emoji/"..value),key,key)
end

f = Button('Tooltip')
f:setOnClick(function(sender)
    -- tip= PopupTooltip(f, 'Title', 'Content goes here', images('tooltip.jpg'))
    -- tip:show()

    SnackBar(window,'Telegram','Lua now has a UI framework that fits!',images('teleg.png'),5000):show()
end)
mainLay:addChild(f)

local anim = "pullup"

b = Button('Hello')
b:setOnClick(function(sender)
    makeFlyout(sender)
end)
mainLay:addChild(b)

-- FluentFlyout: class
function makeFlyout(sender)
    command = CommandBar(window)

    laptop = MenuItem()
    laptop.setImage(images('laptop.png'))

    windows = MenuItem()
    windows.setImage(images('windows.png'))

    linux = MenuItem()
    linux.setImage(images('bash.png'))

    apple = MenuItem()
    apple.setImage(images('apple.png'))

    command.addAction(laptop)

    command.addSeparator()

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

c = Button('img pop')
c:setOnClick(function(sender)
    pop=ImagePopup('Title here','Some random content goes here', images('0.png'))
    pop:show(sender, window)
end)


co = ComboBox({"dropdown", "fadein", "pullup", "slideleft", "slideright"})
co:onItemSelected(function(sender, item)
    anim = item
    print(anim)
end)

mainLay:addChild(c)
mainLay:addChild(co)

window.setLayout(mainLay)
window.show()