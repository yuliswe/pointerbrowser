import Backend 1.0
import QtQuick 2.7
import QtWebView 1.1
import QtQuick.Controls 2.2

BrowserForm {
    id: browser
    function currentWebView() {
        return browserWebViews.currentWebView()
    }

    function currentIndex() {
        return browserWebViews.currentIndex()
    }

    function webViewAt(i) {
        return browserWebViews.webViewAt(i)
    }

    state: Qt.platform.os

    function showWelcomePage() {
        browserWebViews.setCurrentIndex(-1)
        browserForwardButton.enabled = false
        browserRefreshButton.enabled = false
        browserBackButton.enabled = false
        browserDocviewButton.enabled = false
        browserBookmarkButton.enabled = false
        browserAddressBar.update("Welcome", "")
        welcomePage.visible = true
    }

    function hideWelcomePage() {
        //        browserForwardButton.enabled = true
        browserRefreshButton.enabled = true
        //        browserBackButton.enabled = true
        //        browserDocviewButton.enabled = true
        browserBookmarkButton.enabled = true
        welcomePage.visible = false
    }

    function refreshCurrentWebview() {
        console.log("Browser.qml reloadWebViewAt")
        if (currentIndex() > -1) {
            EventFilter.ctrlKeyDown = false
            //            var bookmarked = SearchDB.isBookmarked(currentWebView().url())
            browserWebViews.reloadCurrentWebView()
        }
    }

    function showBrowserSearch() {
        browserSearch.visible = true
        browserSearch.textfield.focus = true
        browserSearch.textfield.selectAll()
        if (browserSearch.textfield.text) {
            var cur = browserSearch.current()
            highlightWordInCurrentWebview(browserSearch.textfield.text, function() {
                scrollToNthHighlightInCurrentWebview(cur)
            })
        }
    }

    function scrollToNthHighlightInCurrentWebview(n) {
        currentWebView().scrollToNthHighlight(n, function() {
            browserSearch.updateCurrent(n)
        })
    }

    function highlightWordInCurrentWebview(word, callback) {
        currentWebView().highlightWord(word, callback)
    }

    function clearBrowserSearchHightlights() {
        currentWebView().clearHighlight()
    }

    function hideBrowserSearch() {
        browserSearch.visible = false
        clearBrowserSearchHightlights()
    }

    function openSavedTab(index) {
        console.log("openSavedTab", index)
        newTab(SearchDB.searchResult.at(index).url, true)
    }


    Component.onCompleted: {
        if (TabsModel.count > 0) {
            openTab(0)
        } else {
            showWelcomePage()
        }
    }

    function newTab(url, switchToView) {
        console.log("newTab:", url, switchToView)
        url = url || "https://www.google.ca/"
        TabsModel.insertTab(0, url, "", "")
        if (switchToView) {
            openTab(0)
        } else {
            openTab(currentIndex() + 1)
        }
        hideWelcomePage()
        return browserWebViews.webViewAt(0)
    }

    //    tabsPanel.rectangle.color: {
    ////        if (splitView.resizing || browserWindow.resizing) {
    ////            return Palette.normal.window_base_background
    ////        } else {
    //            return "transparent"
    ////        }
    //    }

    //    Timer {
    //        id: bugfixTimeout
    //        repeat: false
    //        interval: 1000
    //        onTriggered: tabsPanel.rectangle.color = Qt.binding(function() {
    //            if (splitView.resizing || browserWindow.resizing) {
    //                return Palette.normal.window_base_background
    //            } else {
    //                return "transparent"
    //            }
    //        })
    //    }

    function openTab(index) {
        hideWelcomePage()
        console.log("openTab", "index=", index, "TabsModel.count=", TabsModel.count)
        browserWebViews.setCurrentIndex(index)
        tabsPanel.setCurrentIndex(index)
        var wp = currentWebView()
        browserAddressBar.update(currentWebView().url(), currentWebView().title)
        browserAddressBar.updateProgress(currentWebView().loadProgress)
        prevEnabled = wp && wp.canGoBack
        nextEnabled = wp && wp.canGoForward
        browserDocviewButton.enabled = wp && wp.docviewLoaded
        browserDocviewButton.checked = wp && wp.inDocview
        browserBookmarkButton.checked = SearchDB.bookmarked(wp.url())
    }

    function closeTab(index) {
        console.log("closeTab", "index=", index, "TabsModel.count=", TabsModel.count)
        if (index < 0) { return }
        //        SearchDB.removeWebpage(webViewAt(index).url())
        // todo: remove from backend
        if (currentIndex() === index) {
            // when removing current tab
            // if there's one after, open that
            if (index + 1 < TabsModel.count) {
                TabsModel.removeTab(index)
                openTab(index)
            }
            // if there's one before, open that
            else if (index >= 1) {
                TabsModel.removeTab(index)
                openTab(index - 1)
            }
            // if this is the only one
            else {
                TabsModel.removeTab(index)
                showWelcomePage()
                //                newTab("",true)
            }
        } else if (currentIndex() > index) {
            TabsModel.removeTab(index)
            openTab(currentIndex() - 1)
        } else {
            TabsModel.removeTab(index)
        }
    }

    tabsPanel.buttonSize: buttonSize

    buttonSize: {
        if (Qt.platform.os == "ios") { return 40 }
        return 25
    }

    Connections {
        target: tabsPanel
        onUserOpensNewTab: newTab("", true)
        onUserOpensTab: openTab(index)
        onUserClosesTab: closeTab(index)
        onUserOpensSavedTab: openSavedTab(index)
    }


    Connections {
        target: browserWebViews
        onUserOpensLinkInWebView: {
            browserAddressBar.update(url, "")
            browserAddressBar.updateProgress(currentWebView().loadProgress)
            currentWebView().forceActiveFocus()
            //            prevEnabled = true
            //            nextEnabled = false
        }
        onUserOpensLinkInNewTab: {
            newTab(url)
        }
        onUserRequestsNewView: {
            var wv = newTab()
            wv.handleNewViewRequest(request)
        }
        onWebViewLoadingSucceeded: {
            if (index === currentIndex()) {
                var wp = currentWebView()
                browserAddressBar.update(wp.url(), wp.title)
                browserDocviewButton.enabled = true
            }
        }
        onWebViewLoadingStarted: {
            if (index === currentIndex()) {
                var cw = currentWebView()
                prevEnabled = cw && cw.canGoBack
                nextEnabled = cw && cw.canGoForward
                browserBookmarkButton.checked = SearchDB.bookmarked(cw.url())
                browserBookmarkButton.enabled = true
                browserDocviewButton.enabled = false
            }
        }
        onWebViewLoadingStopped: {
            if (index === currentIndex()) {
                var cw = currentWebView()
                prevEnabled = cw && cw.canGoBack
                nextEnabled = cw && cw.canGoForward
                browserBookmarkButton.checked = SearchDB.bookmarked(cw.url())
            }
        }
        onWebViewLoadingProgressChanged: {
            if (index === currentIndex()) {
                browserAddressBar.updateProgress(progress)
            }
        }
    }

    Connections {
        target: browserSearch
        onUserSearchesWordInBrowser: {
            highlightWordInCurrentWebview(word, function(count) {
                browserSearch.updateCount(count)
                if (count > 0) {
                    browserSearch.updateCurrent(0)
                }
            })
        }
        onUserSearchesNextInBrowser: {
            var cur = browserSearch.current()
            var cnt = browserSearch.count()
            console.log(cur+1, cnt)
            if (cur+1 < cnt) {
                scrollToNthHighlightInCurrentWebview(cur+1)
            }
        }
        onUserSearchesPreviousInBrowser: {
            var cur = browserSearch.current()
            if (cur-1 >= 0) {
                scrollToNthHighlightInCurrentWebview(cur-1)
            }
        }
        onUserClosesSearch: hideBrowserSearch()
        onUserRetypesInSearch: clearBrowserSearchHightlights()
    }

    Connections {
        target: browserAddressBar
        onUserEntersUrl: {
            if (EventFilter.ctrlKeyDown || currentIndex() === -1) {
                EventFilter.ctrlKeyDown = false
                newTab(url, true)
            } else {
                currentWebView().goTo(url)
            }
        }
    }

    Connections {
        target: browserBackButton
        onClicked: {
            currentWebView().goBack()
        }
    }

    Connections {
        target: browserForwardButton
        onClicked: {
            currentWebView().goForward()
        }
    }

    Connections {
        target: browserRefreshButton
        onClicked: refreshCurrentWebview()
    }

    Connections {
        target: browserDocviewButton
        onCheckedChanged: {
            if (browserDocviewButton.checked) {
                currentWebView().docviewOn()
            } else {
                currentWebView().docviewOff()
            }

        }
    }

    Connections {
        target: browserBookmarkButton
        onCheckedChanged: {
            console.log("onCheckedChanged!!", browserBookmarkButton.checked)
        }

        onClicked: {
            if (browserBookmarkButton.checked) {
                SearchDB.setBookmarked(currentWebView().url(), true)
            } else {
                SearchDB.setBookmarked(currentWebView().url(), false)
            }
        }
    }

    Shortcut {
        sequence: "Ctrl+R"
        autoRepeat: false
        onActivated: refreshCurrentWebview()
    }

    //    Timer {
    //        id: ctrl_w_timeout
    //        interval: 100
    //        triggeredOnStart: false
    //        onTriggered: {
    //            ctrl_w.guard = true
    //        }
    //        repeat: false
    //    }

    Shortcut {
        id: ctrl_w
        property bool guard: true
        autoRepeat: true
        sequence: "Ctrl+W"
        onActivated: closeTab(currentIndex()) /*{
            if (guard) {
                guard = false
                EventFilter.ctrlKeyDown = false
                console.log("Ctrl+W", ctrl_w)
                closeTab(currentIndex())
                ctrl_w_timeout.start()
            }
        }*/
    }

    Shortcut {
        sequence: "Ctrl+F"
        onActivated: showBrowserSearch()
    }
    Shortcut {
        sequence: "Ctrl+N"
        onActivated: newTab("", true)
    }
    Shortcut {
        sequence: "Esc"
        onActivated: hideBrowserSearch()
    }
    Shortcut {
        sequence: "Ctrl+K"
        onActivated: FileManager.defaultOpenUrl(FileManager.dataPath() + "/auto-bookmark.txt")
    }
    Shortcut {
        sequence: "Ctrl+Shift+P"
        onActivated: {
            SearchDB.execScript("db/deleteAll.sqlite3")
            var r = FileManager.readQrcFileS('defaults/dbgen.txt').split('\n')
            for (var i = 0; i < r.length; i++) {
                if (! r[i]) { continue; }
                newTab(r[i], true)
            }
        }
    }
}
