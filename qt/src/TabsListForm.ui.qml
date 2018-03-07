import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import Backend 1.0

ListView {
    id: listview
    property alias tabsListModel: listview.model
    model: ListModel {
        ListElement {
            url: "test"
            title: "test"
        }
        ListElement {
            url: "longlonglonglonglonglonglonglong"
            title: "longlonglonglonglonglonglonglong"
        }
    }
}
