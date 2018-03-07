import QtQuick 2.9
import QtQuick.Window 2.3

Window {
    id: mainWindow
    visible: true
    property int startX: -1
    property int startY: -1
    property int startW: -1
    property int startH: -1
    property bool draggingResetted: false
    MainWindowForm {
        id: form
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
        }
        titleBar.onUserDraggingTitleBar: {
            if (mainWindow.draggingResetted) {
                mainWindow.x = startX + deltaX
                mainWindow.y = startY + deltaY
            }
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
                mainWindow.width = startW + deltaX
                mainWindow.height = startH + deltaY
            }
        }
//        resizer.cursorShape: {
//            if (Math.abs(resizer.mouseX - resizer.width) < resizeThreshold
//                    || Math.abs(resizer.mouseX) < resizeThreshold) {
//                return Qt.SizeHorCursor
//            }
//            if (Math.abs(resizer.mouseY - resizer.height) < resizeThreshold
//                  || Math.abs(resizer.mouseY) < resizeThreshold) {
//              return Qt.SizeVerCursor
//          }
//        }
        resizer.hoverEnabled: true
        resizer.cursorShape: Qt.WaitCursor
        resizer.onMouseXChanged: {
//            resizer.cursorShape = Qt.SizeHorCursor
//            if (Math.abs(resizer.mouseX - resizer.width) < resizeThreshold
//                    || Math.abs(resizer.mouseX) < resizeThreshold) {
//                resizer.cursorShape = Qt.SizeHorCursor
//            }
//            console.log("here", resizer.mouseX, resizer.width)
        }
    }

    flags: Qt.Window
           | Qt.FramelessWindowHint
           | Qt.CustomizeWindowHint
           | Qt.WindowTitleHint
           | Qt.WindowCloseButtonHint
           | Qt.WA_TranslucentBackground
}
