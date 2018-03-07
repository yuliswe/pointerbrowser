import QtQuick 2.9
import QtQuick.Controls 2.2

MouseArea {
    id: mouseArea
    property int startX: -1
    property int startY: -1
    signal dragging(int deltaX, int deltaY)
    signal draggingStarts()
    signal draggingStops()
    drag.target: this
    drag.threshold: 1
    drag.onActiveChanged: {
        console.log("mouseArea.drag.active", drag.active)
        if (drag.active) {
            var pos = mapToGlobal(mouseX, mouseY)
            startX = pos.x
            startY = pos.y
            draggingStarts()
        } else {
            draggingStops()
        }
    }
    onPositionChanged: {
//        console.log(mouseX, mouseY)
        var pos = mapToGlobal(mouseX, mouseY)
        if (startX >= 0 && startY >= 0) {
            dragging(pos.x - startX, pos.y - startY)
        }
    }
}
