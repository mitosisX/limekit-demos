-- Charts.
--
-- Four objects, and the order they go together matters:
--
--   chart.Chart       the plot area, its title and its legend
--   a series          the data: bars, lines, or a filled area
--   an axis           ValueAxis for numbers, CategoryAxis for labels
--   chart.ChartView   the widget you actually put in a layout
--
-- The series decides the shape of the picture. Bars come in four
-- arrangements, and choosing between them is a decision about what the
-- reader should be able to compare:
--
--   BarChart            sets side by side      -- compare regions in a month
--   StackedBarChart     sets piled up          -- compare monthly totals
--   PercentBarChart     piled and scaled       -- compare each region's share
--   HorizontalBarChart  side by side, sideways -- when labels are long
--
-- The 1.x name ChartCanvas still works and refers to the same widget as
-- chart.ChartView.

local ui = require("limekit.ui")
local chart = require("limekit.chart")
local sys = require("limekit.sys")

local window = ui.Window { title = "Charts - Limekit 2.0", size = { 960, 700 } }

-- THE DATA -----------------------------------------------------------------
-- One table, drawn six different ways below. Real apps work like this too:
-- the numbers are yours, and a chart is just a view of them.

local MONTHS = { "Jan", "Feb", "Mar", "Apr", "May", "Jun" }

local REGIONS = {
    { "North",   { 12, 15, 19, 17, 22, 25 } },
    { "South",   {  8,  9, 14, 18, 16, 19 } },
    { "East",    { 20, 18, 15, 13, 17, 21 } },
    { "West",    {  5,  7, 11, 16, 20, 24 } },
    { "Central", {  9, 12, 10, 14, 18, 15 } },
}

-- Every ChartView on screen, so the theme control can reach all of them.
local views = {}

-- Building charts from a function rather than by hand is the whole trick to
-- keeping a dashboard readable: four of the six below share this scaffolding
-- and differ only in the series handed in.
local function barChart(series, title, options)
    options = options or {}

    -- One BarSet per region; each holds one value per month.
    for _, region in ipairs(REGIONS) do
        local set = chart.BarSet(region[1])
        set:append(region[2])
        series:append(set)
    end

    series:setBarWidth(options.barWidth or 0.9)

    if options.labels then
        -- @value is the number the bar stands for. Labels are what make a
        -- percentage chart readable; without them you are eyeballing
        -- proportions.
        series:setLabelsVisible(true)
        series:setLabelsFormat(options.format or "@value")
        series:setLabelsPosition(options.labelPosition or "center")
    end

    local plot = chart.Chart { title = title, animation = "series" }
    plot:setLegendVisibility(true)
    plot:setLegendAlignment("bottom")
    plot:addSeries(series)

    local categories = chart.CategoryAxis(MONTHS)

    local values = chart.ValueAxis()
    values:setRange(0, options.max or 30)
    values:setTitleText(options.axisTitle or "Units sold")

    if options.horizontal then
        -- The axes swap round with the bars: categories down the left,
        -- numbers along the bottom.
        plot:addAxis(categories, "left")
        plot:addAxis(values, "bottom")
    else
        plot:addAxis(categories, "bottom")
        plot:addAxis(values, "left")
    end

    -- Attaching the series to both axes is what makes the bars line up with
    -- the labels. Without it the chart still draws, but against Qt's own
    -- default axis rather than the ones you built.
    series:attachAxis(categories)
    series:attachAxis(values)

    local view = chart.ChartView(plot)
    table.insert(views, view)
    return view
end

-- 1. GROUPED BARS ----------------------------------------------------------
-- Five bars per month, side by side. Good for "who sold most in March", poor
-- for "how did March compare with April overall".

local groupedSeries = chart.BarChart()
local grouped = barChart(groupedSeries, "Sales by region", { max = 30 })

-- 2. STACKED BARS ----------------------------------------------------------
-- The same numbers piled up, so a bar's height is the month's total. Now the
-- month-to-month question is the easy one and the per-region one is harder.

local stackedSeries = chart.StackedBarChart()
local stacked = barChart(stackedSeries, "Total sales per month", {
    max = 110,
    labels = true,
    labelPosition = "center",
})

-- 3. PERCENTAGE BARS -------------------------------------------------------
-- Stacked, then scaled so every bar is full height. Sizes disappear
-- entirely; what is left is each region's share of the month.

local percentSeries = chart.PercentBarChart()
local percent = barChart(percentSeries, "Share of sales per month", {
    max = 100,
    axisTitle = "Share (%)",
    labels = true,
    format = "@value%",
})

-- 4. HORIZONTAL BARS -------------------------------------------------------
-- The grouped chart on its side. Reach for it when the category labels are
-- long enough that they would collide under a vertical axis.

local horizontal = barChart(chart.HorizontalBarChart(), "Sales by region, sideways", {
    max = 30,
    horizontal = true,
})

-- 5. LINES -----------------------------------------------------------------
-- Bars compare discrete things; lines show a trend along a continuous axis.

local lines = chart.Chart { title = "Temperature over a week" }
lines:setLegendVisibility(true)
lines:setLegendAlignment("bottom")

local high = chart.LineChart()
high:setName("Daily high")
-- setData takes the whole series at once, as {x, y} pairs. In 1.x this
-- method printed the points to the console instead of plotting them.
high:setData({ { 1, 21 }, { 2, 23 }, { 3, 26 }, { 4, 25 }, { 5, 28 }, { 6, 31 }, { 7, 29 } })

local low = chart.LineChart()
low:setName("Overnight low")
-- Or append a point at a time, which suits data arriving as you go.
for day, value in ipairs({ 12, 13, 15, 14, 17, 19, 18 }) do
    low:append(day, value)
end

