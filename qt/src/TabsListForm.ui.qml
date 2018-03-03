import QtQuick 2.4
import QtQuick.Layouts 1.3
import Backend 1.0

ListView {
    id: listview
    property alias tabsListModel: listview.model
    anchors.fill: parent
    model: [{
            title: "site 1"
        }, {
            title: "site 2"
        }, {
            title: "site 3"
        }, {
            title: "site 3"
        }, {
            title: "site 3"
        }, {
            title: "site 3"
        }, {
            title: "site 3"
        }, {
            title: "site 3"
        }, {
            title: "site 3"
        }, {
            title: "site 3"
        }, {
            title: "site 3"
        }, {
            title: "site 3"
        }]
    delegate: Rectangle {
        id: tab
        height: 30
        color: index === 1 ? "#219cf5" : "transparent"
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        Text {
            color: index === 1 ? "#ffffff" : "default"
            text: modelData.title
            font.pointSize: 10
            font.family: "Segoe UI"
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignLeft
        }
    }
}
