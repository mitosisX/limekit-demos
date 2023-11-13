app.execute(scripts('commons/functions/main.lua'))

docksLay = VLayout()

toolboxDock = Dock("Toolbox")
toolboxDock:setMaxWidth(250)
-- toolboxDock:setMinWidth(250)

toolboxDock:setMagneticAreas(nil)
toolboxDock:setProperties(nil)

scroller = Scroller()

scrollerLayout = VLayout()
scroller:setLayout(scrollerLayout)
scrollerLayout:setMargins(0, 0, 0, 0)

widgetsAccordion = Accordion() -- The Accordion for all widgets available
appAccordion = Accordion() -- The Accordion for all app functions
pyAccordion = Accordion() -- The Accordion for all python utility methods

scrollerLayout:addChild(widgetsAccordion)
scrollerLayout:addChild(appAccordion)
scrollerLayout:addChild(pyAccordion)

-- ######### Widgets listing
widgetsList = ListBox() -- Holds the the list for available widgets

allWidgetUtils = {
    Button = images('widgets/Button.png'),
    ButtonGroup = images('widgets/ButtonGroup.png'),
    CheckBox = images('widgets/CheckBox.png'),
    Accordion = images('widgets/Accordion.png'),
    ComboBox = images('widgets/ComboBox.png'),
    DoubleSpinner = images('widgets/Spinner.png'),
    GroupBox = images('widgets/GroupBox.png'),
    Chart = images('widgets/chart.png'),
    VerticalLine = images('widgets/line.png'),
    HorizontalLine = images('widgets/line.png'),
    Knob = images('widgets/Button.png'),
    Label = images('widgets/dislay.png'),
    LCDNumber = images('widgets/LCD.png'),
    LineEdit = images('widgets/Button.png'),
    ListBox = images('widgets/ListBox.png'),
    ProgressBar = images('widgets/ProgressBar.png'),
    RadioButton = images('widgets/RadioButton.png'),
    Scroller = images('widgets/Scroller.png'),
    Splitter = images('widgets/splitter.png'),
    Slider = images('widgets/Slider.png'),
    Spinner = images('widgets/Spinner.png'),
    Tab = images('widgets/Tab.png'),
    Table = images('widgets/Table.png'),
    TextField = images('widgets/TextField.png'),
    Window = images('widgets/window.png'),
    GridLayout = images('widgets/gridlayout.png'),
    HLayout = images('widgets/HLayout.png'),
    VLayout = images('widgets/VLayout.png'),
    Modal = images('widgets/modal.png'),
    Calendar = images('widgets/Calendar.png'),
    DatePicker = images('widgets/DateTimePicker.png'),
    TimePicker = images('widgets/TimePicker.png'),
    Docker = images('widgets/menu.png'),
    Menu = images('widgets/Button.png'),
    MenuBar = images('widgets/menubar.png')
}

widgetsList:addImageItems(app.sortTable(allWidgetUtils))

-- ######### App utils listing
appUtilsList = ListBox() -- List for all app utils

allAppUtils = {'splitString', 'range', 'joinTables', 'sleep', 'weightedGraph', 'getStyles', 'setStyle', 'quickSort',
               'makeHash', 'hexToRGB', 'readFileLines', 'toBase64', 'fromBase64', 'emoji', 'extractZip',
               'checkIfFolder', 'checkExists', 'checkFileEmpty', 'checkDirEmpty', 'getFileSize', 'readFile',
               'writeFile', 'createFile', 'appendFile', 'readJSON', 'writeJSON', 'getFont', 'openFile', 'colorPicker',
               'textInput', 'multilineInput', 'comboBoxInput', 'integerInput', 'doubleInput', 'alert', 'errorDialog',
               'aboutAlert', 'criticalAlert', 'infoAlert', 'warningAlert', 'getClipboardText', 'setClipboarText',
               'listFolder', 'createFolder', 'playSound', 'getProcesses', 'killProcess', 'getCPUCount', 'getUsers',
               'getBatteryInfo', 'getDiskPartitions', 'getDiskInfo', 'getBootTime', 'getMachineType',
               'getNetworkNodeName', 'getProcessorName', 'getPlatformName', 'getSystemRelease', 'getOSName',
               'getOSRelease', 'getOSVersion' -- 'checkUniqueChars'
}

-- ######### App utils listing
pyUtilsList = ListBox() -- For all python utils

for x in ipairs(allAppUtils) do
    appUtilsList:addImageItem(allAppUtils[x], images('widgets/method.png'))
end

-- ######### Python utils listing

allPythonUtils = {'str_index', 'method_kwargs', 'getattr', 'getitem', 'table_to_list', 'table_to_dict', 'str_format'}

for x in ipairs(allPythonUtils) do
    pyUtilsList:addImageItem(allPythonUtils[x], images('py.png'))
end

widgetsAccordion:addChild(widgetsList, 'Widgets')
appAccordion:addChild(appUtilsList, 'app.')
pyAccordion:addChild(pyUtilsList, 'Python utils')

toolboxDock:setChild(scroller)

editDBDocks = Dock("Edit Database Cell")

appLog = Dock("Application Log")
appLog:setProperties(nil)

logConsole = TextField()
logConsole:setReadOnly(true) -- console shouldn't be edited

logConsole:setMaxHeight(150)

appLog:setChild(logConsole)

docksLay:addChild(editDBDocks)
