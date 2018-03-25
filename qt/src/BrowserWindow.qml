import QtQuick 2.4
import Backend 1.0

BrowserWindowForm {
    id: browserWindow
    sourceComponent: c
    Component {
        id: c
        Browser {
            id: browser
            anchors.fill: parent
            z: 1
        }
    }
    Connections {
        target: browserWindow
        onClosing: {
            TabsModel.saveTabs()
        }
        onActiveFocusItemChanged: {
            console.log("onActiveFocusItemChanged:", activeFocusItem)
        }
    }
}
