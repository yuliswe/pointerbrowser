import Backend 1.0
import QtQuick 2.9
import QtWebView 1.1
import QtQuick.Controls 2.3

BrowserForm {
    readonly property var browserWebView: browserWebViews.getCurrentWebView()
    property int currentWebpageIndex: 0

    ListModel {
        id: tabsModel
    }

    Component.onCompleted: {
        for (var i = 0; i < TabsModel.tabs.length; i++) {
            tabsModel.append(TabsModel.tabs[i])
        }
    }

    browserWebViews.tabsModel: tabsModel
    tabsList.tabsModel: tabsModel

    function newTab(url) {
        url = url || "https://google.ca"
        currentWebpageIndex = 0
        TabsModel.insertTab(currentWebpageIndex, url, "", "")
        browserWebViews.setCurrentIndex(currentWebpageIndex)
        tabsPanel.currentIndex = currentWebpageIndex
        browserAddressBar.update(url, "")
    }

    Connections {
        target: tabsPanel
        onUserOpensNewTab: browser.newTab()
    }

    Connections {
        target: TabsModel
        onTabInserted: {
            console.log("onTabInserted", webpage)
            tabsModel.insert(currentWebpageIndex, webpage)
            browserWebViews.setCurrentIndex(currentWebpageIndex + 1) // view does not change
        }
        onTabRemoved: {
            console.log("onTabRemoved")
            tabsModel.remove(index)
        }
    }

    function openTab(index) {
        console.log("browser.openTab", "index=", index, "tabsModel.count=", tabsModel.count)
        browserWebViews.setCurrentIndex(index)
        var wp = browserWebViews.getWebViewAt(index)
        browserAddressBar.update(wp.url, wp.title)
        browserBookmarkButton.checked = true
        tabsList.setHighlightAt(index)
    }

    function closeTab(index) {
        var indexToOpen;
        var lastIndex = tabsModel.count - 2
        if (browser.currentWebpageIndex > index) {
            indexToOpen = index - 1 // move view backward
        } else {
            indexToOpen = index // move view forward
        }
        console.log("browser.closeTab", "index=", index, "indexToOpen=", indexToOpen, "tabsModel.count=", tabsModel.count)
        tabsModel.remove(index)
        if (indexToOpen > lastIndex) {
            browser.newTab()
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
            TabsModel.tabs[index].title = wp.title
            if (index === currentWebpageIndex) {
                browserBookmarkButton.checked = true
                browserAddressBar.update(wp.url, wp.title)
            }
            console.log("onWebViewLoadingSucceeded", TabsModel.tabs[index].title)
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
