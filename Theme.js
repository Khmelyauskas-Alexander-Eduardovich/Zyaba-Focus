.pragma library

var Zyaba_Themes = {
    "Indigo": {
	name: "Indigo Dark",
	backgroundColor: "#0d0d12",
	cardColor: "#161622",
	headerColor: "#111119",
	textColor: "#FFFFFF",
	subTextColor: "#8888aa",
	accentColor: "Indigo",
	keyboardColor: "Yellow"
    },
    "Lime Grass": {
	name: "Lime Grass (Basque Vibe)",
	backgroundColor: "#051205",
	cardColor: "#0f240f",
	headerColor: "#081908",
	textColor: "#E2F0D9",
	subTextColor: "#85B37D",
	accentColor: "Green",
	keyboardColor: "#00FF66"
    },
    "Default Black": {
	name: "Old-school Black",
	backgroundColor: "#000000",
	cardColor: "#111111",
	headerColor: "#0a0a0a",
	textColor: "#FFFFFF",
	subTextColor: "#777777",
	accentColor: "#FFCC00",
	keyboardColor: "#FFCC00"
    },
    "Cyberpunk 2077": {
	name: "Night City Cyber",
	backgroundColor: "#0a0a12",
	cardColor: "#141424",
	headerColor: "#0f0f1c",
	textColor: "#FEE715",
	subTextColor: "#00F0FF",
	accentColor: "#FF007F",
	keyboardColor: "#00FFFF"
    },
    "Synthwave 84": {
	name: "Neon Synthwave",
	backgroundColor: "#191026",
	cardColor: "#261938",
	headerColor: "#201430",
	textColor: "#01CDFE",
	subTextColor: "#FF71CE",
	accentColor: "#B967FF",
	keyboardColor: "#FF71CE"
    },
    "Hacker Green": {
	name: "Terminal Green",
	backgroundColor: "#020802",
	cardColor: "#061406",
	headerColor: "#040D04",
	textColor: "#00FF66",
	subTextColor: "#009933",
	accentColor: "#00FF66",
	keyboardColor: "#00FF66"
    }
}

var currentThemeKey = "Indigo";
var customKeyboardColor = "";

function getThemeKeys() {
    return Object.keys(Zyaba_Themes);
}

function getCurrentTheme() {
    return Zyaba_Themes[currentThemeKey] || Zyaba_Themes["Indigo"];
}

function getTextColor() {
    return getCurrentTheme().textColor;
}

function getBackgroundColor() {
    return getCurrentTheme().backgroundColor;
}

function getCardColor() {
    return getCurrentTheme().cardColor;
}

function getAccentColor() {
    return getCurrentTheme().accentColor;
}

function getKeyboardColor() {
    return customKeyboardColor !== "" ? customKeyboardColor : (getCurrentTheme().keyboardColor || "Yellow");
}

function setKeyboardColor(color) {
    customKeyboardColor = color;
}

function getThemeName() {
    return getCurrentTheme().name;
}

function setTheme(key) {
    if (Zyaba_Themes[key]) {
	currentThemeKey = key;
	customKeyboardColor = ""; // сбрасываем кастом при смене темы на дефолт темы
	return true;
    }
    return false;
}
