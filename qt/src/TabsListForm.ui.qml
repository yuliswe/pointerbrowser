import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import Backend 1.0

ListView {
    id: listview
    property alias tabsModel: listview.model
    highlightFollowsCurrentItem: true
    snapMode: ListView.NoSnap
    boundsBehavior: Flickable.StopAtBounds
    interactive: true
    highlightRangeMode: ListView.NoHighlightRange
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
