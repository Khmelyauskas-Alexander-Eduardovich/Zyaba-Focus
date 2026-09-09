import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

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
    property real headerTextSize: 10

    property real ht_center_align: Qt.AlignHCenter | Qt.AlignVCenter
    property bool alignTextByCenter: false
    property real theTrueTextHeaderAlignment: Qt.AlignLeft | Qt.AlignVCenter

    property string pathOfTrailingIcon: "Icons/back.svg"
    property string pathOfLeadingIcon: "Icons/other-actions.svg"
    property color sub_text_color: "#f7f7f7"
    property string sub_text: qsTr("Header II - With sub-text")
    property real sub_text_size: 15

    property real textLayout_spacing: 5

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
		implicitHeight: icons_Size
		implicitWidth: icons_Size
		onTapped: {
		    onTrailingActionTriggered()
		}
		iconColor: trailingIcon_color
		iconPath: header.pathOfTrailingIcon
	    }
	    ColumnLayout {
		id: text_layout

		Layout.fillHeight: true
		spacing: textLayout_spacing

		Label {
		    id: header_text
		    font.pixelSize: header.headerTextSize
		    text: header.headerText
		    color: header.headerTextColor
		    Layout.alignment: alignTextByCenter ? header.ht_center_align : header.theTrueTextHeaderAlignment
		}
		Label {
		    id: header_subText
		    font.pixelSize: header.sub_text_size
		    color: header.sub_text_color
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
    }
}
