import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQml 2.2
import QtWebEngine 1.5
import Backend 1.0

Item {
    id: browserWebViews

    signal userRequestsNewView(WebEngineNewViewRequest request)
    signal webViewNavRequested(int index)
    property var currentWebView: repeater.itemAt(currentIndex)
    property alias currentIndex: stackLayout.currentIndex
    property alias crawler: crawler
    property alias model: repeater.model

    function setCurrentIndex(idx) {
        currentIndex = idx
    }

    function reloadWebViewAt(index) {
        console.log("reloadWebViewAt", index)
        var wv = webViewAt(index)
        wv.reload()
    }

    function webViewAt(i) {
        return repeater.itemAt(i)
    }

    function reloadCurrentWebView() {
        reloadWebViewAt(currentIndex)
    }

    function setPreviewMode(index, mode) {
        repeater.itemAt(index).previewMode = mode;
    }

    Crawler {
        id: crawler
    }


    StackLayout {
        id: stackLayout
        anchors.fill: parent
        onCurrentIndexChanged: {
            console.log("browserWebViews.onCurrentIndexChanged",
                        browserWebViews.currentIndex)
        }
        Repeater {
            id: repeater
            delegate: WebUI {}
        }
    }
}

