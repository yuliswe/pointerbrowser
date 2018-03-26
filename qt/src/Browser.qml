import Backend 1.0
import QtQuick 2.9
import QtWebView 1.1
import QtQuick.Controls 2.3

BrowserForm {
    id: browser
    function currentWebView() {
        return browserWebViews.currentWebView()
    }
    function currentIndex() {
        return browserWebViews.currentIndex()
    }

    property bool ctrlKeyPressing: false

    onCtrlKeyPressingChanged: {
        console.log("onCtrlKeyPressingChanged", ctrlKeyPressing)
    }

    Keys.onPressed: {
        console.log("Keys.onPressed:", event.key, Qt.Key_Control)
        if (event.key === Qt.Key_Control) {
            ctrlKeyPressing = true
        }
    }
    Keys.onReleased: {
        console.log("Keys.onReleased:", event.key, Qt.Key_Control)
        if (event.key === Qt.Key_Control) {
            ctrlKeyPressing = false
        }
    }
    Component.onCompleted: {
        if (TabsModel.count() > 0) {
            openTab(0)
        }
    }

    browserWebViews.tabsModel: TabsModel
    tabsPanel.tabsModel: TabsModel
    browserAddressBar.progress: browserWebViews.loadProgress

    function newTab(url, switchToView) {
        console.log("newTab:", url, switchToView)
        url = url || "https://google.ca"
        TabsModel.insertTab(0, url, "", "")
        if (switchToView) {
            openTab(0)
        } else {
            openTab(currentIndex() + 1)
        }
    }

    function openTab(index) {
        console.log("openTab", "index=", index, "TabsModel.count()=", TabsModel.count())

        browserWebViews.setCurrentIndex(index)
        tabsPanel.setCurrentIndex(index)
        var wp = currentWebView()
        wp.forceActiveFocus()
        browserAddressBar.update(wp.url, wp.title)
        browserBookmarkButton.checked = true
        prevEnabled = wp && wp.canGoBack
        nextEnabled = wp && wp.canGoForward
    }

    function closeTab(index) {
        console.log("closeTab", "index=", index, "TabsModel.count()=", TabsModel.count())
        // todo: remove from backend
        if (currentIndex() === index) {
            // when removing current tab
            // if there's one before, open that
            if (index >= 1) {
                TabsModel.removeTab(index)
                openTab(index - 1)
                // if there's one after, open that
            } else if (index + 1 < TabsModel.count()) {
                TabsModel.removeTab(index)
                openTab(index)
                // if this is the only one
            } else {
                newTab("",true)
                TabsModel.removeTab(index+1)
            }
        } else if (currentIndex() > index) {
            openTab(currentIndex() - 1)
            TabsModel.removeTab(index)
        } else {
            TabsModel.removeTab(index)
        }
    }

    Connections {
        target: tabsPanel
        onUserOpensNewTab: newTab("", true)
    }

    // Warning: only use this to semi-sync TabsModel and tabsModel
    // do not take any ui actions here
    Connections {
        target: TabsModel
        onTabInserted: {
            console.log("onTabInserted:", webpage.title, webpage.url)
            TabsModel.insert(index, webpage)
        }
        onTabRemoved: {
            console.log("onTabRemoved", index, webpage.title, webpage.url)
            TabsModel.remove(index)
        }
    }

    Connections {
        target: tabsPanel
        onUserOpensTab: openTab(index)
        onUserClosesTab: closeTab(index)
    }

    Connections {
        target: browserWebViews
        onUserOpensLinkInWebView: {
            browserAddressBar.update(url, "")
            currentWebView().forceActiveFocus()
//            prevEnabled = true
//            nextEnabled = false
        }
        onUserOpensLinkInNewTab: {
            newTab(url)
        }
        onWebViewLoadingSucceeded: {
            var wp = browserWebViews.webViewAt(index)
            if (index === currentIndex()) {
                browserBookmarkButton.checked = true
                browserAddressBar.update(wp.url, wp.title)
            }
        }
        onWebViewLoadingStopped: {
            var cw = currentWebView()
            prevEnabled = cw && cw.canGoBack
            nextEnabled = cw && cw.canGoForward
        }
    }

    Connections {
        target: browserAddressBar
        onUserEntersUrl: {
            currentWebView().url = url
        }
    }

    Connections {
        target: browserBackButton
        onClicked: {
            currentWebView().goBack()
        }
    }

    Connections {
        target: browserForwardButton
        onClicked: {
            currentWebView().goForward()
        }
    }

    Connections {
        target: browserRefreshButton
        onClicked: {
            browserWebViews.reloadCurrentWebView()
        }
    }

    Connections {
        target: browserDocviewSwitch
        onCheckedChanged: {
            var js = FileManager.readFileQrc("docview.js")
            if (browserDocviewSwitch.checked) {
                currentWebView().runJavaScript(js + "Docview.turnOn()",
                                             function (result) {
                                                 print(result)
                                             })
            } else {
                currentWebView().runJavaScript(js + "Docview.turnOff()",
                                             function (result) {
                                                 print(result)
                                             })
            }

        }
    }

    Shortcut {
        sequence: "Ctrl+R"
        onActivated: {
            ctrlKeyPressing = false
            browserWebViews.reloadCurrentWebView()
        }
    }

    Shortcut {
        sequence: "Ctrl+W"
        onActivated: {
            ctrlKeyPressing = false
            closeTab(currentIndex())
        }
    }
}
