import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.LocalStorage 2.12
import "Theme.js" as Theme
import "Storage.js" as Storage
import "ZyabaUI" as ZyabaUIToolkit

Page {
    id: settingsPage

    signal settingsChanged()

    property color backgroundColor: Theme.getBackgroundColor()
    property color accentColor: Theme.getAccentColor()
    property color keyboardColor: Theme.getKeyboardColor()
    property color textColor: Theme.getTextColor()
    property color cardColor: Theme.getCardColor()
    property color accentationColor: Theme.getAccentColor()
    property int appIcon_Radius: 0

    function refreshTheme() {
	backgroundColor = Theme.getBackgroundColor()
	accentColor = Theme.getAccentColor()
	keyboardColor = Theme.getKeyboardColor()
	textColor = Theme.getTextColor()
	cardColor = Theme.getCardColor()
	accentationColor = Theme.getAccentColor()
	settingsPage.settingsChanged()
    }

    Component.onCompleted: {
	let savedPath = Storage.loadSetting("custom_games_dir", "");
	if (typeof gameManager !== "undefined" && savedPath !== "") {
	    gameManager.customGamesPath = savedPath;
	    pathInput.text = savedPath;
	} else if (typeof gameManager !== "undefined") {
	    pathInput.text = gameManager.getEffectiveGamesDir();
	}

	// Восстановление индексов ComboBox при полной готовности компонента
	themeBox.currentIndex = themeBox.indexOfValue(Storage.loadSetting("selected_theme", "Indigo"))
	if (themeBox.currentIndex === -1) themeBox.currentIndex = 0

	kbColorBox.currentIndex = kbColorBox.indexOfValue(Storage.loadSetting("keyboard_color", "Yellow"))
	if (kbColorBox.currentIndex === -1) kbColorBox.currentIndex = 0

	appIcon_radius_manager.currentIndex = appIcon_radius_manager.indexOfValue(Storage.loadSetting("app_icon_radius", "MD3"))
	if (appIcon_radius_manager.currentIndex === -1) appIcon_radius_manager.currentIndex = 1
    }

    background: Rectangle {
	color: settingsPage.backgroundColor

	Behavior on color {
	    ColorAnimation {
		duration: 200
	    }
	}
    }

    header: ZyabaUIToolkit.Header {
	implicitHeight: 40
	icons_Size: 20
	headerTextSize: 15
	headerText: qsTr("Settings")
	headerBackgroundColor: settingsPage.keyboardColor
	headerTextColor: settingsPage.textColor
	pathOfTrailingIcon: "Icons/back.svg"
	trailingIcon_color: settingsPage.textColor
	borderColor: settingsPage.accentColor
	alignTextByCenter: true
	onOnTrailingActionTriggered: stack.pop()

	Behavior on headerBackgroundColor { ColorAnimation { duration: 200 } }
	Behavior on headerTextColor { ColorAnimation { duration: 200 } }
	Behavior on borderColor { ColorAnimation { duration: 200 } }
	Behavior on trailingIcon_color { ColorAnimation { duration: 200 } }
    }

    Flickable {
	anchors.fill: parent
	contentHeight: settingsCol.height + 40
	clip: true

	ColumnLayout {
	    id: settingsCol
	    width: parent.width - 40
	    anchors.horizontalCenter: parent.horizontalCenter
	    anchors.top: parent.top
	    anchors.topMargin: 20
	    spacing: 20

	    // 1. Выбор темы оформления
	    ColumnLayout {
		Layout.fillWidth: true
		spacing: 8

		Label {
		    text: qsTr("Appearance Theme:")
		    color: settingsPage.textColor
		    font.pixelSize: 14
		    font.bold: true
		}

		ComboBox {
		    id: themeBox
		    Layout.preferredHeight: 40
		    Layout.fillWidth: true
		    model: Theme.getThemeKeys()

		    delegate: ItemDelegate {
			width: themeBox.width
			contentItem: Text {
			    text: modelData
			    color: settingsPage.textColor
			    font.bold: themeBox.currentIndex === index
			    verticalAlignment: Text.AlignVCenter
			}
			background: Rectangle {
			    color: highlighted ? settingsPage.accentColor : settingsPage.cardColor
			    opacity: highlighted ? 0.3 : 1.0
			}
		    }

		    background: Rectangle {
			color: settingsPage.cardColor
			radius: 8
			border.color: settingsPage.accentColor
			border.width: 1
		    }

		    contentItem: Text {
			text: themeBox.displayText
			color: settingsPage.textColor
			verticalAlignment: Text.AlignVCenter
			leftPadding: 10
		    }

		    onActivated: {
			let selected = currentText;
			Theme.setTheme(selected);
			Storage.saveSetting("selected_theme", selected);
			settingsPage.refreshTheme();
		    }
		}
	    }

	    // 2. Полноэкранный режим
	    ZyabaUIToolkit.SwitchItem {
		id: fsSwitch
		main_text: qsTr("Fullscreen Mode")
		sub_text: qsTr("Dive into the full HUD app")
		Layout.preferredHeight: 50
		Layout.fillWidth: true
		bckgColor: "transparent"
		checked: Storage.loadSetting("fullscreen_mode", "false") === "true"
		onToggled: {
		    Storage.saveSetting("fullscreen_mode", checked ? "true" : "false");
		    if (typeof window !== "undefined") {
			window.fullscreen = !window.fullscreen
		    }
		}
	    }

	    // 3. Кастомная директория для игр (.jar + DB)
	    ColumnLayout {
		Layout.fillWidth: true
		spacing: 8

		Label {
		    text: qsTr("Games Storage Directory:")
		    color: settingsPage.textColor
		    font.pixelSize: 14
		    font.bold: true
		}

		RowLayout {
		    Layout.fillWidth: true
		    spacing: 8

		    TextField {
			id: pathInput
			Layout.fillWidth: true
			Layout.preferredHeight: 40
			placeholderText: qsTr("Enter path (e.g. /home/phablet/Games)")
			color: settingsPage.textColor
			font.pixelSize: 13
			selectByMouse: true

			background: Rectangle {
			    color: settingsPage.cardColor
			    radius: 8
			    border.color: settingsPage.accentColor
			    border.width: 1
			}
		    }

		    Button {
			text: qsTr("Set")
			Layout.preferredWidth: 60
			Layout.preferredHeight: pathInput.height

			contentItem: Text {
			    text: parent.text
			    color: settingsPage.textColor
			    font.bold: true
			    horizontalAlignment: Text.AlignHCenter
			    verticalAlignment: Text.AlignVCenter
			}

			background: Rectangle {
			    color: settingsPage.cardColor
			    radius: 8
			    border.color: settingsPage.accentColor
			    border.width: 1
			}

			onClicked: {
			    if (typeof gameManager !== "undefined") {
				let cleanText = pathInput.text.trim();
				gameManager.customGamesPath = cleanText;
				Storage.saveSetting("custom_games_dir", cleanText);
				pathInput.text = gameManager.getEffectiveGamesDir();
				console.log("[Settings] Updated custom path to:", pathInput.text);
			    }
			}
		    }
		}
	    }

	    // 4. Кастомный цвет клавиатуры / кнопок управления
	    ColumnLayout {
		Layout.fillWidth: true
		spacing: 8

		Label {
		    text: qsTr("Virtual Keyboard Accent (Moose Color):")
		    color: settingsPage.textColor
		    font.pixelSize: 14
		    font.bold: true
		}

		ComboBox {
		    id: kbColorBox
		    Layout.fillWidth: true
		    Layout.preferredHeight: 40
		    model: ["Yellow", "Green", "Cyan", "Magenta", "Orange", "White", "Red"]

		    delegate: ItemDelegate {
			width: kbColorBox.width
			contentItem: Text {
			    text: qsTr(modelData)
			    color: settingsPage.textColor
			    font.bold: kbColorBox.currentIndex === index
			    verticalAlignment: Text.AlignVCenter
			}
			background: Rectangle {
			    color: highlighted ? settingsPage.accentColor : settingsPage.cardColor
			    opacity: highlighted ? 0.3 : 1.0
			}
		    }

		    background: Rectangle {
			color: settingsPage.cardColor
			radius: 8
			border.color: settingsPage.accentColor
			border.width: 1
		    }

		    contentItem: Text {
			text: kbColorBox.displayText
			color: settingsPage.textColor
			verticalAlignment: Text.AlignVCenter
			leftPadding: 10
		    }

		    onActivated: {
			let col = currentText;
			Theme.setKeyboardColor(col);
			Storage.saveSetting("keyboard_color", col);
			settingsPage.refreshTheme();
		    }
		}
	    }

	    // 5. Форма иконок приложений
	    ColumnLayout {
		Layout.fillWidth: true
		spacing: 8

		Label {
		    text: qsTr("App Icon Shape:")
		    color: settingsPage.textColor
		    font.pixelSize: 14
		    font.bold: true
		}

		ComboBox {
		    id: appIcon_radius_manager
		    Layout.fillWidth: true
		    Layout.preferredHeight: 40
		    model: ["Circled", "MD3", "iOS", "EdgeUI"]

		    delegate: ItemDelegate {
			width: appIcon_radius_manager.width
			contentItem: Text {
			    text: qsTr(modelData)
			    color: settingsPage.textColor
			    font.bold: appIcon_radius_manager.currentIndex === index
			    verticalAlignment: Text.AlignVCenter
			}
			background: Rectangle {
			    color: highlighted ? settingsPage.accentColor : settingsPage.cardColor
			    opacity: highlighted ? 0.3 : 1.0
			}
		    }

		    background: Rectangle {
			color: settingsPage.cardColor
			radius: 8
			border.color: settingsPage.accentColor
			border.width: 1
		    }

		    contentItem: Text {
			text: appIcon_radius_manager.displayText
			color: settingsPage.textColor
			verticalAlignment: Text.AlignVCenter
			leftPadding: 10
		    }

		    onActivated: {
			let preset = currentText;
			Storage.saveSetting("app_icon_radius", preset);
			settingsPage.refreshTheme();
		    }
		}
	    }
	}
    }
}
