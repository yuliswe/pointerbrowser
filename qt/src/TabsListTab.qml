import QtQuick 2.7
import QtQuick.Controls 2.2
import Backend 1.0
import "controls" as C

Item {
    id: tab
    signal userClosesTab()
    signal doubleClicked()
    signal clicked()
    property bool highlighted: true
    property bool showCloseButton: true
    property int visualIndex: 0
    property int tabState: 0

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
        drag {
//            axis: Drag.YAxis
            target: rectangle
        }
        hoverEnabled: true
        scrollGestureEnabled: false
        acceptedButtons: Qt.LeftButton | Qt.MidButton
        onPressed: {
            if (mouse.button == Qt.MidButton) {
                tab.userClosesTab()
            } else {
                tab.forceActiveFocus()
                tab.clicked()
            }
        }
        onDoubleClicked: tab.doubleClicked()
        Rectangle {
            id: hr
            color: "#ebebeb"
            height: 1
            anchors {
                left: mouseArea.left
                right: mouseArea.right
                leftMargin: 10
                rightMargin: 10
                top: mouseArea.top
            }
            visible: (visualIndex != 0) && expanded && ! highlighted
        }
        Rectangle {
            id: rectangle
            //            anchors.fill: parent
            //            width: parent.width
//            anchors.left: parent.left
//            anchors.right: parent.right
            Drag.active: mouseArea.drag.active
            Drag.source: tab
            Drag.hotSpot.x: width / 2
            Drag.hotSpot.y: height / 2

            Drag.onActiveChanged: {
                if (Drag.active) {
                    anchors.fill = undefined
                    rectangle.z = 2
                    rectangle.parent = browser
                } else {
                    rectangle.z = 0
                    rectangle.parent = mouseArea
                    anchors.fill = parent
                }
            }


            height: mouseArea.height
            width: mouseArea.width
            color: tab.pal.search_item_background
            RoundButton {
                id: closeButton
                width: 15
                height: 15
                padding: 4
                anchors.verticalCenter: parent.verticalCenter
                visible: tab.showCloseButton && mouseArea.containsMouse
                z: 2
                contentItem: Image {
                    source: "icon/cross.svg"
                }
                background: Item {
                }
                onClicked: {
                    tab.userClosesTab()
                }
            }
            Column {
                id: column
                anchors.rightMargin: 10
                anchors.bottomMargin: 10
                anchors.topMargin: 10
                anchors.right: parent.right
                anchors.left: closeButton.right
                anchors.verticalCenter: parent.verticalCenter
                //                clip: true
                Text {
                    id: line1
                    text: model.title || model.uri || "Loading..."
                    font.pixelSize: 12
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
                    visible: model.expanded_display[1] || false
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
                    visible: model.expanded_display[2] || false
                    color: pal.search_item_line_3_text
                }
            }
        }
    }

    DropArea {
        id: dropBefore
        anchors {
            top: parent.top
            bottom: parent.verticalCenter
            left: parent.left
            right: parent.right
//            margins: rectangle.height / 8
        }
        onEntered: {
//            dropBeforeRec.opacity = 1
            BrowserController.moveTab(drag.source.tabState,
                                      drag.source.visualIndex,
                                      tab.tabState,
                                      tab.visualIndex)
        }
//        onExited: {
//            dropBeforeRec.opacity = 0.5
//        }
//        Rectangle {
//            id: dropBeforeRec
//            anchors.fill: parent
//            color: "red"
//            opacity: 0.5
//        }
    }
    DropArea {
        id: dropAfter
        anchors {
            top: parent.verticalCenter
            bottom: parent.bottom
            left: parent.left
            right: parent.right
//            margins: rectangle.height / 8
        }
        onEntered: {
//            dropAfterRec.opacity = 1
            BrowserController.moveTab(drag.source.tabState,
                                      drag.source.visualIndex,
                                      tab.tabState,
                                      tab.visualIndex + 1)
        }
//        onExited: {
//            dropAfterRec.opacity = 0.5
//        }
//        Rectangle {
//            id: dropAfterRec
//            anchors.fill: parent
//            color: "green"
//            opacity: 0.5
//        }
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

