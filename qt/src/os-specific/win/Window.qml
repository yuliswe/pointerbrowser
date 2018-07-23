import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.11
import Backend 1.0

Window {
    id: mainWindow
    visible: true
    width: 800
    height: 600
    minimumWidth: 200
    minimumHeight: 200
    readonly property var palette: active ? Palette.normal : Palette.disabled
    readonly property int contentTopMargin: 0

    color: palette.window_background
}
