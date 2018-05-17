import QtQuick 2.0
import QtWebEngine 1.5
import Backend 1.0
import QtQuick.Layouts 1.3

Item {
    property alias url: webview.url
    property alias canGoBack: webview.canGoBack
    property alias canGoForward: webview.canGoForward
    property alias title: webview.title
    property alias loadProgress: webview.loadProgress
    property bool docviewLoaded: false
    property bool inDocview: false

    function docviewOn(callback) {
        //        webview.runJavaScript("Docview.turnOn()", function() {
        //            inDocview = true
        //            callback()
        //        })
        inDocview = true
        webview.visible = false
        docview.visible = true
    }

    function docviewOff(callback) {
        //        webview.runJavaScript("Docview.turnOff()", function() {
        //            inDocview = false
        //            callback()
        //        })
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

    function goTo(url) {
        docviewOff()
        webview.url = url
        TabsModel.updateTab(index, "url", url.toString())
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
        onTitleChanged: {
            TabsModel.updateTab(index, "title", title)
            if (SearchDB.hasWebpage(url)) {
                SearchDB.updateWebpage(url, "title", title)
            }
        }
        onLoadProgressChanged: {
            if (loading) {
                console.log("onLoadProgressChanged", index, loadProgress)
                webViewLoadingProgressChanged(index, loadProgress)
            }
        }
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
//        onNavigationRequested: {
//            switch (request.navigationType) {
//            case WebEngineNavigationRequest.LinkClickedNavigation:
//                console.log("onNavigationRequested", request.url, "WebEngineNavigationRequest.LinkClickedNavigation")
//                break
//            case WebEngineNavigationRequest.TypedNavigation:
//                console.log("onNavigationRequested", request.url, "WebEngineNavigationRequest.TypedNavigation")
//                break
//            default:
//                console.log("onNavigationRequested", request.url, "default")
//            }
//        }
    }

    WebEngineView {
        id: docview
        visible: false
        implicitHeight: browserWebViews.height
        implicitWidth: browserWebViews.width
        url: webview.url
        onNewViewRequested: {
            userRequestsNewView(request)
        }
//        onNavigationRequested: {
//            switch (request.navigationType) {
//            case WebEngineNavigationRequest.LinkClickedNavigation:
//                console.log("onNavigationRequested", request.url, "WebEngineNavigationRequest.LinkClickedNavigation")
//                break
//            case WebEngineNavigationRequest.TypedNavigation:
//                console.log("onNavigationRequested", request.url, "WebEngineNavigationRequest.TypedNavigation")
//                break
//            default:
//                console.log("onNavigationRequested", request.url, "default")
//            }
//        }
        onLoadingChanged: {
            switch (loadRequest.status) {
            case WebEngineView.LoadStartedStatus:
                docviewLoaded = false
                console.log("WebEngineView.LoadStartedStatus", loadRequest.errorString)
                webViewLoadingStarted(index, loadRequest.url)
                break
            case WebEngineView.LoadSucceededStatus:
                console.log("WebEngineView.LoadSucceededStatus", loadRequest.errorString)
                runJavaScript(FileManager.readQrcFileS("js/docview.js"), function() {
                    // when the page is not in db
//                    if (! SearchDB.hasWebpage(url)) {
                        SearchDB.addWebpage(url)
                        SearchDB.updateWebpage(url, "title", title)
                        runJavaScript("Docview.symbols()", function(syms) {
                            SearchDB.addSymbols(url, syms)
                            // when the url's domain is in the auto-bookmark.txt list
                            var arr = FileManager.readFileS("auto-bookmark.txt").split("\n")
                            var domain = url.toString().split("/")[2]
                            SearchDB.updateWebpage(url, "temporary", arr.indexOf(domain) === -1)
                            // turn on docview
                            runJavaScript("Docview.initDocviewHTML(); Docview.turnOn()", function() {
                                docviewLoaded = true
                                if (inDocview) {
                                    docviewOn()
                                }
                                // loading done
                                webViewLoadingSucceeded(index, loadRequest.url)
                                webViewLoadingStopped(index, loadRequest.url)
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
                webViewLoadingFailed(index, loadRequest.url)
                webViewLoadingStopped(index, loadRequest.url)
                break
            case WebEngineView.LoadStoppedStatus:
                console.log("WebEngineView.LoadStoppedStatus",
                            loadRequest.errorString)
                webViewLoadingStopped(index, loadRequest.url)
                break
            }
        }
    }
}
