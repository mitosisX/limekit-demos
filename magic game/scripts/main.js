//Project started on 20 September, 2020
//Algorithms tested and worked on 24 September, 2020 21:55 PM
//Added animations on 25 September, 2020 00:05 AM, stopped at 00:17 AM

theme = Theme('material')
theme.setTheme('light_blue')

window = Window("Magic Game - Miranda")
window.setSize(500, 350)

var peopleData = "Edina,Noah,Juliet,Peter,Dan,Chrissy,Jack,Emmie,Rick,Mary,Sofia,Ezelina,Ronald,Bill,Amanda,Steve,Kate,Rose,Timmy,Ben,Anny";
var animalsData = "Elephant,Hare,Lion,Cheetah,Buffalo,Chicken,Panda,Monkey,Panther,Zebra,Hippo,Giraffe,Beetle,Hyena,Duck,Frog,Cat,Dog,Lizard,Mouse,Bird";
//var font = "Fonts/CeraPro.ttf";

var gameData = {
	people: peopleData,
	animals: animalsData
};

var categoryUse = gameData.people;

var bg = "#6236FF";

top1 = Label("Pick something");

mainLay = VLayout()

hlay = HLayout()
list1 = ListBox();
list2 = ListBox()
list3 = ListBox();

hlay.addChildren(list1, list2, list3)
mainLay.addLayout(hlay)

btnLay = HLayout()

dev = Label("Developed by -- Omega Msiska --");

b = Button("Play Game");
b.onClick(dealToPlace)

sort = Button("How to play");

sort.onClick(function () {
	app.Message("Game rules are simple, pick something with your eyes "+
		"without touching the screen, just keep it to"+ 
		"yourself. After that click one of the three " +
		"bottons to tell the app where your choice is and my app will "+
		"predict your choice");
});

btnLay.addChild(b)
mainLay.addLayout(btnLay)

left = Button("Left");
left.onClick(pickLeft);

middle = Button("Middle");
middle.onClick(pickMiddle);

right = Button("Right");
right.onClick(pickRight);

// app.Message("If you tell me the truth I will always be correct, if you lie, I will lie too!\n\nThis isn't magic but just the power of algorithms. Ok, let's play");
//chooseCategory();

//Called when user touches our button.
function chooseCategory() {
	//Create dialog window.
	dlgTxt = app.CreateDialog("Choose a Category", "NoCancel");

	//Create a layout for dialog.
	layDlg = app.CreateLayout("linear", "vertical,vcenter");
	//   layDlg.SetPadding( 0.02, 0, 0.02, 0.02 );
	dlgTxt.AddLayout(layDlg);

	//Create a list control.
	var list = "Names of People,Names of Animals";
	lstDlg = app.CreateList(list, null, 0.2);
	lstDlg.SetTextSize(22);
	lstDlg.SetTextColor("black");
	lstDlg.SetOnTouch(lst_OnTouch);
	layDlg.AddChild(lstDlg);

	//Show dialog.
	dlgTxt.Show();
}

//Handle list item selection.
function lst_OnTouch(item, b, t, index) {
	//Hide the dialog window.
	dlgTxt.Hide();

	if (index == 0) {
		categoryUse = gameData.people;
	}
	else {
		categoryUse = gameData.animals;
	}
}


//each colums represents an array of names
var columnOne = [];
var columnTwo = [];
var columnThree = [];

var mainList = null;

function dealToPlace() {

	var splitData = shuffleArray(categoryUse.split(','));
	var sevensList = splitSevens(splitData);

	assignColumns(sevensList);      //arrange the data into columns, each column to each list

	mainList = sevensList; //globally store the filtered data
	sevensAllocateLists(sevensList);
}

function sevensAllocateLists(data) {

	var lists = [list1, list2, list3];
	for (countLists in data) {
		var eachList = data[countLists];   //countList is simply an int, this holds the list

		for (listItem in eachList) {    //iterate the current list now
			var getItem = eachList[listItem]
			lists[countLists].addItem(getItem);
		}
	}
}


