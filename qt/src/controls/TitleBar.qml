import QtQuick 2.9

TitleBarForm {
    property int startX: -1
    property int startY: -1
    property bool maximized: false
    signal userDraggingTitleBar(int deltaX, int deltaY)
    signal userStartsDraggingTitleBar()
    signal userStopsDraggingTitleBar()

    mouseArea.onDraggingStops: {
        userStopsDraggingTitleBar()
    }
    mouseArea.onDraggingStarts: {
        userStartsDraggingTitleBar()
    }
    mouseArea.onDragging: {
        userDraggingTitleBar(deltaX, deltaY)
    }

    signal userMaximizesWindow()
    signal userNormalizesWindow()
    mouseArea.onDoubleClicked: {
        if (maximized) {
            userNormalizesWindow()
        } else {
            userMaximizesWindow()
        }
    }

    signal userMinimizesWindow()
    signal userClosesWindow()

}
