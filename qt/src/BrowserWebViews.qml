import QtQuick 2.9
import QtWebView 1.1
import Backend 1.0

BrowserWebViewsForm {
    id: listView

    property alias tabsModel: listView.repeaterModel

    readonly property var currentWebView: getWebViewAt(currentIndex)
    readonly property int loadProgress: currentWebView ? currentWebView.loadProgress : 0
    readonly property string url: currentWebView ? currentWebView.url : ""
    readonly property string title: currentWebView ? currentWebView.title : ""
    readonly property var getWebViewAt: listView.repeater.itemAt
    readonly property int currentIndex: listView.stackLayout.currentIndex
    signal userOpensLinkInCurrentWebView(string url)
    signal webViewLoadingSucceeded(int index)

    repeaterDelegate: WebView {
        id: webview
        url: model.url
        Keys.onPressed: {
            console.log("Keys.onPressed:", event.key, Qt.Key_Control)
            if (event.key === Qt.Key_Control) {
                browser.ctrlKeyPressing = true
            }
        }
        Keys.onReleased: {
            console.log("Keys.onReleased:", event.key, Qt.Key_Control)
            if (event.key === Qt.Key_Control) {
                browser.ctrlKeyPressing = false
            }
        }
        onUrlChanged: {
        }
        onLoadingChanged: {
            switch (loadRequest.status) {
            case WebView.LoadStartedStatus:
                if (index === currentIndex) {
                    var url = loadRequest.url
                    // if control key is held, then stop loading
                    // and open a new tab. If the tab already exists,
                    // do nothing
                    if (browserWindow.ctrlKeyPressing) {
                        this.stop()
                        var idx = TabsModel.findTab(url)
                        if (idx === -1) {
                            idx = TabsModel.insertTab(0,
                                                      url, "Loading", "")
                            //                            getWebViewAt(idx).stop()
                        }
                    } else {
                        userOpensLinkInCurrentWebView(url)
                    }
                }
                break
            case WebView.LoadSucceededStatus:
                //                this.success = true
                var wp = getWebViewAt(index)
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

    function setCurrentIndex(idx) {
        listView.stackLayout.currentIndex = idx
        getWebViewAt(idx).forceActiveFocus()
    }

    function reloadWebViewAt(index) {
        console.log("reloadWebViewAt", index)
        getWebViewAt(index).reload()
    }
    function reloadCurrentWebView() {
        // ignore Ctrl in this function
        reloadWebViewAt(currentIndex)
    }
}

