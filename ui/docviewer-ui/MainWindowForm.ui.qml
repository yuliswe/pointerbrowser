import QtQuick 2.4
import QtQuick.Controls 2.3
import QtQuick.Controls 1.5
import QtQuick.Layouts 1.3

SplitView {
    property alias tabsPanel: tabsPanel

    handleDelegate: Item {
    }

    TabsPanel {
        id: tabsPanel
        Layout.minimumWidth: 200
    }

    Browser {
        id: browser
    }
}
