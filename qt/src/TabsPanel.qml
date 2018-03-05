import QtQuick 2.7

TabsPanelForm {
    id: tabsPanel
    property alias tabsList: tabsPanel.tabsList

    Shortcut {
        sequence: "Ctrl+Shift+F"
        onActivated: {
            tabsSearch.focus = true
            tabsSearch.selectAll()
        }
    }
}
