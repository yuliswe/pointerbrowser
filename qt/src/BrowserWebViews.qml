import QtQuick 2.9
import QtWebView 1.1
import Backend 1.0

BrowserWebViewsForm {
    id: listView

    readonly property string url: currentWebView() ? currentWebView().url : ""
    readonly property string title: currentWebView() ? currentWebView().title : ""
    signal userOpensLinkInWebView(int index, string url)
    signal userOpensLinkInNewTab(string url)
    signal webViewLoadingSucceeded(int index, string url)
    signal webViewLoadingStarted(int index, string url)
    signal webViewLoadingStopped(int index, string url)
    signal webViewLoadingFailed(int index, string url)
    signal webViewLoadingProgressChanged(int index, int progress)

    repeaterModel: TabsModel

    //    Component.onCompleted: {
    //        for (var i = 0; i < TabsModel.count; i++) {
    //            webViewAt(i).url = TabsModel.at(i).url
    //        }
    //    }

    function currentWebView() {
        return webViewAt(currentIndex())
    }

    function currentIndex() {
        return listView.stackLayout.currentIndex
    }

    function setCurrentIndex(idx) {
        console.log("setCurrentIndex", idx)
        listView.stackLayout.currentIndex = idx
    }

    function reloadWebViewAt(index) {
        console.log("reloadWebViewAt", index)
        webViewAt(index).reload()
    }

    function webViewAt(i) {
        return listView.repeater.itemAt(i)
    }

    function reloadCurrentWebView() {
        // ignore Ctrl in this function
        reloadWebViewAt(currentIndex())
    }


    repeaterDelegate: WebView {
        id: webview
        implicitHeight: listView.height
        implicitWidth: listView.width
        Component.onCompleted: {
            url = TabsModel.at(index).url
            //            visible = true
        }
        onUrlChanged: TabsModel.updateTab(index, "url", url.toString())
        onTitleChanged: TabsModel.updateTab(index, "title", title)
        onLoadProgressChanged: webViewLoadingProgressChanged(index, loadProgress)
        onLoadingChanged: {
            switch (loadRequest.status) {
            case WebView.LoadStartedStatus:
                if (index === currentIndex()) {
                    var url = loadRequest.url
                    // if control key is held, then stop loading
                    // and open a new tab. If the tab already exists,
                    // do nothing
                    if (EventFilter.ctrlKeyDown) {
                        this.stop()
                        console.log("userOpensLinkInNewTab:", url);
                        userOpensLinkInNewTab(url)
                    } else {
                        console.log("userOpensLinkInWebView:", url, webview)
                        userOpensLinkInWebView(index, url)
                    }
                }
                webViewLoadingStarted(index, loadRequest.url)
                break
            case WebView.LoadSucceededStatus:
                console.log("WebView.LoadSucceededStatus",
                            loadRequest.errorString)
                var js = FileManager.readQrcFileS("js/docview.js")
//                var lr = loadRequest
//                var url = loadRequest.url
//                console.log("wtf??", loadRequest.url, loadRequest.status)
                webview.runJavaScript(js, function() {
                    webview.runJavaScript("Docview.symbols()", function(syms) {
//                        console.log("wtf??", lr.url, lr.status)
                        SearchDB.addWebpage(webview.url)
                        SearchDB.addSymbols(webview.url, syms)
                    })
                    webViewLoadingSucceeded(index, loadRequest.url)
                    webViewLoadingStopped(index, loadRequest.url)
                })
                break
            case WebView.LoadFailedStatus:
                console.log("WebView.LoadFailedStatus",
                            loadRequest.errorString)
                webViewLoadingFailed(index, loadRequest.url)
                webViewLoadingStopped(index, loadRequest.url)
                break
            case WebView.LoadStoppedStatus:
                console.log("WebView.LoadStoppedStatus",
                            loadRequest.errorString)
                webViewLoadingStopped(index, loadRequest.url)
                break
            }
        }
    }


    Connections {
        target: listView.stackLayout
        onCurrentIndexChanged: {
            console.log("listView.stackLayout.onCurrentIndexChanged",
                        listView.stackLayout.currentIndex)
        }
    }

}

