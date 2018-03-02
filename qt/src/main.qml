import Backend 1.0
import QtQuick 2.9
BrowserWindow {
    Component.onCompleted: {
        console.log("QML running on", Qt.platform.os)
    }
}
