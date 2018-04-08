import QtQuick 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3

RoundButton {
    id: btn

    SystemPalette {
        id: inactPal
        colorGroup: SystemPalette.Inactive
    }

    property string activeColor: "#ff5555"
    property string activeBorderColor: "#dc0000"
    property string inactiveColor: inactPal.button
    property string inactiveBorderColor: inactPal.mid
    property bool active: true
    hoverEnabled: true
    padding: 3
    Layout.maximumHeight: 14
    Layout.maximumWidth: 14
    background: Rectangle {
        id: bk
        radius: parent.height / 2
        //        height: width
        //        width: 10
        color: active ? activeColor : inactiveColor
        border.color: active ? activeBorderColor : inactiveBorderColor
    }

    icon {
        source: "icon/cross.svg"
        color: btn.hovered ? "#000" : btn.background.color
        height: 5
        width: 5
    }
}
