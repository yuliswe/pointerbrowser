import QtQuick 2.7
import Backend 1.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import "controls" as C

Column {

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

    function setHighlightAt(index) {
        listview.currentIndex = index
    }

    state: Qt.platform.os

//    height: name_Text.height + listview.height
//    height: listview.contentHeight + busyIndicator.height + name_Text.height + 5

    Text {
        id: name_Text
        height: 25
//        width: tabsPanel.width
        color: Palette.normal.label_text
        text: tabsList.name
        font.weight: Font.Medium
        anchors.left: parent.left
        anchors.leftMargin: 5
        verticalAlignment: Text.AlignVCenter
        leftPadding: 5
        font.capitalization: Font.Capitalize
//        font.pointSize: 8
        font.pixelSize: 11

        C.BusyIndicator {
            id: busyIndicator
            anchors.leftMargin: 5
            anchors.left: parent.right
            height: 20
            anchors.verticalCenter: parent.verticalCenter
            color: Palette.normal.label_text
        }
    }

    ListView {
        id: listview
        height: contentHeight
        anchors.right: parent.right
        anchors.left: parent.left

        //        anchors.leftMargin: 0
        //        anchors.top: name_Text.bottom
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
    states: [
        State {
            name: "osx"
        },
        State {
            name: "windows"

            PropertyChanges {
                target: name_Text
                font.pixelSize: 11
            }
        }
    ]

    property alias loading: busyIndicator.running
    property alias model: listview.model
}
