import QtQuick 2.4
import QtWebView 1.1
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import Backend 1.0

Item {
    property alias stackLayout: stackLayout
    property alias repeater: repeater
    property alias repeaterListModel: listModel
    property alias repeaterDelegate: repeater.delegate
    StackLayout {
        id: stackLayout
        anchors.fill: parent

        Repeater {
            id: repeater
            model: ListModel {
                id: listModel
            }
        }
    }
}
