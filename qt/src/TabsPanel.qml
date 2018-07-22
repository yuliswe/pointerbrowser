import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import "controls" as C
import QtQuick.Layouts 1.3
import Backend 1.0

Item {
    id: tabsPanel

    //    signal userOpensSavedTab(int index)
    //    signal userPreviewsSavedTab(int index)
    //    signal userClosesTab(int index)
    //    signal userOpensTab(int index)
    //    signal userOpensNewTab()

    property bool searchMode: false
    property int buttonSize: 25

    function filterModelBySymbol(sym) {
        tabsPanel.searchMode = (sym !== "")
        SearchDB.searchAsync(sym)
    }

    function clearSearchField() {
        searchTextField.clear()
    }

    state: Qt.platform.os
    RowLayout {
        id: topControls
        height: buttonSize
        anchors.top: parent.top
        anchors.topMargin: 3
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5

        C.TextField {
            id: searchTextField
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height - (Qt.platform.os == "ios" ? 5 : 0)
            placeholderText: "Search"
            selectByMouse: true
            useActiveBackgroundColorUntilEmpty: true
            clearOnEsc: false
            onDelayedTextChanged: {
                if (searchTextField.text.length > 1) {
                    filterModelBySymbol(searchTextField.text)
                } else if (searchTextField.text.length === 0) {
                    filterModelBySymbol("")
                }
            }
            onAccepted: {
                filterModelBySymbol(searchTextField.text)
            }
        }

        C.Button {
            id: newTabButton
            font.bold: true
            padding: 1
            iconSource: "icon/plus-mid.svg"
            onClicked: BrowserController.newTab(BrowserController.TabStateOpen,
                                                BrowserController.home_url,
                                                BrowserController.WhenCreatedViewNew,
                                                BrowserController.WhenExistsOpenNew)
        }
    }

    ScrollView {
        id: scrollView
        clip: true
        anchors.bottomMargin: 5
        anchors.top: topControls.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.topMargin: 3
        Flickable {
            id: flickable
            boundsBehavior: Flickable.StopAtBounds
            contentHeight: tabsList.height + searchList.height + 10
            TabsList {
                id: tabsList
                width: tabsPanel.width
                loading: false
                showCloseButton: true
                expandEnabled: false
                model: BrowserController.open_tabs
                name: "Open Tabs"
                onUserClosesTab: BrowserController.closeTab(BrowserController.TabStateOpen, index)
                onUserClicksTab: BrowserController.viewTab(BrowserController.TabStateOpen, index)
                anchors.top: parent.top
                tabState: BrowserController.TabStateOpen
                currentIndex: {
                    if (BrowserController.current_tab_state === BrowserController.TabStateOpen) {
                        return BrowserController.current_open_tab_index
                    }
                    return -1
                }
            }
            TabsList {
                id: searchList
                name: searchMode ? (SearchDB.searchInProgress ?
                                        "Searching" :
                                        (SearchDB.searchResult.count === 0 ? "nothing" : "Bookmarks - " + SearchDB.searchResult.count)
                                        + (SearchDB.searchResult.count >= 200 ? "+" : "")
                                        + " found") : "Bookmarks"
                width: tabsPanel.width
                loading: SearchDB.searchInProgress && tabsPanel.searchMode
                showCloseButton: false
                expandEnabled: true
                model: SearchDB.searchResult
                tabState: BrowserController.TabStateSearchResult
                onUserDoubleClicksTab: BrowserController.newTab(BrowserController.TabStateOpen,
                                                                SearchDB.searchResult.at(index).uri,
                                                                BrowserController.SwithToView,
                                                                BrowserController.WhenExistsViewExisting)

                onUserClicksTab: {
                    BrowserController.newTab(BrowserController.TabStatePreview,
                                             SearchDB.searchResult.at(index).uri,
                                             BrowserController.SwithToView,
                                             BrowserController.WhenExistsViewExisting)
                    BrowserController.current_tab_search_highlight_index = index;
                }

                currentIndex: {
                    if (BrowserController.current_tab_state === BrowserController.TabStatePreview) {
                        return BrowserController.current_tab_search_highlight_index
                    }
                    return -1
                }

                anchors.top: tabsList.bottom
            }
        }
    }

    Shortcut {
        sequences: ["Ctrl+Shift+F", "Ctrl+D"]
        onActivated: {
            if (! tabsPanel.visible) {
                tabsPanel.visible = true
                tabsPanel.width = tabsPanel.defaultW
            }
            searchTextField.forceActiveFocus()
            searchTextField.selectAll()
        }
    }

    property alias searchFieldActiveFocus: searchTextField.activeFocus
}
