import QtQuick 2.7
import Backend 1.0
import QtQuick.Controls 2.2

ListView {
    id: tabsList
    signal userClicksTab(int index)
    signal userClosesTab(int index)
    signal userDoubleClicksTab(int index)
    property bool showCloseButton: false
    property bool expandEnabled: false
    property bool hoverHighlight: false

    function setHighlightAt(index) {
        tabsList.currentIndex = index
    }
    height: {
        var h = 0;
        for (var i = 0; i < tabsList.count; i++) {
            h += tabsList.itemAt(i,0).height
        }
        return h
    }

    delegate: TabsListTab {
        id: tab
        showCloseButton: tabsList.showCloseButton
        expandEnabled: tabsList.expandEnabled
        highlighted: (index === currentIndex) // || (hoverHighlight && hovered)
        width: parent.width
        onClicked: {
            tab.forceActiveFocus()
            userClicksTab(index)
//            if (expandEnabled) { expanded = !expanded }
        }
        onDoubleClicked: {
            userDoubleClicksTab(index)
        }
        onUserClosesTab: {
            tabsList.userClosesTab(index)
        }
    }
    highlightFollowsCurrentItem: false
    interactive: false
    model: ListModel {
        ListElement {
            url: "test"
            title: "test"
        }
        ListElement {
            url: "longlonglonglonglonglonglonglong"
            title: "longlonglonglonglonglonglonglong"
        }
    }
}
