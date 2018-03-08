import QtQuick 2.9

TitleBarForm {
    property int startX: -1
    property int startY: -1
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
            maximized = false
        } else {
            userMaximizesWindow()
            maximized = true
        }
    }

    signal userFullscreensWindow()
    maxBtn.onClicked: {
        if (fullscreened) {
            if (maximized) {
                userMaximizesWindow()
            } else {
                userNormalizesWindow()
            }
            fullscreened = false
        } else {
            userFullscreensWindow()
            fullscreened = true
        }
    }

    signal userMinimizesWindow()
    minBtn.onClicked: {
        userMinimizesWindow()
    }
    signal userClosesWindow()
    clsBtn.onClicked: {
        userClosesWindow()
    }

}
