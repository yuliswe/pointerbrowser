import QtQuick 2.9
import QtQuick.Controls 2.3

TabsPanelForm {
    id: tabsPanel
    property alias tabsList: tabsPanel.tabsList
    signal userOpensNewTab
    signal userClosesTab(int index)

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
    }

    Shortcut {
        sequence: "Ctrl+Shift+F"
        onActivated: {
            tabsSearch.focus = true
            tabsSearch.selectAll()
        }
    }
}
