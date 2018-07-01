import QtQuick 2.4
import "qrc:/controls" as C

Column {
    property var mol: [["New Tab", "Ctrl + N"], ["Close Tab", "Ctrl + W"], ["Address Bar", "Ctrl + E"], ["Search Symbols", "Ctrl + D"], ["Automatic Bookmark", "Ctrl + K"]]
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
                font.pixelSize: 13
            }
            Text {
                text: "-"
                anchors.left: parent.left
                anchors.leftMargin: 150
                font.pixelSize: 13
            }
            Text {
                text: mol[index][1]
                anchors.left: parent.left
                anchors.leftMargin: 175
                font.pixelSize: 13
            }
        }
    }
}
