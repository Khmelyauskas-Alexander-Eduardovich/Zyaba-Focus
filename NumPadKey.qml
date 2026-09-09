import QtQuick 2.12
import QtQuick.Controls 2.12
import "ZyabaUI" as ZyabaUIToolkit

Control {
    id: simple_button

    property string numberPadText: "Num"
    property color textColor: "White"
    property color textOnPressedColor: "#f7f7f7"

    property color backgroundColor: "transparent"
    property color onPressedColor: "#333"

    property color borderColor: "#f7f7f7"
    property color onPressedBorderColor: "#ffffff"
    property real borderSize: 0

    property real circled: height / 2
    property real md3_circled: height / 3
    property real edge_circled: height / 4

    property real jbutton_height: 50
    property real jbutton_width: 50

    property real textSize: 25 // in px
    property real jbutton_radius: md3_circled

    property bool isPressed: touch_point.pressed

    signal tap()
    signal whenPressed()
    signal release()

    implicitHeight: jbutton_height
    implicitWidth: jbutton_width

    background: Rectangle {
	id: bckg
	color: simple_button.isPressed ? onPressedColor : backgroundColor
	radius: jbutton_radius
	border.width: borderSize
	border.color: simple_button.isPressed ? onPressedBorderColor : borderColor

	Behavior on color {
	    ColorAnimation {
		duration: 100
		easing.type: Easing.InOutQuad
	    }
	}

	Behavior on border.color {
	    ColorAnimation {
		duration: 100
		easing.type: Easing.InOutQuad
	    }
	}

	anchors.fill: parent

	Text {
	    id: icon
	    text: qsTr(numberPadText)
	    verticalAlignment: Text.AlignVCenter
	    horizontalAlignment: Text.AlignHCenter
	    anchors.fill: parent
	    font.pixelSize: textSize
	    color: simple_button.isPressed ? textOnPressedColor : textColor

	    Behavior on color {
		ColorAnimation {
		    duration: 100
		    easing.type: Easing.InOutQuad
		}
	    }
	}
    }

    MultiPointTouchArea {
	id: touch_control
	anchors.fill: parent

	touchPoints: [
	    TouchPoint {
		id: touch_point
		onPressedChanged: {
		    if (pressed) {
			simple_button.whenPressed()
		    } else {
			simple_button.release()
			simple_button.tap()
		    }
		}
	    }
	]
    }
}
