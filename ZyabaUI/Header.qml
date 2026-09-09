import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import ".."

Control {
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

    signal onTrailingActionTriggered()
    signal onLeadingActionTriggered()

    property real icons_Size: 30
    property color trailingIcon_color: "black"
    property color leadingIcon_color: "black"
    property real headerTextSize: 20

    property real ht_center_align: Qt.AlignHCenter | Qt.AlignVCenter
    property bool alignTextByCenter: false
    property real theTrueTextHeaderAlignment: Qt.AlignLeft | Qt.AlignVCenter

    property string pathOfTrailingIcon: "Icons/back.svg"
    property string pathOfLeadingIcon: "Icons/other-actions.svg"

    implicitHeight: header_height
    implicitWidth: header_width

    background: Rectangle {
	id: bckg
	color: headerBackgroundColor
	anchors.fill: parent

	Rectangle {
	    id: header_border
	    implicitHeight: headerBorder_size
	    width: parent.width
	    color: borderColor
	    anchors.bottom: parent.bottom
	    visible: showBorder ? true : false
	}
    }
    ToolBar {
	anchors.fill: parent
	background: null

	RowLayout {
	    id: header_layout
	    anchors.fill: parent
	    spacing: layoutSpacing
	    anchors.margins: margining

	    Icon {
		id: trailing_action
		Layout.preferredHeight: icons_Size
		Layout.preferredWidth: icons_Size
		onTapped: {
		    onTrailingActionTriggered()
		}
		iconColor: trailingIcon_color
		iconPath: header.pathOfTrailingIcon
		Layout.alignment: Qt.AlignLeft
	    }
	    Label {
		id: header_text
		font.pixelSize: header.headerTextSize
		text: header.headerText
		color: header.headerTextColor
		Layout.alignment: theTrueTextHeaderAlignment
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
		Layout.fillWidth: true
	    }
	    Item {
		Layout.preferredHeight: icons_Size
		Layout.preferredWidth: icons_Size
		Layout.alignment: Qt.AlignRight
	    }
	}
    }
    Component.onCompleted: {
	//header_text.x = 0
	header_text.opacity = 1
    }
}
