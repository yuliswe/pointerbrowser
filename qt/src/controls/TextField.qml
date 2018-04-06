import QtQuick 2.9
import QtQuick.Templates 2.3 as T
import QtQuick.Controls 2.3

T.TextField {
    id: textfield
    SystemPalette { id: actPal; colorGroup: SystemPalette.Active }
    SystemPalette { id: inactPal; colorGroup: SystemPalette.Inactive }
    Component.onCompleted: {
        console.log(inactPal.text)
    }
    readonly property var palette: {
        if (activeFocus) { return actPal }
        return inactPal
    }
    color: activeFocus ? palette.text : palette.buttonText
    property alias rectangle: rectangle
    selectByMouse: true
    selectionColor: palette.highlight
    selectedTextColor: palette.highlightedText
    text: placeholderText
    background: Rectangle {
        id: rectangle
        border.width: 1
        border.color: palette.shadow
        color: textfield.activeFocus ? palette.light : palette.button
        anchors.fill: textfield
        radius: 3
    }
    verticalAlignment: TextInput.AlignVCenter
    leftPadding: 5
    onFocusChanged: {
        if (! focus && ! text) {
            text = placeholderText
        } else if (focus && text == placeholderText) {
            text = ""
        }
    }
}
