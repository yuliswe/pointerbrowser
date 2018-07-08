import QtQuick 2.7
import QtQuick.Controls 2.2
import "controls" as C
import QtQuick.Layouts 1.3
import Backend 1.0

Item {
    id: browserSearch
    //    signal userSearchesWordInBrowser(string word)
    signal userSearchesNextInBrowser(string text)
    signal userSearchesPreviousInBrowser(string text)
    signal userClosesSearch()
    signal userTypesInSearch(string text)
    function setText(t) {
        textfield.text = t
    }
    function updateCount(count) {
        highlightCount = count
        console.log("updateCount " + highlightCount)
    }
    function updateCurrent(current) {
        currentHighlight = current
        console.log("updateCurrent " + currentHighlight)
    }

    function setResult(current, count) {
        updateCount(count)
        updateCurrent(current)
    }

    function current() {
        return currentHighlight;
    }
    function count() {
        return highlightCount;
    }
    function hideCount() {
        counter.visible = false
    }
    function showCount() {
        counter.visible = true
    }

    property int currentHighlight: 0
    property int highlightCount: 0

    readonly property var pal: focus ? Palette.selected : Palette.normal

    Rectangle {
        id: rectangle
        radius: 3
        anchors.fill: parent
        color: browserWindow.palette.window_background

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
                Text {
                    id: counter
                    visible: false
                    text: currentHighlight + "/" + highlightCount
                    anchors.rightMargin: 5
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    z: 5
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignTop
                    font.pixelSize: 12
                    color: pal.input_placeholder_text
                }
                onAccepted: {
                    userSearchesNextInBrowser(textfield.text)
                }
                onTextChanged: {
                    userTypesInSearch(textfield.text)
                }
            }

            C.Button {
                id: prevBtn
                Layout.preferredHeight: parent.height
                Layout.preferredWidth: parent.height
                image.source: "icon/up.svg"
                rectangle.border.width: 0
                padding: 8
                onClicked: {
                    userSearchesPreviousInBrowser(textfield.text)
                    console.log("userSearchesPreviousInBrowser")
                }
            }
            C.Button {
                id: nextBtn
                Layout.preferredHeight: parent.height
                Layout.preferredWidth: parent.height
                image.source: "icon/down.svg"
                rectangle.border.width: 0
                padding: 8
                onClicked: {
                    userSearchesNextInBrowser(textfield.text)
                    console.log("userSearchesNextInBrowser")
                }
            }
            C.Button {
                id: closeBtn
                Layout.preferredHeight: parent.height
                Layout.preferredWidth: parent.height
                image.source: "icon/cross.svg"
                rectangle.border.width: 0
                padding: 10
                onClicked: {
                    userClosesSearch()
                }
            }
        }
    }

    property alias textfield: textfield
}
