import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Backend 1.0

Button {
    id: button
    property alias rectangle: rect
    readonly property var pal: {
        if (! enabled) { return Palette.disabled }
        if (hovered) { return Palette.hovered }
        if (down || checked) { return Palette.selected }
        if (! active) { return Palette.inactive }
        return Palette.normal
    }
    antialiasing: true
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
    contentItem: Image {
//        color: pal.button_icon
        width: button.width
        height: button.height
    }
}
