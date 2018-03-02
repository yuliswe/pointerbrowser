import QtQuick 2.7
import QtQuick.Controls 2.2

MouseArea {
    id: mouseArea
    property int startX: 0
    property int startY: 0
    property bool isDragging: false
    signal dragging(int deltaX, int deltaY)
    signal draggingStarts()
    signal draggingStops()
    drag.target: this
    drag.threshold: 1
    drag.onActiveChanged: {
//        console.log("mouseArea.drag.active", drag.active)
        if (drag.active) {
            var pos = mapToGlobal(mouseX, mouseY)
            startX = pos.x
            startY = pos.y
            draggingStarts()
            isDragging = true
        } else {
            draggingStops()
            isDragging = false;
        }
    }
    onPositionChanged: {
//        console.log(mouseX, mouseY, startX, startY)
        var pos = mapToGlobal(mouseX, mouseY)
        if (isDragging) {
            dragging(pos.x - startX, pos.y - startY)
        }
    }
}
