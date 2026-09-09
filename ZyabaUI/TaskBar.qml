import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Control {
    id: taskBar

    property color taskBar_backgroundColor: "#111"
    property color taskBar_buttonsColors: "#333"
    property color taskBar_iconsColors: "green"
    property color taskBar_negativeActionIconColor: "White"
    property color taskBar_negativeActionBckgColor: "Red"
    property color taskBar_textColor: "White"
    property color taskBar_borderColor: "Pink"

    property bool negativeAction_visible: true
    property bool taskBar_showBorder: false

    property string iconSRC: "Icons/edit.svg"
    property string negativeAction_iconSRC: "Icons/delete.svg"
    property string taskBar_text: qsTr("Search...")

    property real taskBar_width: parent.width
    property real taskBar_height: 50
    property real taskBar_searchField_radius: height / 2
    property real taskBar_buttonsRadius: height / 2
    property real taskBar_borderHeight: 0.5

    property alias filterText: searchInput.text

    signal searchTextChanged(string text)
    signal tap()
    signal tapTheNegativeAction()

    implicitHeight: taskBar_height
    implicitWidth: taskBar_width

    background: Rectangle {
	color: taskBar_backgroundColor
	anchors.fill: parent

	Rectangle {
	    id: taskBar_border
	    height: taskBar_borderHeight
	    color: taskBar_borderColor
	    width: parent.width
	    anchors.bottom: parent.bottom
	    visible: taskBar_showBorder
	}
    }

    RowLayout {
	anchors.fill: parent
	anchors.leftMargin: 5
	anchors.rightMargin: 5
	spacing: 5

	SearchField {
	    id: searchInput
	    Layout.fillWidth: true
	    Layout.preferredHeight: 40
	    Layout.alignment: Qt.AlignVCenter
	    iconColor: taskBar.taskBar_iconsColors
	    textColor: taskBar.taskBar_textColor
	    tf_initialText: taskBar.taskBar_text
	    tf_Radius: taskBar.taskBar_searchField_radius

	    onTextChanged: {
		taskBar.searchTextChanged(text)
	    }
	}

	SimpleButton {
	    Layout.preferredWidth: 40
	    Layout.preferredHeight: 40
	    Layout.alignment: Qt.AlignVCenter
	    sb_radius: taskBar_buttonsRadius
	    backgroundColor: taskBar.taskBar_buttonsColors
	    iconPath: iconSRC
	    iconColor: taskBar.taskBar_iconsColors
	    onOnTap: { taskBar.tap() }
	}

	SimpleButton {
	    Layout.preferredWidth: 40
	    Layout.preferredHeight: 40
	    Layout.alignment: Qt.AlignVCenter
	    visible: taskBar.negativeAction_visible
	    sb_radius: taskBar_buttonsRadius
	    backgroundColor: taskBar.taskBar_negativeActionBckgColor
	    iconPath: negativeAction_iconSRC
	    iconColor: taskBar.taskBar_negativeActionIconColor
	    onOnTap: { taskBar.tapTheNegativeAction() }
	}
    }
}
