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
    readonly property string url: noHash(href)

    id: webUI

    function setBookmarked(hostname) {
        info("setBookmarked", hostname)
        // when the url's domain is in the auto-bookmark.txt list
        var arr = FileManager.readDataFileS("auto-bookmark.txt").split("\n")
        webUI.bookmarked = (arr.indexOf(hostname) > -1)
    }

    function bookmark() {
        info("bookmark")
        var arr = FileManager.readDataFileS("auto-bookmark.txt").split("\n")
        webview.runJavaScript("location.hostname", function(hostname) {
            var i = arr.indexOf(hostname)
            if (i > -1) {
                info("bookmark called on already bookmarked hostname", hostname)
            } else {
                arr.push(hostname)
                FileManager.writeDataFileS("auto-bookmark.txt", arr.join('\n'))
            }
            FileManager.writeDataFileS("auto-bookmark.txt", arr.join('\n'))
            webUI.bookmarked = true
        })
    }

    function unbookmark() {
        info("unbookmark")
        var arr = FileManager.readDataFileS("auto-bookmark.txt").split("\n")
        webview.runJavaScript("location.hostname", function(hostname) {
            var i = arr.indexOf(hostname)
            if (i === -1) {
                info("unbookmark called on non-bookmarked hostname", hostname)
            } else {
                arr.splice(i,1)
                FileManager.writeDataFileS("auto-bookmark.txt", arr.join('\n'))
            }
            webUI.bookmarked = false
        })
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
        info("Goto", u)
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
        goTo(model.uri)
    }

    WebEngineView {
        id: webview
        anchors.fill: parent

        onNewViewRequested: {
            info("webview onNewViewRequested", request, JSON.stringify(request));
            userRequestsNewView(request)
        }

        settings {
            playbackRequiresUserGesture: true
            focusOnNavigationEnabled: false
        }

        onTitleChanged: {
            info('webview title changed', title)
            if (title) {
                model.title = title
//                model.updateTab(index, "title", title)
                if (SearchDB.hasWebpage(noHash(url))) {
                    SearchDB.updateWebpageAsync(noHash(url), "title", title)
                }
            }
        }

        onUrlChanged: {
            info('webview url changed', url)
            if (url) {
//                model.updateTab(index, "url", webUI.href)
                model.url = webUI.href
            }
        }

        onLoadProgressChanged: {
            info('webview load progress', loadProgress)
        }

        onNavigationRequested: {
            info("webview navigation requested", request.url)
//            webViewNavRequested(index)
        }

        WebEnginePullReady {
            id: webviewPullReady_Timer
            debugName: "webview"
        }

        onLoadingChanged: {
            info("webview loading changed", loading)
            webviewPullReady_Timer.stop()
            if (loadRequest.status == WebEngineView.LoadStartedStatus) {
                docviewLoaded = false
                info("webview loading started", loadRequest.url)
            } else {
                switch (loadRequest.status) {
                case WebEngineView.LoadFailedStatus:
                    error("webview loading failed", loadRequest.url)
                    break
                case WebEngineView.LoadStoppedStatus:
                    error("webview loading stopped", loadRequest.url)
                    break
                case WebEngineView.LoadSucceededStatus:
                    info("webview loading suceeded", loadRequest.url)
                    var requestURL = loadRequest.url
                    webviewPullReady_Timer.onReady = function() {
                        runJavaScript("location.hostname", function(hostname) {
                            info("webview checking if hostname is bookmarked", hostname, requestURL, webUI)
                            webUI.setBookmarked(hostname)
                            if (webUI.bookmarked) {
                                info("hostname is bookmarked", hostname)
                                if (webUI.previewMode) {
                                    return
                                }
                                console.info("webview injecting docview.js on", requestURL)
                                runJavaScript(FileManager.readQrcFileS("js/docview"), function() {
                                    console.info("webview calling Docview.crawler() on", requestURL)
                                    runJavaScript("Docview.crawler()", function(result) {
                                        crawler.queueLinks(result.links)
                                        // crawler is a stack
                                        crawler.queueLinks([requestURL])
                                    })
                                })
                            } else {
                                info("hostname is not bookmarked", hostname)
                            }
                        })
                    }
                    webviewPullReady_Timer.restart()
                    break
                }
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
            info("docview navigation requested", request.url)
//            webViewNavRequested(index)
        }
        WebEnginePullReady {
            id: docviewPullReady_Timer
            debugName: "docview"
        }
        onLoadingChanged: {
            info("docview loading changed", loading)
            docviewPullReady_Timer.stop()
            if (loadRequest.status == WebEngineView.LoadStartedStatus) {
                docviewLoaded = false
                info("docview loading started", loadRequest.url)
            } else {
                switch (loadRequest.status) {
                case WebEngineView.LoadFailedStatus:
                    error("docview loading failed", loadRequest.url)
                    break
                case WebEngineView.LoadStoppedStatus:
                    error("docview loading stopped", loadRequest.url)
                    break
                case WebEngineView.LoadSucceededStatus:
                    info("docview loading suceeded", loadRequest.url)
                    var requestURL = loadRequest.url
                    docviewPullReady_Timer.onReady = function() {
                        info("docview injecting docview.js on", requestURL)
                        docview.runJavaScript(FileManager.readQrcFileS("js/docview"), function() {
                            info("docview calling Docview.docviewOn() on", requestURL)
                            docview.runJavaScript("Docview.docviewOn()", function() {
                                if (inDocview) {
                                    docviewOn()
                                }
                                docviewLoaded = true
                            })
                        })
                    }
                    docviewPullReady_Timer.restart()
                    break
                }
            }
        }
        settings {
            focusOnNavigationEnabled: false
            javascriptCanOpenWindows: false
            playbackRequiresUserGesture: true
        }
    }
}
