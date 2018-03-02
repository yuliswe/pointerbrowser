function pointerEnableOpenLinkInNewWindow() {
    var all_links = document.getElementsByTagName('A');
    for (var link of all_links) {
        if (link._target === undefined) {
            link._target = link.target;
        }
        link.target = "_blank";
    }
}

function pointerDisableOpenLinkInNewWindow() {
    var all_links = document.getElementsByTagName('A');
    for (var link of all_links) {
        if (link._target === undefined) {
            link.target = "";
        } else {
            link.target = link._target;
        }
    }
}
