import QtQuick 2.7
import Backend 1.0
import QtQuick.Controls 2.2
import "controls" as C

Item {

    id: tabsList
    signal userClicksTab(int index)
    signal userClosesTab(int index)
    signal userDoubleClicksTab(int index)
    property bool showCloseButton: false
    property bool expandEnabled: false
    property bool expandMultipleEnabled: false
    property int currentExpandedIndex: -1
    property bool hoverHighlight: false
    property string name: "name"
    property alias model: listview.model

    function setHighlightAt(index) {
        listview.currentIndex = index
    }

    height: listview.contentHeight + name_Text.height + 5

    C.Text {
        id: name_Text
        width: tabsPanel.width
        color: Palette.normal.label_text
        text: tabsList.name
        anchors.left: parent.left
        anchors.leftMargin: 5
        verticalAlignment: Text.AlignBottom
        anchors.top: parent.top
        anchors.topMargin: 5
        topPadding: 5
        bottomPadding: 5
        leftPadding: 5
        font.bold: false
        font.capitalization: Font.AllUppercase
        font.pixelSize: 9
    }

    ListView {
        id: listview
        height: contentHeight
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: name_Text.bottom
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
            expanded: tabsList.expandEnabled // tabsList.expandMultipleEnabled ? false : (tabsList.currentExpandedIndex == index);
            highlighted: (index === listview.currentIndex) // || (hoverHighlight && hovered)
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
}
