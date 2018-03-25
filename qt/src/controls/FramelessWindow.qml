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
    FramelessWindowForm {
        id: form
        active: mainWindow.active
        width: mainWindow.width
        height: mainWindow.height
        titleBar.onUserStartsDraggingTitleBar: {
            mainWindow.startX = mainWindow.x
            mainWindow.startY = mainWindow.y
            mainWindow.draggingResetted = true
        }
        titleBar.onUserStopsDraggingTitleBar: {
            mainWindow.draggingResetted = false
            console.log("here", titleBar.width, "vs", mainWindow.width)
        }
        titleBar.onUserDraggingTitleBar: {
            if (mainWindow.draggingResetted) {
                mainWindow.x = startX + deltaX
                mainWindow.y = startY + deltaY
            }
        }
        titleBar.onUserMaximizesWindow: {
            mainWindow.showMaximized()
        }
        titleBar.onUserFullscreensWindow: {
            mainWindow.showFullScreen()
        }
        titleBar.onUserClosesWindow: {
            mainWindow.close()
        }
        titleBar.onUserNormalizesWindow: {
            mainWindow.showNormal()
        }
        titleBar.onUserMinimizesWindow: {
            mainWindow.flags = Qt.Window
            mainWindow.showMinimized()
            mainWindow.flags = Qt.Window | Qt.FramelessWindowHint | Qt.CustomizeWindowHint
                    | Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.WindowMinimizeButtonHint
        }
        property int resizeThreshold: 1
        function resetDragging() {
            mainWindow.startW = mainWindow.width
            mainWindow.startH = mainWindow.height
            mainWindow.startX = mainWindow.x
            mainWindow.startY = mainWindow.y
            mainWindow.draggingResetted = true
        }
        rResizer.onDraggingStarts: resetDragging()
        bResizer.onDraggingStarts: resetDragging()
        tResizer.onDraggingStarts: resetDragging()
        lResizer.onDraggingStarts: resetDragging()
        brResizer.onDraggingStarts: resetDragging()
        trResizer.onDraggingStarts: resetDragging()
        tlResizer.onDraggingStarts: resetDragging()
        blResizer.onDraggingStarts: resetDragging()
        rResizer.onDraggingStops: mainWindow.draggingResetted = false
        bResizer.onDraggingStops: mainWindow.draggingResetted = false
        brResizer.onDraggingStops: mainWindow.draggingResetted = false
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

    flags: Qt.Window | Qt.FramelessWindowHint | Qt.CustomizeWindowHint
           | Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.WindowMinimizeButtonHint
    //           | Qt.WA_TranslucentBackground
    //           | Qt.WA_OpaquePaintEvent
}
