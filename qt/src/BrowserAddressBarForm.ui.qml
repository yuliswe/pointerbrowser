import QtQuick 2.9
import QtQuick.Controls 2.3
import "controls" as C
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 1.4 as C1

Item {
    id: form
    property alias textField: textField
    property alias progressBar: progressBar
    property alias titleDisplay: titleDisplay

    SystemPalette {
        id: inaPal
        colorGroup: SystemPalette.Inactive
    }

    Rectangle {
        id: progressBar
        color: "green"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        width: 0.2 * textField.width // preview
        //                width: progressBar.value/100 * textField.width
    }

    Text {
        id: titleDisplay
        text: qsTr("Text")
        elide: Text.ElideRight
        clip: true
        rightPadding: 5
        leftPadding: 5
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.fill: parent
        color: inaPal.buttonText
    }

    C.TextField {
        id: textField
        horizontalAlignment: Text.AlignHCenter
        anchors.fill: parent

        //        ProgressBar {
        //            id: progressBar
        //            anchors.fill: parent
        //            value: 10
        //            from: 0
        //            to: 100
        //            contentItem:
        //            background: Item {
        //            }
        //        }
    }
}