function shuffleArray(array) {
	var currentIndex = array.length, temporaryValue, randomIndex;

	while (0 !== currentIndex) {
		randomIndex = Math.floor(Math.random() * currentIndex);
		currentIndex -= 1;

		temporaryValue = array[currentIndex];
		array[currentIndex] = array[randomIndex];
		array[randomIndex] = temporaryValue;
	}

	return array;
}


//Responsible for generating the 3 columns of 7 rows
function splitSevens(tokens) {
	var holdTokens = tokens;        // just hold the argument
	var sevensList = [];                 // the main list for the [[], [], []]
	var counter = 7;                      //

	for (var list = 0; list < 3; list++) {
		sevensList.push([]);        // add a blank list at position 
		var tempCounter = counter - 7;  //make sure the list from pos 1 and after 7, then + 7
		for (b = 0; b < 7; b++) {     //run loop 7 times each time
			sevensList[list].push(holdTokens[tempCounter]);
			tempCounter++;           // now keep on increasing after the subtraction
		}
		counter += 7;                    //skip to the next 7th position of the last position
	}

	return sevensList;
}

function tryAssign() {
	assignColumns(mainList);
}


//Assign each column received from splitSevens to each column varible, in order;
function assignColumns(input) {
	var allColumns = getColumnsList();

	for (var columns = 0; columns < 3; columns++) {
		var eachList = input[columns];
		for (var item in eachList) {
			allColumns[columns].push(eachList[item]);
		}
	}
	//alert(JSON.stringify(allColumns));
}

function getColumnsList() {
	var allColumns = [columnOne, columnTwo, columnThree];
	return allColumns;
}


var colPicked = 0;   //1,2,3 to represent each column
function pickLeft() {
	colPicked = 0;
	reOrderColumns()
}

function pickMiddle() {
	colPicked = 1;
	reOrderColumns()
}

function pickRight() {
	colPicked = 2;
	reOrderColumns();
}

//Keep the data consindering that it will be cleared through time. Code will be reused often
function tempHoldColumns() {

	//Hold here for a while to avoid loosing all data after reinitializing originals to empties
	var tempColOne = columnOne;
	var tempColTwo = columnTwo;
	var tempColThree = columnThree;

	columnOne = [];
	columnTwo = [];
	columnThree = [];

	reordering = [tempColOne, tempColTwo, tempColThree];
}


function reOrderColumns() {

	tempHoldColumns();

	var checks = [0, 1, 2];     //Used to check if remaining number is yet in the below list
	var randColSelect = randNotColumn();   //get the column that needs to be in front
	var orderly = [randColSelect, colPicked];  //random picked, column selected

	for (a = 0; a < 3; a++) {
		var num = checks[a]
		if (orderly.indexOf(num) == -1) {   //Yay,it wasn't found
			orderly.push(num);
			break;
		}
	}

	columnOne = reordering[orderly[0]];
	columnTwo = reordering[orderly[1]];
	columnThree = reordering[orderly[2]];

	shareToColumns();
}

var dealTimes = 1;
//Each column will share it's data to other columns, one after another
function shareToColumns() {
	list1.clearItems();
	list2.clearItems();
	list3.clearItems();

	//alert(json(getColumnsList()))

	if (dealTimes <= 2) {
		var counterT = 0;
		tempHoldColumns();
		var realColumns = [columnOne, columnTwo, columnThree];

		var onColumn = 0;   //for alternating columns
		for (a = 0; a < 3; a++) {
			for (var b = 0; b < 7; b++) {
				if (onColumn == 3) {
					onColumn = 0;
				}

				realColumns[onColumn].push(reordering[a][b]);

				onColumn++;
			}
		}

		sevensAllocateLists(getColumnsList());
		dealTimes++;
	}
	else {
		app.Message("I know you chose " + columnTwo[3]);
		dealTimes = 1;
		tempHoldColumns();
	}
}


var ignorePicked = null;
//Any random number but the colPicked
function randNotColumn() {
	var randInt = 0;
	while (true) {
		var gen = rand(0, 2);
		if (gen != colPicked) {

			randInt = gen;
			break;
		}
	}
	return randInt;
}

function rand(min, max) {
	var ra = Math.floor(Math.random() * max) + min
	return ra
}

function json(val) {
	return JSON.stringify(val);
}

window.setLayout(mainLay)
window.show()