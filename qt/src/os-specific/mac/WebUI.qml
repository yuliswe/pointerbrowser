import QtQuick 2.9
import QtQml 2.2
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
    property bool bookmarked: false
    property alias href: webview.url
    id: webUI

    function bookmark() {
        if (SearchDB.setBookmarked(noHash(webview.url), true)) {
            bookmarked = true
        }
    }

    function unbookmark() {
        if (SearchDB.setBookmarked(noHash(webview.url), false)) {
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

    function warning() {
        var args = Array.prototype.slice.call(arguments);
        args.unshift("WebUI", index);
        console.warn.apply(null, args)
    }

    function info() {
        var args = Array.prototype.slice.call(arguments);
        args.unshift("WebUI", index);
        console.info.apply(null, args)
    }

    function error() {
        var args = Array.prototype.slice.call(arguments);
        args.unshift("WebUI", index);
        console.error.apply(null, args)
    }

    function logging() {
        var args = Array.prototype.slice.call(arguments);
        args.unshift("WebUI", index);
        console.log.apply(null, args)
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
            logging("webview onNewViewRequested", request, JSON.stringify(request));
            userRequestsNewView(request)
        }
        settings.focusOnNavigationEnabled: false

        onTitleChanged: {
            logging('webview title changed', title)
            if (title) {
                TabsModel.updateTab(index, "title", title)
                if (SearchDB.hasWebpage(noHash(url))) {
                    SearchDB.updateWebpage(noHash(url), "title", title)
                }
            }
        }
        onUrlChanged: {
            logging('webview url changed', url)
            if (url) {
                TabsModel.updateTab(index, "url", webUI.href)
                bookmarked = SearchDB.bookmarked(noHash(url))
            }
        }
        onLoadProgressChanged: {
            logging('webview load progress', loadProgress)
        }
        onNavigationRequested: {
            logging("webview navigation requested", request.url)
            webViewNavRequested(index)
        }
        onLoadingChanged: {
            logging("webview loading changed", loading)
            if (loadRequest.status == WebEngineView.LoadStartedStatus) {
                docviewLoaded = false
                logging("webview loading started", loadRequest.url)
                if (! SearchDB.hasWebpage(noHash(loadRequest.url))) {
                    SearchDB.addWebpage(noHash(loadRequest.url))
                }
                if (! SearchDB.bookmarked(noHash(loadRequest.url))) {
                    // when the url's domain is in the auto-bookmark.txt list
                    var arr = FileManager.readDataFileS("auto-bookmark.txt").split("\n")
                    var domain = noHash(loadRequest.url).split("/")[2]
                    SearchDB.setBookmarked(noHash(loadRequest.url), arr.indexOf(domain) > -1)
                }
                SearchDB.updateWebpage(noHash(loadRequest.url), "crawling", true)
            } else {
                switch (loadRequest.status) {
                case WebEngineView.LoadFailedStatus:
                    error("webview loading failed", loadRequest.url)
                    break
                case WebEngineView.LoadStoppedStatus:
                    error("webview loading stopped", loadRequest.url)
                    break
                case WebEngineView.LoadSucceededStatus:
                    logging("webview loading suceeded", loadRequest.url)
                    break
                }
                logging("webview injecting docview.js on", loadRequest.url)
                var requestURL = loadRequest.url
                runJavaScript(FileManager.readQrcFileS("js/docview.js"), function() {
                    logging("webview calling Docview.crawler() on", requestURL)
                    runJavaScript("Docview.crawler()", function(result) {
                        logging("webview Docview.crawler() returns from", result.referer)
                        if (! SearchDB.hasWebpage(result.referer)) {
                            SearchDB.addWebpage(result.referer)
                        }
                        SearchDB.addSymbols(result.referer, result.symbols)
                        SearchDB.updateWebpage(result.referer, "crawling", false)
                        SearchDB.updateWebpage(result.referer, "title", result.title)
                        // loading done
                        console.log("calling crawler", browserWebViews.crawler, crawler)
                        crawler.queueLinks(result.referer, result.links)
                    })
                })
            }
        }
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
        onNewViewRequested: {
            userRequestsNewView(request)
        }
        onNavigationRequested: {
            logging("docview navigation requested", request.url)
            webViewNavRequested(index)
        }
        onLoadingChanged: {
            logging("docview loading changed", loading)
            if (loadRequest.status == WebEngineView.LoadStartedStatus) {
                docviewLoaded = false
                logging("docview loading started", loadRequest.url)
            } else {
                switch (loadRequest.status) {
                case WebEngineView.LoadFailedStatus:
                    error("docview loading failed", loadRequest.url)
                    break
                case WebEngineView.LoadStoppedStatus:
                    error("docview loading stopped", loadRequest.url)
                    break
                case WebEngineView.LoadSucceededStatus:
                    logging("docview loading suceeded", loadRequest.url)
                    break
                }
                logging("docview injecting docview.js on", loadRequest.url)
                var requestURL = loadRequest.url
                runJavaScript(FileManager.readQrcFileS("js/docview.js"), function() {
                    logging("docview calling Docview.docviewOn() on", requestURL)
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
}
