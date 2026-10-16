-- report.lua -- the charts, built from whatever the store says right now.
--
-- A chart is a picture of the data at one moment, so rather than trying to
-- update bars in place, every refresh builds a new Chart and hands it to the
-- same ChartView with setChart. That keeps the chart code free of any
-- bookkeeping about what was drawn last time.

local chart = require("limekit.chart")
local Store = require("store")

local Report = {}

--- A bar per category for the filter.
function Report.categoryChart(filter, title)
    local totals = Store.byCategory(filter)

    local set = chart.BarSet("Spent")
    set:append(totals)
    local bars = chart.BarChart()
    bars:append(set)
    bars:setBarWidth(0.7)
    bars:setLabelsVisible(true)
    bars:setLabelsFormat("@value")
    bars:setLabelsPosition("outsideend")

    local plot = chart.Chart { title = title, animation = "series" }
    plot:setLegendVisibility(false)
    plot:addSeries(bars)

    local categories = chart.CategoryAxis(Store.CATEGORIES)
    local values = chart.ValueAxis()
    local top = 0
    for _, total in ipairs(totals) do if total > top then top = total end end
    values:setRange(0, math.max(10, math.ceil(top * 1.15 / 10) * 10))
    values:setTitleText("Amount")
    plot:addAxis(categories, "bottom")
    plot:addAxis(values, "left")
    bars:attachAxis(categories)
    bars:attachAxis(values)
    return plot
end

--- A line through every month's total.
function Report.monthChart()
    local months = Store.byMonth()

    local line = chart.LineChart()
    line:setName("Monthly total")
    local points, labels, top = {}, {}, 0
    for index, entry in ipairs(months) do
        points[#points + 1] = { index, math.floor(entry.total + 0.5) }
        labels[#labels + 1] = entry.month:sub(6) .. "/" .. entry.month:sub(3, 4)
        if entry.total > top then top = entry.total end
    end
    if #points == 0 then points = { { 1, 0 } }; labels = { "-" } end
    line:setData(points)

    local plot = chart.Chart { title = "Spending by month", animation = "series" }
    plot:setLegendVisibility(false)
    plot:addSeries(line)

    local months_ = chart.CategoryAxis(labels)
    local values = chart.ValueAxis()
    values:setRange(0, math.max(10, math.ceil(top * 1.15 / 50) * 50))
    values:setTitleText("Amount")
    plot:addAxis(months_, "bottom")
    plot:addAxis(values, "left")
    line:attachAxis(months_)
    line:attachAxis(values)
    return plot
end

return Report
