import Backend 1.0
import QtQuick 2.7
import QtWebView 1.1
import QtQuick.Controls 2.3

BrowserForm {
    id: browser
    readonly property var browserWebView: browser.browserWebViews.getCurrentWebView()
    function showWebpageAt(idx) {
        browser.browserWebViews.setCurrentIndex(idx)
    }

    Shortcut {
        sequence: "Ctrl+Space"
        onActivated: {
            browserAddressBar.focus = true
            browserAddressBar.selectAll()
        }
    }

    Shortcut {
        sequence: "Ctrl+R"
        onActivated: browserWebView.reload()
    }

    Connections {
        target: browserWebViews
        onTitleChanged: {
            console.log(browserWebViews.getCurrentIndex(),
                        browserWebViews.getCurrentWebView())
            browserAddressBar.text = browserWebView.title
            browserAddressBar.horizontalAlignment = Text.AlignHCenter
            browserAddressBar.ensureVisible(0)
        }
        onUrlChanged: {
            var idx = TabsModel.findTab(browserWebViews.url)
            if (main.currentKeyPress === Qt.Key_Control) {
                if (idx > -1) {


                    // To do: move tab to top
                } else {
                    //                var js = FileManager.readFileQrc("docview.js")
                    browserWebView.runJavaScript(js)
                    TabsModel.appendTab(browserWebViews.url,
                                        browserWebViews.title, "")
                }
            }
        }
    }

    Connections {
        target: browserAddressBar
        onAccepted: {
            var url = browserAddressBar.text
            var exp = new RegExp("http://|https://")
            if (!exp.test(url)) {
                url = "http://www.google.com/search?query=" + url
            }
            browserWebView.url = url
            browserAddressBar.focus = false
            browserWebView.focus = true
        }
        onFocusChanged: {
            if (browserAddressBar.activeFocus) {
                browserAddressBar.horizontalAlignment = Text.AlignLeft
                browserAddressBar.text = browserWebView.url
                browserAddressBar.ensureVisible(0)
                browserAddressBar.selectAll()
            } else {
                browserAddressBar.deselect()
                browserAddressBar.horizontalAlignment = Text.AlignHCenter
                browserAddressBar.text = browserWebView.title
            }
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
