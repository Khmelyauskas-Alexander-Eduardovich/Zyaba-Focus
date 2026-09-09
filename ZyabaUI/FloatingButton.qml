/*
* FloatingButton.qml <- A MD3-Like little button
* Khmelyauskas Alexander Eduardovitx / JasonWalt Bab@ - Kodexo Fitxategiara
*/

import QtQuick 2.12
import "Palette.js" as SystemPalette
import QtGraphicalEffects 1.0

Item {
    id: floating_button

    property string iconSource: "Icons/add.svg" // or your path to own icon
    property color bckgColor: SystemPalette.standartCyan // that's default color
    property string text: "+" // default text
    property color txtColor: SystemPalette.standartBlack // default text color
    property color iconColor: SystemPalette.standartBlack // default icon color

    property color whenPressed: SystemPalette.standartGreen // When pressed button color, or, in default state - color is Cyan, but when We pressed it - it changes to Green Color, and returns into default, when We released it

    property color borderColor: SystemPalette.standartWhite // Default border color
    property real borderSize: 0 // if zero - No border...

    property bool animatedButton: true // you can disable it in different QML-file, where You've imported this component
    property color smooth: SystemPalette.standartRed // IDK

    property real buttonWidth: 75 // default width of button
    property real buttonHeight: 75 // default height of button
    property bool soloText: false // only text, when We disabled it - it shows only icon
    property bool soloIcon: true // also with soloText, but vice-versa

    property real animationSpeed: 200 //Duration of a Bi-color transition

    property real iconMargining: 20 // It's anchors-margining
    property real buttonRadius: height / 3

    signal buttonPressed()
    signal buttonClicked()

    implicitHeight: buttonHeight
    implicitWidth: buttonWidth

    Rectangle {
	id: bckg
	anchors.fill: parent
	color: bckgColor
	Behavior on color {
	    NumberAnimation {
		duration: 150
	    }
	}

	radius: buttonRadius
	border.width: borderSize
	border.color: borderColor

	Image {
	    id: icon
	    fillMode: Image.PreserveAspectFit
	    source: iconSource
	    cache: true
	    asynchronous: true

	    //Attempting to RE-SIZE:

	    anchors.fill: parent
	    anchors.margins: iconMargining
	    visible: soloIcon
	    ColorOverlay {
		id: iconColoring
		anchors.fill: icon
		color: iconColor
		source: icon
		Behavior on color {
		    NumberAnimation {
			duration: 150
		    }
		}
	    }
	}

	Text {
	    id: buttonText
	    text: floating_button.text
	    verticalAlignment: Text.AlignVCenter
	    horizontalAlignment: Text.AlignHCenter
	    anchors.fill: parent
	    color: txtColor
	    Behavior on color {
		NumberAnimation {
		    duration: 150
		}
	    }
	    visible: soloText
	}
	MouseArea {
	    id: mouseButton_control
	    anchors.fill: parent
	    onClicked: { floating_button.buttonClicked(); console.log("[Edge UITK] Floating button clicked")}
	    onPressed: {
		buttonPressed()
	    }
	}
//	SequentialAnimation on smooth {
//	    loops: Animation.Infinite
//	    ColorAnimation {from: SystemPalette.standartRed; to: SystemPalette.standartYellow; duration: animationSpeed; easing.type: Easing.InOutQuad}
//	    ColorAnimation {from: SystemPalette.standartYellow; to: SystemPalette.standartGreen; duration: animationSpeed; easing.type: Easing.InOutQuad}
//	    ColorAnimation {from: SystemPalette.standartGreen; to: SystemPalette.standartCyan; duration: animationSpeed; easing.type: Easing.InOutQuad}
//	    ColorAnimation {from: SystemPalette.standartCyan; to: SystemPalette.standartBlue; duration: animationSpeed; easing.type: Easing.InOutQuad}
//	    ColorAnimation {from: SystemPalette.standartBlue; to: SystemPalette.standartPurple; duration: animationSpeed; easing.type: Easing.InOutQuad}
//	    ColorAnimation {from: SystemPalette.standartPurple; to: SystemPalette.standartRed; duration: animationSpeed; easing.type: Easing.InOutQuad}
//	}
    }
}
