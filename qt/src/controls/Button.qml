import QtQuick 2.7
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.4 as T
//import QtQuick.Templates 2.4 as T
import Backend 1.0

T.AbstractButton {
    id: button
    readonly property var pal: {
        if (! enabled) { return Palette.disabled }
        if (pressed || checked) { return Palette.selected }
        if (hovered) { return Palette.hovered }
        return Palette.normal
    }
//    activeFocusOnPress: true
    state: Qt.platform.os
    states: [
        State {
            name: "windows"
            PropertyChanges {
                target: rect
                radius: 0
            }
        }
    ]
    background: Rectangle {
        id: rect
        color: pal.button_background
        border.color: pal.button_border
        radius: 3
        width: button.width
        height: button.height
    }
    implicitHeight: 25
    implicitWidth: 25
    contentItem: img
    Image {
        id: img
        sourceSize.width: button.width
        sourceSize.height: button.height
        visible: false
    }
    ColorOverlay {
        id: ovl
        source: img
        anchors.fill: img
        color: pal.button_icon
    }

    property alias rectangle: rect
    property alias iconSource: img.source
    property alias overlay: ovl
    property alias image: img
}
