import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 1.4 as C1

Item {
    id: browserAddressBar
    property alias textField: textField
    property alias text: textField.text
    property alias progress: progressBar.value
    property alias progressBar: progressBar
    property string url: "url"
    property string title: "title"
    property alias progressBarOpacity: progressBar.opacity
    property alias progressBarWidth: green.width

    TextField {
        id: textField
        anchors.fill: parent

        ProgressBar {
            id: progressBar
            anchors.fill: parent
            opacity: 0.3
            value: 10
            from: 0
            to: 100
            contentItem: Rectangle {
                id: green
                color: "green"
                width: progressBar.visualPosition * textField.width
                height: progressBar.height
            }
            background: Item {
            }
        }
    }
}
