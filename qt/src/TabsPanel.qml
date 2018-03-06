import QtQuick 2.7
import QtQuick.Controls 2.3

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
