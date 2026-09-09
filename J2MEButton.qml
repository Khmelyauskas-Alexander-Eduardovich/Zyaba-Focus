import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

Control {
    id: simple_button

    property string iconPath: "Icons/go-next"
    property color iconColor: "White"

    property color onPressedColor: "#333"
    property color backgroundColor: "transparent"
    property real circled: height / 2
    property real md3_circled: height / 3
    property real edge_circled: height / 4

    property color iconOnPressedColor: "#f7f7f7"

    property real jbutton_height: 50
    property real jbutton_width: 50

    property color borderColor: "#f7f7f7"
    property real borderSize: 0.5
    property real noBorder: 0

    property real iconSize: 25 // in px
    property real jbutton_radius: md3_circled

    // Родной API сигналов
    signal tap()
    signal whenPressed()
    signal release()

    implicitHeight: jbutton_height
    implicitWidth: jbutton_width

    background: Rectangle {
	id: bckg
	color: touch_control.pressed ? onPressedColor : backgroundColor

	Behavior on color {
	    ColorAnimation {
		duration: 200
	    }
	}

	anchors.fill: parent
	radius: jbutton_radius
	border.width: noBorder
	border.color: borderColor

	Image {
	    id: icon
	    source: iconPath
	    height: iconSize
	    width: height
	    anchors.centerIn: parent

	    ColorOverlay {
		id: color_shade
		anchors.fill: icon
		source: icon
		color: touch_control.pressed ? iconOnPressedColor : iconColor
	    }
	}
    }

    // Исправленный MultiPointTouchArea без спама non-NOTIFYable
    MultiPointTouchArea {
	id: touch_control
	anchors.fill: parent

	property bool pressed: false

	onPressed: {
	    touch_control.pressed = true
	    simple_button.whenPressed()
	}

	onReleased: {
	    touch_control.pressed = false
	    simple_button.release()
	    simple_button.tap()
	}

	onCanceled: {
	    touch_control.pressed = false
	    simple_button.release()
	}
    }
}
