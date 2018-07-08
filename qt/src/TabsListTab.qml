import QtQuick 2.7
import QtQuick.Controls 2.2
import Backend 1.0
import "controls" as C

Item {
    id: form
    signal userClosesTab()
    signal doubleClicked()
    signal clicked()
    property bool highlighted: true
    property bool showCloseButton: true
    readonly property var pal: {
        if (activeFocus) { return Palette.pressed; }
        if (highlighted) { return Palette.selected; }
        if (mouseArea.containsMouse) { return Palette.hovered; }
        return Palette.normal;
    }

    state: Qt.platform.os

    property bool expanded: false
    height: model.preview_mode ? 0 : expanded ? 55 : 30
    visible: ! model.preview_mode
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        state: Qt.platform.os
        acceptedButtons: Qt.LeftButton | Qt.MidButton
        onClicked: {
            if (mouse.button == Qt.MidButton) {
                form.userClosesTab()
            } else {
                form.forceActiveFocus()
                form.clicked()
            }
        }
        onDoubleClicked: form.doubleClicked()
        states: [
            State {
                name: "windows"

                PropertyChanges {
                    target: rectangle
                    radius: 0
                }
            }
        ]
        Rectangle {
            id: rectangle
            anchors.fill: parent
            radius: 2
            anchors.leftMargin: 0
            color: form.pal.search_item_background
            RoundButton {
                id: closeButton
                width: 15
                height: 15
                padding: 4
                anchors.verticalCenter: parent.verticalCenter
                visible: form.showCloseButton && mouseArea.containsMouse
                z: 2
                contentItem: Image {
                    source: "icon/cross.svg"
                }
                background: Item {
                }
                onClicked: {
                    form.userClosesTab()
                }
            }

            Rectangle {
                id: hr
                color: "#ebebeb"
                height: 1
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 10
                    rightMargin: 10
                    top: parent.top
                }
                visible: (index != 0) && expanded && ! highlighted
            }

            Column {
                id: column
                anchors.rightMargin: 10
                anchors.bottomMargin: 10
                anchors.topMargin: 10
//                height: parent.height
//                width: parent.width
                anchors.right: parent.right
                anchors.left: closeButton.right
                anchors.verticalCenter: parent.verticalCenter
                clip: true
                Text {
                    id: line1
                    text: model.expanded_display[0] || model.url
                    font.pixelSize: 12
                    //                    font.weight: Font.Medium
                    anchors.right: parent.right
                    anchors.left: parent.left
                    elide: browser.resizing ? Text.ElideNone : Text.ElideRight
                    height: contentHeight
                    color: pal.search_item_line_1_text
                }
                Text {
                    id: line2
                    text: model.expanded_display[1] || ""
                    anchors.right: parent.right
                    anchors.left: parent.left
                    font.pixelSize: 12
                    elide: browser.resizing ? Text.ElideNone : Text.ElideRight
                    height: model.expanded_display[1] ? contentHeight : 0
                    color: pal.search_item_line_2_text
                }
                Text {
                    id: line3
                    text: model.expanded_display[2] || ""
                    font.weight: Font.Light
                    anchors.right: parent.right
                    anchors.left: parent.left
                    elide: browser.resizing ? Text.ElideNone : Text.ElideRight
                    font.pixelSize: 11
                    height: model.expanded_display[2] ? contentHeight : 0
                    color: pal.search_item_line_3_text
                }
            }
        }
    }
    states: [
        State {
            name: "windows"
            PropertyChanges {
                target: column
                anchors.verticalCenterOffset: -1
            }
        },
        State {
            name: "osx"

            PropertyChanges {
                target: column
                anchors.verticalCenterOffset: 1
            }
        }
    ]

}

