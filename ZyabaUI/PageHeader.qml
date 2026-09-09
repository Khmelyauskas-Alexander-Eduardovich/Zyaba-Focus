import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import ".."

ToolBar {
    id: header

    property real header_height: 50
    property real header_width: parent.width
    property string headerText: qsTr("Custom Header")
    property color headerTextColor: "White"
    property color headerBackgroundColor: "Green"
    readonly property real headerBorder_size: 1

    property color borderColor: "white"

    property bool showBorder: true

    property real layoutSpacing: 5
    property real margining: 10

    signal onLeadingActionTriggered()

    property real icons_Size: 30
    property color leadingIcon_color: "black"
    property real headerTextSize: 20

    property real ht_center_align: Qt.AlignHCenter | Qt.AlignVCenter
    property bool alignTextByCenter: false
    property real theTrueTextHeaderAlignment: Qt.AlignLeft | Qt.AlignVCenter

    property string pathOfLeadingIcon: "Icons/other-actions.svg"

    implicitHeight: header_height
    implicitWidth: header_width

    background: Rectangle {
	id: bckg
	color: headerBackgroundColor
	anchors.fill: parent

	Rectangle {
	    id: header_border
	    height: headerBorder_size
	    width: parent.width
	    border.color: borderColor
	    color: "transparent"
	    anchors.bottom: parent.bottom
	    visible: showBorder ? true : false
	}
    }
	RowLayout {
	    id: header_layout
	    anchors.fill: parent
	    spacing: layoutSpacing
	    anchors.margins: margining

	    Label {
		id: header_text
		font.pixelSize: header.headerTextSize
		text: header.headerText
		color: header.headerTextColor
		Layout.alignment: header.theTrueTextHeaderAlignment
		//x: +60
//		Behavior on x {
//		    NumberAnimation {
//			duration: 180
//			easing.type: Easing.InOutQuad
//		    }
//		}
		opacity: 0
		Behavior on opacity {
		    NumberAnimation {
			duration: 180
			easing.type: Easing.InOutQuad
		    }
		}
	    }
	    Icon {
		id: leading_action
		Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
		implicitHeight: icons_Size
		implicitWidth: icons_Size
		onTapped: {
		    onLeadingActionTriggered()
		}
		iconColor: leadingIcon_color
		iconPath: header.pathOfLeadingIcon
	    }
	}
    Component.onCompleted: {
	//header_text.x = 0
	header_text.opacity = 1
    }
}
