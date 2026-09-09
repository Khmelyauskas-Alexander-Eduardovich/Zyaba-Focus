import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.LocalStorage 2.12
import QtQuick.Window 2.12
import "Theme.js" as Theme
import "Storage.js" as Storage
import "ZyabaUI" as ZyabaUIToolkit

Page {
    id: middleware

    property color zyaba_Color: Theme.getAccentColor()
    property color zyaba_background_Color: Theme.getBackgroundColor()
    property bool darkMode: true
    property color mooseColor: Theme.getKeyboardColor()
    property color zyaba_text_Color: Theme.getTextColor()
    property real appIcon_Radius: calculateIconRadius(Storage.loadSetting("app_icon_radius", "MD3"))
    property color accentationColor: Theme.getAccentColor()

    property bool editMode: false
    property var rawGamesList: []

    // 0: По названию (Name), 1: По разработчику (Vendor), 2: По дате (Date)
    property int sortMode: 0

    function calculateIconRadius(preset) {
	switch (preset) {
	    case "Circled": return 999;
	    case "MD3":     return 16;
	    case "iOS":     return 10;
	    case "EdgeUI":  return 0;
	    default:        return 16;
	}
    }

    function updateTheme() {
	zyaba_Color = Theme.getAccentColor()
	zyaba_background_Color = Theme.getBackgroundColor()
	mooseColor = Theme.getKeyboardColor()
	zyaba_text_Color = Theme.getTextColor()
	accentationColor = Theme.getAccentColor()

	appIcon_Radius = calculateIconRadius(Storage.loadSetting("app_icon_radius", "MD3"))
    }

    // Проверка, находится ли игра в избранном
    function isFavorite(filePath) {
	var favs = JSON.parse(Storage.loadSetting("favorite_games", "[]"))
	return favs.indexOf(filePath) !== -1
    }

    // Переключение состояния избранного для игры
    function toggleFavorite(filePath) {
	var favs = JSON.parse(Storage.loadSetting("favorite_games", "[]"))
	var index = favs.indexOf(filePath)
	if (index === -1) {
	    favs.push(filePath)
	} else {
	    favs.splice(index, 1)
	}
	Storage.saveSetting("favorite_games", JSON.stringify(favs))
	refreshGamesList()
    }

    // Сортировка: Сначала Закрепленные (Favorites), затем по sortMode
    function sortGames() {
	rawGamesList.sort(function(a, b) {
	    var isFavA = a.isFav ? 1 : 0
	    var isFavB = b.isFav ? 1 : 0

	    // Приоритет закрепленным элементам
	    if (isFavA !== isFavB) {
		return isFavB - isFavA
	    }

	    if (sortMode === 0) {
		// По имени
		var nameA = (a.gameName || "").toLowerCase()
		var nameB = (b.gameName || "").toLowerCase()
		return nameA.localeCompare(nameB)
	    } else if (sortMode === 1) {
		// По вендору / категории
		var vendorA = (a.vendorName || "").toLowerCase()
		var vendorB = (b.vendorName || "").toLowerCase()
		if (vendorA === vendorB) {
		    return (a.gameName || "").localeCompare(b.gameName || "")
		}
		return vendorA.localeCompare(vendorB)
	    } else if (sortMode === 2) {
		// По дате добавления/файла (от свежих к старым)
		var dateA = a.installTime || a.fileDate || 0
		var dateB = b.installTime || b.fileDate || 0
		return dateB - dateA
	    }
	    return 0
	})
    }

    // Переключение сортировки по кругу
    function cycleSortMode() {
	sortMode = (sortMode + 1) % 3
	refreshGamesList()
    }

    // Загрузка и обновление списка
    function refreshGamesList() {
	if (typeof gameManager !== "undefined") {
	    var list = gameManager.loadInstalledGames()
	    for (var i = 0; i < list.length; i++) {
		list[i].isFav = isFavorite(list[i].filePath)
	    }
	    rawGamesList = list
	    sortGames()
	} else {
	    rawGamesList = []
	}
	applyFilter(topTaskBar.filterText)
    }

    // Фильтрация модели по поисковому запросу
    function applyFilter(query) {
	gamesModel.clear()
	var search = query.trim().toLowerCase()

	for (var i = 0; i < rawGamesList.length; i++) {
	    var item = rawGamesList[i]
	    var nameMatch = item.gameName && item.gameName.toLowerCase().indexOf(search) !== -1
	    var vendorMatch = item.vendorName && item.vendorName.toLowerCase().indexOf(search) !== -1

	    if (search === "" || nameMatch || vendorMatch) {
		gamesModel.append(item)
	    }
	}
	emptyText.visible = (gamesModel.count === 0)
    }

    background: Rectangle {
	color: zyaba_background_Color
    }

    header: ZyabaUIToolkit.PageHeader {
	implicitHeight: 40
	headerTextSize: 15
	icons_Size: 20
	headerText: qsTr("Zyaba-Focus")
	headerBackgroundColor: middleware.mooseColor
	headerTextColor: middleware.zyaba_text_Color
	pathOfLeadingIcon: "Icons/settings.svg"
	onOnLeadingActionTriggered: {
	    var page = stack.push("SettingsPage.qml")
	    if (page) {
		page.settingsChanged.connect(middleware.updateTheme)
	    }
	}
	leadingIcon_color: middleware.zyaba_text_Color
	borderColor: "Purple"
    }

    ListModel {
	id: gamesModel
    }

    Component.onCompleted: {
	var savedTheme = Storage.loadSetting("selected_theme", "Indigo")
	Theme.setTheme(savedTheme)

	var savedKbColor = Storage.loadSetting("keyboard_color", "Yellow")
	Theme.setKeyboardColor(savedKbColor)

	var savedPath = Storage.loadSetting("custom_games_dir", "")
	if (typeof gameManager !== "undefined" && savedPath !== "") {
	    gameManager.customGamesPath = savedPath
	}

	var isFs = Storage.loadSetting("fullscreen_mode", "false") === "true"
	if (isFs && typeof window !== 'undefined') {
	    window.visibility = Window.FullScreen
	}

	updateTheme()
	refreshGamesList()
    }

    Connections {
	target: typeof gameManager !== "undefined" ? gameManager : null
	onCustomGamesPathChanged: {
	    middleware.refreshGamesList()
	}
    }

    StackView.onStatusChanged: {
	if (StackView.status === StackView.Active) {
	    updateTheme()
	    refreshGamesList()
	}
    }

    ColumnLayout {
	anchors.fill: parent
	anchors.margins: 5
	spacing: 5

	ZyabaUIToolkit.TaskBar {
	    id: topTaskBar
	    Layout.fillWidth: true
	    taskBar_backgroundColor: "transparent"
	    taskBar_textColor: middleware.zyaba_text_Color
	    taskBar_iconsColors: middleware.accentationColor

	    iconSRC: "Icons/sort-listitem.svg"

	    negativeAction_visible: true
	    taskBar_showBorder: false
	    negativeAction_iconSRC: "Icons/edit.svg"

	    onSearchTextChanged: function(text) {
		middleware.applyFilter(text)
	    }

	    onTap: {
		middleware.cycleSortMode()
	    }

	    onTapTheNegativeAction: {
		middleware.editMode = !middleware.editMode
	    }
	}

	Text {
	    id: emptyText
	    text: qsTr("No J2ME games... Tap + to install or ▶ to run JAR directly")
	    verticalAlignment: Text.AlignVCenter
	    horizontalAlignment: Text.AlignHCenter
	    color: middleware.mooseColor
	    wrapMode: Text.WordWrap
	    Layout.fillWidth: true
	    Layout.margins: 20
	    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
	    visible: false
	}

	ListView {
	    id: listView
	    Layout.fillHeight: true
	    Layout.fillWidth: true
	    clip: true
	    model: gamesModel

	    delegate: Item {
		width: listView.width
		height: 65

		RowLayout {
		    anchors.fill: parent
		    spacing: 0

		    ZyabaUIToolkit.ItemBard {
			Layout.fillWidth: true
			Layout.fillHeight: true
			main_text: (model.isFav ? "★ " : "") + model.gameName
			sub_text: model.vendorName
			icon_action_source: model.logo
			iconColor: middleware.mooseColor
			item_radius: 0
			iconRadius: appIcon_Radius
			bckgColor: "transparent"
			mainText_Color: model.isFav ? middleware.accentationColor : middleware.mooseColor

			onClicked: {
			    console.log("[Zyaba Middleware] Starting installed game:", model.filePath)
			    window.launchGame(model.filePath)
			}
			onDelay: {
			    middleware.editMode = !middleware.editMode
			}
			onCancel: {
			    middleware.editMode = false
			}
		    }

		    // Кнопка переключения Избранного (Звездочка)
		    ZyabaUIToolkit.FloatingButton {
			Layout.preferredWidth: 36
			Layout.preferredHeight: 36
			Layout.rightMargin: 4
			Layout.alignment: Qt.AlignVCenter
			bckgColor: "transparent"
			iconColor: model.isFav ? "#FFD700" : middleware.zyaba_text_Color
			iconSource: model.isFav ? "Icons/favorite-selected.svg" : "Icons/favorite-unselected.svg"
			iconMargining: 6

			onButtonClicked: {
			    middleware.toggleFavorite(model.filePath)
			}
		    }

		    // Кнопка удаления (Режим редактирования)
		    ZyabaUIToolkit.FloatingButton {
			Layout.preferredWidth: 36
			Layout.preferredHeight: 36
			Layout.rightMargin: 8
			Layout.alignment: Qt.AlignVCenter
			bckgColor: "transparent"
			iconColor: "#E53E3E"
			iconSource: "Icons/delete.svg"
			iconMargining: 6
			visible: middleware.editMode

			onButtonClicked: {
			    if (typeof gameManager !== "undefined") {
				var removed = gameManager.removeGame(model.filePath)
				if (removed) {
				    console.log("[Zyaba Middleware] Game deleted:", model.filePath)
				    middleware.refreshGamesList()
				}
			    }
			}
		    }
		}
	    }
	}
    }

    Column {
	anchors.right: parent.right
	anchors.bottom: parent.bottom
	anchors.margins: 15
	spacing: 12

	ZyabaUIToolkit.FloatingButton {
	    id: run_direct_button
	    buttonWidth: 50
	    buttonHeight: 50
	    bckgColor: middleware.accentationColor
	    iconColor: middleware.mooseColor
	    iconSource: "Icons/select.svg"
	    iconMargining: 12

	    onButtonClicked: {
		var picker = stack.push("ZyabaFilePicker.qml", { nameFilters: ["*.jar", "*.JAR", "*.jad", "*.JAD", "*.kjx", "*.KJX"] })

		var onSelected = function(path) {
		    picker.fileSelected.disconnect(onSelected)
		    console.log("[Zyaba Middleware] Direct launch:", path)
		    window.launchGame(path)
		}

		picker.fileSelected.connect(onSelected)
	    }
	}

	ZyabaUIToolkit.FloatingButton {
	    id: install_JAR_JAD_or_KJX_button
	    buttonWidth: 50
	    buttonHeight: 50
	    bckgColor: middleware.accentationColor
	    iconColor: middleware.mooseColor
	    iconSource: "Icons/add.svg"
	    iconMargining: 12

	    onButtonClicked: {
		var picker = stack.push("ZyabaFilePicker.qml", { nameFilters: ["*.jar", "*.JAR", "*.jad", "*.JAD", "*.kjx", "*.KJX"] })

		var onSelected = function(path) {
		    picker.fileSelected.disconnect(onSelected)
		    console.log("[Zyaba Middleware] Installing file:", path)

		    if (typeof gameManager !== "undefined") {
			var installed = gameManager.installGame(path)
			console.log("[Zyaba Middleware] Install result:", installed)
			middleware.refreshGamesList()
		    }
		}

		picker.fileSelected.connect(onSelected)
	    }
	}
    }
}
