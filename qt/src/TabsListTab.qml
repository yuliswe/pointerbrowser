import QtQuick 2.9

TabsListTabForm {
    id: form
    closeButton.visible: hovered
    signal userClosesTab()
    closeButton.onClicked: {
        form.userClosesTab()
    }
}
