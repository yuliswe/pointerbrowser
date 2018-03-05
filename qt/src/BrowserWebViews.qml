import QtQuick 2.7
import QtWebView 1.1
import Backend 1.0

BrowserWebViewsForm {
    id: listView

    Component.onCompleted: {
        for (var i = 0; i < TabsModel.tabs.length; i++) {
            repeaterListModel.append(TabsModel.tabs[i])
        }
        setCurrentIndex(0)
    }

    Connections {
        target: TabsModel
        onTabInserted: {
            console.log(webpage)
            repeaterListModel.insert(index, webpage)
            if (listView.stackLayout.currentIndex >= index) {
                listView.stackLayout.currentIndex++
            }
        }
    }

    repeaterDelegate: WebView {
        id: webview
        property bool success: false
        focus: true
        url: model.url
        Keys.onPressed: main.currentKeyPress = event.key
        Keys.onReleased: main.currentKeyPress = -1
        onLoadingChanged: {
            console.log(index, loadRequest, loadRequest.url)
            switch (loadRequest.status) {
            case WebView.LoadStartedStatus:
                if (index === getCurrentIndex()) {
                    // if control key is held, then stop loading
                    // and open a new tab. If the tab already exists,
                    // do nothing
                    if (main.currentKeyPress === Qt.Key_Control) {
                        this.stop()
                        var idx = TabsModel.findTab(loadRequest.url)
                        if (idx === -1) {
                            idx = TabsModel.insertTab(0,
                                                      loadRequest.url, "", "")
                            getWebViewAt(idx).stop()
                        }
                    }
                }
                break
            case WebView.LoadSucceededStatus:
                this.success = true
                break
            }
        }
    }

    //    Component.onCompleted: {
    //        listView.setCurrentIndex(0)
    //        listView.repeater.model = TabsModel.tabs
    //    }
    Connections {
        target: listView.stackLayout
        onCurrentIndexChanged: {
            console.log("listView.stackLayout.onCurrentIndexChanged",
                        listView.stackLayout.currentIndex)
        }
    }
    property string url: getCurrentWebView() ? getCurrentWebView().url : ""
    property string title: getCurrentWebView() ? getCurrentWebView().title : ""
    function setCurrentIndex(idx) {
        listView.stackLayout.currentIndex = idx
        if (!getWebViewAt(idx).success) {
            getWebViewAt(idx).reload()
        }
    }
    function getWebViewAt(idx) {
        return listView.repeater.itemAt(idx)
    }
    function getCurrentIndex() {
        return listView.stackLayout.currentIndex
    }
    function getCurrentWebView() {
        var idx = listView.getCurrentIndex()
        return listView.getWebViewAt(idx)
    }
}
