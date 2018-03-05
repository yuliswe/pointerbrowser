import QtQuick 2.10
import QtQuick.Window 2.10

Window {
    id: main
    visible: true
    width: 1280
    height: 900
    title: qsTr("Hello World")
    property int currentKeyPress: -1

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
