import QtQuick 2.9
import Backend 1.0
import QtQuick.Controls 2.3

TabsListForm {
    id: tabsList
    property alias tabsModel: tabsList.model
    signal userClicksTab(int index)
    signal userClosesTab(int index)
    function setHighlightAt(index) {
        tabsList.currentIndex = index
    }

    delegate: TabsListTab {
        id: tab
        height: 30
        highlighted: index === currentIndex
        width: parent.width
        onClicked: {
            userClicksTab(index)
            currentIndex = index
        }
        onUserClosesTab: {
            tabsList.userClosesTab(index)
        }
    }
}
