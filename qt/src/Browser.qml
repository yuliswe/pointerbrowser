import Backend 1.0
import QtQuick 2.9
import QtWebView 1.1
import QtQuick.Controls 2.3

BrowserForm {
    id: browser
    readonly property var browserWebView: browser.browserWebViews.currentWebView
    property int currentWebpageIndex: 0
    property bool ctrlKeyPressing: false

    ListModel {
        id: tabsModel
    }

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
    Component.onCompleted: {
        for (var i = 0; i < TabsModel.tabs.length; i++) {
            tabsModel.append(TabsModel.tabs[i])
        }
        if (TabsModel.tabs.length > 0) {
            openTab(0)
        }
    }

    browserWebViews.tabsModel: tabsModel
    tabsList.tabsModel: tabsModel
    browserAddressBar.progress: browserWebViews.loadProgress

    function newTab(url) {
        url = url || "https://google.ca"
        currentWebpageIndex = 0
        TabsModel.insertTab(currentWebpageIndex, url, "", "")
        browserWebViews.setCurrentIndex(currentWebpageIndex)
        tabsPanel.currentIndex = currentWebpageIndex
        browserAddressBar.update(url, "")
    }

    function openTab(index) {
        console.log("browser.openTab", "index=", index, "tabsModel.count=", tabsModel.count)
        browserWebViews.setCurrentIndex(index)
        var wp = browserWebViews.getWebViewAt(index)
        browserAddressBar.update(wp.url, wp.title)
        browserBookmarkButton.checked = true
        tabsList.setHighlightAt(index)
        browser.currentWebpageIndex = index
    }

    function closeTab(index) {
        console.log(browser.currentWebpageIndex , index)
        // todo: remove from backend
        TabsModel.removeTab(index)
        if (browser.currentWebpageIndex === index) {
            if (index - 1 >= 0) {
                browser.openTab(index - 1)
            } else if (index < tabsModel.count) {
                browser.openTab(index)
            } else {
                browser.newTab()
            }
        } else if (browser.currentWebpageIndex > index) {
            browser.openTab(index)
        }
        console.log("browser.closeTab", "index=", index, "tabsModel.count=", tabsModel.count)
    }

    Connections {
        target: tabsPanel
        onUserOpensNewTab: browser.newTab()
    }

    Connections {
        target: TabsModel
        onTabInserted: {
            console.log("onTabInserted:", webpage.title, webpage.url)
            tabsModel.insert(currentWebpageIndex, webpage)
            browserWebViews.setCurrentIndex(currentWebpageIndex + 1) // view does not change
        }
        onTabRemoved: {
            console.log("onTabRemoved")
            tabsModel.remove(index)
        }
    }

    Connections {
        target: tabsList
        onUserClicksTab: browser.openTab(index)
        onUserClosesTab: browser.closeTab(index)
    }

    Connections {
        target: browserWebViews
        onUserOpensLinkInCurrentWebView: {
            browserAddressBar.update(url, "")
        }
        onWebViewLoadingSucceeded: {
            var wp = browserWebViews.getWebViewAt(index)
//            TabsModel.tabs[index].title = wp.title
            if (index === currentWebpageIndex) {
                browserBookmarkButton.checked = true
                browserAddressBar.update(wp.url, wp.title)
            }
//            console.log("onWebViewLoadingSucceeded", TabsModel.tabs[index].title)
        }
    }

    Connections {
        target: browserAddressBar
        onUserEntersUrl: {
            browserWebView.url = url
        }
    }

    Connections {
        target: browserBackButton
        onClicked: {
            browserWebView.goBack()
        }
    }

    Connections {
        target: browserForwardButton
        onClicked: {
            browserWebView.goForward()
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
                browserWebView.runJavaScript(js + "Docview.turnOn()",
                                             function (result) {
                                                 print(result)
                                             })
            } else {
                browserWebView.runJavaScript(js + "Docview.turnOff()",
                                             function (result) {
                                                 print(result)
                                             })
            }

        }
    }

    Shortcut {
        sequence: "Ctrl+R"
        onActivated: browserWebViews.reloadCurrentWebView()
    }

}
