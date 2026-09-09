import QtQuick 2.12
import QtGraphicalEffects 1.0

Item {
    id: logo

    property real logoWidth: 50
    property real logoHeight: logoWidth

    property string logoPath: "Icons/Logo_Exemple.svg"
    property real logoRadius: height / 4
    property color borderColor: "#333"
    property real borderSize: 0

    implicitWidth: logoWidth
    implicitHeight: logoHeight

    // 1. Исходная картинка (скрыта, используется как источник данных)
    Image {
	id: img
	anchors.fill: parent
	source: logo.logoPath
	fillMode: Image.PreserveAspectCrop
	visible: false
    }

    // 2. Маска со скруглениями (тоже скрыта)
    Rectangle {
	id: mask
	anchors.fill: parent
	radius: logo.logoRadius
	color: "black"
	visible: false
    }

    // 3. Наложение маски на изображение
    OpacityMask {
	anchors.fill: parent
	source: img
	maskSource: mask
    }

    // 4. Внешняя рамка (рисуется поверх скругленной картинки)
    Rectangle {
	anchors.fill: parent
	color: "transparent"
	radius: logo.logoRadius
	border.width: logo.borderSize
	border.color: logo.borderColor
    }
}
