import QtQuick 2.7
import QtWebEngine 1.5
import Backend 1.0

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

    property var queue: ({})
    function queueLinks(referer, links) {
        console.log("crawler.queueLinks", referer, links)
//        var arr = FileManager.readDataFileS("auto-bookmark.txt").split("\n")
        for (var i = 0; i < links.length; i++) {
            var l = links[i]
            crawler.queue[l] = true
        }
        crawler.crawNext()
    }

    function crawNext() {
        console.log("crawNext called on", Object.keys(crawler.queue).length, "links")
        for (var first in crawler.queue) {
            console.log("crawNext", first)
            if (! crawler.loading) {
                url = first
                console.log("crawNext", url)
                delete crawler.queue[first]
            } else {
                console.log("crawNext aborted because the crawler is still loading")
            }
            break
        }
    }

    onLoadingChanged: {
        switch (loadRequest.status) {
        case WebEngineView.LoadStartedStatus:
            console.log("crawler loading", loadRequest.url)
            break
        default:
            switch (loadRequest.status) {
            case WebEngineView.LoadFailedStatus:
                console.info("crawler loading failed", loadRequest.url)
                break
            case WebEngineView.LoadStoppedStatus:
                console.info("crawler loading stopped", loadRequest.url)
                break
            case WebEngineView.LoadSucceededStatus:
                console.log("crawler loading suceeded", loadRequest.url)
                break
            }
            console.log("crawler injecting docview.js on", loadRequest.url)
            var requestURL = loadRequest.url
            runJavaScript(FileManager.readQrcFileS("js/docview.js"), function() {
                console.log("crawler calling Docview.crawler() on", requestURL)
                runJavaScript("Docview.crawler()", function(result) {
                    console.log("crawler Docview.crawler() returns from", requestURL)
                    if (! SearchDB.hasWebpage(result.referer)) {
                        SearchDB.addWebpage(result.referer)
                    }
                    SearchDB.addSymbols(result.referer, result.symbols)
                    SearchDB.updateWebpage(result.referer, "crawling", false)
                    SearchDB.updateWebpage(result.referer, "title", result.title)
                    // loading done
                    crawler.crawNext()
                })
            })
        }
    }
}
