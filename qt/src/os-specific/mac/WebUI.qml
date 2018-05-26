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
        width: browserWebViews.width
        height: browserWebViews.height
        onNewViewRequested: {
            console.log("onNewViewRequested", request, JSON.stringify(request));
            userRequestsNewView(request)
        }
        settings.focusOnNavigationEnabled: false
    }

    function noHash(u) {
        var s = u.toString()
        var i = s.indexOf("#")
        if (i > -1) {
            return s.substring(0, i)
        }
        return s
    }

    WebEngineView {

        id: docview
        visible: false
        height: browserWebViews.height
        width: browserWebViews.width
        url: webview.url
        settings.focusOnNavigationEnabled: false
        onTitleChanged: {
            if (title) {
                TabsModel.updateTab(index, "title", title)
                if (SearchDB.hasWebpage(noHash(url))) {
                    SearchDB.updateWebpage(noHash(url), "title", title)
                }
            }
        }
        onUrlChanged: {
            TabsModel.updateTab(index, "url", webUI.href)
            bookmarked = SearchDB.bookmarked(noHash(url))
        }
        onLoadProgressChanged: {
            if (loading) {
                console.log("onLoadProgressChanged", index, loadProgress)
                // webViewLoadingProgressChanged(index, loadProgress)
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
            if (loadRequest.status == WebEngineView.LoadStartedStatus) {
                docviewLoaded = false
                console.log("WebEngineView.LoadStartedStatus", loadRequest.errorString)
                if (! SearchDB.hasWebpage(noHash(url))) {
                    SearchDB.addWebpage(noHash(url))
                }
                if (! SearchDB.bookmarked(noHash(url))) {
                    // when the url's domain is in the auto-bookmark.txt list
                    var arr = FileManager.readFileS("auto-bookmark.txt").split("\n")
                    var domain = noHash(url).split("/")[2]
                    SearchDB.setBookmarked(noHash(url), arr.indexOf(domain) > -1)
                }
                SearchDB.updateWebpage(noHash(url), "crawling", true)
            } else {
                SearchDB.updateWebpage(noHash(url), "crawling", false)
                runJavaScript(FileManager.readQrcFileS("js/docview.js"), function() {
                    runJavaScript("Docview.crawler()", function(result) {
                        SearchDB.addSymbols(noHash(url), result.symbols)
                        // loading done
                        crawler.queueLinks(noHash(url), result.links)
                    })
                    runJavaScript("Docview.docviewOn()", function() {
                        if (inDocview) {
                            docviewOn()
                        }
                        docviewLoaded = true
                    })
                })
            }
        }
        settings {
            focusOnNavigationEnabled: false
            pluginsEnabled: false
            linksIncludedInFocusChain: false
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
        height: browserWebViews.height
        width: browserWebViews.width
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

        Component.onDestruction: {
            if (loading) {
                queue.push(url)
            }
            queue.forEach(function(l) {
                SearchDB.updateWebpage(l, "crawling", false)
            })
        }

        property var queue: []
        //        url: queue.length ? queue[0] : ""
        function queueLinks(referer, links) {
            console.log("crawler.queueLinks", referer, links)
            // check if referer is fully crawled
            var incomplete = []
            var unstarted = []
            var arr = FileManager.readFileS("auto-bookmark.txt").split("\n")
            for (var i = 0; i < links.length; i++) {
                var l = links[i]
                if (! SearchDB.hasWebpage(l)) {
                    SearchDB.addWebpage(l)
                }
                if (! SearchDB.bookmarked(l)) {
                    // when the url's domain is in the auto-bookmark.txt list
                    var domain = l.split("/")[2]
                    SearchDB.setBookmarked(l, arr.indexOf(domain) > -1)
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
            console.log("unstarted", unstarted)
            crawNext()
        }
        function crawNext() {
            console.log("crawNext")
            if (queue.length) {
                var u = queue.shift()
                console.log("crawling next", u)
                url = u
            }
        }

        onTitleChanged: {
            if (title && SearchDB.hasWebpage(url)) {
                SearchDB.updateWebpage(url, "title", title)
            }
        }

        onLoadingChanged: {
            switch (loadRequest.status) {
            case WebEngineView.LoadStartedStatus:
                break
            default:
                SearchDB.updateWebpage(url, "crawling", false)
                runJavaScript(FileManager.readQrcFileS("js/docview.js"), function() {
                    runJavaScript("Docview.crawler()", function(result) {
                        SearchDB.addSymbols(url, result.symbols)
                        // loading done
                        crawNext()
                    })
                })
            }
        }
    }
}
