import QtQuick 2.7
import Backend 1.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4

BusyIndicator {
    id: busyIndicator
    running: true
    visible: animation.running
    height: 25
    width: 25
    property int recH: 5
    property int recW: 2
    property string color: ""
    property int t: 0
    readonly property int bound: busyIndicator.height - recH
    onRunningChanged: {
        if (running) {
            phaseIn.restart()
            animation.restart()
        } else {
            animation.stop()
        }
    }
    NumberAnimation {
        id: phaseIn
        target: busyIndicator
        property: "opacity"
        from: 0
        to: 1
        duration: 1000
        easing.type: Easing.InExpo
    }
    NumberAnimation {
        id: animation
        target: busyIndicator
        property: "t"
        duration: 500
        loops: Animation.Infinite
        from: -Math.PI
        to: Math.PI
    }
    contentItem: Row {
        anchors.fill: parent
        spacing: 1.5 * busyIndicator.recW
        Rectangle {
            id: rec1
            width: recW
            height: recH
            color: busyIndicator.color
            Behavior on y { PropertyAnimation {} }
            y: (Math.cos(t) + 1) * bound / 2
        }
        Rectangle {
            id: rec2
            width: recW
            height: recH
            color: busyIndicator.color
            Behavior on y { PropertyAnimation {} }
            y: (Math.cos(t + Math.PI/2) + 1) * bound / 2
        }
        Rectangle {
            id: rec3
            width: recW
            height: recH
            color: busyIndicator.color
            Behavior on y { PropertyAnimation {} }
            y: (Math.cos(t + Math.PI) + 1) * bound / 2
        }
    }
}
