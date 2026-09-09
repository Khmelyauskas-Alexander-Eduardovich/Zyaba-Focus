import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

Control {
    id: fileModel_ItemDelegate

    property real modelWidth: parent.width
    property real modelHeight: 50
    property color fileModel_background: "#333"
    property color fileModel_background_onPressed: "#111"
    property real inModel_spacing: 10
    property real inModel_margining: 5
    property color textColor: "Indigo"
    property color subText_Color: "Darkgreen"
    property color iconColor: "Yellow"
    property bool subText_Visible: false
    property string fileName_Text: "J2ME Example.jar"
    property string subText: "Some descriptive file..."
    property string iconSRC: "Icons/folder-symbolic.svg"
    property bool hasFileModelBckg: false
    property color logoBckgColor: "green"
    property real itemRadius: 10

    signal press()
    signal tap()

    property real textPixelSize: 20
    property real subText_pixelSize: 10


    implicitHeight: modelHeight
    implicitWidth: modelWidth

    clip: true

    background: Rectangle {
	color: mouseArea.pressed ? fileModel_background_onPressed : fileModel_background
	Behavior on color {
	    ColorAnimation {
		duration: 200
	    }
	}

	anchors.fill: parent
	radius: itemRadius
    }

    RowLayout {
	id: row_layout
	anchors.fill: parent
	spacing: inModel_spacing
	anchors.margins: inModel_margining

	Item {
	    id: icon
	    Layout.preferredHeight: Math.max(0, Math.min(parent.width, parent.height) - 10)
	    Layout.preferredWidth: height
	    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
	    
	    Rectangle {
		id: logoBckg
		anchors.fill: parent
		radius: 5
		color: logoBckgColor
		visible: hasFileModelBckg
	    }
	    Icon {
		iconColor: fileModel_ItemDelegate.iconColor
		anchors.fill: parent
		anchors.margins: 2
		iconPath: iconSRC
	    }
	}
	
	ColumnLayout {
	    id: columnLayout
	    Layout.fillHeight: true
	    Layout.fillWidth: true

	    Label {
		id: fileName
		text: fileName_Text
		verticalAlignment: Text.AlignVCenter
		horizontalAlignment: Text.AlignHCenter
		wrapMode: Text.WrapAtWordBoundaryOrAnywhere
		color: textColor
		font.pixelSize: textPixelSize
	    }
	    Label {
		id: subtitle
		text: subText
		visible: subText_Visible
		color: subText_Color
		font.pixelSize: subText_pixelSize
		font.italic: true
	    }
	}
	Item {
	    Layout.fillWidth: true
	}
    }
    MouseArea {
	id: mouseArea
	anchors.fill: parent
	onClicked: {
	    tap()
	}
	onPressed: {
	    press()
	}
    }
}
