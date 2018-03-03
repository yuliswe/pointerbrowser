import QtQuick 2.4
import QtWebView 1.1
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Rectangle {
    property alias browserWebView: webView
    property alias browserAddressBar: addressBar
    property alias browserBackButton: prev
    property alias browserForwardButton: next
    property alias browserRefreshButton: refresh
    property alias browserBookmarkButton: bookmark
    property alias browserDocviewSwitch: docview

    WebView {
        id: webView
        anchors.topMargin: 40
        url: addressBar.text
        anchors.fill: parent
    }

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
            Layout.maximumHeight: toolbar.height
        }

        Button {
            id: next
            text: qsTr("Button")
            Layout.maximumWidth: toolbar.height
            Layout.maximumHeight: toolbar.height
        }

        Button {
            id: refresh
            text: qsTr("Button")
            Layout.maximumWidth: toolbar.height
            Layout.maximumHeight: toolbar.height
        }

        TextField {
            id: addressBar
            Layout.fillWidth: true
            Layout.maximumHeight: toolbar.height
            selectByMouse: true
        }

        Button {
            id: docview
            property bool inDocview: false
            text: inDocview ? qsTr("Original") : qsTr("Docview")
            Layout.maximumHeight: toolbar.height
        }

        Button {
            id: bookmark
            text: qsTr("Bookmark")
            Layout.maximumHeight: toolbar.height
        }
    }
}
