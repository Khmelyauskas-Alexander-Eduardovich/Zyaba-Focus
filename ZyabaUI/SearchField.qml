import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

Control {
    id: zyaba_TextField_search_only

    property color bckgColor: "#111"
    property color textColor: "#f7f7f7"
    property color iconColor: "#f7f7f7"
    property color deactivatedColor: "#333"
    property color atFocusColor: "lightblue"
    property real tf_Width: parent.width
    property real tf_Height: 50
    property color borderColor: "#333"
    property real borderSize: 0.5
    property real tf_Radius: height / 2
    property string tf_initialText: qsTr("Search...")
    property string tf_unavailiable_text: qsTr("Disabled / unavailable")
    property string iconSRC: "Icons/search.svg"

    // Алиас автоматически создает и пробрасывает сигнал textChanged
    property alias text: inputField.text

    signal accepted()

    implicitHeight: tf_Height
    implicitWidth: tf_Width

    background: Rectangle {
	color: zyaba_TextField_search_only.bckgColor
	border.width: zyaba_TextField_search_only.borderSize
	border.color: inputField.activeFocus ? zyaba_TextField_search_only.atFocusColor : zyaba_TextField_search_only.borderColor
	anchors.fill: parent
	radius: zyaba_TextField_search_only.tf_Radius

	Behavior on border.color {
	    ColorAnimation { duration: 150 }
	}
    }

    RowLayout {
	id: rowLayout
	anchors.fill: parent
	anchors.leftMargin: 12
	anchors.rightMargin: 12
	spacing: 8

	Icon {
	    id: icon
	    Layout.preferredHeight: 20
	    Layout.preferredWidth: 20
	    Layout.alignment: Qt.AlignVCenter
	    iconColor: zyaba_TextField_search_only.iconColor
	    iconPath: zyaba_TextField_search_only.iconSRC
	}

	TextField {
	    id: inputField
	    Layout.fillWidth: true
	    Layout.fillHeight: true
	    verticalAlignment: Text.AlignVCenter
	    font.pixelSize: 14
	    color: zyaba_TextField_search_only.textColor
	    enabled: zyaba_TextField_search_only.enabled

	    background: Rectangle {
		color: "transparent"
	    }

	    placeholderText: zyaba_TextField_search_only.enabled ? tf_initialText : tf_unavailiable_text
	    placeholderTextColor: zyaba_TextField_search_only.enabled ? zyaba_TextField_search_only.deactivatedColor : "#222"

	    onAccepted: {
		zyaba_TextField_search_only.accepted()
	    }
	}
    }
}
