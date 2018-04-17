import QtQuick 2.7
import Backend 1.0
import QtQuick.Controls 2.2
import "controls"

FramelessWindow {
    title: qsTr("DOCVIEWER")
    id: browserWindow
    //    visible: false
    Component {
        Item {
            Browser {
                id: browser
                anchors.fill: parent
                Shortcut {
                    sequence: "Ctrl+G"
                    autoRepeat: false
                    onActivated: {
                        console.log("qml test Ctrl pressed")
                    }
                }
            }
//            Rectangle {
//                id: splash
//                height: browser.height
//                width: browser.width
//                color: "#000"
//                visible: TabsModel.count === 0
//            }
//            Timer {
//                id: timeout
//                repeat: false
//                triggeredOnStart: false
//                interval: 500
//                onTriggered: {
//                    TabsModel.loadTabs()
//                }
//            }
//            Component.onCompleted: {
//                timeout.start()
//            }
        }
    }

    onActiveFocusItemChanged: {
        console.log("onActiveFocusItemChanged:", activeFocusItem)
    }
}
