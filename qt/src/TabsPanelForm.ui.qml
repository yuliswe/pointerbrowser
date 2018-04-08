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
        color: splitView.resizing ? actPal.window : "#00000000"
        //        color: "#00000000"
        border.width: 0
        anchors.fill: form
    }

    RowLayout {
        id: topControls
        x: 5
        y: 5
        height: 25
        anchors.top: parent.top
        anchors.topMargin: 3
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        Layout.maximumHeight: 25
        Layout.fillWidth: true
        Layout.margins: 5

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

    Flickable {
        id: flickable
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        clip: true
        anchors.bottomMargin: 5
        anchors.top: topControls.bottom
        anchors.right: parent.right
        anchors.bottom: bottomControls.top
        anchors.left: parent.left
        anchors.topMargin: 3

        //        contentWidth: contentItem.childrenRect.width
        //        contentHeight: contentItem.childrenRect.height
        Text {
            id: text1
            x: 0
            width: form.width
            color: actPal.mid
            text: qsTr("Open Tabs")
            anchors.top: parent.top
            anchors.topMargin: 0
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
            anchors.top: text1.bottom
            anchors.topMargin: 0
            implicitHeight: 100
            tabHeight: form.tabHeight
            interactive: false
            highlightFollowsCurrentItem: false
            Layout.fillHeight: false
            Layout.fillWidth: true
        }

        Text {
            id: text2
            x: 0
            width: form.width
            color: actPal.mid
            text: qsTr("Saved")
            anchors.top: tabsList.bottom
            anchors.topMargin: 0
            bottomPadding: 5
            leftPadding: 5
            topPadding: 5
            font.capitalization: Font.AllUppercase
            font.bold: false
            font.pixelSize: 9
        }

        TabsList {
            id: searchList
            x: 0
            width: form.width
            height: 100
            anchors.top: text2.bottom
            anchors.topMargin: 0
            tabHeight: form.tabHeight
            Layout.fillHeight: true
            Layout.fillWidth: true
            showCloseButton: false
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
