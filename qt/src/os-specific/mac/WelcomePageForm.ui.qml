import QtQuick 2.4
import "qrc:/controls" as C

Column {
    property var mol: [["New Tab", "Cmd + N"], ["Close Tab", "Cmd + W"], ["Address Bar", "Cmd + E"], ["Search Symbols", "Cmd + D"], ["Automatic Bookmark", "Cmd + K"]]
    height: 225
    width: 250
    Repeater {
        id: repeater
        model: mol
        delegate: Item {
            implicitHeight: 25
            implicitWidth: parent.width
            id: dele
            Text {
                text: mol[index][0]
            }
            Text {
                text: "-"
                anchors.left: parent.left
                anchors.leftMargin: 150
            }
            Text {
                text: mol[index][1]
                anchors.left: parent.left
                anchors.leftMargin: 175
            }
        }
    }
}
