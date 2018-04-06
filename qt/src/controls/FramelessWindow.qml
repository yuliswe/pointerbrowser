import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Window 2.3

Window {
    id: mainWindow
    visible: true
    width: 800
    height: 600
    minimumWidth: 200
    minimumHeight: 200
    property alias titleBar: form.titleBar
    property int startX: -1
    property int startY: -1
    property int startW: -1
    property int startH: -1
    property bool draggingResetted: false
    property alias sourceComponent: form.sourceComponent
    //    property var delegate: null
//        color: "green"
    color: "#00000000"

    readonly property int customFlags: Qt.Window | Qt.FramelessWindowHint

    flags: customFlags

    property int prevVisibility: Window.Hidden

    Timer {
        id: onExitFromFullscreen
        repeat: false
        triggeredOnStart: false
        interval: 50
        onTriggered: {
            console.log("Exited from fullscreen")
            mainWindow.visible = false
            mainWindow.visible = true
        }
    }

    onVisibilityChanged: {
        console.log("onVisibilityChanged", visibility)
        if (visibility !== Window.Minimized && visibility !== Window.FullScreen) {
            mainWindow.flags = customFlags
        }
        if (visibility === Window.FullScreen) {
            mainWindow.flags = Qt.Window | Qt.CustomizeWindowHint | Qt.WindowFullscreenButtonHint | Qt.WindowCloseButtonHint
        } else {
            titleBar.showTitleBar()
        }
        if (prevVisibility === Window.FullScreen) {
            prevVisibility = visibility
            onExitFromFullscreen.start()
        }
        prevVisibility = visibility
    }

    FramelessWindowForm {
        id: form
        active: mainWindow.active
        width: mainWindow.width
        height: mainWindow.height
        // title bar dragging
        titleBar.onUserStopsDraggingTitleBar: stopDragging()
        titleBar.onUserStartsDraggingTitleBar: {
            console.log("onUserStartsDraggingTitleBar")
            mainWindow.startX = mainWindow.x
            mainWindow.startY = mainWindow.y
            mainWindow.draggingResetted = true
        }
        titleBar.onUserDraggingTitleBar: {
            // console.log("onUserDraggingTitleBar", deltaX, deltaY)
            if (mainWindow.draggingResetted) {
                mainWindow.x = startX + deltaX
                mainWindow.y = startY + deltaY
            }
        }
        function macosRenderBugFix() {
            if (Qt.platform.os === "osx") {
                mainWindow.visible = false
                mainWindow.visible = true
            }
        }
        // control buttons
        Timer {
            id: afterFullscreened
            triggeredOnStart: false
            interval: 500
            repeat: false
            running: (mainWindow.visibility == Window.FullScreen)
            onTriggered: {
                titleBar.hideTitleBar()
            }
        }
        titleBar.onUserMaximizesWindow: {
            switch (mainWindow.visibility) {
            case Window.FullScreen:
                mainWindow.showNormal()
                //                macosRenderBugFix()
                break
            default:
                mainWindow.showFullScreen()
            }
        }
        titleBar.onUserDoubleClicksTitleBar: {
            switch (mainWindow.visibility) {
            case Window.Maximized:
                mainWindow.showNormal()
                break
            default:
                mainWindow.showMaximized()
            }
            macosRenderBugFix()
        }
        titleBar.onUserClosesWindow: {
            mainWindow.close()
        }
        titleBar.onUserMinimizesWindow: {
            if (Qt.platform.os === 'osx') {
                mainWindow.flags = Qt.Window | Qt.CustomizeWindowHint | Qt.WindowMinMaxButtonsHint
            }
            mainWindow.showMinimized()
        }

        // Resizers
        property int resizeThreshold: 1
        function resetDragging() {
            mainWindow.startW = mainWindow.width
            mainWindow.startH = mainWindow.height
            mainWindow.startX = mainWindow.x
            mainWindow.startY = mainWindow.y
            mainWindow.draggingResetted = true
        }
        function stopDragging() {
            mainWindow.draggingResetted = false
            macosRenderBugFix()
        }
        rResizer.onDraggingStarts: resetDragging()
        bResizer.onDraggingStarts: resetDragging()
        tResizer.onDraggingStarts: resetDragging()
        lResizer.onDraggingStarts: resetDragging()
        brResizer.onDraggingStarts: resetDragging()
        trResizer.onDraggingStarts: resetDragging()
        tlResizer.onDraggingStarts: resetDragging()
        blResizer.onDraggingStarts: resetDragging()
        rResizer.onDraggingStops: stopDragging()
        lResizer.onDraggingStops: stopDragging()
        tResizer.onDraggingStops: stopDragging()
        bResizer.onDraggingStops: stopDragging()
        blResizer.onDraggingStops: stopDragging()
        brResizer.onDraggingStops: stopDragging()
        tlResizer.onDraggingStops: stopDragging()
        trResizer.onDraggingStops: stopDragging()
        rResizer.onDragging: {
            if (mainWindow.draggingResetted) {
                if (startW + deltaX >= minimumWidth) {
                    mainWindow.width = startW + deltaX
                }
            }
        }
        bResizer.onDragging: {
            if (mainWindow.draggingResetted) {
                if (startH + deltaY >= minimumHeight) {
                    mainWindow.height = startH + deltaY
                }
            }
        }
        tResizer.onDragging: {
            if (mainWindow.draggingResetted) {
                if (startH + deltaY >= minimumHeight) {
                    mainWindow.height = startH - deltaY
                    mainWindow.y = startY + deltaY
                }
            }
        }
        lResizer.onDragging: {
            if (mainWindow.draggingResetted) {
                if (startW - deltaX >= minimumWidth) {
                    mainWindow.x = startX + deltaX
                    mainWindow.width = startW - deltaX
                }
            }
        }
        brResizer.onDragging: {
            if (mainWindow.draggingResetted) {
                if (startW + deltaX >= minimumWidth) {
                    mainWindow.width = startW + deltaX
                }
                if (startH + deltaY >= minimumHeight) {
                    mainWindow.height = startH + deltaY
                }
            }
        }
        tlResizer.onDragging: {
            if (mainWindow.draggingResetted) {
                if (startW - deltaX >= minimumWidth) {
                    mainWindow.x = startX + deltaX
                    mainWindow.width = startW - deltaX
                }
                if (startH - deltaY >= minimumHeight) {
                    mainWindow.height = startH - deltaY
                    mainWindow.y = startY + deltaY
                }
            }
        }
        blResizer.onDragging: {
            if (mainWindow.draggingResetted) {
                if (startW - deltaX >= minimumWidth) {
                    mainWindow.width = startW - deltaX
                    mainWindow.x = startX + deltaX
                }
                if (startH + deltaY >= minimumHeight) {
                    mainWindow.height = startH + deltaY
                }
            }
        }
        trResizer.onDragging: {
            if (mainWindow.draggingResetted) {
                if (startW + deltaX >= minimumWidth) {
                    mainWindow.width = startW + deltaX
                }
                if (startH - deltaY >= minimumHeight) {
                    mainWindow.height = startH - deltaY
                    mainWindow.y = startY + deltaY
                }
            }
        }
    }

}
