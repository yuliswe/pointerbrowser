import QtQuick 2.7
import QtQuick.Controls 2.2
import "controls" as C
import QtQuick.Layouts 1.3
import Backend 1.0

Item {
    id: form

    property alias textfield: textField
    property int currentHighlight: 0
    property int highlightCount: 0
    property alias prevBtn: prev
    property alias nextBtn: next
    property alias closeBtn: close
    property alias counter: counter

    readonly property var pal: focus ? Palette.selected : Palette.normal

    Rectangle {
        id: rectangle
        radius: 3
        clip: true
        anchors.fill: parent
        color: pal.window_background

        RowLayout {
            id: rowLayout
            spacing: 0
            anchors.fill: parent

            C.TextField {
                id: textField
                Layout.fillWidth: true
                Layout.fillHeight: true
                placeholderText: "Find in document"
                rectangle.opacity: 0.8
                rightPadding: counter.width + 10

                Text {
                    id: counter
                    text: currentHighlight + "/" + highlightCount
                    anchors.rightMargin: 5
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    z: 5
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignTop
                    font.pixelSize: 12
                    color: pal.input_placeholder
                }
            }

            C.Button {
                id: prev
                Layout.preferredHeight: parent.height
                Layout.preferredWidth: parent.height
                image.source: "icon/up.svg"
                rectangle.border.width: 0
                padding: 8
            }
            C.Button {
                id: next
                Layout.preferredHeight: parent.height
                Layout.preferredWidth: parent.height
                image.source: "icon/down.svg"
                rectangle.border.width: 0
                padding: 8
            }
            C.Button {
                id: close
                Layout.preferredHeight: parent.height
                Layout.preferredWidth: parent.height
                image.source: "icon/cross.svg"
                onClicked: form.visible = false
                rectangle.border.width: 0
                padding: 10
            }
        }
    }
}
