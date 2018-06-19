import QtQuick 2.7
import QtWebEngine 1.7
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
            console.log("crawler timed out", crawler.crawling)
            crawler.url = ""
            crawler.stop()
            crawler.crawNext(true)
        }
        interval: 5000
        repeat: true

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

    function crawNext(forced) {
        console.log("crawNext called on", Object.keys(crawler.queue).length, "links")
        for (var first in crawler.queue) {
            if (forced || ! crawler.loading) {
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

    Timer {
        id: pullReady
        interval: 500
        repeat: true
        onTriggered: {
            console.log("cralwer pulling document ready..")
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
            console.log("crawler loading", loadRequest.url)
            break
        default:
            switch (loadRequest.status) {
            case WebEngineView.LoadFailedStatus:
                console.warn("crawler loading failed", loadRequest.url)
                break
            case WebEngineView.LoadStoppedStatus:
                console.warn("crawler loading stopped", loadRequest.url)
                break
            case WebEngineView.LoadSucceededStatus:
                console.log("crawler loading succeeded", loadRequest.url)
                console.log("crawler injecting docview.js on", loadRequest.url)
                pullReady.onReady = function() {
                    runJavaScript(FileManager.readQrcFileS("js/docview.js"), function() {
                        console.log("crawler calling Docview.crawler() on", requestURL)
                        runJavaScript("Docview.crawler()", function(result) {
                            console.log("crawler Docview.crawler() returns from", requestURL)
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
            var requestURL = loadRequest.url
        }
    }
}
