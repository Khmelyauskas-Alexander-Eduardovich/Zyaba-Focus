import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import ".."

Control {
    id: switchItem

    property string main_text: qsTr("Switch Setting")
    property string sub_text: qsTr("Enable or disable feature")

    property bool checked: false

    property color mainText_Color: "White"
    property color subText_Color: "#888888"
    property color accentColor: "Indigo"

    property real item_width: parent ? parent.width : 300
    property real item_height: 64

    property color bckgColor: "#111"
    property color bckgPressedColor: "#131313"
    property real item_radius: height / 4

    property string icon_action_source: ""
    property bool showLogo: false
    property real iconRadius: radiused_by_JWB
    property real radiused_by_JWB: height / 4

    property bool showBorder: false

    signal toggled(bool state)

    implicitHeight: item_height
    implicitWidth: item_width
    clip: true

    background: Rectangle {
	id: bckg
	anchors.fill: parent
	color: mouseArea.pressed ? switchItem.bckgPressedColor : switchItem.bckgColor
	radius: switchItem.item_radius
	clip: true

	Rectangle {
	    id: item_border
	    height: 0.5
	    color: "#333"
	    width: parent.width
	    anchors.bottom: parent.bottom
	    visible: showBorder
	}

	RowLayout {
	    anchors.fill: parent
	    anchors.leftMargin: 12
	    anchors.rightMargin: 12
	    spacing: 12

	    // Опциональная иконка слева
	    Item {
		id: item_logo
		Layout.preferredWidth: 36
		Layout.preferredHeight: 36
		Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
		visible: switchItem.showLogo && switchItem.icon_action_source !== ""

		Image {
		    id: img
		    anchors.fill: parent
		    source: switchItem.icon_action_source
		    fillMode: Image.PreserveAspectCrop
		    visible: false
		}

		Rectangle {
		    id: mask
		    anchors.fill: parent
		    radius: switchItem.iconRadius
		    color: "black"
		    visible: false
		}

		OpacityMask {
		    anchors.fill: parent
		    source: img
		    maskSource: mask
		}
	    }

	    // Текстовый блок
	    ColumnLayout {
		spacing: 2
		Layout.fillWidth: true
		Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

		Label {
		    id: mainText
		    font.pixelSize: 14
		    font.bold: true
		    text: switchItem.main_text
		    color: switchItem.mainText_Color
		    Layout.fillWidth: true
		    elide: Text.ElideRight
		}

		Label {
		    id: subText
		    font.pixelSize: 10
		    font.italic: true
		    text: switchItem.sub_text
		    color: switchItem.subText_Color
		    Layout.fillWidth: true
		    elide: Text.ElideRight
		    visible: text !== ""
		}
	    }

	    // Сам MD3 Свитч / Тумблер
	    Switch {
		id: controlSwitch
		checked: switchItem.checked
		Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

		onToggled: {
		    switchItem.checked = checked
		    switchItem.toggled(checked)
		}

		indicator: Rectangle {
		    implicitWidth: 44
		    implicitHeight: 24
		    x: controlSwitch.leftPadding
		    y: parent.height / 2 - height / 2
		    radius: 12
		    color: controlSwitch.checked ? switchItem.accentColor : "#333333"
		    border.color: controlSwitch.checked ? switchItem.accentColor : "#444444"
		    border.width: 1

		    Rectangle {
			x: controlSwitch.checked ? parent.width - width - 3 : 3
			y: 3
			width: 18
			height: 18
			radius: 9
			color: "White"

			Behavior on x {
			    NumberAnimation { duration: 150 }
			}
		    }
		}
	    }
	}
    }

    MouseArea {
	id: mouseArea
	anchors.fill: parent
	// Оставляем проход кликов на свитч, но даем общую зону нажатия по плашке
	onClicked: {
	    switchItem.checked = !switchItem.checked
	    switchItem.toggled(switchItem.checked)
	}
    }
}
