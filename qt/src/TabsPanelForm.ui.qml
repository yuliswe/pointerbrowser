import QtQuick 2.9
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.3
import "controls" as C
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4 as C1

Item {
    id: form

    Rectangle {
        id: background
        color: (splitView.resizing
                || browserWindow.resizing) ? actPal.window : "#00000000"
        //        color: "#00000000"
        border.width: 0
        anchors.fill: form
    }

    RowLayout {
        id: topControls
        height: 25
        anchors.top: parent.top
        anchors.topMargin: 3
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5

        C.Button {
            id: newTabButton
            font.bold: true
            Layout.preferredWidth: 25
            Layout.preferredHeight: 25
            padding: 1
            Layout.fillHeight: true
            icon {
                source: "icon/plus-mid.svg"
            }
        }

        C.TextField {
            id: tabsSearch
            height: 25
            Layout.fillHeight: true
            Layout.fillWidth: true
            placeholderText: "Search Tabs"
            selectByMouse: true
        }
    }

    C1.ScrollView {
        id: scrollView
        //        interactive: true
        //        boundsBehavior: Flickable.DragOverBounds
        //        flickableDirection: Flickable.VerticalFlick
        clip: true
        anchors.bottomMargin: 5
        anchors.top: topControls.bottom
        anchors.right: parent.right
        anchors.bottom: bottomControls.top
        anchors.left: parent.left
        anchors.topMargin: 3
        verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        //        contentWidth: form.width
        //        contentHeight: 1000 //text1.height + tabsList.height + text2.height + searchList.height
        Flickable {
            boundsBehavior: Flickable.DragOverBounds
            contentHeight: text1.height + tabsList.height + text2.height + searchList.height
            Text {
                id: text1
                width: form.width
                color: actPal.mid
                text: qsTr("Open Tabs")
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
                x: 0
                width: form.width
                //            height: 500
                anchors.top: text1.bottom
                anchors.topMargin: -3
                tabHeight: form.tabHeight
                interactive: false
                highlightFollowsCurrentItem: false
            }

            Text {
                id: text2
                x: 0
                width: form.width
                color: actPal.mid
                text: qsTr("Bookmarks")
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
                anchors.topMargin: -3
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

        Switch {
            id: docviewSwitch
            checked: true
        }
    }

    SystemPalette {
        id: actPal
        colorGroup: SystemPalette.Active
    }

    property alias tabsSearch: tabsSearch
    property alias newTabButton: newTabButton
    property alias tabsList: tabsList
    property alias searchList: searchList
    property alias tabsModel: tabsList.tabsModel
    property alias searchListHeight: searchList.height
    property int tabHeight: 30
    property alias tabsListHeight: tabsList.height
    clip: true
}
