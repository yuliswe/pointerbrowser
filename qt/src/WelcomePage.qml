import QtQuick 2.4
import "qrc:/controls" as C
import Backend 1.0

Item {
    function reload() {
        listModel.clear()
        var current = KeyMaps.toVariantMap()
        for (var k in current) {
            listModel.append({key: KeyMaps[k], desc: KeyMaps[k+"_desc"]})
        }
    }

    ListView {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenterOffset: -15
        Component.onCompleted: {
            reload()
        }
        model: ListModel {
            id: listModel
        }
        height: contentHeight
        width: 225
        delegate: Item {
            id: dele
            height: 30
            Text {
                id: text1
                text: desc
            }
            Text {
                id: text2
                text: "-"
                anchors.left: parent.left
                anchors.leftMargin: 150
            }
            Text {
                id: text3
                text: key
                anchors.left: parent.left
                anchors.leftMargin: 175
            }
        }
    }
}
