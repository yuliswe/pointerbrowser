import QtQuick 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import Backend 1.0

ListView {
    id: listview
    property alias tabsListModel: listview.model
    model: [{
            url: "test",
            title: "test"
        }, {
            url: "test",
            title: "test"
        }]
}
