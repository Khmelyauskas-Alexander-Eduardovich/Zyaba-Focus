import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQuick.Window 2.12

Window {
    id: window
    width: 640
    height: 900
    visible: true
    title: (retroHost && retroHost.suitName !== "")
	       ? "Zyaba-Focus - " + retroHost.suitName
	       : "Zyaba-Focus - J2ME Emulator"

    color: "#1e1e1e"

    visibility: fullscreen ? Window.FullScreen : Window.Windowed

    property bool fullscreen: false

    StackView {
	id: stack
	anchors.fill: parent
	initialItem: "GamesMiddleware.qml"
    }

    function launchGame(gamePath) {
	stack.push("GameEmulationView.qml", { targetGamePath: gamePath })
    }
}
