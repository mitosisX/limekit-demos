window = Window("Calculator - Miranda")
window:setIcon(route('app_icon'))
window:setSize(280, 150)
window:setOnClose(function(obj, event)
    event.ignore()
    question = app.questionPopup(window,'Quit?','Are you sure you want to quit?')
    res = question:getSelectedButton()

    if res == 'yes' then
        event.accept()
    end
end)

shortcut = ShortcutKeys(window, 'Ctrl+Q')
shortcut.setOnKeyPress(function()
    app.quit()
end)

-- site = requests.get('https://webscraper.io/test-sites/e-commerce/allinone')
-- soup = BeautifulSoup(site.text, "html.parser")
-- local divs = py_getatrr(soup).findAll('div','col-sm-4 col-lg-4 col-md-4')

-- length = len(divs)
-- for index = 0, length - 1 do
--     aElement = py_getatrr(divs[index]).find('a','title')
--     text = py_getatrr(aElement).get_text())
--     print(text)
-- end

-- theme = Theme("material")
-- theme:setTheme("light_blue")

mainLay = VLayout()

button = Button('Hello')
button:setOnClick(function()
    alert = app.alert(window,'Hello','I am from Limekit','question', {'ok','open','save','ignore','rety'})
end)

mainLay:addChild(button)

cal = Calendar();
cal.setOnDateChaged(function(obj, date)
    print(date)
end)
-- cal:setDate("12/13/1996");

mainLay:addChild(cal)

-- window:setMainWidget(button)

window:setLayout(mainLay)
window:show()