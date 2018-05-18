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
    default property var body

    FramelessWindowForm {
        id: form
        loader.sourceComponent: body
        active: mainWindow.active
        width: mainWindow.width
        height: mainWindow.height
    }
}
