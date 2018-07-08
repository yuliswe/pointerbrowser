import QtQuick 2.9
import Backend 1.0
import QtQuick.Controls 2.2
import "controls"

Window {
    id: browserWindow

    title: "Dereference"
    Browser {
        id: browser
        anchors.fill: parent
        anchors.topMargin: contentTopMargin
    }

    onActiveFocusItemChanged: {
        console.log("new active focus", activeFocusItem);
    }
    onScreenChanged: {
        console.log("Screen changed", JSON.stringify(screen))
    }
    Component.onCompleted: {
        console.log("Screen changed", JSON.stringify(screen))
    }
}
