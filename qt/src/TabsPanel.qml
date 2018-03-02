import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import "controls" as C
import QtQuick.Layouts 1.3
import Backend 1.0

Item {
    id: tabsPanel

    signal userOpensSavedTab(int index)
    signal userPreviewsSavedTab(int index)
    signal userClosesTab(int index)
    signal userOpensTab(int index)
    signal userOpensNewTab()

    property bool searchMode: false
    property int buttonSize: 25

    function setCurrentIndex(i) {
        tabsList.setHighlightAt(i)
    }

    function setOpenTabsCurrentIndex(i) {
        tabsList.setHighlightAt(i)
    }

    function setSavedTabsCurrentIndex(i) {
        searchList.setHighlightAt(i)
    }

    function filterModelBySymbol(sym) {
        tabsPanel.searchMode = (sym !== "")
        SearchDB.searchAsync(sym)
    }

    function clearSearchField() {
        searchTextField.clear()
    }

    //    flickable {
    //        rebound: Transition {
    //            NumberAnimation {
    //                properties: "x,y"
    //                duration: {
    //                    switch (Qt.platform.os) {
    //                    case "ios": return 2500; break;
    //                    default: return 500
    //                    }
    //                }
    //                easing.type: Easing.OutQuint
    //            }
    //        }

    //        boundsBehavior: {
    //            if (Qt.platform.os == "ios") {
    //                return Flickable.DragAndOvershootBounds
    //            } else {
    //                return Flickable.StopAtBounds
    //            }
    //        }
    //    }

    Component.onCompleted: {
        searchList.setHighlightAt(-1)
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
            fakeActiveFocusUntilEmpty: true
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
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height
            padding: 1
            Layout.fillHeight: true
            iconSource: "icon/plus-mid.svg"
            onClicked: {
                tabsPanel.userOpensNewTab()
            }
        }
    }

    ScrollView {
        id: scrollView
        clip: true
        anchors.bottomMargin: 5
        anchors.top: topControls.bottom
        anchors.right: parent.right
        anchors.bottom: bottomControls.top
        anchors.left: parent.left
        anchors.topMargin: 3
        Flickable {
            id: flickable
            clip: false
            boundsBehavior: Flickable.StopAtBounds
            contentHeight: tabsList.height + searchList.height + 10
            TabsList {
                id: tabsList
                width: tabsPanel.width
                loading: false
                showCloseButton: true
                expandEnabled: false
                model: TabsModel
                name: "Open Tabs"
                onUserClosesTab: {
                    tabsPanel.userClosesTab(index)
                }
                onUserClicksTab: {
                    tabsPanel.setCurrentIndex(index)
                    tabsPanel.userOpensTab(index)
                }
                anchors.top: parent.top
//                anchors.topMargin: tabsPanel.searchMode ? searchList.height : 0
            }
            TabsList {
                id: searchList
                name: searchMode ? (SearchDB.searchInProgress ?
                                        "Searching" :
                                        (SearchDB.searchResult.count === 0 ? "nothing" : "BOOKMARKS - " + SearchDB.searchResult.count)
                                        + (SearchDB.searchResult.count >= 200 ? "+" : "")
                                        + " found") : "Bookmarks"
                width: tabsPanel.width
                loading: SearchDB.searchInProgress && tabsPanel.searchMode
                hoverHighlight: true
                showCloseButton: false
                expandEnabled: true
                model: SearchDB.searchResult
                onUserDoubleClicksTab: {
                    tabsPanel.userOpensSavedTab(index)
//                    searchList.setHighlightAt(-1)
                }
                onUserClicksTab: {
//                    searchList.setHighlightAt(index)
                    tabsPanel.userPreviewsSavedTab(index)
                }
                anchors.top: tabsList.bottom
//                anchors.top: parent.top
//                anchors.topMargin: tabsPanel.searchMode ? 0 : tabsList.height
            }
        }
    }

    RowLayout {
        id: bottomControls
        x: 0
        y: 177
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        Layout.maximumHeight: 25
        Layout.fillWidth: true
        Layout.margins: 5
    }

    clip: true

    Shortcut {
        sequences: ["Ctrl+Shift+F", "Ctrl+D"]
        onActivated: {
            searchTextField.forceActiveFocus()
            searchTextField.selectAll()
        }
    }

    property alias searchFieldActiveFocus: searchTextField.activeFocus
}
