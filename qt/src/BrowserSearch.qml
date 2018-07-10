import QtQuick 2.7
import QtQuick.Controls 2.2
import "controls" as C
import QtQuick.Layouts 1.3
import Backend 1.0

Item {
    id: browserSearch
    signal userSearchesNextInBrowser(string text)
    signal userSearchesPreviousInBrowser(string text)
    signal userTypesInSearch(string text)

    property int currentHighlight: 0
    property int highlightCount: 0

    readonly property var pal: focus ? Palette.selected : Palette.normal
    visible: BrowserController.current_page_search_visible

    function searchNext() {
        if (currentWebUI !== null) {
            currentWebUI.findNext(textfield.text, function(cnt) {
                BrowserController.setCurrentPageSearchState(BrowserController.CurrentPageSearchStateAfterSearch,
                                                            BrowserController.current_page_search_text,
                                                            BrowserController.current_page_search_current_index + 1,
                                                            cnt)
            })
        }
    }

    function searchPrev() {
        if (currentWebUI !== null) {
            currentWebUI.findPrev(textfield.text, function(cnt) {
                BrowserController.setCurrentPageSearchState(BrowserController.CurrentPageSearchStateAfterSearch,
                                                            BrowserController.current_page_search_text,
                                                            BrowserController.current_page_search_current_index - 1,
                                                            cnt)
            })
        }
    }

    function clearSearch() {
        if (currentWebUI) {
            currentWebUI.clearFindText()
        }
        BrowserController.setCurrentPageSearchState(BrowserController.CurrentPageSearchStateClosed)
    }

    Rectangle {
        id: rectangle
        radius: 3
        anchors.fill: parent
        color: browserWindow.palette.window_background_opaque

        RowLayout {
            id: rowLayout
            spacing: 0
            anchors.fill: parent

            C.TextField {
                id: textfield
                Layout.fillWidth: true
                Layout.fillHeight: true
                placeholderText: "Find in document"
                rightPadding: counter.width + 10
                clearOnEsc: false
                selectTextOnFocus: true
                focus: BrowserController.current_page_search_focus
                Text {
                    id: counter
                    visible: BrowserController.current_page_search_count_visible
                    text: {
                        if (BrowserController.current_page_search_count > 0) {
                            return 1 + BrowserController.current_page_search_current_index + "/" + BrowserController.current_page_search_count
                        } else {
                            return "0/0"
                        }
                    }
                    anchors.rightMargin: 5
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    z: 5
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignTop
                    font.pixelSize: 12
                    color: pal.input_placeholder_text
                }
                onAccepted: searchNext()
                onTextChanged: BrowserController.setCurrentPageSearchState(BrowserController.CurrentPageSearchStateBeforeSearch, textfield.text)
            }

            C.Button {
                id: prevBtn
                Layout.preferredHeight: parent.height
                Layout.preferredWidth: parent.height
                image.source: "icon/up.svg"
                rectangle.border.width: 0
                padding: 8
                onClicked: searchPrev()
            }
            C.Button {
                id: nextBtn
                Layout.preferredHeight: parent.height
                Layout.preferredWidth: parent.height
                image.source: "icon/down.svg"
                rectangle.border.width: 0
                padding: 8
                onClicked: searchNext()
            }
            C.Button {
                id: closeBtn
                Layout.preferredHeight: parent.height
                Layout.preferredWidth: parent.height
                image.source: "icon/cross.svg"
                rectangle.border.width: 0
                padding: 10
                onClicked: clearSearch()
            }
        }
    }

    property alias textfield: textfield
}
