import QtQuick 2.4
import QtQuick.Controls 2.3 as C2
import "controls" as C
import QtQuick.Layouts 1.3

Item {
    id: form

    property alias textfield: textField

    SystemPalette {
        id: actPal
        colorGroup: SystemPalette.Active
    }

    SystemPalette {
        id: inaPal
        colorGroup: SystemPalette.Inactive
    }

    readonly property var pal: focus ? actPal : inaPal

    Rectangle {
        id: rectangle
        radius: 3
        clip: true
        anchors.fill: parent
        color: pal.window

        RowLayout {
            id: rowLayout
            spacing: 1
            anchors.fill: parent

            C2.Button {
                id: close
                Layout.maximumHeight: 15
                Layout.maximumWidth: 15
                icon {
                    source: "icon/cross.svg"
                    color: inaPal.dark
                }
                onClicked: form.visible = false
                background: Item {
                }
            }

            C.TextField {
                id: textField
                Layout.fillWidth: true
                Layout.fillHeight: true
                placeholderText: "Find in document"
                rectangle.opacity: 0.8
            }

            C2.Button {
                id: next
                Layout.maximumHeight: 15
                Layout.maximumWidth: 15
                icon {
                    source: "icon/down.svg"
                    color: inaPal.dark
                }
                background: Item {
                }
            }

            C2.Button {
                id: prev
                Layout.maximumHeight: 15
                Layout.maximumWidth: 15
                icon {
                    source: "icon/up.svg"
                    color: inaPal.dark
                }
                background: Item {
                }
            }
        }
    }
}
