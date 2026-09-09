import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.1
import Retro 1.0
import "Theme.js" as Theme
import "Idazketa.js" as Idazketa
import "Storage.js" as Storage
import "ZyabaUI" as ZyabaUIToolkit

Page {
    id: gamePage

    property string targetGamePath: ""
    property bool isEngineReady: false
    property bool virtualKeyboardHidden: false
    property bool softpadHidden: false
    property bool keypadHidden: false
    property bool dialpadHidden: false

    // Динамический массив кастомных кнопок из Idazketa.js
    property var currentCustomKeys: []

    property real iconSizes: 18
    property color pressedColor: "transparent"

    property real keyboardHeight: 300

    /* Dynamic Theme Properties */
    property color zyaba_Color: Theme.getAccentColor()
    property color zyaba_background_Color: Theme.getBackgroundColor()
    property color mooseColor: Theme.getKeyboardColor()
    property color zyaba_text_Color: Theme.getTextColor()

    /* Custom Button HEX Colors (ВЫНЕСЕНО В КОРЕНЬ PAGE) */
    property string btnBgHex: Storage.loadSetting("btn_bg_hex", "#16161a")
    property string btnPressedBgHex: Storage.loadSetting("btn_pressed_bg_hex", "#333333")
    property string btnTextHex: Storage.loadSetting("btn_text_hex", "#ffffff")
    property string btnPressedTextHex: Storage.loadSetting("btn_pressed_text_hex", "#000000")
    property string btnBorderHex: Storage.loadSetting("btn_border_hex", "#2a2a35")
    property string btnPressedBorderHex: Storage.loadSetting("btn_pressed_border_hex", "#ffffff")

    function saveCustomButtonColors() {
	Storage.saveSetting("btn_bg_hex", btnBgHex)
	Storage.saveSetting("btn_pressed_bg_hex", btnPressedBgHex)
	Storage.saveSetting("btn_text_hex", btnTextHex)
	Storage.saveSetting("btn_pressed_text_hex", btnPressedTextHex)
	Storage.saveSetting("btn_border_hex", btnBorderHex)
	Storage.saveSetting("btn_pressed_border_hex", btnPressedBorderHex)
    }

    /* Rainbow Gradient Properties */
    property int rainbowMode: 1
    property real rainbowPhase: 0.0
    property int rainbowSpeed: 3000

    readonly property var rainbowColors: [
	"#FF0000", "#FF7F00", "#FFFF00", "#00FF00", "#00FFFF", "#0000FF", "#8B00FF"
    ]

    NumberAnimation on rainbowPhase {
	from: 0.0
	to: 1.0
	duration: gamePage.rainbowSpeed
	loops: Animation.Infinite
	running: gamePage.rainbowMode !== 0
    }

    function updateColors() {
	zyaba_Color = Theme.getAccentColor()
	zyaba_background_Color = Theme.getBackgroundColor()
	mooseColor = Theme.getKeyboardColor()
	zyaba_text_Color = Theme.getTextColor()
    }

    title: qsTr("Running ") + (retroHost && retroHost.suitName ? retroHost.suitName : "")

    background: Rectangle {
	color: "#0d0d0d"
    }

    Component.onCompleted: {
	updateColors()

	// Загрузка сохранённых настроек из Storage.js
	var savedPresetIndex = parseInt(Storage.loadSetting("layout_preset", "0"))
	applyLayoutPreset(savedPresetIndex)
	presetCombo.currentIndex = savedPresetIndex

	rainbowMode = parseInt(Storage.loadSetting("rainbow_mode", "1"))
	rainbowSpeed = parseInt(Storage.loadSetting("rainbow_speed", "3000"))

	keyboardHeight = parseInt(Storage.loadSetting("keyboard_height", "300"))

	if (targetGamePath !== "") {
	    startGameProcess(targetGamePath)
	}
    }

    function startGameProcess(path) {
	isEngineReady = false
	splashOverlay.opacity = 1.0
	logoImg.visible = true
	splashText.text = qsTr("Core is starting up, please wait...")
	splashText.color = "White"
	busyIndicator.running = true

	var jarCore = "freej2me.jar"
	try {
	    if (appSettings && appSettings.freej2mePath) {
		jarCore = appSettings.freej2mePath
	    }
	} catch(e) {
	    console.log("[QML Warning] Cannot read freej2mePath:", e)
	}

	console.log("[QML] Starting engine for:", path, "Core JAR:", jarCore)
	retroHost.start(jarCore, path)
	keyHandler.forceActiveFocus()
    }

    // Применение раскладки через Idazketa.js + сохранение в Storage.js
    function applyLayoutPreset(index) {
	var p = Idazketa.getPreset(index)
	virtualKeyboardHidden = false
	softpadHidden = p.softpadHidden
	dialpadHidden = p.dialpadHidden
	keypadHidden = p.keypadHidden
	currentCustomKeys = p.customKeys

	Storage.saveSetting("layout_preset", index.toString())
    }

    Item {
	id: keyHandler
	anchors.fill: parent
	focus: true

	function mapNativeKey(event) {
	    switch (event.key) {
		case Qt.Key_Up:        return keyMap["UP"]
		case Qt.Key_Down:      return keyMap["DOWN"]
		case Qt.Key_Left:      return keyMap["LEFT"]
		case Qt.Key_Right:     return keyMap["RIGHT"]
		case Qt.Key_Return:
		case Qt.Key_Enter:
		case Qt.Key_Space:     return keyMap["FIRE"]

		case Qt.Key_Q:
		case Qt.Key_F1:        return keyMap["LSK"]
		case Qt.Key_E:
		case Qt.Key_F2:        return keyMap["RSK"]
		case Qt.Key_Backspace:
		case Qt.Key_Delete:    return keyMap["CLR"]

		case Qt.Key_0:         return keyMap["0"]
		case Qt.Key_1:         return keyMap["1"]
		case Qt.Key_2:         return keyMap["2"]
		case Qt.Key_3:         return keyMap["3"]
		case Qt.Key_4:         return keyMap["4"]
		case Qt.Key_5:         return keyMap["5"]
		case Qt.Key_6:         return keyMap["6"]
		case Qt.Key_7:         return keyMap["7"]
		case Qt.Key_8:         return keyMap["8"]
		case Qt.Key_9:         return keyMap["9"]
		case Qt.Key_Asterisk:  return keyMap["*"]
		case Qt.Key_NumberSign:return keyMap["#"]

		default: return -1
	    }
	}

	Keys.onPressed: {
	    if (!event.isAutoRepeat) {
		var j2meKey = mapNativeKey(event)
		if (j2meKey !== -1) {
		    retroHost.sendKeyPress(j2meKey)
		    event.accepted = true
		} else {
		    retroHost.sendKeyPress(event.key)
		    event.accepted = true
		}
	    }
	}

	Keys.onReleased: {
	    if (!event.isAutoRepeat) {
		var j2meKey = mapNativeKey(event)
		if (j2meKey !== -1) {
		    retroHost.sendKeyRelease(j2meKey)
		    event.accepted = true
		} else {
		    retroHost.sendKeyRelease(event.key)
		    event.accepted = true
		}
	    }
	}
    }

    Settings {
	id: appSettings
	category: "Emulator"
	property string freej2mePath: ""
    }

    readonly property var keyMap: {
	"UP": 0, "DOWN": 1, "LEFT": 2, "RIGHT": 3,
	"9": 4, "7": 5, "0": 6, "FIRE": 7,
	"RSK": 8, "LSK": 9, "1": 10, "3": 11,
	"*": 12, "#": 13, "2": 14, "4": 15,
	"6": 16, "8": 17, "5": 18, "CLR": 19
    }

    Connections {
	target: retroHost

	onRunningChanged: {
	    if (!retroHost.running && isEngineReady) {
		console.log("[QML] Engine process stopped unexpectedly!")
		splashText.text = qsTr("Game is closed or error occured!")
		splashOverlay.opacity = 1.0
		busyIndicator.running = false
	    }
	}

	onFrameReady: {
	    if (!isEngineReady) {
		isEngineReady = true
		busyIndicator.running = false
		splashText.text = qsTr("Initialized successfully!")
		splashAnimation.start()
	    }
	}

	onLogMessage: {
	    console.log(message)
	}

	onConfigLoaded: function(config) {
	    if (config.fps !== undefined) fpsSlider.value = parseInt(config.fps)
	    if (config.scrwidth !== undefined) resW.text = String(config.scrwidth)
	    if (config.scrheight !== undefined) resH.text = String(config.scrheight)

	    var hack = String(config.fpshack || "").toLowerCase()
	    if (hack === "safe") fpsHackCombo.currentIndex = 1
	    else if (hack === "extended") fpsHackCombo.currentIndex = 2
	    else if (hack === "aggressive") fpsHackCombo.currentIndex = 3
	    else fpsHackCombo.currentIndex = 0

	    var bg = String(config.backlightcolor || "").toLowerCase()
	    if (bg === "green") bgCombo.currentIndex = 1
	    else if (bg === "cyan") bgCombo.currentIndex = 2
	    else if (bg === "orange") bgCombo.currentIndex = 3
	    else if (bg === "violet") bgCombo.currentIndex = 4
	    else if (bg === "red") bgCombo.currentIndex = 5
	    else bgCombo.currentIndex = 0

	    var rot = parseInt(config.rotate || 0)
	    if (rot === 90) rotCombo.currentIndex = 1
	    else if (rot === 180) rotCombo.currentIndex = 2
	    else if (rot === 270) rotCombo.currentIndex = 3
	    else rotCombo.currentIndex = 0
	}
    }

    /* ПОПАП НАСТРОЕК */
    Popup {
	id: settingsPopup
	x: (parent.width - width) / 2
	y: (parent.height - height) / 2
	width: Math.min(parent.width * 0.95, 520)
	height: Math.min(parent.height * 0.95, 750)
	modal: true
	closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

	background: Rectangle {
	    color: "#1e1e24"
	    radius: 12
	    border.color: "#33333f"
	    border.width: 1
	}

	ColumnLayout {
	    anchors.fill: parent
	    anchors.margins: 15
	    spacing: 12

	    RowLayout {
		Layout.fillWidth: true
		Label {
		    text: qsTr("Emulator Settings")
		    font.bold: true
		    font.pixelSize: 20
		    color: "White"
		    Layout.fillWidth: true
		}
		ZyabaUIToolkit.SimpleButton {
		    sb_width: 32
		    sb_height: 32
		    iconSize: 16
		    iconPath: "Icons/close.svg"
		    backgroundColor: "transparent"
		    iconColor: "White"
		    onOnTap: settingsPopup.close()
		}
	    }

	    Rectangle { Layout.fillWidth: true; height: 1; color: "#333" }

	    ScrollView {
		Layout.fillWidth: true
		Layout.fillHeight: true
		clip: true

		ColumnLayout {
		    width: parent.width - 10
		    spacing: 14

		    Label { text: qsTr("System Control"); font.bold: true; font.pixelSize: 15; color: gamePage.zyaba_Color }
		    RowLayout {
			Layout.fillWidth: true
			spacing: 8
			Button {
			    text: qsTr("Restart JAR")
			    Layout.fillWidth: true
			    onClicked: { settingsPopup.close(); startGameProcess(targetGamePath) }
			}
			Button {
			    text: qsTr("Kill Core")
			    Layout.fillWidth: true
			    onClicked: { retroHost.stop(); stack.pop() }
			}
		    }

		    Rectangle { Layout.fillWidth: true; height: 1; color: "#2d2d35" }

		    Label { text: qsTr("Controls & Key Layout"); font.bold: true; font.pixelSize: 15; color: gamePage.zyaba_Color }
		    Label { text: qsTr("Preset Layout:"); color: "#ccc" }
		    ComboBox {
			id: presetCombo
			Layout.fillWidth: true
			model: Idazketa.getPresetNames()
			onActivated: gamePage.applyLayoutPreset(index)
		    }

		    Rectangle { Layout.fillWidth: true; height: 1; color: "#2d2d35" }

		    Label { text: qsTr("Keyboard Rainbow Backlight"); font.bold: true; font.pixelSize: 15; color: gamePage.zyaba_Color }
		    Label { text: qsTr("Rainbow Mode:"); color: "#ccc" }
		    ComboBox {
			id: rainbowCombo
			Layout.fillWidth: true
			model: [qsTr("Off (Mono)"), qsTr("Linear Wave"), qsTr("Color Flow"), qsTr("Conical Vortex")]
			currentIndex: gamePage.rainbowMode
			onActivated: {
			    gamePage.rainbowMode = index
			    Storage.saveSetting("rainbow_mode", index.toString())
			}
		    }

		    Label { text: qsTr("Animation Speed (ms): ") + speedSlider.value; color: "#ccc" }
		    Slider {
			id: speedSlider
			Layout.fillWidth: true
			from: 1000; to: 10000; stepSize: 500
			value: gamePage.rainbowSpeed
			onMoved: {
			    gamePage.rainbowSpeed = value
			    Storage.saveSetting("rainbow_speed", value.toString())
			}
		    }

		    Rectangle { Layout.fillWidth: true; height: 1; color: "#2d2d35" }

		    Label { text: qsTr("Screen & Display Tweaks"); font.bold: true; font.pixelSize: 15; color: gamePage.zyaba_Color }
		    Label { text: qsTr("Standard Resolutions:"); color: "#ccc" }
		    ComboBox {
			id: resPresetCombo
			Layout.fillWidth: true
			model: ["Custom", "128x128 (SQ)", "128x160 (K300)", "176x220 (K700)", "240x320 (QVGA)", "320x240 (Landscape)", "360x640 (S60v5)", "480x800 (WVGA)"]
			onActivated: {
			    var w = "240", h = "320";
			    switch (index) {
				case 1: w="128"; h="128"; break;
				case 2: w="128"; h="160"; break;
				case 3: w="176"; h="220"; break;
				case 4: w="240"; h="320"; break;
				case 5: w="320"; h="240"; break;
				case 6: w="360"; h="640"; break;
				case 7: w="480"; h="800"; break;
			    }
			    if (index > 0) {
				resW.text = w
				resH.text = h
				retroHost.setResolution(parseInt(w), parseInt(h))
			    }
			}
		    }

		    Label { text: qsTr("Custom Resolution (W x H):"); color: "#ccc" }
		    RowLayout {
			Layout.fillWidth: true
			TextField { id: resW; text: "240"; Layout.fillWidth: true }
			Label { text: "x"; color: "White" }
			TextField { id: resH; text: "320"; Layout.fillWidth: true }
			Button {
			    text: qsTr("Apply")
			    onClicked: retroHost.setResolution(parseInt(resW.text), parseInt(resH.text))
			}
		    }

		    Label { text: qsTr("Screen Rotation:"); color: "#ccc" }
		    ComboBox {
			id: rotCombo
			Layout.fillWidth: true
			model: ["0°", "90°", "180°", "270°"]
			onActivated: retroHost.setRotation(index * 90)
		    }

		    Rectangle { Layout.fillWidth: true; height: 1; color: "#2d2d35" }

		    Label { text: qsTr("Performance & Hacks"); font.bold: true; font.pixelSize: 15; color: gamePage.zyaba_Color }
		    Label { text: qsTr("FPS Limit: ") + fpsSlider.value; color: "#ccc" }
		    Slider {
			id: fpsSlider
			Layout.fillWidth: true
			from: 0; to: 60; stepSize: 5; value: 60
			onMoved: retroHost.setFpsLimit(value)
		    }

		    Label { text: qsTr("FPS Hacks:"); color: "#ccc" }
		    ComboBox {
			id: fpsHackCombo
			Layout.fillWidth: true
			model: [qsTr("Disabled"), qsTr("Safe"), qsTr("Extended"), qsTr("Aggressive")]
			onActivated: retroHost.setFpsHack(index)
		    }

		    Label { text: qsTr("Hardware Backlight:"); color: "#ccc" }
		    ComboBox {
			id: bgCombo
			Layout.fillWidth: true
			model: [qsTr("Disabled"), qsTr("Green"), qsTr("Cyan"), qsTr("Orange"), qsTr("Violet"), qsTr("Red")]
			onActivated: retroHost.setBacklightColor(index)
		    }

		    Rectangle { Layout.fillWidth: true; height: 1; color: "#2d2d35" }

		    Label {
			text: qsTr("Button HEX Colors Customizer")
			font.bold: true
			font.pixelSize: 15
			color: gamePage.zyaba_Color
		    }

		    // 1. Цвет фона (Обычный / Нажатый)
		    Label { text: qsTr("Background (Normal / Pressed):"); color: "#ccc" }
		    RowLayout {
			Layout.fillWidth: true
			spacing: 8

			TextField {
			    id: bgHexInput
			    text: gamePage.btnBgHex
			    placeholderText: "#16161a"
			    Layout.fillWidth: true
			    color: "White"
			    selectByMouse: true
			    background: Rectangle { color: "#2a2a35"; radius: 6 }
			}

			Rectangle {
			    width: 30; height: 30; radius: 6
			    color: bgHexInput.text
			    border.color: "#555"
			}

			TextField {
			    id: bgPressedHexInput
			    text: gamePage.btnPressedBgHex
			    placeholderText: "#333333"
			    Layout.fillWidth: true
			    color: "White"
			    selectByMouse: true
			    background: Rectangle { color: "#2a2a35"; radius: 6 }
			}

			Rectangle {
			    width: 30; height: 30; radius: 6
			    color: bgPressedHexInput.text
			    border.color: "#555"
			}
		    }

		    // 2. Цвет текста / иконки (Обычный / Нажатый)
		    Label { text: qsTr("Text/Icon (Normal / Pressed):"); color: "#ccc" }
		    RowLayout {
			Layout.fillWidth: true
			spacing: 8

			TextField {
			    id: textHexInput
			    text: gamePage.btnTextHex
			    placeholderText: "#ffffff"
			    Layout.fillWidth: true
			    color: "White"
			    selectByMouse: true
			    background: Rectangle { color: "#2a2a35"; radius: 6 }
			}

			Rectangle {
			    width: 30; height: 30; radius: 6
			    color: textHexInput.text
			    border.color: "#555"
			}

			TextField {
			    id: textPressedHexInput
			    text: gamePage.btnPressedTextHex
			    placeholderText: "#000000"
			    Layout.fillWidth: true
			    color: "White"
			    selectByMouse: true
			    background: Rectangle { color: "#2a2a35"; radius: 6 }
			}

			Rectangle {
			    width: 30; height: 30; radius: 6
			    color: textPressedHexInput.text
			    border.color: "#555"
			}
		    }

		    // 3. Цвет рамки (Обычный / Нажатый)
		    Label { text: qsTr("Border (Normal / Pressed):"); color: "#ccc" }
		    RowLayout {
			Layout.fillWidth: true
			spacing: 8

			TextField {
			    id: borderHexInput
			    text: gamePage.btnBorderHex
			    placeholderText: "#2a2a35"
			    Layout.fillWidth: true
			    color: "White"
			    selectByMouse: true
			    background: Rectangle { color: "#2a2a35"; radius: 6 }
			}

			Rectangle {
			    width: 30; height: 30; radius: 6
			    color: borderHexInput.text
			    border.color: "#555"
			}

			TextField {
			    id: borderPressedHexInput
			    text: gamePage.btnPressedBorderHex
			    placeholderText: "#ffffff"
			    Layout.fillWidth: true
			    color: "White"
			    selectByMouse: true
			    background: Rectangle { color: "#2a2a35"; radius: 6 }
			}

			Rectangle {
			    width: 30; height: 30; radius: 6
			    color: borderPressedHexInput.text
			    border.color: "#555"
			}
		    }

		    // Кнопка применения HEX-палитры
		    Button {
			text: qsTr("Apply Button Colors")
			Layout.fillWidth: true
			onClicked: {
			    gamePage.btnBgHex = bgHexInput.text.trim()
			    gamePage.btnPressedBgHex = bgPressedHexInput.text.trim()
			    gamePage.btnTextHex = textHexInput.text.trim()
			    gamePage.btnPressedTextHex = textPressedHexInput.text.trim()
			    gamePage.btnBorderHex = borderHexInput.text.trim()
			    gamePage.btnPressedBorderHex = borderPressedHexInput.text.trim()

			    gamePage.saveCustomButtonColors()
			}
		    }

		    Label { text: qsTr("Keyboard Height (px): ") + keyboardHeight_slider.value; color: "#ccc" }
		    Slider {
			id: keyboardHeight_slider
			Layout.fillWidth: true
			from: 200; to: 600; stepSize: 1
			value: gamePage.keyboardHeight
			onMoved: {
			    gamePage.keyboardHeight = value
			    Storage.saveSetting("keyboard_height", value.toString())
			}
		    }
		}
	    }
	}
    }

    ColumnLayout {
	anchors.fill: parent
	anchors.margins: 5
	spacing: 5

	RowLayout {
	    Layout.fillWidth: true
	    spacing: 5

	    ZyabaUIToolkit.SimpleButton {
		sb_width: 30
		sb_height: sb_width
		iconSize: iconSizes
		iconPath: "Icons/go-previous.svg"
		backgroundColor: "transparent"
		iconColor: gamePage.mooseColor
		onOnTap: {
		    retroHost.stop()
		    stack.pop()
		}
	    }

	    ZyabaUIToolkit.SimpleButton {
		sb_width: 30
		sb_height: sb_width
		iconSize: iconSizes
		iconPath: "Icons/reset.svg"
		backgroundColor: "transparent"
		iconColor: gamePage.mooseColor
		onOnTap: startGameProcess(targetGamePath)
		onPressedColor: pressedColor
	    }

	    ZyabaUIToolkit.SimpleButton {
		sb_width: 30
		sb_height: sb_width
		iconSize: iconSizes
		iconPath: "Icons/folder-symbolic.svg"
		backgroundColor: "transparent"
		iconColor: gamePage.mooseColor
		onPressedColor: pressedColor
		onOnTap: {
		    var picker = stack.push("ZyabaFilePicker.qml", { nameFilters: ["*.jar", "*.jad", "*.kjx"] })
		    picker.fileSelected.connect(function(path) {
			targetGamePath = path
			startGameProcess(path)
		    })
		}
	    }

	    ZyabaUIToolkit.SimpleButton {
		sb_width: 30
		onPressedColor: pressedColor
		sb_height: sb_width
		iconSize: iconSizes
		iconPath: "Icons/input-gaming-symbolic.svg"
		backgroundColor: "transparent"
		iconColor: virtualKeyboardHidden ? "#333" : gamePage.mooseColor
		onOnTap: {
		    virtualKeyboardHidden = !virtualKeyboardHidden
		}
	    }

	    ZyabaUIToolkit.SimpleButton {
		sb_width: 30
		sb_height: sb_width
		iconSize: iconSizes
		onPressedColor: pressedColor
		iconPath: dialpadHidden ? "Icons/input-dialpad-symbolic.svg" : "Icons/input-dialpad-hidden-symbolic.svg"
		backgroundColor: "transparent"
		iconColor: gamePage.mooseColor
		onOnTap: {
		    dialpadHidden = !dialpadHidden
		}
	    }

	    ZyabaUIToolkit.SimpleButton {
		sb_width: 30
		iconSize: iconSizes
		sb_height: sb_width
		onPressedColor: pressedColor
		iconPath: "Icons/input-keyboard-symbolic.svg"
		backgroundColor: "transparent"
		iconColor: softpadHidden ? "#333" : gamePage.mooseColor
		onOnTap: {
		    softpadHidden = !softpadHidden
		}
	    }

	    ZyabaUIToolkit.SimpleButton {
		sb_width: 30
		onPressedColor: pressedColor
		sb_height: sb_width
		iconSize: iconSizes
		iconPath: "Icons/keypad.svg"
		backgroundColor: "transparent"
		iconColor: keypadHidden ? "#333" : gamePage.mooseColor
		onOnTap: {
		    keypadHidden = !keypadHidden
		}
	    }

	    Item { Layout.fillWidth: true }

	    ZyabaUIToolkit.SimpleButton {
		sb_width: 30
		sb_height: sb_width
		iconSize: iconSizes
		onPressedColor: pressedColor
		Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
		iconPath: "Icons/settings.svg"
		backgroundColor: "transparent"
		iconColor: gamePage.mooseColor
		onOnTap: settingsPopup.open()
	    }

	    ZyabaUIToolkit.SimpleButton {
		sb_width: 30
		sb_height: sb_width
		iconSize: iconSizes
		Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
		iconPath: "Icons/system-shutdown.svg"
		backgroundColor: "transparent"
		iconColor: gamePage.mooseColor
		onPressedColor: pressedColor
		onOnTap: {
		    retroHost.stop(); stack.pop()
		}
	    }
	}

	Rectangle {
	    Layout.fillWidth: true
	    Layout.fillHeight: true
	    Layout.minimumHeight: 200
	    color: "black"

	    J2MEView {
		id: j2meDisplay
		objectName: "j2meView"
		anchors.fill: parent
		host: retroHost

		MouseArea {
		    anchors.fill: parent
		    onPressed: retroHost.sendPointerPressed(mouse.x, mouse.y)
		    onReleased: retroHost.sendPointerReleased(mouse.x, mouse.y)
		    onPositionChanged: {
			if (pressed) retroHost.sendPointerPressed(mouse.x, mouse.y)
		    }
		}
	    }

	    Rectangle {
		id: splashOverlay
		anchors.fill: parent
		color: "#121212"
		z: 10

		ColumnLayout {
		    anchors.centerIn: parent
		    spacing: 15

		    Image {
			id: logoImg
			source: "Zyaba-Splash.svg"
			Layout.preferredWidth: 80
			Layout.preferredHeight: 80
			Layout.alignment: Qt.AlignHCenter
			fillMode: Image.PreserveAspectFit
		    }

		    BusyIndicator {
			id: busyIndicator
			running: true
			Layout.alignment: Qt.AlignHCenter
		    }

		    Label {
			id: splashText
			text: qsTr("Core is starting up, please wait...")
			color: "White"
			font.pixelSize: 14
			font.bold: true
			horizontalAlignment: Text.AlignHCenter
			Layout.alignment: Qt.AlignHCenter
		    }
		}

		SequentialAnimation {
		    id: splashAnimation
		    PauseAnimation { duration: 800 }
		    NumberAnimation {
			target: splashOverlay
			property: "opacity"
			to: 0.0
			duration: 400
			easing.type: Easing.InOutQuad
		    }
		}
	    }
	}

	/* Виртуальная клавиатура */
	Item {
	    id: virtualKeyboard
	    visible: !virtualKeyboardHidden
	    Layout.fillWidth: true
	    Layout.preferredHeight: !dialpadHidden || !keypadHidden || gamePage.currentCustomKeys.length > 0 ? gamePage.keyboardHeight : 50

	    function getButtonColor(xRatio) {
		if (gamePage.rainbowMode === 0) {
		    return gamePage.mooseColor
		}

		var count = rainbowColors.length;
		var effectivePhase = 0.0;

		if (gamePage.rainbowMode === 1) {
		    effectivePhase = (gamePage.rainbowPhase + xRatio) % 1.0;
		} else if (gamePage.rainbowMode === 2 || gamePage.rainbowMode === 3) {
		    effectivePhase = gamePage.rainbowPhase;
		}

		var progress = effectivePhase * count;
		var index1 = Math.floor(progress) % count;
		var index2 = (index1 + 1) % count;
		var factor = progress - Math.floor(progress);

		var c1 = Qt.darker(rainbowColors[index1], 1.0);
		var c2 = Qt.darker(rainbowColors[index2], 1.0);

		return Qt.rgba(
		    c1.r + (c2.r - c1.r) * factor,
		    c1.g + (c2.g - c1.g) * factor,
		    c1.b + (c2.b - c1.b) * factor,
		    1.0
		);
	    }

	    ColumnLayout {
		anchors.fill: parent
		spacing: 5

		// Софт-клавиши (LSK, FIRE, CLR, RSK)
		RowLayout {
		    Layout.fillWidth: true
		    Layout.preferredHeight: 40
		    spacing: 5
		    visible: !softpadHidden

		    Repeater {
			model: [
			    { name: "LSK", icon: "ZyabaUI/Icons/go-first.svg" },
			    { name: "FIRE", icon: "ZyabaUI/Icons/select.svg" },
			    { name: "CLR", icon: "ZyabaUI/Icons/delete.svg" },
			    { name: "RSK", icon: "ZyabaUI/Icons/go-last.svg" }
			]

			J2MEButton {
			    Layout.fillWidth: true
			    Layout.fillHeight: true
			    iconColor: parent.parent.parent.getButtonColor(index / 3.0)
			    iconPath: modelData.icon
			    onWhenPressed: retroHost.sendKeyPress(keyMap[modelData.name])
			    onRelease: retroHost.sendKeyRelease(keyMap[modelData.name])
			}
		    }
		}

		// Нижний блок: D-Pad и Динамическая сетка кнопок
		RowLayout {
		    id: input_DPad
		    Layout.fillWidth: true
		    Layout.fillHeight: true
		    spacing: 5

		    // D-Pad (Стрелки управления)
		    GridLayout {
			Layout.fillWidth: true
			Layout.fillHeight: true
			columns: 3; rows: 3
			visible: !dialpadHidden

			Item { Layout.fillWidth: true; Layout.fillHeight: true }
			J2MEButton {
			    iconPath: "ZyabaUI/Icons/go-up.svg"; Layout.fillWidth: true; Layout.fillHeight: true
			    onWhenPressed: retroHost.sendKeyPress(keyMap["UP"])
			    onRelease: retroHost.sendKeyRelease(keyMap["UP"])
			    iconColor: parent.parent.parent.parent.getButtonColor(0.16)
			}
			Item { Layout.fillWidth: true; Layout.fillHeight: true }

			J2MEButton {
			    iconPath: "ZyabaUI/Icons/go-previous.svg"; Layout.fillWidth: true; Layout.fillHeight: true
			    onWhenPressed: retroHost.sendKeyPress(keyMap["LEFT"])
			    onRelease: retroHost.sendKeyRelease(keyMap["LEFT"])
			    iconColor: parent.parent.parent.parent.getButtonColor(0.0)
			}
			J2MEButton {
			    iconPath: "ZyabaUI/Icons/select.svg"; Layout.fillWidth: true; Layout.fillHeight: true
			    onWhenPressed: retroHost.sendKeyPress(keyMap["FIRE"])
			    onRelease: retroHost.sendKeyRelease(keyMap["FIRE"])
			    iconColor: parent.parent.parent.parent.getButtonColor(0.16)
			}
			J2MEButton {
			    iconPath: "ZyabaUI/Icons/go-next.svg"; Layout.fillWidth: true; Layout.fillHeight: true
			    onWhenPressed: retroHost.sendKeyPress(keyMap["RIGHT"])
			    onRelease: retroHost.sendKeyRelease(keyMap["RIGHT"])
			    iconColor: parent.parent.parent.parent.getButtonColor(0.33)
			}

			Item { Layout.fillWidth: true; Layout.fillHeight: true }
			J2MEButton {
			    iconPath: "ZyabaUI/Icons/go-down.svg"; Layout.fillWidth: true; Layout.fillHeight: true
			    onWhenPressed: retroHost.sendKeyPress(keyMap["DOWN"])
			    onRelease: retroHost.sendKeyRelease(keyMap["DOWN"])
			    iconColor: parent.parent.parent.parent.getButtonColor(0.16)
			}
			Item { Layout.fillWidth: true; Layout.fillHeight: true }
		    }

		    // Чистый динамический NumPad / CustomKeys Блок
		    GridLayout {
			id: dynamicKeypad
			visible: !keypadHidden || gamePage.currentCustomKeys.length > 0
			Layout.fillWidth: true
			Layout.fillHeight: true

			columns: gamePage.currentCustomKeys.length > 0 ? gamePage.currentCustomKeys.length : 3
			rows: gamePage.currentCustomKeys.length > 0 ? 1 : 4

			Repeater {
			    model: gamePage.currentCustomKeys.length > 0
				   ? gamePage.currentCustomKeys
				   : ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"]

			    NumPadKey {
				Layout.fillWidth: true
				Layout.fillHeight: true
				numberPadText: modelData

				// Цвета фона
				backgroundColor: gamePage.btnBgHex
				onPressedColor: gamePage.btnPressedBgHex

				// Цвета текста
				textColor: gamePage.rainbowMode === 0 ? gamePage.btnTextHex : parent.parent.parent.parent.getButtonColor(0.5 + (index % 3) * 0.25)
				textOnPressedColor: gamePage.btnPressedTextHex

				// Цвета рамок
				borderColor: gamePage.btnBorderHex
				onPressedBorderColor: gamePage.btnPressedBorderHex
				borderSize: 1

				onWhenPressed: retroHost.sendKeyPress(keyMap[modelData])
				onRelease: retroHost.sendKeyRelease(keyMap[modelData])
			    }
			}
		    }
		}
	    }
	}
    }
}
