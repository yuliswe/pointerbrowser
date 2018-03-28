import QtQuick 2.9

TabsListTabForm {
    id: form
    property bool showCloseButton: true
    closeButton.visible: hovered && showCloseButton
    signal userClosesTab()
    closeButton.onClicked: {
        form.userClosesTab()
    }
}
