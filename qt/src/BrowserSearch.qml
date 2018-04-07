import QtQuick 2.4

BrowserSearchForm {
    signal userSearchesWordInBrowser(string word)
    signal userSearchesNextInBrowser()
    signal userSearchesPreviousInBrowser()
    function updateCount(count) {
        highlightCount = count
        console.log("updateCount " + highlightCount)
    }
    function updateCurrent(current) {
        currentHighlight = current
        console.log("updateCurrent " + currentHighlight)
    }
    function current() {
        return currentHighlight;
    }
    function count() {
        return highlightCount;
    }
//    function lock() {
//        locked = true
//    }
//    function unlock() {
//        locked = false
//    }
    property bool locked: false
    id: form
    textfield.onAccepted: {
        if (locked) {
            userSearchesNextInBrowser()
        } else {
            userSearchesWordInBrowser(textfield.text)
            updateCount(0)
            updateCurrent(-1)
        }
        locked = true
        console.log("userSearchesWordInBrowser", textfield.text)
    }
    textfield.onTextEdited: {
        locked = false
        updateCount(0)
        updateCurrent(-1)
    }
    prevBtn.onClicked: {
        userSearchesPreviousInBrowser()
        console.log("userSearchesPreviousInBrowser")
    }
    nextBtn.onClicked: {
        userSearchesNextInBrowser()
        console.log("userSearchesNextInBrowser")
    }
}
