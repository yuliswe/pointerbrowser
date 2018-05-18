import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import Backend 1.0

Item {
    id: form
    property bool active: false
    property alias loader: loader

    readonly property var palette: active ? Palette.selected : Palette.normal


        Loader {
            id: loader
            x: 0
            y: 20
            anchors.fill: parent
        }

}
