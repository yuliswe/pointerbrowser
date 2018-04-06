import QtQuick 2.9
import QtQuick.Templates 2.3 as T
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

T.Button {
    id: button
    SystemPalette { id: actPal; colorGroup: SystemPalette.Active }
    SystemPalette { id: inaPal; colorGroup: SystemPalette.Inactive }
    SystemPalette { id: disPal; colorGroup: SystemPalette.Disabled }
    contentItem: Text {
        text: button.text
        font: button.font
        color: pal.buttonText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    readonly property var pal: {
        if (! enabled) { return disPal }
        if (button.down || checked) { return actPal }
        return inaPal
    }
    background: Rectangle {
        color: pal.button
        border.color: pal.shadow
        radius: 3
    }
}
