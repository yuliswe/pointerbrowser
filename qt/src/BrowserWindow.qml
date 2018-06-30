import QtQuick 2.7
import Backend 1.0
import QtQuick.Controls 2.2
import "qrc:/controls"

FramelessWindow {
    title: qsTr("DOCVIEWER")
    id: browserWindow
    Component {
        Item {
            Browser {
                id: browser
                anchors.fill: parent
            }
        }
    }

    onActiveFocusItemChanged: {
        console.log("onActiveFocusItemChanged:", activeFocusItem)
    }
}
