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

    C.TextField {
        id: textField
        anchors.fill: parent
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
