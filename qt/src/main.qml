import Backend 1.0
import QtQuick 2.11

BrowserWindow {
    Component.onCompleted: {
        console.log("QML running on", Qt.platform.os)
    }
}
