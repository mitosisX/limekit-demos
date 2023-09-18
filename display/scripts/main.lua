window = Window()
window:center()
window:setIcon(images("lua.png"))
window:setCustomCursor(route('cursor'))

-- app.readFile(misc('sample.txt'))

-- print(py_indexing({1,2,3,4,5,6}, "[0]"))

window:setOnShown(function()
  window:center()
  noti = Notification(images('furniture.png'))
  noti:setMessage('limekit', 'First ever lua material framework!', 'information', 1000)


end)
window:setOnResize(function()
  window:setTitle('Width: '..window:getSize()[0]..' Height: '..window:getSize()[1])
end)
window:setOnClose(function(sender, event)
  -- event.ignore()
  event.accept()
end)
window:setSize(400, 100)

toolbar = Toolbar();

tray = SysTray();
tray:setImage(images("heart.png"));
tray:setVisibility(true);

menubar = Menubar()
menu = Menu();
compose = MenuItem("Compose");
compose:setImage(images("add.png"));

open = MenuItem("Open");
open:setImage(images("open.png"));

exit = MenuItem("Exit");
exit:setImage(images("exit.png"));
menu:addMenuItems(compose, open, exit);
tray:setMenu(menu);

malawi = ToolbarButton();
malawi:setTooltip("Develoepd from Malawi");
malawi:setImage(images("malawi.png"));
toolbar.addAction(malawi);

toolbar.addSeparator();

b = ToolbarButton();
b:setTooltip("hey");
b:setImage(images("icons8_send_50px.png"));
b:onClick(function (self)
  self.setImage(images("icons8_curriculum_50px.png"));
end);
b.setCheckable(true);
toolbar.addAction(b);

 -- window.setMenubar(menu);
window.addToolbar(toolbar);

-- menu = Menu(window);

-- Theme to be used
theme = Theme("material");
 -- theme.setTheme("light_blue");
mainLayout = HLayout();

mainLay1 = VLayout();

button = Button();
button.setText("Click me");
button.setToolTip("I am a tooltip");
button:onClick(function (x) 
  -- app.setClipboardText("Clipboard text!");
   -- app.qPopup(window, 'title', 'message', ['yes', 'apply', 'discard', 'retry'])
   -- alert(window, "Alert title", app.getClipboardText());
  alert(window, "Title here", "These buttons are super cool!", "question", {
    "ok",
    "save",
    "close",
    "cancel",
    "ignore",
    "notoall",
  });

  -- return;
  -- dialog = InputDialog(window);
  -- obtainedText = dialog.getText();
  -- if (obtainedText) x.setText(obtainedText);
end);

mainLay1:addChild(button);

 -- label = Label("Hello World");
combo = ComboBox();
 -- combo.addItems(["Omega", "Msiska", "Mitosis", "X"]);
combo:addDataItems(theme.getThemes());
combo:onItemSelected(function (sender, data) 
  theme:setTheme(data);
end);

progress = ProgressBar();
progress.setValue(20);

spin = Spinner();
spin.setPrefix("%");
spin.setToolTip("Progressbar percentage");
spin:onValueChange(function (sender, value) 
  progress.setValue(value);
end);
spin.setRange(10, 50);

slider = Slider();
slider.setSingleStep(3);
slider.setMaximum(100);
slider.onValueChange(function (sender, value) 
  progress.setProgress(value);
end);

timer = Timer(2000);
cou = 40;

timer.onTick(function (self) 
  progress.setValue(cou);
  cou = cou + 10;
  -- self.stop();
end);

timer.start();

edit = TextEdit();
-- edit.setInputMask('000.000.000.000;_');
edit.setPlaceholderText("Hello");
edit.onTextChange(function (sender, text) 
  console.log(text);
end);

lunch_list = {"egg", "turkey sandwich", "ham sandwich", "cheese", "hummus"};

totalLabel = Label("Total: $0");
totalLabel.setImage(images("icons8_plus_1_year_50px.png"));
-- totalLabel.setTextAlign("right");

lay1 = HLayout();
combo1 = ComboBox();
spin1 = Spinner();
spin1.setPrefix("$");
spin1.setRange(1, 100);
combo1.addItems(lunch_list);

lay1.addChildren(combo1, spin1);

lay2 = HLayout();

combo2 = ComboBox();
combo2.addImageItems({{'heart', images('heart.png') }, {'malawi', images('malawi.png')}});

spin2 = Spinner();
spin2.setPrefix("$");
spin2.setRange(1, 100);
lay2.addChildren(combo2, spin2);

spin1:onValueChange(calculateTotal);
spin2:onValueChange(calculateTotal);

function calculateTotal(sender)
  total = spin1.getValue() + spin2.getValue();
  totalLabel.setText("Total Spent: " + total);
end

styles = ComboBox();
styles.addDataItems(window.getStyles());
styles.onItemSelected(function (sender, style)
  window.setStyle(style);
end);

mainLay1.addChildren(combo, spin, progress, slider, edit, styles);
mainLay1.addLayouts(lay1, lay2);
mainLay1.addChild(totalLabel);

mainLay2 = VLayout();

tab = Tab();
tabitem1 = TabItem();

tab.addTabitem(tabitem1, "Cas&h");

tabitem2 = TabItem();

grid1 = GridLayout();
label1 = Label("Ch&eck No.:");
tedit1 = TextEdit();
grid1.addChild(label1, 0, 0);
grid1.addChild(tedit1, 0, 1);

label2 = Label("Bank:");
tedit2 = TextEdit();
grid1.addChild(label2, 0, 2);
grid1.addChild(tedit2, 0, 3);

label3 = Label("Account No.:");
tedit3 = TextEdit();
grid1.addChild(label3, 1, 0);
grid1.addChild(tedit3, 1, 1);

label4 = Label("Sort Code:");
tedit4 = TextEdit();
grid1.addChild(label4, 1, 2);
grid1.addChild(tedit4, 1, 3);

tabitem2.addChild(grid1);

tab.addTabitem(tabitem2, "Chec&k");

tabitem3 = TabItem();
tab.addTabitem(tabitem3, "Credit &Card");

mainLay1.addChild(tab);

mainLayout.addLayouts(mainLay1, mainLay2);

window.setLayout(mainLayout);
window.show();