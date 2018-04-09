import QtQuick 2.9
import QtWebView 1.1
import Backend 1.0

BrowserWebViewsForm {
    id: listView

    readonly property int loadProgress: currentWebView() ? currentWebView().loadProgress : 0
    readonly property string url: currentWebView() ? currentWebView().url : ""
    readonly property string title: currentWebView() ? currentWebView().title : ""
    signal userOpensLinkInWebView(int index, string url)
    signal userOpensLinkInNewTab(string url)
    signal webViewLoadingSucceeded(int index, string url)
    signal webViewLoadingStarted(int index, string url)
    signal webViewLoadingStopped(int index, string url)
    signal webViewLoadingFailed(int index, string url)

    repeaterModel: TabsModel

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
        property string modelUrl: model ? model.url : ""
        onModelUrlChanged: {
            // must compare with ==
            // the two string types might be different!
            console.log("onModelUrlChanged:", url, model.url, url == modelUrl)
            if (url != modelUrl) {
                url = modelUrl
            }
        }
        onTitleChanged: {
            TabsModel.updateTab(index, "title", title)
        }
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
                TabsModel.updateTab(index, "url", loadRequest.url)
                webViewLoadingSucceeded(index, loadRequest.url)
                webViewLoadingStopped(index, loadRequest.url)
                break
            case WebView.LoadFailedStatus:
                TabsModel.updateTab(index, "url", loadRequest.url)
                webViewLoadingFailed(index, loadRequest.url)
                webViewLoadingStopped(index, loadRequest.url)
                break
            case WebView.LoadStoppedStatus:
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

