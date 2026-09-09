import QtQuick 2.12
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.12

Item {
    id: icon

    property real iconWidth: 50
    property real iconHeight: 50

    property string iconPath: "Icons/settings.svg"
    property real iconRadius: height / 2

    property color iconColor: "white"

    signal tapped()

    implicitHeight: iconHeight
    implicitWidth: implicitWidth

    Image {
	id: img
	source: iconPath
	anchors.fill: parent
	fillMode: Image.PreserveAspectFit

	ColorOverlay {
	    id: color_shade
	    source: img
	    anchors.fill: img
	    color: iconColor
	}
    }

    MouseArea {
	anchors.fill: parent
	onClicked: {
	   tapped()
	}
    }
}
