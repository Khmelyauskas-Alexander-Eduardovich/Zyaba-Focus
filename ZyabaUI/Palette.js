.pragma library

// Базовые цвета и константы
const neonGreen = "#00FF66"
const neonYellow = "#FFFF00"
const neonRed = "#FF3333"
const neonBlue = "#3399FF"
const neonPurple = "#9933FF"
const neonCyan = "#00FFFF"
const neonPink = "#FF007F"
const neonOrange = "#FF7F00"
const pureBlack = "#000000"
const pureWhite = "#FFFFFF"
const transparent = "transparent"

const standartGreen = "#00ff00"
const standartRed = "#ff0000"
const standartBlue = "#0000ff"
const standartYellow = "#ffff00"
const standartCyan = "#00ffff"
const standartBlack = "#000000"
const standartWhite = "#ffffff"
const stamdartPink = "#ff00ff"

var palettes = {
    "Cyberpunk Neon": {
	primary: neonCyan,
	secondary: neonPink,
	accent: neonGreen,
	darkBg: "#05050A",
	cardBg: "#0F0F1A",
	borderCol: "#1F1F3D"
    },
    "Matrix Terminal": {
	primary: neonGreen,
	secondary: "#008833",
	accent: "#FFFFFF",
	darkBg: "#010801",
	cardBg: "#041404",
	borderCol: "#0A290A"
    },
    "Synthwave Sunset": {
	primary: "#FF71CE",
	secondary: "#01CDFE",
	accent: "#B967FF",
	darkBg: "#1A002B",
	cardBg: "#2A0D45",
	borderCol: "#4A1B73"
    },
    "Basque Mountain": {
	primary: "#38A169",
	secondary: "#3182CE",
	accent: "#D69E2E",
	darkBg: "#0A120A",
	cardBg: "#132213",
	borderCol: "#223E22"
    },
    "Catalan Gold": {
	primary: "#FFCC00",
	secondary: "#E53E3E",
	accent: "#3182CE",
	darkBg: "#121008",
	cardBg: "#211D10",
	borderCol: "#3D351A"
    },
    "Deep Space Void": {
	primary: "#805AD5",
	secondary: "#D53F8C",
	accent: "#319795",
	darkBg: "#08060B",
	cardBg: "#120E17",
	borderCol: "#221A2E"
    },
    "Blood Moon": {
	primary: "#E53E3E",
	secondary: "#DD6B20",
	accent: "#718096",
	darkBg: "#120808",
	cardBg: "#221010",
	borderCol: "#3D1A1A"
    },
    "Monokai Pro": {
	primary: "#A6E22E",
	secondary: "#66D9EF",
	accent: "#FD971F",
	darkBg: "#2D2A2E",
	cardBg: "#3E3B3F",
	borderCol: "#5B565C"
    }
}

function getPalette(name) {
    return palettes[name] || palettes["Cyberpunk Neon"];
}
