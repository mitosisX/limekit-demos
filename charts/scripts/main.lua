window = Window{title='Charts - Limekit', size={400, 300}, icon=route('app_icon')}

mainLay = VLayout()

chart = Chart{title="Simple barchat Example"}

canvas = ChartCanvas(chart)

line_chart = BarChart()
chart:setLegendVisibility(true)
chart:setLegendAlignment('bottom')

set_0 = BarSet("Jane")
set_1 = BarSet("John")
set_2 = BarSet("Axel")
set_3 = BarSet("Mary")
set_4 = BarSet("Samantha")

set_0:addData({1, 2, 3, 4, 5, 6})
set_1:addData({5, 0, 0, 4, 0, 7})
set_2:addData({3, 5, 8, 13, 8, 5})
set_3:addData({5, 6, 7, 3, 4, 5})
set_4:addData({9, 7, 5, 3, 1, 2})

line_chart:addData(set_0)
line_chart:addData(set_1)
line_chart:addData(set_2)
line_chart:addData(set_3)
line_chart:addData(set_4)

axis_x = ValueAxis()
axis_x:setRange(0, 15)
chart:addAxis(axis_x, 'left')

chart:addSeries(line_chart)

mainLay:addChild(canvas)

window:setLayout(mainLay)
window:show()