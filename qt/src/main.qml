import QtQuick 2.10
import QtQuick.Window 2.10

Window {
    id: main
    visible: true
    width: 1280
    height: 900
    title: qsTr("DOCVIEWER")
    property int currentKeyPress: -1
    x: (Screen.width - width) / 2
        y: (Screen.height - height) / 2
//    color: "transparent"
//    flags: Qt.Window |
//           Qt.FramelessWindowHint |
//           Qt.CustomizeWindowHint |
//           Qt.WindowTitleHint |
//           Qt.WindowCloseButtonHint
////           Qt.WA_TranslucentBackground
    Browser {
        anchors.fill: parent
        focus: true
        Keys.onPressed: main.currentKeyPress = event.key
        Keys.onReleased: main.currentKeyPress = -1
    }

    onActiveFocusItemChanged: {
        console.log("focus:", activeFocusItem)
    }
    onCurrentKeyPressChanged: {
        console.log(currentKeyPress)
    }
    property var theme: {
        return {
            control_on: "#2576f9",
            control_hover: "#ccc",
            control_normal: "#ddd"
        }
    }
}
