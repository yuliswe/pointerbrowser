/*
var elementStyle = '.-pointerbrowser-fullscreen-element { left:0; right:0; position:fixed; z-index: 2147483647; }';
var bodyStyle = '.-pointerbrowser-fullscreen-body { overflow: hidden; z-index: 0 !important; }';
var backgroundStyle = '.-pointerbrowser-fullscreen-background { background-color: #000; left:0; top:0; right:0; bottom:0; position:fixed; }';
var otherElementStyle = '.-pointerbrowser-fullscreen-other-element { position:unset !important; z-index: 9 !important; }';
var style = document.createElement('style');
style.innerHTML = [elementStyle, bodyStyle, backgroundStyle, otherElementStyle].join(" ");

document.addEventListener("DOMContentLoaded", function() {
   document.head.appendChild(style);
});
*/

document.fullscreenEnabled = true;
document.webkitFullscreenEnabled = true;
document.mozFullScreenEnabled = true;

Element.prototype.requestFullscreen = function() {
    var element = this;

    return new Promise(function(resolve, reject) {

        document.fullscreen = true;
        document.webkitIsFullScreen = true;
        document.mozFullScreen = true;

        document.fullscreenElement = element;
        document.webkitFullscreenElement = element;
        document.mozFullscreenElement = element;

        if (window.webkit !== undefined) {
            window.webkit.messageHandlers.pointerbrowser.postMessage("requestFullscreen");
        }

        /*
        element.classList.add("-pointerbrowser-fullscreen-element");
        document.body.classList.add("-pointerbrowser-fullscreen-body");
        var allElements = document.querySelectorAll("body *");
        for (var i = allElements.length - 1; i >= 0; i--) {
            var e = allElements[i];
            if (e !== document.body && e !== element) {
                if (getComputedStyle(e).position === "fixed") {
                    e.classList.add("-pointerbrowser-fullscreen-other-element");
                }
            }
        }
        var background = document.createElement("DIV");
        background.className = "-pointerbrowser-fullscreen-background";
        document.body.appendChild(background);
        */

        var event = new Event("fullscreenchange");
        event.target = element;
        event.srcElement = element;
        document.dispatchEvent(event);

        var webkitEvent = new Event("webkitfullscreenchange");
        webkitEvent.target = element;
        webkitEvent.srcElement = element;
        document.dispatchEvent(webkitEvent);

        var mozEvent = new Event("mozfullscreenchange");
        mozEvent.target = element;
        mozEvent.srcElement = element;
        document.dispatchEvent(mozEvent);

        // fire resize event
        window.dispatchEvent(new Event('resize'));

        resolve();
    });
}
Element.prototype.webkitRequestFullscreen = Element.prototype.requestFullscreen;
Element.prototype.mozRequestFullScreen = Element.prototype.requestFullscreen;

Document.prototype.exitFullscreen = function() {
    var element = document.fullscreenElement;

    return new Promise(function(resolve, reject) {

        document.fullscreen = false;
        document.webkitIsFullScreen = false;
        document.mozFullScreen = false;

        document.fullscreenElement = null;
        document.webkitFullscreenElement = null;
        document.mozFullscreenElement = null;

        if (window.webkit !== undefined) {
            window.webkit.messageHandlers.pointerbrowser.postMessage("exitFullscreen");
        }

        /*
        element.classList.remove("-pointerbrowser-fullscreen-element");
        document.body.classList.remove("-pointerbrowser-fullscreen-body");
        var allElements = document.querySelectorAll("body *");
        for (var i = allElements.length - 1; i >= 0; i--) {
            var e = allElements[i];
            e.classList.remove("-pointerbrowser-fullscreen-other-element");
        }
        */

        var event = new Event("fullscreenchange");
        event.target = element;
        event.srcElement = element;
        document.dispatchEvent(event);

        var webkitEvent = new Event("webkitfullscreenchange");
        webkitEvent.target = element;
        webkitEvent.srcElement = element;
        document.dispatchEvent(webkitEvent);

        var mozEvent = new Event("mozfullscreenchange");
        mozEvent.target = element;
        mozEvent.srcElement = element;
        document.dispatchEvent(mozEvent);

        // fire resize event
        window.dispatchEvent(new Event('resize'));

        resolve();
    });
}
Document.prototype.webkitExitFullscreen = Document.prototype.exitFullscreen;
Document.prototype.mozCancelFullScreen = Document.prototype.exitFullscreen;
