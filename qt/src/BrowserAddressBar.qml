import QtQuick 2.7
import QtQuick.Controls 2.2
import "controls" as C
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 1.4 as C1
import Backend 1.0

Item {
    id: form
    property string url: ""
    property string title: ""
    property int progress: 0
    signal userEntersUrl(string url)

    state: Qt.platform.os

    onUrlChanged: update(url, title)
    onTitleChanged: update(url, title)
    onProgressChanged: updateProgress(progress)

    //    property alias titleDisplay: titleDisplay
    C.TextField {
        id: textField
        horizontalAlignment: Text.AlignHCenter
        anchors.fill: parent
        onAccepted: {
            var url = textField.text
            var exp = new RegExp(".+://")
            if (!exp.test(url)) {
                url = "http://www.google.com/search?q=" + encodeURIComponent(url)
            }
            textField.focus = false
            console.log("userEntersUrl", url)
            userEntersUrl(url)
        }
        onActiveFocusChanged: {
            if (textField.activeFocus) {
                //            textField.horizontalAlignment = Text.AlignHCenter
                textField.color = Palette.selected.input_text
                textField.text = form.url
                if (Qt.platform.os != "ios") {
                    textField.ensureVisible(0)
                }
                textField.selectAll()
            } else {
                textField.deselect()
                //            textField.horizontalAlignment = Text.AlignHCenter
                textField.text = ""
                textField.placeholderText = form.title || form.url
                //            textField.color = "transparent"
            }
        }
        placeholder {
            color: textField.color
            opacity: 0.8
        }
    }

    Rectangle {
        id: progressBar
        color: "green"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        radius: textField.rectangle.radius
        width: 0
        opacity: 0.3

        Behavior on width {
            id: barWidthAnimation
            enabled: progress < 100
            SmoothedAnimation {
                duration: 100
                velocity: -1
            }
        }

        PropertyAnimation {
            id: fadeProgress
            target: progressBar
            properties: "opacity"
            to: 0
            duration: 1000
            alwaysRunToEnd: false
        }
    }

    function update(url, title) {
        console.log("addressBar update", url, title)
        if (title !== "") {
            textField.placeholderText = title
        } else {
            textField.placeholderText = url
        }
    }

    function updateProgress(progress) {
        console.log("addressbar updateProgress", progress)
        var w = Math.max(10,progress)/100 * textField.width
        if (progressBar.width >= w) {
            barWidthAnimation.enabled = false
            progressBar.opacity = 0
            progressBar.width = w
            fadeProgress.stop()
            return
        }
        barWidthAnimation.enabled = true
        progressBar.opacity = 0.3
        progressBar.width = w
        if (progress === 100) {
            fadeProgress.restart()
        } else {
            fadeProgress.stop()
        }
    }

    Shortcut {
        sequence: "Ctrl+E"
        autoRepeat: false
        onActivated: {
            textField.forceActiveFocus()
            textField.selectAll()
        }
    }
    states: [
        State {
            name: "windows"

            PropertyChanges {
                target: textField
                placeholder.opacity: 0.5
            }
        }
    ]

}
