import QtQuick 2.9
import QtWebView 1.1
import Backend 1.0

BrowserWebViewsForm {
    id: listView

    property alias tabsModel: listView.repeaterModel

    readonly property int loadProgress: currentWebView() ? currentWebView().loadProgress : 0
    readonly property string url: currentWebView() ? currentWebView().url : ""
    readonly property string title: currentWebView() ? currentWebView().title : ""
    signal userOpensLinkInWebView(int index, string url)
    signal userOpensLinkInNewTab(string url)
    signal webViewLoadingSucceeded(int index)

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
        reloadWebViewAt(currentIndex)
    }


    repeaterDelegate: WebView {
        id: webview
        url: model.url
        Keys.onPressed: {
            console.log("Keys.onPressed:", event.key)
            if (event.key === Qt.Key_Control) {
                browser.ctrlKeyPressing = true
            }
        }
        Keys.onReleased: {
            console.log("Keys.onReleased:", event.key)
            if (event.key === Qt.Key_Control) {
                browser.ctrlKeyPressing = false
            }
        }
        onUrlChanged: {
        }
        onLoadingChanged: {
            switch (loadRequest.status) {
            case WebView.LoadStartedStatus:
                if (index === currentIndex()) {
                    var url = loadRequest.url
                    // if control key is held, then stop loading
                    // and open a new tab. If the tab already exists,
                    // do nothing
                    if (browser.ctrlKeyPressing) {
                        this.stop()
                        var idx = TabsModel.findTab(url)
                        if (idx === -1) {
                            console.log("userOpensLinkInNewTab:", url);
                            userOpensLinkInNewTab(url)
                        }
                    } else {
                        console.log("userOpensLinkInWebView:", url, webview)
                        userOpensLinkInWebView(index, url)
                    }
                }
                break
            case WebView.LoadSucceededStatus:
                //                this.success = true
                var wp = webViewAt(index)
                tabsModel.setProperty(index, "title", wp.title)
                //                tabsModel.setProperty(index, "url", wp.url.toString())
                webViewLoadingSucceeded(index)
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

