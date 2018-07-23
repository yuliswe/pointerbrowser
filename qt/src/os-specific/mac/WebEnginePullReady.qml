import QtQuick 2.9
import QtQml 2.2
import QtWebEngine 1.5
import Backend 1.0
import QtQuick.Layouts 1.3

Timer {
    id: timer
    interval: 500
    repeat: true
    property WebEngineView target: parent
    property string debugName: ""
    onTriggered: {
        console.info(debugName, "pulling document ready..")
        target.runJavaScript("document.readyState", function(ready) {
            if (ready === "complete") {
                timer.onReady()
                timer.stop()
            }
        })
    }
    property var onReady: null
}
