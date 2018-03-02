import QtQuick 2.10
import QtQuick.Window 2.10

Window {
    id: mainWindow
    visible: true
    width: 1280
    height: 900
    title: qsTr("Hello World")
    MainWindow {
        anchors.fill: parent
    }
}
