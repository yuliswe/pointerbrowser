import QtQuick 2.7
import QtWebView 1.1
import Backend 1.0

BrowserWebViewsForm {
    id: listView

    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: {

            var idx = TabsModel.appendTab("loadRequest.url", "", "")
        }
    }

    Component.onCompleted: {
        for (var i = 0; i < TabsModel.tabs.length; i++) {
            repeaterListModel.append(TabsModel.tabs[i])
        }
    }

    Connections {
        target: TabsModel
        onTabInserted: {
            console.log(webpage)
            repeaterListModel.append(webpage)
        }
    }

    repeaterDelegate: WebView {
        id: webview
        focus: true
        url: repeaterListModel.get(index).url
        Keys.onPressed: main.currentKeyPress = event.key
        Keys.onReleased: main.currentKeyPress = -1
        onLoadingChanged: {
            if (index === getCurrentIndex()) {
                if (loadRequest.status === WebView.LoadStartedStatus) {
                    console.log(index, loadRequest, loadRequest.url)
                    // if control key is held, then stop loading
                    // and open a new tab. If the tab already exists,
                    // do nothing
                    if (main.currentKeyPress === Qt.Key_Control) {
                        this.stop()
                        var idx = TabsModel.findTab(loadRequest.url)
                        if (idx === -1) {
                            TabsModel.appendTab(loadRequest.url, "", "")
                        }
                    }
                }
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
