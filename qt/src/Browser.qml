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
            browserWebView.reload()
        }
    }

    Connections {
        target: browserBookmarkButton
        onClicked: {
            browserWebView.reload()
        }
    }

    Connections {
        target: browserDocviewButton
        onClicked: {
            var js = FileManager.readFileQrc("docview.js")
            console.log(js)
            browserWebView.runJavaScript(js, function (output) {
                print(output)
            })
        }
    }

    Component.onCompleted: {
        browserWebView.url = "https://google.ca"
    }
}
