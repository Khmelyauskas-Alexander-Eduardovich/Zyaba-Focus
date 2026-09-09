import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Control {
    id: md3_switch

	property color bckgColor: activated ? activatedColor : desactivatedColor // true
	property color activatedColor: "cyan"
	property color desactivatedColor: "#333"
	property color activatedHandleColor: "Blue"
	property color desactivatedHandleColor: "White"
	property color borderColor: activated ? activatedBorderColor : desactivatedBorderColor
	property color activatedBorderColor: "cyan"
	property color desactivatedBorderColor: "White"
	property real md3_switch_width: 50 * 2
	property real md3_switch_height: 50
	property real squaredRadius: height / 4
	property real circledRadius: height / 2

    property bool activated: false

    property real durationAnim: 100

    property real md3_switch_radius: md3_switch.circledRadius

    property real borderSize: 1

    implicitHeight: md3_switch_height
    implicitWidth: md3_switch_width
    clip: true

    background: Rectangle {
	id: bckg
	color: bckgColor
	radius: md3_switch_radius
	clip: true
	border.width: borderSize
	border.color: borderColor
	implicitHeight: md3_switch.implicitHeight
	implicitWidth: md3_switch.implicitWidth
	Behavior on color {
	    ColorAnimation {
		duration: md3_switch.durationAnim
		easing.type: Easing.inOutQuad
	    }
	}
	Behavior on border.color {
	    ColorAnimation {
		duration: md3_switch.durationAnim
		easing.type: Easing.inOutQuad
	    }
	}

	Rectangle {
	    id: handle
	    width: height
	    height: parent.height - 10
	    radius: md3_switch_radius
	    anchors.verticalCenter: parent.verticalCenter
	    color: activated ? activatedHandleColor : desactivatedHandleColor
	    x: md3_switch.activated ? (parent.width - width) - 5 : 0 + 5

	    Behavior on x {
		NumberAnimation {
		    duration: md3_switch.durationAnim
		    easing.type: Easing.inOutQuad
		}
	    }
	    Behavior on color {
		ColorAnimation {
		    duration: md3_switch.durationAnim
		    easing.type: Easing.inOutQuad
		}
	    }
	}
    }

    MouseArea {
	anchors.fill: parent
	preventStealing: true

	onClicked: activated = !activated
    }
}
