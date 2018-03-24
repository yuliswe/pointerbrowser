import QtQuick 2.9
import QtQuick.Window 2.10
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import "controls"

Item {
    id: main
    visible: true
//    title: qsTr("DOCVIEWER")
    property int currentKeyPress: -1
//    color: "transparent"
//    flags: Qt.Desktop

//    FramelessWindow {}
    BrowserWindow {}
//    Window {
//        id: ww
//        visible: true
//        color: "transparent"
//        width: 50
//        height: 30
//        flags: Qt.FramelessWindowHint
//        Behavior on width {
//            SmoothedAnimation {
//                duration: 1000
//            }
//        }
//        Rectangle {
//            color: "grey"
//            anchors.fill: parent
//            radius: 100

//            MouseArea {
//                anchors.fill: parent
//                onDoubleClicked: {
////                    console.log('test')
//                    ww.showMaximized()
//                }
//                onClicked: {
//                    ww.showNormal()
//                }
//            }
//        }
//    }

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
