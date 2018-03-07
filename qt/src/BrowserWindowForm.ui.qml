import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.3
import "controls" as C

C.FramelessWindow {
    id: mainWindow
    sourceComponent: c
    SystemPalette {
        id: activePalette
        colorGroup: SystemPalette.Active
    }

    titleBar.rectangle.color: activePalette.button
    titleBar.rectangle.opacity: 0.95
}
