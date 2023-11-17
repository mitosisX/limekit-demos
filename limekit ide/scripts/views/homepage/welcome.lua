welcomeView = VLayout()

homeSlider = SlidingStackedWidget()
homeSlider:setOrientation('vertical')
homeSlider:setAnimation('OutExpo')
homeSlider:setOrientation('horizontal')
homeSlider:autoStart()

-- for a = 1, 18 do
--     local img = Label()
--     img:setImage(images(py.str_format('homepage/{}.png', a)))
--     img.resize(10, 10)
--     homeSlider:addChild(img)
-- end

welcomeView:addChild(homeSlider)
