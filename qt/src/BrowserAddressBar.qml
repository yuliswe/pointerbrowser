import QtQuick 2.9
import Backend 1.0

BrowserAddressBarForm {
    id: form
    property int progress: 0
    property string url: "url"
    property string title: "title"
    signal userEntersUrl(string url)

    progressBar.opacity: 0.3
    progressBar.width: 0

    function update(index) {
        form.url = TabsModel.tab(index).url
        form.title = TabsModel.tab(index).title
        console.log("update", form.url, form.title)
        if (title !== "") {
            titleDisplay.text = title
//            textField.horizontalAlignment = Text.AlignHCenter
        } else {
            titleDisplay.text = url
//            textField.horizontalAlignment = Text.AlignHCenter
//            textField.horizontalAlignment = Text.AlignLeft
            titleDisplay.ensureVisible(0)
        }
//        textField.focus = false
    }

    textField.onAccepted: {
        var url = textField.text
        var exp = new RegExp("http://|https://")
        if (!exp.test(url)) {
            url = "http://www.google.com/search?query=" + url
        }
        textField.focus = false
        userEntersUrl(url)
    }

    textField.onActiveFocusChanged: {
        if (textField.activeFocus) {
//            textField.horizontalAlignment = Text.AlignHCenter
            textField.text = form.url
            textField.ensureVisible(0)
            textField.selectAll()
        } else {
            textField.deselect()
//            textField.horizontalAlignment = Text.AlignHCenter
            textField.text = ""
        }
    }

    onProgressChanged: {
        if (progress === 0) {
            barWidthAnimation.enabled = true
            progressBar.opacity = 0.3
        } else if (progress === 100) {
            fadeProgress.start()
        } else {
        }
        var newW = progress/100 * textField.width
        progressBar.width = newW
        console.log("progress=", progress, "newW=",newW,"progressBar.width=",progressBar.width, "progressBar.opacity=", progressBar.opacity, "barWidthAnimation.enabled=", barWidthAnimation.enabled)
    }

    Behavior on progressBar.width {
        id: barWidthAnimation
        enabled: progress < 100
        SmoothedAnimation {
            duration: 100
        }
    }


    PropertyAnimation {
        id: fadeProgress
        target: progressBar
        properties: "opacity"
        to: 0
        duration: 1000
        onStopped: {
            progressBar.width = 0
        }
    }

    Shortcut {
        sequence: "Ctrl+E"
        autoRepeat: false
        onActivated: {
            textField.focus = true
            textField.selectAll()
        }
    }

}
