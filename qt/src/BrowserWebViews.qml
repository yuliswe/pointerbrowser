import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQml 2.2
import QtWebEngine 1.5
import Backend 1.0

Item {
    id: browserWebViews

    function userRequestsNewView(request) {
        if (request.userInitiated || request.destination === WebEngineView.NewViewInBackgroundTab) {
            BrowserController.newTab(BrowserController.TabStateOpen,
                                     request.requestedUrl,
                                     BrowserController.WhenCreatedStayOnCurrent,
                                     BrowserController.WhenExistsViewExisting);
            open_repeater.itemAt(0).handleNewViewRequest(request)
        } else {
            BrowserController.newTab(BrowserController.TabStateOpen,
                                     request.requestedUrl,
                                     BrowserController.WhenCreatedSwitchToView,
                                     BrowserController.WhenExistsViewExisting);
            open_repeater.itemAt(0).handleNewViewRequest(request)
        }
    }

    readonly property WebUI currentWebUI: {
        if (BrowserController.current_tab_state === BrowserController.TabStateOpen) {
            return open_repeater.itemAt(BrowserController.current_open_tab_index)
        }
        if (BrowserController.current_tab_state === BrowserController.TabStatePreview) {
            return preview_repeater.itemAt(BrowserController.current_preview_tab_index)
        }
        return null;
    }

    property alias crawler: crawler
    property int loadProgress: currentWebUI ? currentWebUI.loadProgress : 0

    onLoadProgressChanged: {
        BrowserController.address_bar_load_progress = loadProgress;
    }

    Crawler {
        id: crawler
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: BrowserController.current_open_tab_index
        visible: BrowserController.current_tab_state === BrowserController.TabStateOpen
        Repeater {
            id: open_repeater
            model: BrowserController.open_tabs
            delegate: WebUI {
                width: parent.width
                height: parent.height
            }
        }
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: BrowserController.current_preview_tab_index
        visible: BrowserController.current_tab_state === BrowserController.TabStatePreview
        Repeater {
            id: preview_repeater
            model: BrowserController.preview_tabs
            delegate: WebUI {
                width: parent.width
                height: parent.height
            }
        }

    }

}

