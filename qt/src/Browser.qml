import Backend 1.0
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtWebEngine 1.5
import QtQuick.Layouts 1.3
import "controls" as C

C.SplitView {
    id: browser

    state: Qt.platform.os

    property alias currentWebUI: browserWebViews.currentWebUI
    property int buttonSize: 25
    property alias searchMode: tabsPanel.searchMode

    handleDelegate: Item {
    }

    TabsPanel {
        id: tabsPanel
        readonly property int defaultW: 300
        width: defaultW
        property int prevW: 0
        onWidthChanged: {
            if (width < 50 && prevW > width) {
                visible = false
            }
            prevW = width
        }
        buttonSize: buttonSize
    }

    Item {
        id: mainPanel
        RowLayout {
            id: toolbar
            height: buttonSize
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.rightMargin: 5
            anchors.leftMargin: 5
            anchors.topMargin: 3
            readonly property int buttonWidth: buttonSize
            C.Button {
                id: back_Button
                Layout.minimumWidth: toolbar.buttonWidth
                Layout.preferredHeight: parent.height
                iconSource: "icon/left.svg"
                enabled: currentWebUI && currentWebUI.canGoBack
                onClicked: currentWebUI.goBack()
            }

            C.Button {
                id: forward_Button
                width: height
                Layout.minimumWidth: toolbar.buttonWidth
                Layout.preferredHeight: parent.height
                iconSource: "icon/right.svg"
                enabled: currentWebUI && currentWebUI.canGoForward
                onClicked: currentWebUI.goForward()
            }

            C.Button {
                id: refresh_Button
                Layout.minimumWidth: toolbar.buttonWidth
                Layout.preferredHeight: parent.height
                iconSource: "icon/refresh.svg"
                enabled: currentWebUI
                onClicked: currentWebUI.reload()
            }

            BrowserAddressBar {
                id: addressBar
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height
            }

            C.Button {
                id: docview_Button
                checkable: true
                Layout.minimumWidth: toolbar.buttonWidth
                Layout.preferredHeight: parent.height
                iconSource: "icon/list.svg"
                enabled: currentWebUI && currentWebUI.docviewLoaded
                checked: currentWebUI && currentWebUI.inDocview
                onCheckedChanged: {
                    if (docview_Button.checked) {
                        currentWebUI.docviewOn()
                    } else {
                        currentWebUI.docviewOff()
                    }
                }
            }

            C.Button {
                id: bookmark_Button
                Layout.minimumWidth: toolbar.buttonWidth
                Layout.preferredHeight: parent.height
                iconSource: bookmark_Button.checked ? "icon/bookmark.svg" : "icon/book.svg"
                checkable: false
                enabled: currentWebUI
                checked: currentWebUI && currentWebUI.bookmarked
                onClicked: currentWebUI && (currentWebUI.bookmarked ? currentWebUI.unbookmark() : currentWebUI.bookmark())
            }
        }

        BrowserWebViews {
            id: browserWebViews
            anchors.top: toolbar.bottom
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.topMargin: 3
            //            onUserRequestsNewView: {
            //                if (request.requestedUrl) {
            //                    var opened = TabsModel.findTab(request.requestedUrl);
            //                    if (opened !== -1) {
            //                        return openTab(opened)
            //                    }
            //                }
            //                var wv = openOrNewTab()
            //                wv.handleNewViewRequest(request)
            //            }
        }


        WelcomePage {
            clip: true
            id: welcomePage
            opacity: 0.5
            visible: BrowserController.welcome_page_visible
            anchors {
                left: mainPanel.left
                top: toolbar.bottom
                right: mainPanel.right
                bottom: mainPanel.bottom
            }
        }


        BrowserSearch {
            id: browserSearch
            width: 300
            height: 30
            anchors.right: parent.right
            anchors.top: toolbar.bottom
            onUserSearchesNextInBrowser: browserSearchNext(text)
            onUserSearchesPreviousInBrowser: browserSearchPrev(text)
            onUserTypesInSearch: {
                browserSearch.updateCount(0)
                browserSearch.updateCurrent(0)
                browserSearch.hideCount()
                if (currentWebUI !== null) {
                    currentWebUI.clearFindText()
                }
            }
        }

        //        Layout.minimumWidth: 300
        Layout.fillWidth: true
        Layout.fillHeight: true
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
                leftPadding: 5
                padding: 6
            }

            PropertyChanges {
                target: forward_Button
                rightPadding: 5
                padding: 6
            }

            PropertyChanges {
                target: refresh_Button
                bottomPadding: 2
                topPadding: 3
                padding: 3
            }
        }
    ]

    Shortcut {
        sequence: "Ctrl+R"
        autoRepeat: false
        onActivated: if (currentWebUI) { currentWebUI.reload() }
    }

    Shortcut {
        id: ctrl_w
        property bool guard: true
        autoRepeat: true
        sequence: "Ctrl+W"
        onActivated: {
            browser.forceActiveFocus()
            BrowserController.closeTab(BrowserController.current_tab_state,
                                       BrowserController.current_open_tab_index)
        }
    }

    Shortcut {
        sequence: "Ctrl+F"
        onActivated: BrowserController.setCurrentPageSearchState(BrowserController.CurrentPageSearchStateBeforeSearch)
    }
    Shortcut {
        sequence: "Ctrl+N"
        onActivated: BrowserController.newTab(BrowserController.TabStateOpen,
                                              BrowserController.home_url,
                                              BrowserController.WhenCreatedSwitchToNew,
                                              BrowserController.WhenExistsOpenNew)
    }
    Shortcut {
        sequence: "Esc"
        onActivated: {
            if (BrowserController.current_page_search_visible) {
                return browserSearch.clearSearch()
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
            SearchDB.execScriptAsync("db/dropAll.sqlite3")
            SearchDB.execScriptAsync("db/setup.sqlite3")
            var r = FileManager.readQrcFileS('defaults/dbgen.txt').split('\n')
            for (var i = 0; i < r.length; i++) {
                if (! r[i]) { continue; }
                BrowserController.newTab(BrowserController.TabStateOpen,
                                         r[i],
                                         BrowserController.WhenCreatedSwitchToNew,
                                         BrowserController.WhenExistsViewExisting)
            }
        }
    }
}
