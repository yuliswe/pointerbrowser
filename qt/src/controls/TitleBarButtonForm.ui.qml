import QtQuick 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3

RoundButton {

    SystemPalette {
        id: inactPal
        colorGroup: SystemPalette.Inactive
    }

    property string activeColor: "#ff5555"
    property string activeBorderColor: "#dc0000"
    property string inactiveColor: inactPal.button
    property string inactiveBorderColor: inactPal.mid
    property string hoverText: "x"
    property bool active: false
    hoverEnabled: true
    id: btn
    width: 10
    height: 10
    text: hovered ? hoverText : ""
    focusPolicy: Qt.StrongFocus
    font.bold: true
    font.pointSize: 10
    Layout.maximumHeight: 14
    Layout.maximumWidth: 14
    background: Rectangle {
        id: bk
        radius: 14
        color: active ? activeColor : inactiveColor
        border.color: active ? activeBorderColor : inactiveBorderColor
    }
}
