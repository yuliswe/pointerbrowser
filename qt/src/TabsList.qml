import QtQuick 2.7
import Backend 1.0
import QtQuick.Controls 2.2

TabsListForm {
    id: tabsList
    signal userClicksTab(int index)
    signal userClosesTab(int index)
    signal userDoubleClicksTab(int index)
    property bool showCloseButton: false
    property bool hoverHighlight: false

    function setHighlightAt(index) {
        tabsList.currentIndex = index
    }

    property int tabHeight: 0;

    delegate: TabsListTab {
        id: tab
        implicitHeight: tabsList.tabHeight
        showCloseButton: tabsList.showCloseButton
        highlighted: (index === currentIndex) // || (hoverHighlight && hovered)
        width: parent.width
        onClicked: {
            tab.forceActiveFocus()
            userClicksTab(index)
        }
        onDoubleClicked: {
            userDoubleClicksTab(index)
        }
        onUserClosesTab: {
            tabsList.userClosesTab(index)
        }
    }
}
