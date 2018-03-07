import QtQuick 2.4

BrowserWindowForm {
    sourceComponent: c
    Component {
        id: c
        Browser {
            id: browser
            anchors.fill: parent
            z: 1
        }
    }
}
