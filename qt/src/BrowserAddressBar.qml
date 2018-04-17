import QtQuick 2.7
import Backend 1.0

BrowserAddressBarForm {
    id: form
    property string url: "url"
    property string title: "title"
    signal userEntersUrl(string url)

    progressBar.opacity: 0.3
    progressBar.width: 0

    function update(url, title) {
        form.title = title
        form.url = url
        console.log("update", form.url, form.title)
        if (title !== "") {
            titleDisplay.text = title
            //            textField.horizontalAlignment = Text.AlignHCenter
        } else {
            titleDisplay.text = url
            //            textField.horizontalAlignment = Text.AlignHCenter
            //            textField.horizontalAlignment = Text.AlignLeft
            //            titleDisplay.ensureVisible(0)
        }
        //        textField.focus = false
    }

    function updateProgress(progress) {
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


    textField.onAccepted: {
        var url = textField.text
        var exp = new RegExp("http://|https://")
        if (!exp.test(url)) {
            url = "http://www.google.com/search?q=" + url
        }
        textField.focus = false
        console.log("userEntersUrl", url)
        userEntersUrl(url)
    }

    textField.onActiveFocusChanged: {
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
            textField.color = "transparent"
        }
    }

    Behavior on progressBar.width {
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

    Shortcut {
        sequence: "Ctrl+E"
        autoRepeat: false
        onActivated: {
            textField.forceActiveFocus()
            textField.selectAll()
        }
    }

}
