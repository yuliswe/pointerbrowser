import QtQuick 2.9
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.3
import "controls" as C
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.3

Item {
    property alias currentIndex: tabsList.currentIndex

    id: form

    SystemPalette {
        id: actPal
        colorGroup: SystemPalette.Active
    }

    Rectangle {
        id: background
        color: actPal.button
        border.width: 0
        anchors.fill: form
        opacity: 0.95
    }
    property alias docviewSwitchFocusPolicy: docviewSwitch.focusPolicy
    property alias tabsList: tabsList
    property alias tabsSearch: tabsSearch
    property alias newTabButton: newTabButton

    ColumnLayout {
        id: columnLayout
        anchors.rightMargin: 0
        spacing: 0
        anchors.fill: parent

        RowLayout {
            id: topControls
            height: 25
            Layout.maximumHeight: 25
            Layout.fillWidth: true
            Layout.margins: 5

            C.Button {
                id: newTabButton
                x: 550
                width: 25
                height: 25
                text: qsTr("+")
                font.bold: true
                Layout.fillHeight: true
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

        Text {
            id: text1
            text: qsTr("Open Tabs")
            topPadding: 5
            bottomPadding: 5
            leftPadding: 5
            font.bold: false
            font.capitalization: Font.AllUppercase
            font.pixelSize: 9
            color: actPal.mid
        }

        TabsList {
            id: tabsList
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        RowLayout {
            id: bottomControls
            Layout.maximumHeight: 25
            Layout.fillWidth: true
            Layout.margins: 5

            Switch {
                id: docviewSwitch
                checked: true
            }
        }


    }
}
