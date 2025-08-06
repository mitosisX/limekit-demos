-- Welcome to the new era for modern lua gui development

window = Window{title='Advanced Slider- Limekit', icon = images('app.png'), size={360, 200}}
mainLayout = FormLayout()

slider1 = AdvancedSlider()
slider1:setValue(6)

slider2 = AdvancedSlider()
slider2:setRange(-500.0, 2500.0)
slider2:setValue(100.0)
slider2:setFloat(true)
slider2:setDecimals(2)
slider2:setPrefix('~')
slider2:setSuffix(' €')
slider2:setThousandsSeparator(',')
slider2:setSingleStep(50)
slider2:setPageStep(250)
slider2:setBorderRadius(3)
slider2:setAccentColor('#f0921f')

slider3 = AdvancedSlider()
slider3:setRange(-1.0, -0.1)
slider3:setValue(-0.552)
slider3:setFloat(true)
slider3:setDecimals(3)
slider3:setSuffix('°') 
slider3:setBorderRadius(5)
slider3:setAccentColor('#a033e8')

slider4 = AdvancedSlider()
slider4:setRange(-150.0, 300.0)
slider4:setValue(12.5)
slider4:setFloat(true)
slider4:setBorderRadius(3)
slider4:setAccentColor('#666666')
slider4:setBorderColor('#999999')

mainLayout:addChild("Slider 1:", slider1)
mainLayout:addChild("Slider 2:", slider2)
mainLayout:addChild("Slider 3:", slider3)
mainLayout:addChild("Slider 4:", slider4)

window:setLayout(mainLayout)

window:show()