import QtQuick 2.4
import QtQuick.Templates 2.3 as T
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

T.Button {
    id: button
    Control {
        id: ctl
    }
    contentItem: Text {
        text: button.text
        font: button.font
        opacity: enabled ? 1.0 : 0.3
        color: button.down ? "#17a81a" : "#21be2b"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    background: Rectangle {
        opacity: enabled ? 1 : 0.3
        color: button.down ? palette.mid : palette.button
    }
}
