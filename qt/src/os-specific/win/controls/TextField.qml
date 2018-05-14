import QtQuick 2.7
import QtQuick.Templates 2.2 as T
import QtQuick.Controls 2.2
import Backend 1.0

T.TextField {
    id: textfield
    readonly property var pal: {
        if (activeFocus) { return Palette.selected }
        return Palette.normal
    }
    color: text == placeholderText ? pal.input_placeholder : pal.input_text
    property alias rectangle: rectangle
    selectByMouse: true
    selectionColor: pal.text_background
    selectedTextColor: pal.text
    text: placeholderText
    renderType: Text.NativeRendering
    font.pixelSize: pal.input_font_size
    background: Rectangle {
        id: rectangle
        border.width: 1
        border.color: pal.input_border
        color: textfield.activeFocus ? pal.input_background : pal.input_background
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
