import QtQuick 2.7
import Backend 1.0
import QtQuick.Controls 2.2
import "controls"

Window {
    title: qsTr("DOCVIEWER")
    id: browserWindow

    Browser {
        id: browser
        anchors.fill: parent
        anchors.topMargin: contentTopMargin
    }
}
