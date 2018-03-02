import QtQuick 2.4
import QtWebView 1.1
import QtWebEngine 1.6

Rectangle {
    width: 400
    height: 400
    WebView {
        url: "https://www.google.com"
        anchors.fill: parent
    }
}
