import QtQuick 2.7
import QtQuick.Controls 2.2
import "controls" as C
import QtQuick.Layouts 1.3
import Backend 1.0

Item {
    id: form
    property int progress: BrowserController.address_bar_load_progress
    signal userEntersUrl(string url)

    state: Qt.platform.os

    //    onUrlChanged: update(url, title)
    //    onTitleChanged: update(url, title)
    onProgressChanged: updateProgress(progress)


    //    property alias titleDisplay: titleDisplay

    Rectangle {
        id: progressBar
        color: Palette.normal.addressbar_progress
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        width: 0

        Behavior on width {
            id: barWidthAnimation
            enabled: progress < 100
            SmoothedAnimation {
                duration: 500
                alwaysRunToEnd: true
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

    C.TextField {
        id: textField
        horizontalAlignment: Text.AlignHCenter
        anchors.fill: parent
        property var pal: activeFocus ? Palette.selected : Palette.normal
        function makeUri(input) {
            var exp = new RegExp(".+://")
            if (!exp.test(input)) {
                return "http://www.google.com/search?q=" + encodeURIComponent(input)
            }
            return input;
        }
        placeholderText: (!BrowserController.current_tab_webpage) ? "Welcome" : (BrowserController.current_tab_webpage.title || BrowserController.current_tab_webpage.uri)
        onActiveFocusChanged: {
            if (textField.activeFocus) {
                textField.text = BrowserController.current_tab_webpage ? BrowserController.current_tab_webpage.uri : ""
                textField.ensureVisible(0)
                textField.selectAll()
            } else {
                textField.deselect()
                textField.text = ""
            }
        }
        color: pal.addressbar_text
        placeholder {
            color: pal.addressbar_text
        }
        Keys.onReturnPressed: {
            event.accepted = true
            var uri = makeUri(textField.text)
            textField.focus = false
            console.info("userEntersUri", uri)
            if (event.modifiers & Qt.ControlModifier) {
                BrowserController.newTab(BrowserController.TabStateOpen, uri, BrowserController.WhenCreatedViewNew, BrowserController.WhenExistsOpenNew)
            } else {
                BrowserController.newTab(BrowserController.TabStateOpen, uri)
            }

        }
    }

    Connections {
        target: BrowserController
    }

    function updateProgress(progress) {
        console.info("addressbar updateProgress", progress)
        var w = Math.max(10,progress)/100 * textField.width
        // if we are suddenly visiting a different tab
        // that has smaller load progress, we want to hide progress bar
        if (progressBar.width >= w) {
            barWidthAnimation.enabled = false
            progressBar.opacity = 0
            progressBar.width = w
            fadeProgress.stop()
            return
        }
        barWidthAnimation.enabled = true
        progressBar.opacity = 0.6
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

            PropertyChanges {
                target: progressBar
                radius: 0
            }
        },
        State {
            name: "osx"

            PropertyChanges {
                target: textField
                placeholder.opacity: 1
            }

            PropertyChanges {
                target: progressBar
                radius: 4
            }
        }
    ]

}
