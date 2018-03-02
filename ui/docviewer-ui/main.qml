import QtQuick 2.10
import QtQuick.Window 2.10

Window {
    id: mainWindow
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")
    MainWindow {
        anchors.fill: parent
    }
}
