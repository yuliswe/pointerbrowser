import QtQuick 2.4
import QtQuick.Templates 2.3 as T
import QtQuick.Controls 2.3

T.TextField {
    id: textfield
    Control {
        id: ctl
    }
    color: ctl.palette.text
    background: Rectangle {
        border.width: 1
        border.color: ctl.palette.mid
        color: ctl.palette.button
        anchors.fill: textfield
        radius: 3
    }
    verticalAlignment: TextInput.AlignVCenter
    leftPadding: 5
    onFocusChanged: {
        if (! focus && ! text) {
            text = placeholderText
            console.log(ctl.palette.buttonText)
            color = ctl.palette.buttonText
        } else {
            text = ""
            color = ctl.palette.text
        }
    }
    Component.onCompleted: {
        text = placeholderText
        color = ctl.palette.buttonText
    }
}
