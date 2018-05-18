import QtQuick 2.0
import QtWebEngine 1.5
import Backend 1.0
import QtQuick.Layouts 1.3

Item {
    property alias canGoBack: webview.canGoBack
    property alias canGoForward: webview.canGoForward
    property alias title: webview.title
    property alias loadProgress: webview.loadProgress
    property bool docviewLoaded: false
    property bool inDocview: false
    id: webUI


    function url() {
        var s = webview.url.toString()
        var i = s.indexOf("#")
        if (i > -1) {
            return s.substring(0, i)
        }
        return s
    }

    function docviewOn() {
        inDocview = true
        webview.visible = false
        docview.visible = true
    }

    function docviewOff() {
        inDocview = false
        webview.visible = true
        docview.visible = false
    }

    function goBack() {
        docviewOff()
        webview.goBack()
    }

    function goForward() {
        docviewOff()
        webview.goForward()
    }

    function goTo(u) {
        docviewOff()
        webview.url = u
    }

    function reload() {
        docviewOff()
        webview.reload()
        docview.reload()
    }

    function clearHighlight() {
        webview.runJavaScript("Docview.clearHighlight()")
        docview.runJavaScript("Docview.clearHighlight()")
    }

    function highlightWord(word, callback) {
        (inDocview ? docview : webview).runJavaScript("Docview.highlightWord('"+word+"')", callback)
    }

    function scrollToNthHighlight(n, callback) {
        (inDocview ? docview : webview).runJavaScript("Docview.scrollToNthHighlight("+n+")", callback)
    }

    function handleNewViewRequest(request) {
        request.openIn(webview)
    }

    Component.onCompleted: {
        goTo(TabsModel.at(index).url)
    }

    WebEngineView {
        id: webview
        implicitHeight: browserWebViews.height
        implicitWidth: browserWebViews.width
        onLoadingChanged: {
            switch (loadRequest.status) {
            case WebEngineView.LoadSucceededStatus:
                console.log("WebEngineView.LoadSucceededStatus", loadRequest.errorString)
                runJavaScript(FileManager.readQrcFileS("js/docview.js"))
            }
        }
        onNewViewRequested: {
            userRequestsNewView(request)
        }
    }

    WebEngineView {
        id: docview
        visible: false
        implicitHeight: browserWebViews.height
        implicitWidth: browserWebViews.width
        url: webview.url
        onTitleChanged: {
            TabsModel.updateTab(index, "title", title)
            if (SearchDB.hasWebpage(webUI.url())) {
                SearchDB.updateWebpage(webUI.url(), "title", title)
            }
        }
        onUrlChanged: {
            TabsModel.updateTab(index, "url", webUI.url())
        }
        onLoadProgressChanged: {
            if (loading) {
                console.log("onLoadProgressChanged", index, loadProgress)
                webViewLoadingProgressChanged(index, loadProgress)
            }
        }
        onNewViewRequested: {
            userRequestsNewView(request)
        }
        onNavigationRequested: {
            console.log("onWebViewNavRequested", index)
            webViewNavRequested(index)
        }
        onLoadingChanged: {
            switch (loadRequest.status) {
            case WebEngineView.LoadStartedStatus:
                docviewLoaded = false
                console.log("WebEngineView.LoadStartedStatus", loadRequest.errorString)
                SearchDB.addWebpage(webUI.url())
                // when the url's domain is in the auto-bookmark.txt list
                var arr = FileManager.readFileS("auto-bookmark.txt").split("\n")
                var domain = webUI.url().split("/")[2]//
                SearchDB.setBookmarked(webUI.url(), arr.indexOf(domain) > -1)
                webViewLoadingStarted(index, webUI.url())
                break
            case WebEngineView.LoadSucceededStatus:
                console.log("WebEngineView.LoadSucceededStatus", loadRequest.errorString)
                runJavaScript(FileManager.readQrcFileS("js/docview.js"), function() {
                    // when the page is not in db
//                    if (! SearchDB.hasWebpage(url)) {
                        SearchDB.updateWebpage(webUI.url(), "title", title)
                        runJavaScript("Docview.symbols()", function(syms) {
                            SearchDB.addSymbols(webUI.url(), syms)
                            // turn on docview
                            runJavaScript("Docview.docviewOn()", function() {
                                if (inDocview) {
                                    docviewOn()
                                }
                                // loading done
                                docviewLoaded = true
                                webViewLoadingSucceeded(index, webUI.url())
                                webViewLoadingStopped(index, webUI.url())
                            })
                        })
//                    }
//                    // when the page is already in db, skip symbol parsing (too expensive)
//                    else {
//                        // when the url's domain is in the auto-bookmark.txt list
//                        var arr = FileManager.readFileS("auto-bookmark.txt").split("\n")
//                        var domain = url.toString().split("/")[2]
//                        if (arr.indexOf(domain) > -1) {
//                            SearchDB.updateWebpage(url, "temporary", false)
//                        }
//                        // turn on docview
//                        runJavaScript("Docview.initDocviewHTML(); Docview.turnOn()", function() {
//                            docviewLoaded = true
//                            if (inDocview) {
//                                docviewOn()
//                            }
//                            // loading done
//                            webViewLoadingSucceeded(index, loadRequest.url)
//                            webViewLoadingStopped(index, loadRequest.url)
//                        })
//                    }
                })
                break
            case WebEngineView.LoadFailedStatus:
                console.log("WebEngineView.LoadFailedStatus",
                            loadRequest.errorString)
                webViewLoadingFailed(index, webUI.url())
                webViewLoadingStopped(index, webUI.url())
                break
            case WebEngineView.LoadStoppedStatus:
                console.log("WebEngineView.LoadStoppedStatus",
                            loadRequest.errorString)
                webViewLoadingStopped(index, webUI.url())
                break
            }
        }
    }
}
