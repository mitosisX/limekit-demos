docksLay = VLayout()

toolboxDock = Dock("Toolbox")
toolboxDock:setMaxWidth(250)
-- toolboxDock:setMinWidth(250)

toolboxDock:setMagneticAreas(nil)
toolboxDock:setProperties(nil)

scroller = Scrollable()

scrollerLayout = VLayout()
scroller:setLayout(scrollerLayout)
scrollerLayout:setMargins(0, 0, 0, 0)

widgetsCollapsible = Collapsible() -- The collapsible for all widgets available
appCollapsible = Collapsible() -- The collapsible for all app functions
pyCollapsible = Collapsible() -- The collapsible for all python utility methods

scrollerLayout:addChild(widgetsCollapsible)
scrollerLayout:addChild(appCollapsible)
scrollerLayout:addChild(pyCollapsible)

items = {
    alarm = images('print.png'),
    avocado = images('print.png'),
    face = images("print.png"),
    files = images('print.png'),
    flower = images('print.png'),
    medal = images('print.png')
}

-- ######### Widgets listing
widgetsList = ListBox() -- Holds the the list for available widgets

allWidgetUtils = {
    Button = images('Button.png'),
    ButtonGroup = images('Button.png'),
    CheckBox = images('Button.png'),
    Collapsible = images('Button.png'),
    ComboBox = images('Button.png'),
    DoubleSpinner = images('Button.png'),
    GroupBox = images('Button.png'),
    HorizontalLine = images('Button.png'),
    Knob = images('Button.png'),
    Label = images('Button.png'),
    LCDNumber = images('Button.png'),
    LineEdit = images('Button.png'),
    ListBox = images('Button.png'),
    ProgressBar = images('Button.png'),
    RadioButton = images('Button.png'),
    Scrollable = images('Button.png'),
    Segmenter = images('Button.png'),
    Slider = images('Button.png'),
    SpinBox = images('Button.png'),
    Tab = images('Button.png'),
    Table = images('Button.png'),
    TextField = images('Button.png'),
    VerticalLine = images('Button.png'),
    Window = images('Button.png'),
    HLayout = images('Button.png'),
    VLayout = images('Button.png'),
    Calendar = images('Button.png'),
    DatePicker = images('Button.png'),
    TimePicker = images('Button.png'),
    Docker = images('Button.png'),
    Menu = images('Button.png'),
    MenuBar = images('Button.png')
}

widgetsList:addImageItems(allWidgetUtils)

-- ######### App utils listing
appUtilsList = ListBox() -- List for all app utils

allAppUtils = {'joinTables', 'sleep', 'weightedGraph', 'getStyles', 'setStyle', 'quickSort', 'makeHash', 'hexToRGB',
               'readFileLines', 'toBase64', 'fromBase64', 'emoji', 'extractZip', 'checkIfFolder', 'checkExists',
               'checkFileEmpty', 'checkDirEmpty', 'getFileSize', 'readFile', 'writeFile', 'createFile', 'appendFile',
               'readJSON', 'writeJSON', 'getFont', 'openFile', 'colorPicker', 'textInput', 'multilineInput',
               'comboBoxInput', ' integerInput', 'doubleInput', 'alert', 'errorDialog', 'aboutPopup', ' criticalPopup',
               'infoPopup', ' warningPopup', 'getClipboardText', 'setClipboarText', 'listFolder', 'createFolder',
               'playSound', ' getProcesses', 'killProcess', 'getCPUCount', 'getUsers', ' getBatteryInfo',
               'getDiskPartitions', 'getDiskInfo', 'getBootTime', 'getMachineType', 'getNetworkNodeName',
               'getProcessorName', ' getPlatformName', 'getSystemRelease', 'getOSName', ' getOSRelease', 'getOSVersion',
               ' checkUniqueChars'}

-- ######### App utils listing
pyUtilsList = ListBox() -- For all python utils

for x, apputil in pairs(allAppUtils) do
    appUtilsList:addImageItem(apputil, images('widget.png'))
end

for a = 0, 100 do
    pyUtilsList:addImageItem("Item " .. a, images('py.png'))
end

widgetsCollapsible:addChild(widgetsList, 'Widgets')
appCollapsible:addChild(appUtilsList, 'App utils')
pyCollapsible:addChild(pyUtilsList, 'Python utils')

toolboxDock:setChild(scroller)

editDBDocks = Dock("Edit Database Cell")

appLog = Dock("Application Log")

logConsole = TextField()
logConsole:setReadOnly(true)

logConsole:setMaxHeight(150)

appLog:setChild(logConsole)

docksLay:addChild(editDBDocks)
