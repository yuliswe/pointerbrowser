import QtQuick 2.9
import Backend 1.0
import QtQuick.Controls 2.3

TabsListForm {
    id: tabsList
    property alias tabsModel: tabsList.model
    property int selected: -1
    signal userOpensTab(int index)
    delegate: TabsListTab {
        id: tab
        height: 30
        width: parent.width
        onClicked: {
            console.log(index)
            userOpensTab(index)
        }
    }
}
