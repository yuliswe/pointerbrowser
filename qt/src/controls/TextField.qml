import QtQuick 2.9
import QtQuick.Templates 2.3 as T
import QtQuick.Controls 2.3

T.TextField {
    id: textfield

    SystemPalette { id: actPal; colorGroup: SystemPalette.Active }
    focus: false
    color: actPal.text
    background: Rectangle {
        border.width: 1
        border.color: actPal.mid
        color: textfield.focus ? actPal.light : actPal.midlight
        anchors.fill: textfield
        radius: 3
    }
    verticalAlignment: TextInput.AlignVCenter
    leftPadding: 5
    onFocusChanged: {
        if (! focus && ! text) {
            text = placeholderText
            color = actPal.buttonText
        } else {
            text = ""
            color = actPal.text
        }
    }
    Component.onCompleted: {
        text = placeholderText
        color = actPal.buttonText
    }
}
