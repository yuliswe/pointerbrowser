import QtQuick 2.9

TabsListTabForm {
    id: form
    signal userClosesTab()
    closeButton.onClicked: {
        form.userClosesTab()
    }
}
