import Backend 1.0
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtWebEngine 1.5
import QtQuick.Layouts 1.3
import "controls" as C

C.SplitView {
    id: browser

    state: Qt.platform.os

    property alias currentWebView: browserWebViews.currentWebView
    property alias currentWebViewIndex: browserWebViews.currentIndex
    property int buttonSize: 25
    property alias searchMode: tabsPanel.searchMode

    function refreshCurrentWebview() {
        browserWebViews.reloadCurrentWebView()
    }

    function showBrowserSearch() {
        browserSearch.visible = true
        browserSearch.textfield.forceActiveFocus()
        browserSearch.textfield.selectAll()
    }

    function hideBrowserSearch() {
        browserSearch.visible = false
        browserSearch.textfield.focus = false
        if (currentWebView !== null) {
            currentWebView.clearFindText()
        }
    }

    function browserSearchNext(text) {
        if (currentWebView !== null) {
            currentWebView.findNext(text, function(cnt) {
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

    function browserSearchPrev(text) {
        if (currentWebView !== null) {
            currentWebView.findPrev(text, function(cnt) {
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

    function openSavedTab(index, previewMode) {
        console.log("openSavedTab", index)
        var wp = SearchDB.searchResult.at(index)
        if (wp.hash) {
            SearchDB.updateSymbolAsync(wp.hash, 'visited', Date.now())
        }
        openOrNewTab(wp.url + (wp.hash ? "#"+wp.hash : ""), true, previewMode)
        if (previewMode) {
            tabsPanel.setSavedTabsCurrentIndex(index)
        } else {
            //            SearchDB.searchResult.removeTab(index)
            SearchDB.updateWebpageAsync(wp.url, 'visited', Date.now())
            //            tabsPanel.setSavedTabsCurrentIndex(-1)
        }
    }

    function newTabHome() {
        openOrNewTab("https://www.google.ca/", true)
    }

    function openOrNewTab(url, switchToView, previewMode) {
        console.log("newTab:", url, switchToView)
        var opened = TabsModel.findTab(url)
        if (opened !== -1) {
            if (! previewMode) {
                TabsModel.updateTab(opened, "open", true)
                TabsModel.updateTab(opened, "preview_mode", false)
                browserWebViews.setPreviewMode(opened, false)
                browserWebViews.reloadWebViewAt(opened)
            }
            if (! TabsModel.at(opened).open && previewMode) {
                TabsModel.updateTab(opened, "preview_mode", true)
            }
            return openTab(opened)
        }
        var newtab = {
            url: url,
            preview_mode: previewMode,
            open: ! previewMode
        }
        TabsModel.insertTab(0, newtab)

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
        console.log("openTab", "index=", index, "TabsModel.count=",
                    TabsModel.count)
        browserWebViews.setCurrentIndex(index)
        tabsPanel.setOpenTabsCurrentIndex(index)
        tabsPanel.setSavedTabsCurrentIndex(-1)
        hideBrowserSearch()
        browserSearch.hideCount()
    }

    //    function closeAllPreviewTabs() {
    //        if (curr)
    //    }
    //    function nextOpenTab(index) {
    //        for
    //        if (TabsModel.at(currentWebViewIndex).preview_mode) {
    //            //            closeAllPreviewTabs()
    //            //                for (var i = 0; i < TabsModel.count; i++) {
    //            //                    if (! TabsModel.at(i).preview_mode) {
    //            //                        return openTab(i)
    //            //                    }
    //            //                }
    //            TabsModel.clear()
    //        } else {

    //        }
    //    }

    function closeAllPreviewTabs() {
        for (var i = TabsModel.count - 1; i >= 0; i--) {
            if (TabsModel.at(i).preview_mode) {
                TabsModel.removeTab(i)
            }
        }
        tabsPanel.setSavedTabsCurrentIndex(-1)
    }

    function closeTab(index) {
        console.log("closeTab", "index=", index, "TabsModel.count=",
                    TabsModel.count)
        if (index < 0) {
            return
        }
        if (TabsModel.at(index).preview_mode) {
            closeAllPreviewTabs()
            if (TabsModel.count > 0) {
                openTab(0)
            } else {
                browserWebViews.setCurrentIndex(-1)
            }
            return
        }
        closeAllPreviewTabs()
        if (currentWebViewIndex === index) {
            // when removing current tab
            // if there's one after, open that
            if (index + 1 < TabsModel.count) {
                TabsModel.removeTab(index)
                browserWebViews.setCurrentIndex(-1) // force update binding
                openTab(index)
            } // if there's one before, open that
            else if (index >= 1) {
                TabsModel.removeTab(index)
                openTab(index - 1)
            } // if this is the only one
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

    handleDelegate: Item {
    }

    TabsPanel {
        id: tabsPanel
        Layout.minimumWidth: 150
        Layout.preferredWidth: 300
        width: 300
        buttonSize: buttonSize
        onUserOpensNewTab: newTabHome()
        onUserOpensTab: openTab(index)
        onUserClosesTab: closeTab(index)
        onUserOpensSavedTab: openSavedTab(index)
        onUserPreviewsSavedTab: openSavedTab(index, true)
    }

    Rectangle {
        id: mainPanel
        color: "#00000000"
        RowLayout {
            id: toolbar
            height: buttonSize
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.rightMargin: 5
            anchors.leftMargin: 5
            anchors.topMargin: 3
            readonly property int buttonWidth: buttonSize * (Qt.platform.os == "ios" ? 1 : 1)
            //            spacing: (Qt.platform.os == "ios") ? 0 : 2
            C.Button {
                id: back_Button
                Layout.minimumWidth: toolbar.buttonWidth
                Layout.preferredHeight: parent.height
                iconSource: "icon/left.svg"
                enabled: currentWebView && currentWebView.canGoBack
                onClicked: {
                    currentWebView.goBack()
                }
            }

            C.Button {
                id: forward_Button
                width: height
                Layout.minimumWidth: toolbar.buttonWidth
                Layout.preferredHeight: parent.height
                iconSource: "icon/right.svg"
                enabled: currentWebView && currentWebView.canGoForward
                onClicked: {
                    currentWebView.goForward()
                }
            }

            C.Button {
                id: refresh_Button
                Layout.minimumWidth: toolbar.buttonWidth
                Layout.preferredHeight: parent.height
                iconSource: "icon/refresh.svg"
                enabled: currentWebView
                onClicked: refreshCurrentWebview()
            }

            BrowserAddressBar {
                id: addressBar
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height - (Qt.platform.os == "ios" ? 5 : 0)
                url: currentWebView ? currentWebView.href : ""
                title: currentWebView ? currentWebView.title : ""
                progress: currentWebView ? currentWebView.loadProgress : 0
                onUserEntersUrl: {
                    if (currentWebViewIndex === -1) {
                        openOrNewTab(url, true)
                    } else if (EventFilter.ctrlKeyDown) {
                        EventFilter.ctrlKeyDown = false
                        openOrNewTab(url, true)
                    } else if (TabsModel.at(currentWebViewIndex).preview_mode) {
                        openOrNewTab(url, true)
                    } else {
                        currentWebView.goTo(url)
                    }
                }
            }

            C.Button {
                id: docview_Button
                checkable: true
                Layout.minimumWidth: toolbar.buttonWidth
                Layout.preferredHeight: parent.height
                iconSource: "icon/list.svg"
                enabled: currentWebView && currentWebView.docviewLoaded
                active: currentWebView && currentWebView.inDocview
                onCheckedChanged: {
                    if (docview_Button.checked) {
                        currentWebView.docviewOn()
                    } else {
                        currentWebView.docviewOff()
                    }
                }
            }

            C.Button {
                id: bookmark_Button
                Layout.minimumWidth: toolbar.buttonWidth
                Layout.preferredHeight: parent.height
                iconSource: bookmark_Button.checked ? "icon/bookmark.svg" : "icon/book.svg"
                checkable: false
                enabled: currentWebView
                active: currentWebView && currentWebView.bookmarked
                onClicked: currentWebView && (currentWebView.bookmarked ? currentWebView.unbookmark() : currentWebView.bookmark())
            }
        }

        BrowserWebViews {
            id: browserWebViews
            anchors.top: toolbar.bottom
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.topMargin: 3
            onUserRequestsNewView: {
                if (request.requestedUrl) {
                    var opened = TabsModel.findTab(request.requestedUrl);
                    if (opened !== -1) {
                        return openTab(opened)
                    }
                }
                var wv = openOrNewTab()
                wv.handleNewViewRequest(request)
            }

            WelcomePageForm {
                id: welcomePage
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                opacity: 0.5
                visible: ! currentWebView
            }

            BrowserSearch {
                id: browserSearch
                width: 300
                height: 30
                visible: false
                anchors.right: parent.right
                anchors.top: parent.top
                onUserSearchesNextInBrowser: browserSearchNext(text)
                onUserSearchesPreviousInBrowser: browserSearchPrev(text)
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
        }

        //        Layout.minimumWidth: 300
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

    onSearchModeChanged: {
        closeAllPreviewTabs()
    }

    states: [
        State {
            name: "osx"

            PropertyChanges {
                target: docview_Button
                padding: 4
            }

            PropertyChanges {
                target: bookmark_Button
                padding: 4
            }

            PropertyChanges {
                target: back_Button
                padding: 6
            }

            PropertyChanges {
                target: forward_Button
                padding: 6
            }

            PropertyChanges {
                target: refresh_Button
                padding: 3
            }
        },
        State {
            name: "ios"
        },
        State {
            name: "windows"

            PropertyChanges {
                target: docview_Button
                padding: 3
            }

            PropertyChanges {
                target: bookmark_Button
                padding: 3
            }

            PropertyChanges {
                target: back_Button
                padding: 6
            }

            PropertyChanges {
                target: forward_Button
                padding: 6
            }

            PropertyChanges {
                target: refresh_Button
                padding: 3
            }
        }
    ]

    Component.onCompleted: {
        TabsModel.loadTabs()
        if (TabsModel.count > 0) {
            openTab(0)
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
        onActivated: {
            if (browserSearch.visible) {
                return hideBrowserSearch()
            }
            if (searchMode) {
                return tabsPanel.clearSearchField()
            }
        }
    }
    Shortcut {
        sequence: "Ctrl+K"
        onActivated: FileManager.defaultOpenUrl(FileManager.dataPath())
    }
    Shortcut {
        sequence: "Ctrl+Shift+P"
        onActivated: {
            TabsModel.clear()
            SearchDB.execScriptAsync("db/dropAll.sqlite3")
            SearchDB.execScriptAsync("db/setup.sqlite3")
            var r = FileManager.readQrcFileS('defaults/dbgen.txt').split('\n')
            for (var i = 0; i < r.length; i++) {
                if (! r[i]) { continue; }
                openOrNewTab(r[i], true)
            }
        }
    }
}
