import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.folderlistmodel 2.12
import "ZyabaUI" as UI

Page {
    id: pickerPage

    signal fileSelected(string filePath)

    property var nameFilters: ["*.jar", "*.JAR", "*.jad", "*.JAD", "*.kjx", "*.KJX"]

    readonly property color zyaba_Color: "Indigo"
    readonly property color zyaba_background_Color: darkMode ? "black" : "White"
    property bool darkMode: true
    property color mooseColor: "Yellow"
    property color zyaba_text_Color: "black"

    property string j2me_files_description: qsTr("This file is JavaMicroEdition-executable")
    property string directory_description: qsTr("Folder / Directory may contain the JME files or might be empty")

    header: UI.Header {
	implicitHeight: 35
	headerText: qsTr("Select the JAR / JAD / KJX file...")
	headerBackgroundColor: mooseColor
	headerTextColor: "black"
	trailingIcon_color: headerTextColor
	onOnTrailingActionTriggered: stack.pop()
	pathOfTrailingIcon: "Icons/go-previous.svg"
    }

    background: Rectangle {
	color: zyaba_background_Color
    }

    ColumnLayout {
	anchors.fill: parent
	anchors.margins: 10
	spacing: 8

	Rectangle {
	    Layout.fillWidth: true
	    height: 32
	    color: "#1e1e1e"
	    radius: 6

	    Label {
		anchors.fill: parent
		anchors.margins: 6
		text: folderModel.folder.toString().replace(/^file:\/\/\//, "/").replace(/^file:\/\//, "")
		color: "#aaaaaa"
		elide: Text.ElideMiddle
		verticalAlignment: Text.AlignVCenter
		font.pixelSize: 12
	    }
	}

	UI.SimpleButton {
	    iconPath: "Icons/go-up.svg"
	    iconColor: mooseColor
	    Layout.fillWidth: true
	    onOnTap: {
		if (folderModel.parentFolder !== "")
		    folderModel.folder = folderModel.parentFolder
	    }
	}

	ListView {
	    id: listView
	    Layout.fillWidth: true
	    Layout.fillHeight: true
	    clip: true

	    FolderListModel {
		    id: folderModel
		    // Используем системный домашний путь или Downloads, чтобы не улетать в /opt/click
		    folder: {
			if (Qt.platform.os === "windows") {
			    return "file:///C:/"
			} else {
			    // В Ubuntu Touch цепляем стандартный путь к Документам или Загрузкам
			    return "file:///home/phablet"
			}
		    }
		    showDirsFirst: true
		    nameFilters: pickerPage.nameFilters
		}

	    model: folderModel

	    delegate: UI.FileDelegate {
		modelWidth: listView.width
		height: 50
		iconColor: fileIsDir ? "#2D3748" : "transparent"
		itemRadius: 10
		iconSRC: fileIsDir ? "Icons/folder-symbolic.svg" : "/Zyaba-Splash.svg"
		fileName_Text: fileName
		fileModel_background: "transparent"
		fileModel_background_onPressed: "#131313"
		textColor: fileIsDir ? "Indigo" : "#90CDF4"
		subText_Visible: true
		subText: fileIsDir ? directory_description : j2me_files_description

		///////////////////////////////////////////////////////////////////
		//Danger Zone!!!
		///////////////////////////////////////////////////////////////////
		onTap: {
		    if (fileIsDir) {
			folderModel.folder = fileURL
		    } else {
			var cleanPath = filePath ? filePath : fileURL.toString()

			if (Qt.platform.os === "windows") {
			    cleanPath = cleanPath.replace(/^file:\/\/\//, "").replace(/^file:\/\//, "")
			    if (cleanPath.search(/^\/[a-zA-Z]:/) !== -1) {
				cleanPath = cleanPath.substring(1)
			    }
			} else {
			    cleanPath = cleanPath.replace(/^file:\/\//, "")
			    if (!cleanPath.startsWith("/")) {
				cleanPath = "/" + cleanPath
			    }
			}

			console.log("[ZyabaFilePicker] FIXED ABSOLUTE PATH:", cleanPath)

			// СНАЧАЛА закрываем экран пикера, чтобы pop() не зацепил GameEmulationView!
			stack.pop()

			// А ЗАТЕМ отправляем путь к файлу
			pickerPage.fileSelected(cleanPath)
		    }
		}
	    }
	}
    }
}
