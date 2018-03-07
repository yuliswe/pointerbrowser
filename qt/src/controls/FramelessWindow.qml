import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Window 2.3

Window {
    id: mainWindow
    visible: true
    width: 800
    height: 600
    minimumWidth: 50
    minimumHeight: 50
    property alias titleBar: form.titleBar
    property alias resizer: form.resizer
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
        Keys.onPressed: main.currentKeyPress = event.key
        Keys.onReleased: main.currentKeyPress = -1
        width: mainWindow.width
        height: mainWindow.height
        focus: true
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
            mainWindow.flags = Qt.Window
                    | Qt.FramelessWindowHint
                    | Qt.CustomizeWindowHint
                    | Qt.WindowTitleHint
                    | Qt.WindowCloseButtonHint
                    | Qt.WindowMinimizeButtonHint
        }
        property int resizeThreshold: 10
        resizer.onDraggingStarts: {
            mainWindow.startW = mainWindow.width
            mainWindow.startH = mainWindow.height
            mainWindow.draggingResetted = true
        }
        resizer.onDraggingStops: {
            mainWindow.draggingResetted = false
        }
        resizer.onDragging: {
            if (mainWindow.draggingResetted) {
                if (startW + deltaX >= minimumWidth) {
                    mainWindow.width = startW + deltaX
                }
                if (startH + deltaY >= minimumHeight) {
                    mainWindow.height = startH + deltaY
                }
            }
        }
        resizer.cursorShape: {
            if (Math.abs(resizer.mouseY - resizer.height) < resizeThreshold
                  && Math.abs(resizer.mouseY - resizer.height) < resizeThreshold) {
              return Qt.SizeFDiagCursor
          }
            if (Math.abs(resizer.mouseX - resizer.width) < resizeThreshold
                    || Math.abs(resizer.mouseX) < resizeThreshold) {
                return Qt.SplitHCursor
            }
            if (Math.abs(resizer.mouseY - resizer.height) < resizeThreshold
                  || Math.abs(resizer.mouseY) < resizeThreshold) {
              return Qt.SplitVCursor
          }
        }
        resizer.hoverEnabled: true
    }

    flags: Qt.Window
           | Qt.FramelessWindowHint
           | Qt.CustomizeWindowHint
           | Qt.WindowTitleHint
           | Qt.WindowCloseButtonHint
           | Qt.WindowMinimizeButtonHint
//           | Qt.WA_TranslucentBackground
//           | Qt.WA_OpaquePaintEvent
}
