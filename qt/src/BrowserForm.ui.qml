import QtQuick 2.4
import QtWebView 1.1
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: root
    property alias browserAddressBar: addressBar
    property alias browserBackButton: prev
    property alias browserForwardButton: next
    property alias browserRefreshButton: refresh
    property alias browserBookmarkButton: bookmark
    property alias browserDocviewSwitch: docview
    property alias browserWebViews: browserWebViews

    RowLayout {
        id: toolbar
        height: 30
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.rightMargin: 10
        anchors.leftMargin: 10
        anchors.topMargin: 5

        Button {
            id: prev
            text: qsTr("Button")
            Layout.maximumWidth: toolbar.height
            Layout.fillHeight: true
        }

        Button {
            id: next
            text: qsTr("Button")
            Layout.maximumWidth: toolbar.height
            Layout.fillHeight: true
        }

        Button {
            id: refresh
            text: qsTr("Button")
            Layout.maximumWidth: toolbar.height
            Layout.fillHeight: true
        }

        TextField {
            id: addressBar
            Layout.fillWidth: true
            Layout.fillHeight: true
            selectByMouse: true
        }

        Button {
            id: docview
            property bool inDocview: false
            text: inDocview ? qsTr("Original") : qsTr("Docview")
            Layout.fillHeight: true
        }

        Button {
            id: bookmark
            property bool browserWebView: false
            text: qsTr("Bookmark")
            Layout.fillWidth: false
            Layout.fillHeight: true
            Layout.maximumHeight: toolbar.height
            background: Rectangle {
                anchors.fill: parent
                color: this.browserWebView ? main.theme.control_on : (this.hovered ? main.theme.control_hover : main.theme.control_normal)
            }
        }
    }

    BrowserWebViews {
        id: browserWebViews
        anchors.topMargin: 40
        anchors.fill: parent
    }
}
