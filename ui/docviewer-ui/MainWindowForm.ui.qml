import QtQuick 2.4
import QtQuick.Controls 2.3

Item {
    property alias tabsPanel: tabsPanel

    Browser {
        id: browser
        anchors.left: tabsPanel.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top
    }

    TabsPanel {
        id: tabsPanel
        width: 200
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.top: parent.top
    }
}
