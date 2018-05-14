import QtQuick 2.7
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import QtQuick.Templates 2.2 as T
import Backend 1.0

T.Button {
    id: button
    readonly property var pal: {
        if (! enabled) { return Palette.disabled }
        if (hovered) { return Palette.hovered }
        if (down || checked) { return Palette.selected }
        return Palette.normal
    }
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
