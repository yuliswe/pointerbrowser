import QtQuick 2.9
import QtQuick.Templates 2.3 as T
import QtQuick.Controls 2.3
import Backend 1.0

T.TextField {
    id: textfield
    readonly property var palette: {
        if (activeFocus) { return Palette.selected }
        return Palette.normal
    }
    color: text == placeholderText ? palette.input_placeholder : palette.input_text
    property alias rectangle: rectangle
    selectByMouse: true
    selectionColor: palette.text_background
    selectedTextColor: palette.text
    text: placeholderText
    font.pixelSize: palette.input_font_size
    background: Rectangle {
        id: rectangle
        border.width: 1
        border.color: palette.input_border
        color: textfield.activeFocus ? palette.input_background : palette.input_background
        anchors.fill: textfield
        radius: (Qt.platform.os == "ios" ? 10 : 3)
    }
    verticalAlignment: TextInput.AlignVCenter
    leftPadding: 5
    rightPadding: 5
    onActiveFocusChanged: {
        if (! activeFocus) {
            focus = false
        }
        if (! activeFocus && ! text) {
            text = placeholderText
        } else if (activeFocus && text == placeholderText) {
            text = ""
        }
    }
}
