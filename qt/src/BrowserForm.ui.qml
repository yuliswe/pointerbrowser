import QtQuick 2.9
import QtWebView 1.1
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.5 as C1
import "controls" as C

C1.SplitView {
    id: splitView
    property alias tabsPanel: tabsPanel
    property alias tabsList: tabsPanel.tabsList
    property alias browserAddressBar: addressBar
    property alias browserBackButton: prev
    property alias browserForwardButton: next
    property alias browserRefreshButton: refresh
    property alias browserBookmarkButton: bookmark
    property alias browserDocviewSwitch: docview
    property alias browserWebViews: browserWebViews
    property alias prevEnabled: prev.enabled
    property alias nextEnabled: next.enabled
    property alias browserSearch: browserSearch
    property int buttonSize: 40

    SystemPalette {
        id: actPal
        colorGroup: SystemPalette.Active
    }

    handleDelegate: Item {
    }

    Rectangle {
        id: rectangle
        color: "#00000000"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        RowLayout {
            id: toolbar
            height: buttonSize
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.rightMargin: 5
            anchors.leftMargin: 5
            anchors.topMargin: 3

            C.Button {
                id: prev
                leftPadding: 5
                padding: 7
                Layout.preferredWidth: parent.height
                Layout.preferredHeight: parent.height
                icon {
                    source: "icon/left.svg"
                }
            }

            C.Button {
                id: next
                width: height
                rightPadding: 5
                padding: 7
                Layout.preferredWidth: parent.height
                Layout.preferredHeight: parent.height
                icon {
                    source: "icon/right.svg"
                }
            }

            C.Button {
                id: refresh
                topPadding: 4
                padding: 3
                Layout.preferredWidth: parent.height
                Layout.preferredHeight: parent.height
                icon {
                    source: "icon/refresh.svg"
                }
            }

            BrowserAddressBar {
                id: addressBar
                Layout.fillWidth: true
                Layout.fillHeight: true
                url: browserWebViews.url
                title: browserWebViews.title
            }

            C.Button {
                id: docview
                topPadding: 4
                bottomPadding: 4
                padding: 0
                checkable: true
                Layout.preferredWidth: parent.height
                Layout.preferredHeight: parent.height
                icon {
                    source: "icon/list.svg"
                }
            }

            C.Button {
                id: bookmark
                checkable: true
                Layout.preferredWidth: parent.height
                Layout.preferredHeight: parent.height
                icon {
                    source: checked ? "icon/bookmark.svg" : "icon/book.svg"
                }
            }
        }

        BrowserWebViews {
            id: browserWebViews
            anchors.top: toolbar.bottom
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.topMargin: 3

            BrowserSearch {
                id: browserSearch
                width: 300
                height: 30
                visible: false
                anchors.right: parent.right
                anchors.top: parent.top
            }
        }

        Layout.minimumWidth: 300
        Layout.fillWidth: true
    }

    TabsPanel {
        id: tabsPanel
        width: 150
        Layout.minimumWidth: 150
    }
}
