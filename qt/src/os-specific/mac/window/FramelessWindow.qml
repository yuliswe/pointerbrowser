import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Window 2.2
import Backend 1.0

Window {
    id: mainWindow
    visible: true
    width: 800
    height: 600
    minimumWidth: 200
    minimumHeight: 200
    property int startX: -1
    property int startY: -1
    property int startW: -1
    property int startH: -1
    property bool draggingResetted: false
    default property var body

    //    property var delegate: null
    //        color: "green"
    color: "#00000000"

    readonly property int customFlags: {
        return Qt.Window | Qt.FramelessWindowHint
    }

    property bool resizing: false

    flags: customFlags

    property int prevVisibility: Window.Hidden

    Timer {
        id: resizingTimeout
        onTriggered: resizing = false
        triggeredOnStart: false
        interval: 0
    }

    function maximizeWindow() {
        resizing = true
        mainWindow.showMaximized()
        resizingTimeout.restart()
    }

    function minimizeWindow() {
        resizing = true
        mainWindow.showMinimized()
        resizingTimeout.restart()
    }

    function normalizeWindow() {
        resizing = true
        mainWindow.showNormal()
        resizingTimeout.restart()
    }

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
        if (Qt.platform.os == 'osx') {
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
    }

    property int resizerThreshold: 5

    readonly property var palette: active ? Palette.selected : Palette.normal

    Draggable {
        id: vertiTSizer
        height: resizerThreshold
        hoverEnabled: true
        anchors.rightMargin: 0
        anchors.leftMargin: 0
        z: 2
        cursorShape: Qt.SplitVCursor
        anchors.right: diagTRSizer.left
        anchors.left: diagTLSizer.right
        anchors.top: parent.top
        onDraggingStarts: resetDragging()
        onDraggingStops: stopDragging()
        onDragging: {
            if (mainWindow.draggingResetted) {
                if (startH + deltaY >= minimumHeight) {
                    mainWindow.height = startH - deltaY
                    mainWindow.y = startY + deltaY
                }
            }
        }
    }

    Draggable {
        id: horiLSizer
        width: resizerThreshold
        anchors.bottomMargin: 0
        anchors.topMargin: 0
        hoverEnabled: true
        z: 2
        cursorShape: Qt.SplitHCursor
        anchors.top: diagTLSizer.bottom
        anchors.bottom: diagBLSizer.top
        anchors.left: parent.left
        onDraggingStarts: resetDragging()
        onDraggingStops: stopDragging()
        onDragging: {
            if (mainWindow.draggingResetted) {
                if (startW - deltaX >= minimumWidth) {
                    mainWindow.x = startX + deltaX
                    mainWindow.width = startW - deltaX
                }
            }
        }
    }

    Draggable {
        id: vertiBSizer
        height: resizerThreshold
        hoverEnabled: true
        anchors.rightMargin: 0
        anchors.leftMargin: 0
        anchors.right: diagBRSizer.left
        anchors.left: diagBLSizer.right
        anchors.bottom: parent.bottom
        z: 2
        cursorShape: Qt.SplitVCursor
        onDraggingStarts: resetDragging()
        onDraggingStops: stopDragging()
        onDragging: {
            if (mainWindow.draggingResetted) {
                if (startH + deltaY >= minimumHeight) {
                    mainWindow.height = startH + deltaY
                }
            }
        }
    }

    Draggable {
        id: horiRSizer
        y: 0
        width: resizerThreshold
        hoverEnabled: true
        anchors.bottomMargin: 0
        anchors.topMargin: 0
        anchors.bottom: diagBRSizer.top
        anchors.top: diagTRSizer.bottom
        anchors.right: parent.right
        z: 2
        cursorShape: Qt.SplitHCursor
        onDraggingStarts: resetDragging()
        onDraggingStops: stopDragging()
        onDragging: {
            if (mainWindow.draggingResetted) {
                if (startW + deltaX >= minimumWidth) {
                    mainWindow.width = startW + deltaX
                }
            }
        }
    }

    Draggable {
        id: diagBRSizer
        width: resizerThreshold * 2
        height: resizerThreshold * 2
        hoverEnabled: true
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        z: 2
        cursorShape: Qt.SizeFDiagCursor
        onDraggingStarts: resetDragging()
        onDraggingStops: stopDragging()
        onDragging: {
            if (mainWindow.draggingResetted) {
                if (startW + deltaX >= minimumWidth) {
                    mainWindow.width = startW + deltaX
                }
                if (startH + deltaY >= minimumHeight) {
                    mainWindow.height = startH + deltaY
                }
            }
        }
    }

    Draggable {
        id: diagTLSizer
        width: resizerThreshold * 2
        height: resizerThreshold * 2
        hoverEnabled: true
        z: 2
        cursorShape: Qt.SizeFDiagCursor
        anchors.left: parent.left
        anchors.top: parent.top
        onDraggingStarts: resetDragging()
        onDraggingStops: stopDragging()
        onDragging: {
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
    }

    Draggable {
        id: diagBLSizer
        width: resizerThreshold * 2
        height: resizerThreshold * 2
        hoverEnabled: true
        z: 2
        cursorShape: Qt.SizeBDiagCursor
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        onDraggingStarts: resetDragging()
        onDraggingStops: stopDragging()
        onDragging: {
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
    }

    Draggable {
        id: diagTRSizer
        width: resizerThreshold * 2
        height: resizerThreshold * 2
        hoverEnabled: true
        z: 2
        cursorShape: Qt.SizeBDiagCursor
        anchors.right: parent.right
        anchors.top: parent.top
        onDraggingStarts: resetDragging()
        onDraggingStops: stopDragging()
        onDragging: {
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


    Rectangle {
        TitleBar {
            id: titleBar
            height: 20
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            onUserStopsDraggingTitleBar: stopDragging()
            onUserStartsDraggingTitleBar: {
                console.log("onUserStartsDraggingTitleBar")
                mainWindow.startX = mainWindow.x
                mainWindow.startY = mainWindow.y
                mainWindow.draggingResetted = true
            }
            onUserDraggingTitleBar: {
                console.log("onUserDraggingTitleBar", deltaX, deltaY)
                if (mainWindow.draggingResetted) {
                    mainWindow.x = mainWindow.startX + deltaX
                    mainWindow.y = mainWindow.startY + deltaY
                    if (mainWindow.y > 0 && mainWindow.startY + deltaY < -mainWindow.height/2) {
                        mainWindow.y = -mainWindow.height
                        mainWindow.y = -mainWindow.height / 2 - 1
                    }
                }
            }
            onUserMaximizesWindow: {
                switch (mainWindow.visibility) {
                case Window.FullScreen:
                    normalizeWindow()
                    //                macosRenderBugFix()
                    break
                default:
                    mainWindow.showFullScreen()
                }
            }
            onUserDoubleClicksTitleBar: {
                switch (mainWindow.visibility) {
                case Window.Maximized:
                    normalizeWindow()
                    break
                default:
                    maximizeWindow()
                }
                macosRenderBugFix()
            }
            onUserClosesWindow: {
                mainWindow.close()
            }
            onUserMinimizesWindow: {
                if (Qt.platform.os === 'osx') {
                    mainWindow.flags = Qt.Window | Qt.CustomizeWindowHint | Qt.WindowMinMaxButtonsHint
                }
                minimizeWindow()
            }
        }

        color: palette.window_background
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        Loader {
            id: loader
            anchors.fill: parent
            anchors.topMargin: titleBar.height
            sourceComponent: mainWindow.body
        }
        radius: 4
    }

    function macosRenderBugFix() {
        mainWindow.visible = false
        mainWindow.visible = true
    }
    // control buttons
    Timer {
        id: afterFullscreened
        triggeredOnStart: false
        interval: 500
        repeat: false
        running: mainWindow.visibility == Window.FullScreen
        onTriggered: {
            titleBar.hideTitleBar()
        }
    }
    // Resizers
    property int resizeThreshold: 1
    function resetDragging() {
        mainWindow.startW = mainWindow.width
        mainWindow.startH = mainWindow.height
        mainWindow.startX = mainWindow.x
        mainWindow.startY = mainWindow.y
        mainWindow.draggingResetted = true
        mainWindow.resizing = true
    }
    function stopDragging() {
        mainWindow.draggingResetted = false
        mainWindow.resizing = false
        macosRenderBugFix()
    }
}
