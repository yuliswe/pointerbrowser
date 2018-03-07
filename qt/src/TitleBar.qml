import QtQuick 2.9

TitleBarForm {
    property int startX: -1
    property int startY: -1
    signal userDraggingTitleBar(int deltaX, int deltaY)
    signal userStartsDraggingTitleBar()
    signal userStopsDraggingTitleBar()
    mouseArea.drag.threshold: 0
    mouseArea.drag.onActiveChanged: {
        console.log("mouseArea.drag.active", mouseArea.drag.active)
        if (mouseArea.drag.active) {
            var pos = mapToGlobal(mouseArea.mouseX, mouseArea.mouseY)
            startX = pos.x
            startY = pos.y
            userStartsDraggingTitleBar()
        } else {
            userStopsDraggingTitleBar()
        }
    }
    mouseArea.onPositionChanged: {
        var pos = mapToGlobal(mouseArea.mouseX, mouseArea.mouseY)
        if (startX >= 0 && startY >= 0) {
            userDraggingTitleBar(pos.x - startX, pos.y - startY)
        }
        console.log(pos.x - startX, pos.y - startY)
    }

    signal userMaximizesWindow()
    mouseArea.onDoubleClicked: {
        userMaximizesWindow()
    }

    signal userMinimizesWindow()
    signal userClosesWindow()

}
