import QtQuick 2.7
import QtWebView 1.1
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.5 as C1
import "qrc:/controls" as C

C1.SplitView {
    id: splitView
    property alias tabsPanel: tabsPanel
    property alias browserAddressBar: addressBar
    property alias browserBackButton: prev
    property alias browserForwardButton: next
    property alias browserRefreshButton: refresh
    property alias browserBookmarkButton: bookmark
    property alias browserDocviewButton: docview
    property alias browserWebViews: browserWebViews
    property alias prevEnabled: prev.enabled
    property alias nextEnabled: next.enabled
    property alias browserSearch: browserSearch
    property alias splitView: splitView
    property alias welcomePage: welcomePage
    property int buttonSize: 40

    handleDelegate: Item {
    }

    TabsPanel {
        id: tabsPanel
        Layout.minimumWidth: 150
    }

    Rectangle {
        id: mainPanel
        color: "#00000000"
        RowLayout {
            id: toolbar
            height: buttonSize
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.rightMargin: 5
            anchors.leftMargin: 5
            anchors.topMargin: 3
            readonly property int buttonWidth: buttonSize * (Qt.platform.os == "ios" ? 1 : 1)
            //            spacing: (Qt.platform.os == "ios") ? 0 : 2
            C.Button {
                id: prev
                Layout.minimumWidth: toolbar.buttonWidth
                Layout.preferredHeight: parent.height
                iconSource: "icon/left.svg"
            }

            C.Button {
                id: next
                width: height
                Layout.minimumWidth: toolbar.buttonWidth
                Layout.preferredHeight: parent.height
                iconSource: "icon/right.svg"
            }

            C.Button {
                id: refresh
                Layout.minimumWidth: toolbar.buttonWidth
                Layout.preferredHeight: parent.height
                iconSource: "icon/refresh.svg"
            }

            BrowserAddressBar {
                id: addressBar
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height - (Qt.platform.os == "ios" ? 5 : 0)
            }

            C.Button {
                id: docview
                enabled: false
                checkable: true
                Layout.minimumWidth: toolbar.buttonWidth
                Layout.preferredHeight: parent.height
                iconSource: "icon/list.svg"
            }

            C.Button {
                id: bookmark
                enabled: false
                checkable: true
                Layout.minimumWidth: toolbar.buttonWidth
                Layout.preferredHeight: parent.height
                iconSource: bookmark.checked ? "icon/bookmark.svg" : "icon/book.svg"
            }
        }

        BrowserWebViews {
            id: browserWebViews
            anchors.top: toolbar.bottom
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.topMargin: 3

            WelcomePageForm {
                id: welcomePage
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                visible: !browserWindow.resizing
                opacity: 0.5
            }

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

    states: [
        State {
            name: "osx"

            PropertyChanges {
                target: docview
                padding: 4
            }

            PropertyChanges {
                target: bookmark
                padding: 4
            }

            PropertyChanges {
                target: prev
                padding: 6
            }

            PropertyChanges {
                target: next
                padding: 6
            }

            PropertyChanges {
                target: refresh
                padding: 3
            }
        },
        State {
            name: "ios"
        },
        State {
            name: "windows"

            PropertyChanges {
                target: docview
                padding: 3
            }

            PropertyChanges {
                target: bookmark
                padding: 3
            }

            PropertyChanges {
                target: prev
                padding: 6
            }

            PropertyChanges {
                target: next
                padding: 6
            }

            PropertyChanges {
                target: refresh
                padding: 3
            }
        }
    ]
}
