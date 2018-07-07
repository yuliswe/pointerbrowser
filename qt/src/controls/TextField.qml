import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.impl 2.4
import QtQuick.Templates 2.4 as T
import Backend 1.0

T.TextField {
    id: control
    /* Qt 11.1 source with duplicated properties removed */
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                                         placeholderText ? placeholder.implicitWidth + leftPadding + rightPadding : 0)
                   || contentWidth + leftPadding + rightPadding
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding,
                             background ? background.implicitHeight : 0,
                                          placeholder.implicitHeight + topPadding + bottomPadding)

    PlaceholderText {
        id: placeholder
        x: control.leftPadding
        y: control.topPadding
        width: control.width - (control.leftPadding + control.rightPadding)
        height: control.height - (control.topPadding + control.bottomPadding)

        text: control.placeholderText
        font.pixelSize: 13
        font.weight: Font.Thin
        font.family: control.font.family
//        opacity: 0.001
        color: control.pal.input_placeholder_text
        verticalAlignment: control.verticalAlignment
        visible: !control.length && !control.preeditText && (!control.activeFocus || control.horizontalAlignment !== Qt.AlignHCenter)
        elide: Text.ElideRight
    }

    /* Our implementation */
    property bool fakeActiveFocusUntilEmpty: false
    readonly property bool fakeActiveFocus: (fakeActiveFocusUntilEmpty && text) || activeFocus
    readonly property var pal: {
        if (fakeActiveFocus) { return Palette.selected }
        return Palette.normal
    }
    state: Qt.platform.os
    color: pal.input_text
    property alias rectangle: rectangle
    property bool clearOnEsc: true
    selectByMouse: true
    selectionColor: pal.text_background
    selectedTextColor: pal.text
    placeholderText: ""
    states: [
        State {
            name: "windows"
            PropertyChanges {
                target: rectangle
                radius: 0
            }
        },
        State {
            name: "osx"
            PropertyChanges {
                target: rectangle
                radius: 3
            }
        }
    ]
    font.pixelSize: pal.input_font_size
    background: Rectangle {
        id: rectangle
        border.width: 1
        border.color: pal.input_border
        color: fakeActiveFocus ? pal.input_background : pal.input_background
        anchors.fill: control
    }
    verticalAlignment: TextInput.AlignVCenter
    leftPadding: 5
    rightPadding: 5
    onFakeActiveFocusChanged: {
        if (! fakeActiveFocus) {
            focus = false
        }
    }
    signal delayedTextChanged()
    Timer {
        id: timeout
        repeat: false
        triggeredOnStart: false
        interval: 250
        onTriggered: {
            delayedTextChanged(control.text)
        }
    }
    onTextChanged: {
        timeout.restart()
    }
    Keys.onShortcutOverride: {
        if (event.key === Qt.Key_Escape
                && text.length > 0
                && clearOnEsc) {
            event.accepted = true
        }
    }
    Keys.onReleased: {
        if (event.key === Qt.Key_Escape && clearOnEsc) {
            event.accepted = true;
            text = ""
        }
    }
    property alias placeholder: placeholder
}

