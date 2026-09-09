import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import ".."

Control {
    id: sliderItem

    property string main_text: qsTr("Slider Setting")
    property string sub_text: qsTr("Adjust the parameter value")

    property real fromValue: 0
    property real toValue: 100
    property real stepSize: 1
    property real currentValue: 50

    property bool showValueLabel: true

    property color mainText_Color: "White"
    property color subText_Color: "#888888"
    property color accentColor: "Indigo"

    property real item_width: parent ? parent.width : 300
    property real item_height: 80

    property color bckgColor: "#111"
    property color bckgPressedColor: "#131313"
    property real item_radius: height / 4

    property bool showBorder: false

    signal valueChanged(real value)

    implicitHeight: item_height
    implicitWidth: item_width
    clip: true

    background: Rectangle {
	id: bckg
	anchors.fill: parent
	color: sliderItem.bckgColor
	radius: sliderItem.item_radius
	clip: true

	Rectangle {
	    id: item_border
	    height: 0.5
	    color: "#333"
	    width: parent.width
	    anchors.bottom: parent.bottom
	    visible: showBorder
	}

	ColumnLayout {
	    anchors.fill: parent
	    anchors.margins: 12
	    spacing: 4

	    // Верхняя строка с текстами и значением
	    RowLayout {
		Layout.fillWidth: true
		Layout.alignment: Qt.AlignTop

		ColumnLayout {
		    Layout.fillWidth: true
		    spacing: 2

		    Label {
			id: mainText
			font.pixelSize: 14
			font.bold: true
			text: sliderItem.main_text
			color: sliderItem.mainText_Color
			Layout.fillWidth: true
			elide: Text.ElideRight
		    }

		    Label {
			id: subText
			font.pixelSize: 10
			font.italic: true
			text: sliderItem.sub_text
			color: sliderItem.subText_Color
			Layout.fillWidth: true
			elide: Text.ElideRight
			visible: text !== ""
		    }
		}

		Label {
		    text: Math.round(sliderItem.currentValue)
		    font.pixelSize: 13
		    font.bold: true
		    color: sliderItem.accentColor
		    visible: sliderItem.showValueLabel
		    Layout.alignment: Qt.AlignRight | Qt.AlignTop
		}
	    }

	    // Сам MD3 Слайдер
	    Slider {
		id: controlSlider
		Layout.fillWidth: true
		Layout.preferredHeight: 24
		from: sliderItem.fromValue
		to: sliderItem.toValue
		stepSize: sliderItem.stepSize
		value: sliderItem.currentValue

		onMoved: {
		    sliderItem.currentValue = value
		    sliderItem.valueChanged(value)
		}

		background: Rectangle {
		    x: controlSlider.leftPadding
		    y: controlSlider.topPadding + controlSlider.availableHeight / 2 - height / 2
		    width: controlSlider.availableWidth
		    height: 4
		    radius: 2
		    color: "#333333"

		    Rectangle {
			width: controlSlider.visualPosition * parent.width
			height: parent.height
			color: sliderItem.accentColor
			radius: 2
		    }
		}

		handle: Rectangle {
		    x: controlSlider.leftPadding + controlSlider.visualPosition * (controlSlider.availableWidth - width)
		    y: controlSlider.topPadding + controlSlider.availableHeight / 2 - height / 2
		    width: 18
		    height: 18
		    radius: 9
		    color: controlSlider.pressed ? sliderItem.accentColor : "White"
		    border.color: sliderItem.accentColor
		    border.width: 2
		}
	    }
	}
    }
}
