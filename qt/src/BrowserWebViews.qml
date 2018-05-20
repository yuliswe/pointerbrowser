import QtQuick 2.7
import Backend 1.0

BrowserWebViewsForm {
    id: browserWebViews

    signal userOpensLinkInWebView(int index, string url)
    signal userOpensLinkInNewTab(string url)
    signal userRequestsNewView(var request)
    signal webViewLoadingSucceeded(int index, string url)
    signal webViewLoadingStarted(int index, string url)
    signal webViewLoadingStopped(int index, string url)
    signal webViewLoadingFailed(int index, string url)
    signal webViewLoadingProgressChanged(int index, int progress)
    signal webViewNavRequested(int index)
    property var currentWebView: repeater.itemAt(currentIndex)

    repeaterModel: TabsModel

    //    Component.onCompleted: {
    //        for (var i = 0; i < TabsModel.count; i++) {
    //            webViewAt(i).url = TabsModel.at(i).url
    //        }
    //    }

    function setCurrentIndex(idx) {
        browserWebViews.stackLayout.currentIndex = idx
        console.log("setCurrentIndex", idx, browserWebViews.stackLayout.currentIndex)
    }

    function reloadWebViewAt(index) {
        console.log("reloadWebViewAt", index)
        var wv = webViewAt(index)
        wv.reload()
        //        SearchDB.updateWebpage(wv.url, "title", wv.title)
        //        wv
        //        SearchDB.addSymbols(wv.url, )
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

