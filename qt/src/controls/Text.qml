import QtQuick 2.7
import QtQuick.Templates 2.2 as T

Text {
    renderType: (Qt.platform.os == "win" ? Text.NativeRendering : Text.QtRendering)
}