lines:addSeries(high)
lines:addSeries(low)

local days = chart.ValueAxis()
days:setRange(1, 7)
days:setTitleText("Day")
lines:addAxis(days, "bottom")

local degrees = chart.ValueAxis()
degrees:setRange(0, 40)
degrees:setTitleText("Degrees C")
lines:addAxis(degrees, "left")

for _, series in ipairs({ high, low }) do
    series:attachAxis(days)
    series:attachAxis(degrees)
end

local lineView = chart.ChartView(lines)
table.insert(views, lineView)

-- 6. AN AREA ---------------------------------------------------------------
-- An AreaChart fills the gap between two line series, which is the natural
-- way to draw a range -- here, the daily swing between the two lines above.
--
-- It takes the upper and lower series in its constructor. 1.x declared
-- AreaChart("title") and an append() method, neither of which exists on the
-- Qt class underneath, so both raised the moment they were called.

local upper = chart.LineChart()
upper:setData({ { 1, 21 }, { 2, 23 }, { 3, 26 }, { 4, 25 }, { 5, 28 }, { 6, 31 }, { 7, 29 } })

local lower = chart.LineChart()
lower:setData({ { 1, 12 }, { 2, 13 }, { 3, 15 }, { 4, 14 }, { 5, 17 }, { 6, 19 }, { 7, 18 } })

local band = chart.AreaChart(upper, lower)
band:setName("Daily range")

local spread = chart.Chart { title = "How much the temperature moved" }
spread:setLegendVisibility(true)
spread:setLegendAlignment("bottom")
spread:addSeries(band)

local spreadDays = chart.ValueAxis()
spreadDays:setRange(1, 7)
spreadDays:setTitleText("Day")
spread:addAxis(spreadDays, "bottom")

local spreadDegrees = chart.ValueAxis()
spreadDegrees:setRange(0, 40)
spreadDegrees:setTitleText("Degrees C")
spread:addAxis(spreadDegrees, "left")

band:attachAxis(spreadDays)
band:attachAxis(spreadDegrees)

local areaView = chart.ChartView(spread)
table.insert(views, areaView)

-- LIVE DATA ----------------------------------------------------------------
-- A chart is not a picture you draw once. Keeping the series in a variable
-- lets you change it later, and Qt redraws.

local status = ui.Label("Six views of the same figures.")
status:setWordWrap(true)

local added = 0

local addRegion = ui.Button("Add a region")
addRegion:setOnClick(function(sender)
    if added >= 3 then
        status:setText("Five series was already a lot for one chart; that is the point.")
        sender:setEnabled(false)
        return
    end
    added = added + 1

    local values = {}
    for _ = 1, #MONTHS do
        table.insert(values, sys.System.randomChoice({ 4, 7, 9, 12, 15, 18, 21 }))
    end

    local set = chart.BarSet("New " .. added)
    set:append(values)

    -- Only the grouped chart gets it, so you can watch what one more series
    -- costs in readability while the other three stay as they were.
    groupedSeries:append(set)
    status:setText("Added series " .. (5 + added) .. " to the first chart only.")
end)

local widen = ui.Button("Fatten the bars")
widen:setOnClick(function(sender)
    groupedSeries:setBarWidth(1.0)
    sender:setEnabled(false)
    status:setText("setBarWidth is the share of each category slot the bars fill, 0 to 1.")
end)

-- Label placement, applied to both charts that draw labels. An unrecognised
-- name raises and lists the valid ones rather than quietly leaving them put.
local placement = ui.ComboBox({ "center", "insideend", "insidebase", "outsideend" })
placement:setOnItemSelect(function(sender, index)
    if index == 0 then return end
    local position = sender:getItemAt(index)
    stackedSeries:setLabelsPosition(position)
    percentSeries:setLabelsPosition(position)
    status:setText("Value labels moved to " .. position .. ".")
end)

-- THEMES -------------------------------------------------------------------
-- getThemes() reports what the chart module supports, so a ComboBox built
-- from it cannot drift out of step with the code.

local themes = ui.ComboBox(grouped:getThemes())
themes:setOnItemSelect(function(sender, index)
    if index == 0 then return end
    local name = sender:getItemAt(index)
    for _, view in ipairs(views) do
        view:setTheme(name)
    end
    status:setText("Theme " .. name .. ", applied to all " .. #views .. " views.")
end)

-- LAYOUT -------------------------------------------------------------------

local controls = ui.HLayout()
controls:addChild(ui.Label("Theme:"))
controls:addChild(themes)
controls:addChild(ui.VLine())
controls:addChild(ui.Label("Labels:"))
controls:addChild(placement)
controls:addChild(ui.VLine())
controls:addChild(addRegion)
controls:addChild(widen)
controls:addStretch(1)

-- The four bar arrangements together, so the same numbers can be compared
-- shape against shape.
local bars = ui.GridLayout()
bars:setSpacing(8)
bars:addChild(grouped, 1, 1)
bars:addChild(stacked, 1, 2)
bars:addChild(percent, 2, 1)
bars:addChild(horizontal, 2, 2)

local barsPage = ui.TabItem()
barsPage:setLayout(bars)

local trend = ui.HLayout()
trend:addChild(lineView)
trend:addChild(areaView)

local trendPage = ui.TabItem()
trendPage:setLayout(trend)

local tabs = ui.Tab()
tabs:addTab(barsPage, "Four ways to draw bars")
tabs:addTab(trendPage, "Lines and areas")

local layout = ui.VLayout()
layout:setMargins(12, 12, 12, 12)
layout:setSpacing(10)
layout:addLayout(controls)
layout:addChild(tabs, 1)
layout:addChild(ui.HLine())
layout:addChild(status)

window:setLayout(layout)
window:show()
