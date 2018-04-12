import QtQuick 2.9
import QtQuick.Window 2.10
import QtQuick.Controls 2.2
import Backend 1.0
import "controls"

Item {
    id: main
    visible: true
    BrowserWindow {
    }

    Shortcut {
        sequence: "Ctrl"
        onActivated: {
            console.log("qml test Ctrl pressed")
        }
    }//
}
