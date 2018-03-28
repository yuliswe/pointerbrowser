import QtQuick 2.9
import QtQuick.Controls 2.3
import Backend 1.0

TabsPanelForm {
    id: tabsPanel
    signal userOpensNewTab
    signal userClosesTab(int index)
    signal userOpensTab(int index)

    tabHeight: 30

    tabsListHeight: TabsModel.count * tabHeight
    searchListHeight: TabsModel.count * tabHeight
    tabsList.model: TabsModel
    searchList.model: TabsModel

    function setCurrentIndex(i) {
        tabsList.setHighlightAt(i)
    }

    Component.onCompleted: {
        searchList.setHighlightAt(-1);
    }

    Connections {
        target: newTabButton
        onClicked: {
            tabsPanel.userOpensNewTab()
        }
    }

    Connections {
        target: tabsList
        onUserClosesTab: {
            userClosesTab(index)
        }
        onUserClicksTab: {
            setCurrentIndex(index)
            userOpensTab(index)
        }
    }

    Shortcut {
        sequence: "Ctrl+Shift+F"
        onActivated: {
            tabsSearch.focus = true
            tabsSearch.selectAll()
        }
    }
}
