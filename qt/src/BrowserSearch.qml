import QtQuick 2.7

BrowserSearchForm {
    //    signal userSearchesWordInBrowser(string word)
    signal userSearchesNextInBrowser(string text)
    signal userSearchesPreviousInBrowser(string text)
    signal userClosesSearch()
    signal userTypesInSearch(string text)
    function setText(t) {
        textfield.text = t
    }
    function updateCount(count) {
        highlightCount = count
        console.log("updateCount " + highlightCount)
    }
    function updateCurrent(current) {
        currentHighlight = current
        console.log("updateCurrent " + currentHighlight)
    }

    function setResult(current, count) {
        updateCount(count)
        updateCurrent(current)
    }

    function current() {
        return currentHighlight;
    }
    function count() {
        return highlightCount;
    }
    function hideCount() {
        counter.visible = false
    }
    function showCount() {
        counter.visible = true
    }
    property bool locked: false
    id: form
    counter.visible: false
    textfield.onAccepted: {
        userSearchesNextInBrowser(textfield.text)
    }
    textfield.onTextChanged: {
        userTypesInSearch(textfield.text)
    }
    prevBtn.onClicked: {
        userSearchesPreviousInBrowser(textfield.text)
        console.log("userSearchesPreviousInBrowser")
    }
    nextBtn.onClicked: {
        userSearchesNextInBrowser(textfield.text)
        console.log("userSearchesNextInBrowser")
    }
    closeBtn.onClicked: {
        userClosesSearch()
    }
}
