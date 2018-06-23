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
    property var pal: form.highlighted ? Palette.selected : mouseArea.containsMouse ? Palette.hovered : Palette.normal

    property bool expanded: false
    height: model.preview_mode ? 0 : expanded ? 50 : 30
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
                form.clicked()
            }
        }
        onDoubleClicked: form.doubleClicked()
        states: [
            State {
                name: "windows"

                PropertyChanges {
                    target: text1
                    font.pixelSize: 11
                    renderType: Text.NativeRendering
                }

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
            color: form.pal.list_item_background
            RoundButton {
                id: closeButton
                width: 15
                height: 15
//                anchors.leftMargin: 2
                padding: 4
//                anchors.left: parent.left
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
                color: "#eee"
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
            C.Text {
                id: text1
                color: highlighted ? pal.list_item_text : pal.button_text
                font.pixelSize: 11
                anchors.rightMargin: 10
                anchors.right: parent.right
//                textFormat: Text.PlainText
                anchors.left: closeButton.right
                anchors.verticalCenter: parent.verticalCenter
//                anchors.top: parent.top
//                anchors.topMargin: 8
                verticalAlignment: Text.AlignTop
                horizontalAlignment: Text.AlignLeft
                text: (expanded ? model.expanded_display : model.display) || "Loading"
                clip: true
            }
        }
    }

}

