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

    Timer {
        id: timeout
        triggeredOnStart: false
        onTriggered: {
            console.info("crawler timed out", crawling)
            crawler.stop()
        }
        interval: 30000 // 30s
        repeat: false

    }

    property var queue: ({})
    property string crawling: ""
    function queueLinks(links) {
        console.log("crawler.queueLinks", links)
        for (var i = 0; i < links.length; i++) {
            var l = links[i]
            crawler.queue[l] = true
        }
        crawler.crawNext()
    }

    function crawNext() {
        console.log("crawNext called on", Object.keys(crawler.queue).length, "links")
        for (var first in crawler.queue) {
            if (! crawler.loading) {
                url = first
                crawling = first
                timeout.restart()
                console.log("crawNext", url)
                delete crawler.queue[first]
            } else {
                console.log("crawNext aborted because the crawler is still loading")
            }
            return
        }
        crawling = ""
        console.log("crawler queue is empty")
    }

    onLoadingChanged: {
        switch (loadRequest.status) {
        case WebEngineView.LoadStartedStatus:
            console.log("crawler loading", loadRequest.url)
            break
        default:
            switch (loadRequest.status) {
            case WebEngineView.LoadFailedStatus:
                console.warn("crawler loading failed", loadRequest.url)
                crawler.queue[crawler.crawling] = true // retry later
                break
            case WebEngineView.LoadStoppedStatus:
                console.warn("crawler loading stopped", loadRequest.url)
                crawler.queue[crawler.crawling] = true // retry later
                break
            case WebEngineView.LoadSucceededStatus:
                console.log("crawler loading suceeded", loadRequest.url)
                break
            }
            timeout.stop()
            var requestURL = loadRequest.url
            console.log("crawler injecting docview.js on", loadRequest.url)
            runJavaScript(FileManager.readQrcFileS("js/docview.js"), function() {
                console.log("crawler calling Docview.crawler() on", requestURL)
                runJavaScript("Docview.crawler()", function(result) {
                    console.log("crawler Docview.crawler() returns from", requestURL)
                    if (! SearchDB.hasWebpage(result.referer)) {
                        SearchDB.addWebpage(result.referer)
                    }
                    SearchDB.addSymbolsAsync(result.referer, result.symbols)
                    SearchDB.updateWebpage(result.referer, "title", result.title)
                    // loading done
                    crawler.crawNext()
                })
            })
        }
    }
}
