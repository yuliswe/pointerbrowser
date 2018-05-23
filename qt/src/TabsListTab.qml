import QtQuick 2.7

TabsListTabForm {
    id: form
    signal userClosesTab()
    closeButton.onClicked: {
        form.userClosesTab()
    }
    displayText: (model.title || model.url || "Loading")
}
