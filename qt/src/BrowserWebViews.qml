import QtQuick 2.7
import Backend 1.0

BrowserWebViewsForm {
    id: browserWebViews

    signal userRequestsNewView(var request)
    signal webViewNavRequested(int index)
    property var currentWebView: repeater.itemAt(currentIndex)

    repeaterModel: TabsModel

    function setCurrentIndex(idx) {
        browserWebViews.stackLayout.currentIndex = idx
        console.log("setCurrentIndex", idx, browserWebViews.stackLayout.currentIndex)
    }

    function reloadWebViewAt(index) {
        console.log("reloadWebViewAt", index)
        var wv = webViewAt(index)
        wv.reload()
    }

    function webViewAt(i) {
        return browserWebViews.repeater.itemAt(i)
    }

    function reloadCurrentWebView() {
        reloadWebViewAt(currentIndex)
    }

    repeaterDelegate: WebUI {}

    Connections {
        target: browserWebViews.stackLayout
        onCurrentIndexChanged: {
            console.log("browserWebViews.stackLayout.onCurrentIndexChanged",
                        browserWebViews.stackLayout.currentIndex)
        }
    }

}

