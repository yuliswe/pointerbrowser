import QtQuick 2.9

TitleBarForm {
    id: titleBar
    property int startX: -1
    property int startY: -1
    signal userDraggingTitleBar(int deltaX, int deltaY)
    signal userStartsDraggingTitleBar()
    signal userStopsDraggingTitleBar()

    mouseArea.onDraggingStops: {
        userStopsDraggingTitleBar()
    }
    mouseArea.onDraggingStarts: {
        //        console.log("userStartsDraggingTitleBar()")
        userStartsDraggingTitleBar()
    }

    mouseArea.onDragging: {
        //        console.log("userDraggingTitleBar(%d,%d)", deltaX, deltaY)
        userDraggingTitleBar(deltaX, deltaY)
    }

    signal userMaximizesWindow()
    signal userMinimizesWindow()
    signal userNormalizesWindow()
    signal userDoubleClicksTitleBar()
    //    signal userFullscreensWindow()
    signal userClosesWindow()

    mouseArea.onDoubleClicked: userDoubleClicksTitleBar()
    maxBtn.onClicked: userMaximizesWindow()
    minBtn.onClicked: userMinimizesWindow()
    clsBtn.onClicked: userClosesWindow()

    function showTitleBar() {
        show.restart()
        //        titleBar.height = 25
        //        titleBar.visible = true
    }

    function hideTitleBar() {
        //        titleBar.height = 0
        hide.restart()
        //        titleBar.visible = false
    }

    SmoothedAnimation {
        id: show
        duration: 1000
        target: titleBar
        property: "height"
        to: 20
    }
    SmoothedAnimation {
        id: hide
        duration: 1000
        target: titleBar
        property: "height"
        to: 0
    }
}
