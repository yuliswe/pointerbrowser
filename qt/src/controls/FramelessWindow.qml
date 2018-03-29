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
    //    color: "black"
    color: "#00000000"

    readonly property int customFlags: Qt.Window | Qt.FramelessWindowHint

    flags: customFlags

    onVisibilityChanged: {
        console.log("onVisibilityChanged", visibility)
        if (visibility != Window.Minimized) {
            mainWindow.flags = customFlags
        }
    }

    FramelessWindowForm {
        id: form
        active: mainWindow.active
        width: mainWindow.width
        height: mainWindow.height
        titleBar.onUserStartsDraggingTitleBar: {
            console.log("onUserStartsDraggingTitleBar")
            mainWindow.startX = mainWindow.x
            mainWindow.startY = mainWindow.y
            mainWindow.draggingResetted = true
        }
        titleBar.onUserStopsDraggingTitleBar: stopDragging()
        titleBar.onUserDraggingTitleBar: {
            //            console.log("onUserDraggingTitleBar", deltaX, deltaY)
            if (mainWindow.draggingResetted) {
                mainWindow.x = startX + deltaX
                mainWindow.y = startY + deltaY
            }
        }
        titleBar.onUserMaximizesWindow: {
            mainWindow.showMaximized()
            macosRenderBugFix()
        }
        titleBar.onUserFullscreensWindow: {
            mainWindow.showFullScreen()
        }
        titleBar.onUserClosesWindow: {
            mainWindow.close()
        }
        titleBar.onUserNormalizesWindow: {
            mainWindow.showNormal()
            macosRenderBugFix()
        }
        titleBar.onUserMinimizesWindow: {
            if (Qt.platform.os === 'osx') {
                mainWindow.flags = Qt.Window | Qt.CustomizeWindowHint | Qt.WindowMinMaxButtonsHint
            }
            mainWindow.showMinimized()
        }
        property int resizeThreshold: 1
        function resetDragging() {
            mainWindow.startW = mainWindow.width
            mainWindow.startH = mainWindow.height
            mainWindow.startX = mainWindow.x
            mainWindow.startY = mainWindow.y
            mainWindow.draggingResetted = true
        }
        function macosRenderBugFix() {
            mainWindow.visible = false
            mainWindow.visible = true
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
