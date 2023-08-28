window = Window("Docking - MirandaJS");
window.setSize(500, 500);
window.setIcon(images("calc.png"));

dock = Dock();
b = Button("Click me");

dock.setMagneticAreas(['top', 'bottom', 'left'])
dock.setChild(b);
window.addDock(dock);
window.show();