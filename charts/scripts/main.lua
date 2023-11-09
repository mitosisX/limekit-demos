window = Window{title='Charts - Limekit', size={400, 300}, icon=route('app_icon')}
Theme('darklight'):setTheme('dark')
mainLay = GridLayout()

combo = ComboBox()
combo:setOnItemSelected(function(obj, item)
	canvas:setTheme(item)
end)

mainLay:addChild(combo, 0, 0)

barChart = Chart{title="Simple barchat Example", animation=nil}

canvas = ChartCanvas(barChart)
combo:addItems(canvas:getThemes())

line_chart = BarChart()
category = CategoryAxis({"Jan", "Feb", "Mar", "Apr", "May", "Jun"})
barChart:setLegendVisibility(true)
barChart:setLegendAlignment('bottom')

set_0 = BarSet("Jane")
set_1 = BarSet("John")
set_2 = BarSet("Axel")
set_3 = BarSet("Mary")
set_4 = BarSet("Samantha")

set_0:append({1, 2, 3, 4, 5, 6})
set_1:append({5, 0, 0, 4, 0, 7})
set_2:append({3, 5, 8, 13, 8, 5})
set_3:append({5, 6, 7, 3, 4, 5})
set_4:append({9, 7, 5, 3, 1, 2})

line_chart:append(set_0)
line_chart:append(set_1)
line_chart:append(set_2)
line_chart:append(set_3)
line_chart:append(set_4)

axis_x = ValueAxis()
axis_x:setRange(0, 15)
barChart:addAxis(axis_x, 'left')

barChart:addSeries(line_chart)

barChart:addAxis(category, 'bottom')
line_chart:attachAxis(category)

mainLay:addChild(canvas,1, 0)

window:setLayout(mainLay)
window:show()