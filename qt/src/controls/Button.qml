import QtQuick 2.9
import QtQuick.Controls 2.3 as C
import QtQuick.Layouts 1.3

C.Button {
    id: button
    SystemPalette { id: actPal; colorGroup: SystemPalette.Active }
    SystemPalette { id: inaPal; colorGroup: SystemPalette.Inactive }
    SystemPalette { id: disPal; colorGroup: SystemPalette.Disabled }
//    contentItem: Text {
//        text: button.text
//        font: button.font
//        color: pal.buttonText
//        horizontalAlignment: Text.AlignHCenter
//        verticalAlignment: Text.AlignVCenter
//        elide: Text.ElideRight
//    }
//    contentItem: Image {
//        source: button.icon.source
//    }
    property alias rectangle: rect
    readonly property var pal: {
        if (! enabled) { return disPal }
        if (down || checked || hovered) { return actPal }
        return inaPal
    }
    background: Rectangle {
        id: rect
        color: pal.button
        border.color: pal.shadow
        radius: 3
    }
    icon {
        color: pal.buttonText
    }
}
