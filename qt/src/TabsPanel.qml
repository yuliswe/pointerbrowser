import QtQuick 2.9
import QtQuick.Controls 2.3

TabsPanelForm {
    id: tabsPanel
    signal userOpensNewTab
    signal userClosesTab(int index)
    signal userOpensTab(int index)

    function setCurrentIndex(i) {
        tabsList.setHighlightAt(i)
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
