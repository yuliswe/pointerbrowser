import QtQuick 2.9
import QtQuick.Window 2.10
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

Item {
    id: main
    visible: true
    width: 800
    height: 600
//    title: qsTr("DOCVIEWER")
    property int currentKeyPress: -1
//    color: "transparent"
//    flags: Qt.Desktop


    MainWindow {}


//    onActiveFocusItemChanged: {
//        console.log("focus:", activeFocusItem)
//    }
//    onCurrentKeyPressChanged: {
//        console.log(currentKeyPress)
//    }
    property var theme: {
        return {
            control_on: "#2576f9",
            control_hover: "#ccc",
            control_normal: "#ddd"
        }
    }
}
