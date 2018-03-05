import Backend 1.0
import QtQuick 2.7
import QtWebView 1.1
import QtQuick.Controls 2.3

BrowserForm {
    readonly property var browserWebView: browserWebViews.getCurrentWebView()

    Shortcut {
        sequence: "Ctrl+R"
        onActivated: browserWebViews.reloadCurrentWebView()
    }

    Connections {
        target: tabsList
        onUserOpensTab: {
            browserWebViews.setCurrentIndex(index)
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
        }
    }

    Connections {
        target: browserAddressBar
        onUserEnterUrl: {
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
            browserWebView.reload()
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
            browserWebView.runJavaScript(js, callback)
        }
    }

    Connections {
        target: browserDocviewSwitch
        onClicked: {
            browserDocviewSwitch.inDocview = !browserDocviewSwitch.inDocview
            var js = FileManager.readFileQrc("docview.js")
            if (browserDocviewSwitch.inDocview) {
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
}
