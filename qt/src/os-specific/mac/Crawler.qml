import QtQuick 2.7
import QtWebEngine 1.7
import Backend 1.0

WebEngineView {
    id: crawler
    height: browserWebViews.height
    width: browserWebViews.width
    visible: false
    enabled: false
    focus: false
    activeFocusOnPress: false
    //        JavaScriptConsoleMessageLevel:
    settings {
        // efficiency
        errorPageEnabled: false
        autoLoadImages: false
        autoLoadIconsForPage: false
        touchIconsEnabled: false
        // security
        playbackRequiresUserGesture: true
        spatialNavigationEnabled: false
        focusOnNavigationEnabled: false
        linksIncludedInFocusChain: false
        localStorageEnabled: false
        //        javascriptEnabled: false
        webGLEnabled: false
        pluginsEnabled: false
        screenCaptureEnabled: false
        allowRunningInsecureContent: false
        unknownUrlSchemePolicy: WebEngineSettings.DisallowUnknownUrlSchemes
        allowGeolocationOnInsecureOrigins: false
        //        fullscreenSupportEnabled: false
        localContentCanAccessFileUrls: false
        localContentCanAccessRemoteUrls: false
        webRTCPublicInterfacesOnly: true
        // js
        javascriptCanOpenWindows: false
        allowWindowActivationFromJavaScript: false
    }

    Timer {
        id: timeout
        triggeredOnStart: false
        onTriggered: {
            console.info("Crawler: timed out", crawler.crawling)
            crawler.url = ""
            crawler.stop()
            crawler.crawNext(true)
        }
        interval: 20000
        repeat: true

    }

    property var queue: ({})
    property string crawling: ""
    function queueLinks(links) {
        console.info("crawler.queueLinks", links)
        for (var i = 0; i < links.length; i++) {
            var l = links[i]
            crawler.queue[l] = Date.now()
        }
        crawler.crawNext()
    }

    function crawNext(forced) {
        console.info("crawNext called on", Object.keys(crawler.queue).length, "links")
        var latest = {
            url: "",
            time: -1
        }
        for (var url in crawler.queue) {
            if (crawler.queue[url] > latest.time) {
                latest.url = url
                latest.time = crawler.queue[url]
            }
        }
        if (latest.time === -1) {
            crawling = ""
            timeout.stop()
            console.info("Crawler: queue is empty, timer stopped.")
            return
        }
        console.info("Crawler: next", latest.url)
        if (forced || ! crawler.loading) {
            crawler.url = latest.url
            crawler.crawling = latest.url
            timeout.restart()
            console.info("Crawler: timer restarted", latest.url)
            delete crawler.queue[latest.url]
        } else {
            console.info("crawNext aborted because the crawler is still loading")
        }
    }

    Timer {
        id: pullReady
        interval: 500
        repeat: true
        onTriggered: {
            console.info("Crawler: pulling document ready..")
            runJavaScript("document.readyState", function(ready) {
                if (ready !== "complete") { return }
                onReady()
                pullReady.stop()
            })
        }
        property var onReady: null
    }

    onLoadingChanged: {
        pullReady.stop()
        switch (loadRequest.status) {
        case WebEngineView.LoadStartedStatus:
            console.info("Crawler: loading", loadRequest.url)
            break
        default:
            switch (loadRequest.status) {
            case WebEngineView.LoadFailedStatus:
                console.warn("Crawler: loading failed", loadRequest.url)
                break
            case WebEngineView.LoadStoppedStatus:
                console.warn("Crawler: loading stopped", loadRequest.url)
                break
            case WebEngineView.LoadSucceededStatus:
                console.info("Crawler: loading succeeded", loadRequest.url)
                console.info("Crawler: injecting docview.js on", loadRequest.url)
                var requestURL = loadRequest.url
                pullReady.onReady = function() {
                    runJavaScript(FileManager.readQrcFileS("js/docview"), function() {
                        console.info("Crawler: calling Docview.crawler() on", requestURL)
                        runJavaScript("Docview.crawler()", function(result) {
                            console.info("Crawler: Docview.crawler() returns from", requestURL)
                            if (! SearchDB.hasWebpage(result.referer)) {
                                SearchDB.addWebpageAsync(result.referer)
                            }
                            SearchDB.addSymbolsAsync(result.referer, result.symbols)
                            SearchDB.updateWebpageAsync(result.referer, "title", result.title)
                            // loading done
                            crawler.crawNext(true)
                        })
                    })
                }
                pullReady.restart()
                break
            }
        }
    }
}
