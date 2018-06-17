import Backend 1.0
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtWebEngine 1.5

BrowserForm {
    id: browser

    function webViewAt(i) {
        return browserWebViews.webViewAt(i)
    }

    state: Qt.platform.os


    browserDocviewButton {
        checkable: false
        enabled: currentWebView && currentWebView.docviewLoaded
        active: currentWebView && currentWebView.inDocview
        onClicked: currentWebView && (currentWebView.inDocview ? currentWebView.docviewOff() : currentWebView.docviewOn())
    }

    browserBookmarkButton {
        checkable: false
        enabled: currentWebView
        active: currentWebView && currentWebView.bookmarked
        onClicked: currentWebView && (currentWebView.bookmarked ? currentWebView.unbookmark() : currentWebView.bookmark())
    }

    welcomePage {
        visible: ! currentWebView
    }

    browserRefreshButton {
        enabled: currentWebView
    }

    browserBackButton {
        enabled: currentWebView && currentWebView.canGoBack
    }

    browserForwardButton {
        enabled: currentWebView && currentWebView.canGoForward
    }

    browserAddressBar {
        url: currentWebView ? currentWebView.href : ""
        title: currentWebView ? currentWebView.title : ""
        progress: currentWebView ? currentWebView.loadProgress : 0
    }

    function refreshCurrentWebview() {
        browserWebViews.reloadCurrentWebView()
    }

    function showBrowserSearch() {
        browserSearch.visible = true
        browserSearch.textfield.focus = true
        browserSearch.textfield.selectAll()
    }

    function hideBrowserSearch() {
        browserSearch.visible = false
        if (currentWebView !== null) {
            currentWebView.clearFindText()
        }
    }

    function openSavedTab(index) {
        console.log("openSavedTab", index)
        var wp = SearchDB.searchResult.at(index)
        if (wp.hash) {
            SearchDB.updateSymbolAsync(wp.hash, 'visited', Date.now())
        }
//        if (wp.title || wp.url_matched) {
            SearchDB.updateWebpageAsync(wp.url, 'visited', Date.now())
//        }
        newTab(wp.url + (wp.hash ? "#"+wp.hash : ""), true)
    }


    Component.onCompleted: {
        TabsModel.loadTabs()
        if (TabsModel.count > 0) {
            openTab(0)
        }
    }

    function newTabHome() {
        newTab("https://www.google.ca/", true)
    }

    function newTab(url, switchToView) {
        console.log("newTab:", url, switchToView)
        var opened = TabsModel.findTab(url);
        if (opened !== -1) {
            return openTab(opened)
        }
        TabsModel.insertTab(0, url, "", "")
        if (switchToView) {
            if (currentWebViewIndex === 0) {
                openTab(1) // trigger binding update
            }
            openTab(0)
        } else {
            // in case we are at the welcome page
            if (currentWebViewIndex > -1) {
                openTab(currentWebViewIndex + 1)
            }
        }
        return browserWebViews.webViewAt(0)
    }

    function openTab(index) {
        console.log("openTab", "index=", index, "TabsModel.count=", TabsModel.count)
        browserWebViews.setCurrentIndex(index)
        tabsPanel.setCurrentIndex(index)
    }

    function closeTab(index) {
        console.log("closeTab", "index=", index, "TabsModel.count=", TabsModel.count)
        if (index < 0) { return }
        if (currentWebViewIndex === index) {
            // when removing current tab
            // if there's one after, open that
            if (index + 1 < TabsModel.count) {
                TabsModel.removeTab(index)
                browserWebViews.setCurrentIndex(-1) // force update binding
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
                browserWebViews.setCurrentIndex(-1)
            }
        } else if (currentWebViewIndex > index) {
            TabsModel.removeTab(index)
            openTab(currentWebViewIndex - 1)
        } else {
            TabsModel.removeTab(index)
        }
    }

    tabsPanel.buttonSize: buttonSize

    Connections {
        target: tabsPanel
        onUserOpensNewTab: newTabHome()
        onUserOpensTab: openTab(index)
        onUserClosesTab: closeTab(index)
        onUserOpensSavedTab: openSavedTab(index)
    }


    Connections {
        target: browserWebViews
        onUserRequestsNewView: {
            if (request.requestedUrl) {
                var opened = TabsModel.findTab(request.requestedUrl);
                if (opened !== -1) {
                    return openTab(opened)
                }
            }
            var wv = newTab()
            wv.handleNewViewRequest(request)
        }
    }

    Connections {
        target: browserSearch
        onUserSearchesNextInBrowser: {
            if (currentWebView !== null) {
                currentWebView.findNext(browserSearch.textfield.text, function(cnt) {
                    browserSearch.showCount()
                    var cur = browserSearch.current()
                    browserSearch.updateCount(cnt)
                    if (cnt === 0) {
                        browserSearch.updateCurrent(0)
                    } else if (cur === cnt) {
                        browserSearch.updateCurrent(1)
                    } else {
                        browserSearch.updateCurrent(cur + 1)
                    }
                })
            }
        }
        onUserSearchesPreviousInBrowser: {
            if (currentWebView !== null) {
                currentWebView.findPrev(browserSearch.textfield.text, function(cnt) {
                    browserSearch.showCount()
                    var cur = browserSearch.current()
                    browserSearch.updateCount(cnt)
                    if (cnt === 0) {
                        browserSearch.updateCurrent(0)
                    } else if (cur <= 1) {
                        browserSearch.updateCurrent(cnt)
                    } else {
                        browserSearch.updateCurrent(cur - 1)
                    }
                })
            }
        }
        onUserClosesSearch: hideBrowserSearch()
        onUserTypesInSearch: {
            browserSearch.updateCount(0)
            browserSearch.updateCurrent(0)
            browserSearch.hideCount()
            if (currentWebView !== null) {
                currentWebView.clearFindText()
            }
        }
    }

    Connections {
        target: browserAddressBar
        onUserEntersUrl: {
            if (EventFilter.ctrlKeyDown || currentWebViewIndex === -1) {
                EventFilter.ctrlKeyDown = false
                newTab(url, true)
            } else {
                currentWebView.goTo(url)
            }
        }
    }

    Connections {
        target: browserBackButton
        onClicked: {
            currentWebView.goBack()
        }
    }

    Connections {
        target: browserForwardButton
        onClicked: {
            currentWebView.goForward()
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

    Shortcut {
        sequence: "Ctrl+R"
        autoRepeat: false
        onActivated: refreshCurrentWebview()
    }

    Shortcut {
        id: ctrl_w
        property bool guard: true
        autoRepeat: true
        sequence: "Ctrl+W"
        onActivated: closeTab(currentWebViewIndex)
    }

    Shortcut {
        sequence: "Ctrl+F"
        onActivated: showBrowserSearch()
    }
    Shortcut {
        sequence: "Ctrl+N"
        onActivated: newTabHome()
    }
    Shortcut {
        sequence: "Esc"
        onActivated: hideBrowserSearch()
    }
    Shortcut {
        sequence: "Ctrl+K"
        onActivated: FileManager.defaultOpenUrl(FileManager.dataPath())
    }
    Shortcut {
        sequence: "Ctrl+Shift+P"
        onActivated: {
            TabsModel.clear()
            if (! SearchDB.execScript("db/dropAll.sqlite3")) { return }
            if (! SearchDB.execScript("db/setup.sqlite3")) { return }
            var r = FileManager.readQrcFileS('defaults/dbgen.txt').split('\n')
            for (var i = 0; i < r.length; i++) {
                if (! r[i]) { continue; }
                newTab(r[i], true)
            }
        }
    }
}
