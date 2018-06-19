import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import "controls" as C
import QtQuick.Layouts 1.3
import Backend 1.0

Item {
    id: tabsPanel

    signal userOpensSavedTab(int index)
    signal userClosesTab(int index)
    signal userOpensTab(int index)
    signal userOpensNewTab()

    function setCurrentIndex(i) {
        tabsList.setHighlightAt(i)
    }

    function filterModelBySymbol(sym) {
        SearchDB.searchAsync(sym)
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
            onDelayedTextEdited: {
                if (searchTextField.text.length > 1) {
                    filterModelBySymbol(searchTextField.text)
                } else if (searchTextField.text.length === 0) {
                    filterModelBySymbol("")
                }
            }
            onTextCleared: {
                filterModelBySymbol("")
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
        //        interactive: true
        //        boundsBehavior: Flickable.DragOverBounds
        //        flickableDirection: Flickable.VerticalFlick
        //        clip: true
        anchors.bottomMargin: 5
        anchors.top: topControls.bottom
        anchors.right: parent.right
        anchors.bottom: bottomControls.top
        anchors.left: parent.left
        anchors.topMargin: 3
        //                ScrollViewStyle.transientScrollBars: true

        //        verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        //        contentWidth: tabsPanel.width
        //        contentHeight: 1000 //text1.height + tabsList.height + text2.height + searchList.height
        Flickable {
            id: flickable
            clip: false
            boundsBehavior: Flickable.StopAtBounds
            //            flickDeceleration: 10
            //            maximumFlickVelocity: 1000
            contentHeight: text1.height + tabsList.height + text2.height + searchList.height + 10
            C.Text {
                id: text1
                width: tabsPanel.width
                color: Palette.normal.label_text
                text: qsTr("Open Tabs")
                anchors.left: parent.left
                anchors.leftMargin: 5
                verticalAlignment: Text.AlignBottom
                anchors.top: parent.top
                anchors.topMargin: 5
                topPadding: 5
                bottomPadding: 5
                leftPadding: 5
                font.bold: false
                font.capitalization: Font.AllUppercase
                font.pixelSize: 9
            }

            TabsList {
                id: tabsList
                width: tabsPanel.width
                anchors.top: text1.bottom
                interactive: false
                highlightFollowsCurrentItem: false
                showCloseButton: true
                expandEnabled: false
                model: TabsModel

                onUserClosesTab: {
                    tabsPanel.userClosesTab(index)
                }
                onUserClicksTab: {
                    tabsPanel.setCurrentIndex(index)
                    tabsPanel.userOpensTab(index)
                }
            }

            C.Text {
                id: text2
                width: tabsPanel.width
                color: Palette.normal.label_text
                text: qsTr("Bookmarks")
                anchors.left: parent.left
                anchors.leftMargin: 5
                verticalAlignment: Text.AlignBottom
                anchors.top: tabsList.bottom
                anchors.topMargin: 5
                bottomPadding: 5
                leftPadding: 5
                topPadding: 5
                font.capitalization: Font.AllUppercase
                font.bold: false
                font.pixelSize: 9
            }

            TabsList {
                id: searchList
                //            height: 500
                width: tabsPanel.width
                hoverHighlight: true
                anchors.top: text2.bottom
                showCloseButton: false
                expandEnabled: false
                model: SearchDB.searchResult
                onUserClicksTab: {
                    tabsPanel.userOpensSavedTab(index)
                }
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
    states: [
        State {
            name: "windows"

            PropertyChanges {
                target: text1
                renderType: Text.NativeRendering
                font.pixelSize: 11
            }

            PropertyChanges {
                target: text2
                renderType: Text.NativeRendering
                font.pixelSize: 11
            }
        }
    ]

    property int buttonSize: 40
    clip: true

    Shortcut {
        sequences: ["Ctrl+Shift+F", "Ctrl+D"]
        onActivated: {
            searchTextField.forceActiveFocus()
            searchTextField.selectAll()
        }
    }

}
