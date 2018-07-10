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
    property alias currentIndex: listview.currentIndex
    property string name: "name"

    state: Qt.platform.os

    Text {
        id: name_Text
        height: 25
        color: Palette.normal.label_text
        text: tabsList.name
        font.weight: Font.Medium
        anchors.left: parent.left
        anchors.leftMargin: 5
        verticalAlignment: Text.AlignVCenter
        leftPadding: 5
        font.capitalization: Font.Capitalize
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
                font.pixelSize: 12
            }
        }
    ]

    property alias loading: busyIndicator.running
    property alias model: listview.model
}
