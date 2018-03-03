import QtQuick 2.4
import Backend 1.0

TabsListForm {
    id: tabsList
    property int selected: 1
    Component.onCompleted: {
        tabsListModel = Qt.binding(function () {
            return TabsModel.tabs
        })
    }
}
