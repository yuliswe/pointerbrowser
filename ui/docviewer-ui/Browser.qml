import QtQuick 2.4

BrowserForm {
    Connections {
        target: browserWebView
        onUrlChanged: {
            browserAddressBar.text = browserWebView.url
            browserAddressBar.ensureVisible(0)
        }
    }

    Connections {
        target: browserAddressBar
        onAccepted: {
            browserWebView.url = browserAddressBar.text
        }
        onFocusChanged: {
            if (browserAddressBar.focus) {
                browserAddressBar.selectAll()
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

    Component.onCompleted: {
        browserWebView.url = "https://google.ca"
    }
}
