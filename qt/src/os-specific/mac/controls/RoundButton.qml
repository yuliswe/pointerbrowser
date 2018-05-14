import QtQuick 2.7
import QtGraphicalEffects 1.0
import QtQuick.Templates 2.2 as T
import Backend 1.0

Button {
    id: button
    property alias rectangle: rect
    background: Rectangle {
        id: rect
        radius: height / 2
        width: button.width
        height: button.height
    }
}
