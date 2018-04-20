import QtQuick 2.7
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
        var wv = webViewAt(index)
        wv.reload()
        //        SearchDB.updateWebpage(wv.url, "title", wv.title)
        //        wv
        //        SearchDB.addSymbols(wv.url, )
    }

    function webViewAt(i) {
        return listView.repeater.itemAt(i)
    }

    function reloadCurrentWebView() {
        reloadWebViewAt(currentIndex())
    }

    repeaterDelegate: WebView {
        id: webview
        property bool docviewLoaded: false
        property bool inDocview: false

        function docviewOn(callback) {
            webview.runJavaScript("Docview.turnOn()", function() {
                webview.inDocview = true
                callback()
            })
        }

        function docviewOff(callback) {
            webview.runJavaScript("Docview.turnOff()", function() {
                webview.inDocview = false
                callback()
            })
        }

        implicitHeight: listView.height
        implicitWidth: listView.width
        Component.onCompleted: {
            url = TabsModel.at(index).url
        }
        onUrlChanged: TabsModel.updateTab(index, "url", url.toString())
        onTitleChanged: TabsModel.updateTab(index, "title", title)
        onLoadProgressChanged: {
            if (loading) {
                console.log("onLoadProgressChanged", index, loadProgress)
                webViewLoadingProgressChanged(index, loadProgress)
            }
        }
        onLoadingChanged: {
            switch (loadRequest.status) {
            case WebView.LoadStartedStatus:
                webview.docviewLoaded = false
                console.log("WebView.LoadStartedStatus", loadRequest.errorString)
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
                console.log("WebView.LoadSucceededStatus", loadRequest.errorString)
                var js = FileManager.readQrcFileS("js/docview.js")
                webview.runJavaScript(js, function() {
                    webview.docviewLoaded = true
                    if (webview.inDocview) {
                        docviewOn()
                    }
                    if (! SearchDB.hasWebpage(webview.url)) {
                        SearchDB.addWebpage(webview.url)
                        SearchDB.updateWebpage(webview.url, "title", webview.title)
                        SearchDB.updateWebpage(webview.url, "temporary", true)
                        webview.runJavaScript("Docview.symbols()", function(syms) {
                            SearchDB.addSymbols(webview.url, syms)
                            webViewLoadingSucceeded(index, loadRequest.url)
                            webViewLoadingStopped(index, loadRequest.url)
                        })
                    } else {
                        webViewLoadingSucceeded(index, loadRequest.url)
                        webViewLoadingStopped(index, loadRequest.url)
                    }
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

