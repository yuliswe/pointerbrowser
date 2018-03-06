import Backend 1.0
import QtQuick 2.7
import QtWebView 1.1
import QtQuick.Controls 2.3

BrowserForm {
    readonly property var browserWebView: browserWebViews.getCurrentWebView()

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

    Connections {
        target: TabsModel
        onTabInserted: {
            console.log("onTabInserted", webpage)
            var idx = browserWebViews.getCurrentIndex()
            tabsModel.insert(index, webpage)
            browserWebViews.setCurrentIndex(idx + 1)
        }
    }

    Shortcut {
        sequence: "Ctrl+R"
        onActivated: browserWebViews.reloadCurrentWebView()
    }

    Connections {
        target: tabsList
        onUserOpensTab: {
            browserWebViews.setCurrentIndex(index)
            var wp = browserWebViews.getWebViewAt(index)
            browserAddressBar.update(wp.url, wp.title)
        }
    }

    Connections {
        target: browserWebViews
        onUserOpensLinkInCurrentWebView: {
            browserAddressBar.update(url, url)
        }
        onWebViewLoadingSucceeded: {
            var wp = browserWebViews.getWebViewAt(index)
            browserAddressBar.update(wp.url, wp.title)
            TabsModel.tabs[index].title = wp.title
            console.log(TabsModel.tabs[index].title)
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
        target: browserBookmarkButton
        onClicked: {
            var js = FileManager.readFileQrc("docview.js")
            function callback(jsOut) {
                var idx = TabsModel.findTab(browserWebView.url)
                if (idx === -1) {
                    browserBookmarkButton.text = "Bookmarked"
                    TabsModel.insertTab(0, browserWebView.url,
                                        browserWebView.title, jsOut)
                } else {
                    browserBookmarkButton.text = "Bookmark"
                    TabsModel.removeTab(idx)
                }
            }
//            browserWebView.runJavaScript(js, callback)
        }
    }

    Connections {
        target: browserDocviewSwitch
        onClicked: {
            browserDocviewSwitch.inDocview = !browserDocviewSwitch.inDocview
            var js = FileManager.readFileQrc("docview.js")
            if (browserDocviewSwitch.inDocview) {
//                browserWebView.runJavaScript(js + "Docview.turnOn()",
//                                             function (result) {
//                                                 print(result)
//                                             })
            } else {
//                browserWebView.runJavaScript(js + "Docview.turnOff()",
//                                             function (result) {
//                                                 print(result)
//                                             })
            }
        }
    }
}
