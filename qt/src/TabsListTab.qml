import QtQuick 2.9

TabsListTabForm {
    id: form
    highlighted: ListView.isCurrentItem
    closeButton.visible: hovered
    signal userClosesTab()
    closeButton.onClicked: {
        form.userClosesTab()
    }
}
