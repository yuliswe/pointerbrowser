import QtQuick 2.4
import Backend 1.0
import QtQuick.Controls 2.3

TabsListForm {
    id: tabsList
    property int selected: -1
    signal userOpensTab(int index)
    delegate: TabsListTab {
        id: tab
        height: 30
        onClicked: {
            console.log(index)
            userOpensTab(index)
        }
    }
    model: TabsModel.tabs
}
