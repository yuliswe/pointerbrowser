import QtQuick 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
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
    delegate: TabsListTab {
    }
}
