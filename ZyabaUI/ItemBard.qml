import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import ".."

Control {
    id: item_rectangle

    property string main_text: qsTr("Rectangle Settings' Item")
    property string sub_text: qsTr("It's usual for ListItem's Delegates")

    property bool subTextForm_italic: true
    property bool mainText_bold: false

    property color mainText_Color: "White"
    property color subText_Color: "#888888"

    property real item_width: parent ? parent.width : 300
    property real item_height: 70

    property color bckgColor: "#111"
    property color bckgPressedColor: "#131313"

    property real item_radius: radiused_by_JWB

    property real md3_radius: height / 3
    property real circled: height / 2
    property real radiused_by_JWB: height / 4

    property real iconRadius: radiused_by_JWB

    property string icon_action_source: "Icons/Logo_Exemple.svg"

    property real sibt_iconSize: 20 // in px

    property bool showLogo: true
    property bool showBorder: false

    property color iconColor: "White"

    signal actionClicked()

    signal clicked()

    signal delay()

    signal press()

    signal cancel()

    implicitHeight: item_height
    implicitWidth: item_width
    clip: true

    background: Rectangle {
	id: bckg
	anchors.fill: parent
	color: mouse.pressed ? item_rectangle.bckgPressedColor : item_rectangle.bckgColor
	radius: item_radius
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
	    anchors.leftMargin: 10
	    anchors.rightMargin: 10
	    spacing: 12

	    // Контейнер Иконки
	    Item {
		id: item_logo
		Layout.preferredWidth: 42
		Layout.preferredHeight: 42
		Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
		visible: item_rectangle.showLogo

		// 1. Исходная картинка
		Image {
		    id: img
		    anchors.fill: parent
		    source: item_rectangle.icon_action_source
		    fillMode: Image.PreserveAspectCrop
		    visible: false
		}

		// 2. Маска со скруглениями
		Rectangle {
		    id: mask
		    anchors.fill: parent
		    radius: item_rectangle.iconRadius
		    color: "black"
		    visible: false
		}

		// 3. Наложение маски
		OpacityMask {
		    anchors.fill: parent
		    source: img
		    maskSource: mask
		}

		// 4. Внешняя рамка
		Rectangle {
		    anchors.fill: parent
		    color: "transparent"
		    radius: item_rectangle.iconRadius
		}
	    }

	    // Текстовый блок (Теперь занимает ВСЁ свободное место!)
	    ColumnLayout {
		id: text_Layout
		spacing: 2
		Layout.fillWidth: true
		Layout.fillHeight: true
		Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

		Item { Layout.fillHeight: true } // Распорка сверху

		Label {
		    id: mainText
		    font.pixelSize: 15
		    font.bold: item_rectangle.mainText_bold
		    text: item_rectangle.main_text
		    verticalAlignment: Text.AlignVCenter
		    elide: Text.ElideRight
		    color: item_rectangle.mainText_Color
		    Layout.fillWidth: true
		}

		Label {
		    id: subText
		    font.pixelSize: 11
		    font.italic: item_rectangle.subTextForm_italic
		    text: item_rectangle.sub_text
		    verticalAlignment: Text.AlignVCenter
		    elide: Text.ElideRight
		    color: item_rectangle.subText_Color
		    Layout.fillWidth: true
		}

		Item { Layout.fillHeight: true } // Распорка снизу
	    }

	    // Кнопка / Стрелочка справа
	    SimpleButton {
		id: actionTrigger
		sb_height: item_rectangle.sibt_iconSize
		sb_width: sb_height
		Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
		iconSize: 20
		iconColor: item_rectangle.iconColor
	    }
	}
    }

    MouseArea {
	id: mouse
	anchors.fill: parent
	preventStealing: true
	onClicked: {
	    item_rectangle.clicked()
	}
	onPressed: {
	    item_rectangle.press()
	}
	onPressAndHold: {
	    item_rectangle.delay()
	}
	onCanceled: {
	    item_rectangle.cancel()
	}
    }
}
