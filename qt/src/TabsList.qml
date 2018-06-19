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
    property bool expandMultipleEnabled: false
    property int currentExpandedIndex: -1
    property bool hoverHighlight: false

    function setHighlightAt(index) {
        tabsList.currentIndex = index
    }
    height: contentHeight
//    height: {
//        var h = 0;
//        for (var i = 0; i < tabsList.count; i++) {
//            console.warn(h)
//            h += tabsList.itemAt(i,0).height
//        }
//        return h
//    }

    delegate: TabsListTab {
        id: tab
        showCloseButton: tabsList.showCloseButton
        expanded: tabsList.expandMultipleEnabled ? false : (tabsList.currentExpandedIndex == index);
        highlighted: (index === currentIndex) // || (hoverHighlight && hovered)
        width: parent.width
        onClicked: {
            tab.forceActiveFocus()
            userClicksTab(index)
            if (tabsList.expandEnabled) {
                if (tabsList.expandMultipleEnabled) {
                    expanded = !expanded
//                    expanded = Qt.binding(function() {return tabsList.currentExpandedIndex == index})
                } else {
                    tabsList.currentExpandedIndex = index
                }
            }
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
