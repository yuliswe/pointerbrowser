import QtQuick 2.9
import Backend 1.0

TabsPanelForm {
    id: tabsPanel

    signal userOpensSavedTab(int index)
    signal userClosesTab(int index)
    signal userOpensTab(int index)
    signal userOpensNewTab()

    tabHeight: 30

    function setCurrentIndex(i) {
        openTabsList.setHighlightAt(i)
    }

    function filterModelBySymbol(sym) {
        SearchDB.search(sym)
    }

    flickable {
        rebound: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: {
                    switch (Qt.platform.os) {
                    case "ios": return 2500; break;
                    default: return 500
                    }
                }
                easing.type: Easing.OutQuint
            }
        }

        boundsBehavior: {
            if (Qt.platform.os == "ios") {
                return Flickable.DragAndOvershootBounds
            } else {
                return Flickable.StopAtBounds
            }
        }
    }


    openTabsList {
        height: TabsModel.count * tabHeight
        model: TabsModel

        onUserClosesTab: {
            userClosesTab(index)
        }
        onUserClicksTab: {
            setCurrentIndex(index)
            userOpensTab(index)
        }
    }

    searchTabsList {
        height: SearchDB.searchResult.count * tabHeight
        model: SearchDB.searchResult

        onUserDoubleClicksTab: {
            userOpensSavedTab(index)
        }
    }

    searchTextField {
        onTextEdited: {
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

    Component.onCompleted: {
        searchTabsList.setHighlightAt(-1);
    }

    newTabButton.onClicked: {
        tabsPanel.userOpensNewTab()
    }

    Shortcut {
        sequences: ["Ctrl+Shift+F", "Ctrl+T"]
        onActivated: {
            searchTextField.forceActiveFocus()
            searchTextField.selectAll()
        }
    }

}
