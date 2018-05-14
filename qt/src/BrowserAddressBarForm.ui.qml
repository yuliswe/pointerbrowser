import QtQuick 2.7
import QtQuick.Controls 2.2
import "controls" as C
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 1.4 as C1
import Backend 1.0

Item {
    id: form
    property alias textField: textField
    property alias progressBar: progressBar
    property alias titleDisplay: titleDisplay

    C.TextField {
        id: textField
        horizontalAlignment: Text.AlignHCenter
        anchors.fill: parent
    }

    Text {
        id: titleDisplay
        font.pixelSize: Palette.normal.input_font_size
        fontSizeMode: Text.FixedSize
        elide: Text.ElideRight
        clip: true
        rightPadding: 5
        leftPadding: 5
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.fill: parent
        color: Palette.normal.input_placeholder
        renderType: Text.NativeRendering
        visible: !textField.activeFocus
    }

    Rectangle {
        id: progressBar
        color: "green"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        radius: textField.rectangle.radius
        width: 0.2 * textField.width // preview
        //                width: progressBar.value/100 * textField.width
    }
}
