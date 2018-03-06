import QtQuick 2.4
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

    handleDelegate: Item {
    }

    TabsPanel {
        id: tabsPanel
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        Layout.minimumWidth: 200
    }

    Rectangle {
        id: rectangle
        y: 0
        color: ctl.palette.button
        RowLayout {
            id: toolbar
            x: -835
            y: 5
            height: 25
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.rightMargin: 5
            anchors.leftMargin: 5
            anchors.topMargin: 5

            C.Button {
                id: prev
                width: 25
                text: "Button"
                Layout.maximumWidth: toolbar.height
                Layout.fillHeight: true
            }

            C.Button {
                id: next
                width: height
                text: "Button"
                Layout.maximumWidth: toolbar.height
                Layout.fillHeight: true
            }

            C.Button {
                id: refresh
                width: height
                text: qsTr("Button")
                Layout.maximumWidth: toolbar.height
                Layout.fillHeight: true
            }

            BrowserAddressBar {
                id: addressBar
                Layout.fillWidth: true
                Layout.fillHeight: true
                url: browserWebViews.url
                title: browserWebViews.title
                progress: browserWebView.loadProgress
            }

            C.Button {
                id: docview
                property bool inDocview: false
                width: height
                text: inDocview ? qsTr("Original") : qsTr("Docview")
                Layout.fillHeight: true
            }

            C.Button {
                id: bookmark
                property bool browserWebView: false
                width: height
                text: qsTr("Bookmark")
                Layout.fillWidth: false
                Layout.fillHeight: true
                Layout.maximumHeight: toolbar.height
            }
        }

        BrowserWebViews {
            id: browserWebViews
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.topMargin: 34
        }

        Control {
            id: ctl
            x: 0
            y: 0
        }
    }
}
