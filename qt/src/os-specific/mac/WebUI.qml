import QtQuick 2.9
import QtQml 2.2
import QtWebEngine 1.5
import Backend 1.0
import QtQuick.Layouts 1.3

Item {
    property alias canGoBack: webview.canGoBack
    property alias canGoForward: webview.canGoForward
    property alias title: webview.title
    property alias loadProgress: docview.loadProgress
    property bool docviewLoaded: false
    property bool inDocview: false
    property bool bookmarked: false
    property alias href: webview.url
    id: webUI

    function bookmark() {
        if (SearchDB.setBookmarked(url(), true)) {
            bookmarked = true
        }
    }

    function unbookmark() {
        if (SearchDB.setBookmarked(url(), false)) {
            bookmarked = false
        }
    }

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

    function clearFindText() {
        findNext("")
    }

    function findNext(word, callback) {
        var target = inDocview ? docview : webview
        target.findText(word, 0, callback)
    }


    function findPrev(word, callback) {
        var target = inDocview ? docview : webview
        target.findText(word, WebEngineView.FindBackward, callback)
    }

    function handleNewViewRequest(request) {
        request.openIn(webview)
    }

    Component.onCompleted: {
        var url = TabsModel.at(index).url
        goTo(url)
        bookmarked = SearchDB.bookmarked(url)
    }

    WebEngineView {
        id: webview
        onWidthChanged: {
            console.log(width)
        }
        width: Math.round(browserWebViews.width)
        height: Math.round(browserWebViews.height)
//        implicitHeight: browserWebViews.height
//        implicitWidth: Math.floor(browserWebViews.width)
        onNewViewRequested: {
            console.log("onNewViewRequested", request, JSON.stringify(request));
//            userRequestsNewView(request)

        }
        settings.focusOnNavigationEnabled: false
    }

    WebEngineView {
        id: docview
        visible: false
        implicitHeight: browserWebViews.height
        implicitWidth: browserWebViews.width
        url: webview.url
        settings.focusOnNavigationEnabled: false
        onTitleChanged: {
            TabsModel.updateTab(index, "title", title)
            if (SearchDB.hasWebpage(webUI.url())) {
                SearchDB.updateWebpage(webUI.url(), "title", title)
            }
        }
        onUrlChanged: {
            TabsModel.updateTab(index, "url", webUI.href)
            bookmarked = SearchDB.bookmarked(webUI.url())
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
                if (! SearchDB.hasWebpage(webUI.url())) {
                    SearchDB.addWebpage(webUI.url())
                }
                if (! SearchDB.bookmarked(webUI.url())) {
                    // when the url's domain is in the auto-bookmark.txt list
                    var arr = FileManager.readFileS("auto-bookmark.txt").split("\n")
                    var domain = webUI.url().split("/")[2]
                    SearchDB.setBookmarked(webUI.url(), arr.indexOf(domain) > -1)
                }
                webViewLoadingStarted(index, webUI.href)
                break
            case WebEngineView.LoadSucceededStatus:
                console.log("WebEngineView.LoadSucceededStatus", loadRequest.errorString)
                SearchDB.updateWebpage(webUI.url(), "crawling", true)
                SearchDB.updateWebpage(webUI.url(), "title", title)
                runJavaScript(FileManager.readQrcFileS("js/docview.js"), function() {
                    runJavaScript("Docview.crawler()", function(result) {
                        console.log(result.referer, result.symbols, result.links)
                        console.log(result.referer, webUI.url())
                        SearchDB.addSymbols(result.referer, result.symbols)
                        SearchDB.updateWebpage(result.referer, "crawling", false)
                        // loading done
                        crawler.queueLinks(result.referer, result.links)
                    })
                    runJavaScript("Docview.docviewOn()", function() {
                        if (inDocview) {
                            docviewOn()
                        }
                        docviewLoaded = true
                    })
                    webViewLoadingSucceeded(index, webUI.url())
                    webViewLoadingStopped(index, webUI.url())
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
        settings {
            focusOnNavigationEnabled: false
            pluginsEnabled: false
            linksIncludedInFocusChain: false
            autoLoadImages: false
            autoLoadIconsForPage: false
            javascriptCanOpenWindows: false
            allowGeolocationOnInsecureOrigins: false
//            allowWindowActivationFromJavaScript: false
            allowRunningInsecureContent: false
            webGLEnabled: false
//            playbackRequiresUserGesture: true
//            unknownUrlSchemePolicy: WebEngineSettings.DisallowUnknownUrlSchemes
        }
    }


    WebEngineView {
        id: crawler
        implicitHeight: browserWebViews.height
        implicitWidth: browserWebViews.width
        visible: false
        focus: false
        activeFocusOnPress: false
//        JavaScriptConsoleMessageLevel:
        settings {
            focusOnNavigationEnabled: false
            pluginsEnabled: false
            linksIncludedInFocusChain: false
            errorPageEnabled: false
            autoLoadImages: false
            autoLoadIconsForPage: false
            javascriptCanOpenWindows: false
            allowGeolocationOnInsecureOrigins: false
//            allowWindowActivationFromJavaScript: false
            allowRunningInsecureContent: false
            webGLEnabled: false
//            playbackRequiresUserGesture: true
//            unknownUrlSchemePolicy: WebEngineSettings.DisallowUnknownUrlSchemes
        }

        property var queue: []
//        url: queue.length ? queue[0] : ""
        function queueLinks(referer, links) {
            console.log("crawler.queueLinks", referer, links)
            // check if referer is fully crawled
            var incomplete = []
            var unstarted = []
            for (var i = 0; i < links.length; i++) {
                var l = links[i]
                if (! SearchDB.hasWebpage(l)) {
                    SearchDB.addWebpage(l)
                }
                var w = SearchDB.findWebpage(l)
                if (w.crawling) {
                    incomplete.push(l)
                } else if (! w.crawled) {
                    unstarted.push(l)
                    SearchDB.updateWebpage(l, "crawling", true)
                }
            }
            if (incomplete.length == 0 && unstarted.length == 0) {
                SearchDB.updateWebpage(referer, "crawled", true)
            }
            queue = queue.concat(unstarted)
//            console.log("now queue is", loading, queue.length)
            crawNext()
        }
        function crawNext() {
            if (queue.length && ! loading) {
                var u = queue.shift()
                console.log("crawling", u)
                url = u
            }
        }
        onLoadingChanged: {
            switch (loadRequest.status) {
            case WebEngineView.LoadStartedStatus:
                if (! SearchDB.hasWebpage(url)) {
                    SearchDB.addWebpage(url)
                }
                break
            default:
                runJavaScript(FileManager.readQrcFileS("js/docview.js"), function() {
                    runJavaScript("Docview.crawler()", function(result) {
                        SearchDB.addSymbols(result.referer, result.symbols)
                        SearchDB.updateWebpage(result.referer, "crawling", false)
                        SearchDB.updateWebpage(result.referer, "title", title)
                        // loading done
//                        queueLinks(result.referer, result.links)
                        crawNext()
                    })
                })
            }
        }
    }
}
