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

    property real sb_height: 50
    property real sb_width: 50

    property color borderColor: "#f7f7f7"
    property real borderSize: 0.5
    property real noBorder: 0

    // Автоматический ресайз с безопасным отступом (padding 10px)
    property real iconSize: Math.max(0, Math.min(width, height) - 10)
    property real sb_radius: md3_circled

    signal onTap()

    implicitHeight: sb_height
    implicitWidth: sb_width

    background: Rectangle {
	id: bckg
	color: touch_control.pressed ? onPressedColor : backgroundColor

	Behavior on color {
	    ColorAnimation {
		duration: 200
	    }
	}

	anchors.fill: parent
	radius: sb_radius
	border.width: noBorder
	border.color: borderColor

	Image {
	    id: icon
	    source: iconPath
	    width: simple_button.iconSize
	    height: simple_button.iconSize
	    sourceSize.width: simple_button.iconSize
	    sourceSize.height: simple_button.iconSize
	    fillMode: Image.PreserveAspectFit
	    anchors.centerIn: parent

	    ColorOverlay {
		id: color_shade
		anchors.fill: icon
		source: icon
		color: touch_control.pressed ? iconOnPressedColor : iconColor
	    }
	}
    }

    MultiPointTouchArea {
	id: touch_control
	anchors.fill: parent

	// Явное свойство вместо зависимости от non-NOTIFYable touchPoints
	property bool pressed: false

	onPressed: {
	    pressed = true
	}

	onReleased: {
	    pressed = false
	    onTap()
	}

	onCanceled: {
	    pressed = false
	}
    }
}
