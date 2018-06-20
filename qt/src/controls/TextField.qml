import QtQuick 2.7
import QtQuick.Templates 2.2 as T
import QtQuick.Controls 2.2
import Backend 1.0

TextField {
    id: textfield
    property bool fakeActiveFocusUntilEmpty: false
    readonly property bool fakeActiveFocus: (fakeActiveFocusUntilEmpty && text) || activeFocus
    readonly property var pal: {
        if (fakeActiveFocus) { return Palette.selected }
        return Palette.normal
    }
    state: Qt.platform.os
    color: text == placeholderText ? pal.input_placeholder : pal.input_text
    property alias rectangle: rectangle
    selectByMouse: true
    selectionColor: pal.text_background
    selectedTextColor: pal.text
    placeholderText: ""
    renderType: Text.NativeRendering
//    text: placeholderText
//    states: [
//        State {
//            name: "windows"
//            PropertyChanges {
//                target: rectangle
//                radius: 0
//            }
//            PropertyChanges {
//                target: textfield
//                renderType: Text.NativeRendering
//            }
//        },
//        State {
//            name: "mac"
//            PropertyChanges {
//                target: rectangle
//                radius: 3
//            }
//            PropertyChanges {
//                target: textfield
//                renderType: Text.QtRendering
//            }
//        }
//    ]
    font.pixelSize: pal.input_font_size
    background: Rectangle {
        id: rectangle
        border.width: 1
        border.color: pal.input_border
        color: fakeActiveFocus ? pal.input_background : pal.input_background
        anchors.fill: textfield
        radius: (Qt.platform.os == "ios" ? 10 : 3)
    }
    verticalAlignment: TextInput.AlignVCenter
    leftPadding: 5
    rightPadding: 5
    onFakeActiveFocusChanged: {
        if (! fakeActiveFocus) {
            focus = false
        }
//        if (! fakeActiveFocus && ! text) {
//            text = placeholderText
//        } else if (fakeActiveFocus && text == placeholderText) {
//            text = ""
//        }
    }
    signal textCleared()
    signal delayedTextChanged()
    Timer {
        id: timeout
        repeat: false
        triggeredOnStart: false
        interval: 250
        onTriggered: {
            delayedTextChanged(textfield.text)
        }
    }
    onTextChanged: {
        timeout.restart()
    }
    Keys.onReleased: {
        if (event.key === Qt.Key_Escape) {
            event.accepted = true;
            textCleared()
            timeout.stop()
        }
    }
}
