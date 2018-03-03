import QtQuick 2.4
import Backend 1.0

BrowserForm {
    Connections {
        target: browserWebView
        onTitleChanged: {
            browserAddressBar.text = browserWebView.title
            browserAddressBar.horizontalAlignment = Text.AlignHCenter
            browserAddressBar.ensureVisible(0)
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
            TabsModel.addTab(url)
        }
    }

    Connections {
        target: browserBookmarkButton
        onClicked: {
            var js = FileManager.readFileQrc("docview.js")
            function callback(jsOut) {
                TabsModel.insertTab(0, browserWebView.url,
                                    browserWebView.title, jsOut)
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

    Component.onCompleted: {
        browserWebView.url = "https://google.ca"
        var js = FileManager.readFileQrc("docview.js")
        // load framework // doesn't work!
        browserWebView.runJavaScript(js, function (result) {
            print(result)
        })
    }
}
