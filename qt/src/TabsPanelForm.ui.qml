import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "qrc:/controls" as C
import QtQuick.Layouts 1.3
import Backend 1.0

Item {
    id: form

    //    Rectangle {
    //        id: background
    //        //        color: "#00000000"
    //        border.width: 0
    //        anchors.fill: form
    //    }
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
            id: tabsSearch
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height - (Qt.platform.os == "ios" ? 5 : 0)
            placeholderText: "Search"
            selectByMouse: true
        }

        C.Button {
            id: newTabButton
            font.bold: true
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height
            padding: 1
            Layout.fillHeight: true
            iconSource: "icon/plus-mid.svg"
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
        //        contentWidth: form.width
        //        contentHeight: 1000 //text1.height + tabsList.height + text2.height + searchList.height
        Flickable {
            id: flickable
            clip: false
            //            flickDeceleration: 10
            //            maximumFlickVelocity: 1000
            contentHeight: text1.height + tabsList.height + text2.height + searchList.height + 10
            C.Text {
                id: text1
                width: form.width
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
                width: form.width
                anchors.top: text1.bottom
                tabHeight: form.tabHeight
                interactive: false
                highlightFollowsCurrentItem: false
            }

            C.Text {
                id: text2
                width: form.width
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
                width: form.width
                hoverHighlight: true
                anchors.top: text2.bottom
                tabHeight: form.tabHeight
                showCloseButton: false
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

    property alias flickable: flickable
    property int buttonSize: 40
    //    property alias rectangle: background
    property alias newTabButton: newTabButton
    property alias openTabsList: tabsList
    property alias searchTextField: tabsSearch
    property alias searchTabsList: searchList
    property int tabHeight: 30
    clip: true
}
