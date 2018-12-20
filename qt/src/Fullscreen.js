//*
var elementStyle = '.-pointerbrowser-fullscreen-video { visibility:visible!important; top:0!important; bottom:0!important; left:0!important; right:0!important; position:fixed!important; z-index: 2147483647!important; width:100vw!important; height:100vh!important; background-color:#000!important; }';
var bodyStyle = '.-pointerbrowser-fullscreen-body { overflow:hidden!important; }';
var htmlStyle = '.-pointerbrowser-fullscreen-html { overflow:hidden!important; }';
var otherElementStyle = '.-pointerbrowser-fullscreen-other { visibility:hidden!important; overflow:visible!important; }';
var style = document.createElement('style');
style.innerHTML = [elementStyle, bodyStyle, htmlStyle, otherElementStyle].join(" ");

document.addEventListener("DOMContentLoaded", function() {
   document.head.appendChild(style);
});
//*/

document.fullscreenEnabled = true;
document.webkitFullscreenEnabled = true;
document.mozFullScreenEnabled = true;

Element.prototype.requestFullscreen = function() {
    var element = this;

    return new Promise(function(resolve, reject) {

        if (window.webkit !== undefined) {
            window.webkit.messageHandlers.pointerbrowser.postMessage("requestFullscreen");
        }

        document.fullscreen = true;
        document.webkitIsFullScreen = true;
        document.mozFullScreen = true;

        document.fullscreenElement = element;
        document.webkitFullscreenElement = element;
        document.mozFullscreenElement = element;

        element.classList.add("-pointerbrowser-fullscreen-element");
        var htmlVideo = document.querySelector(".-pointerbrowser-fullscreen-element video");
        htmlVideo.classList.add("-pointerbrowser-fullscreen-video");

        // now make sure controls are shown
        {
            htmlVideo.setAttribute("controls","controls");
            // Options for the observer (which mutations to observe)
            var config = { attributes: true };

            // Callback function to execute when mutations are observed
            var callback = function(mutationsList, observer) {
                if (! document.fullscreen) { return; }
                for(var mutation of mutationsList) {
                    if (mutation.type === "attributes"
                            && mutation.attributeName === "controls"
                            && mutation.target.getAttribute("controls") !== "controls")
                    {
                        htmlVideo.setAttribute("controls","controls");
                    }
                }
            };

            // Create an observer instance linked to the callback function
            var observer = new MutationObserver(callback);

            // Start observing the target node for configured mutations
            observer.observe(htmlVideo, config);

            document.pointerbrowser_fullscreen_observer = observer;
        }
        // listen to escape key
        {
            document.onkeyup = function(evt) {
                if (evt.key === "Escape") {
                    document.exitFullscreen();
                }
            }
        }
        {
            window.onbeforeunload = function(event) {
                document.exitFullscreen();
            }
        }


        document.body.classList.add("-pointerbrowser-fullscreen-body");
        document.documentElement.classList.add("-pointerbrowser-fullscreen-html");
        var allElements = document.querySelectorAll("body *");
        for (var i = allElements.length - 1; i >= 0; i--) {
            var e = allElements[i];
            if (e !== htmlVideo) {
                e.classList.add("-pointerbrowser-fullscreen-other");
            }
        }

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

        // start video
        htmlVideo.play();
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

        // remove video controls
        {
            document.pointerbrowser_fullscreen_observer.disconnect();
            document.pointerbrowser_fullscreen_observer.takeRecords();
            var htmlVideo = document.querySelector(".-pointerbrowser-fullscreen-video");
            while (htmlVideo.getAttribute("controls") === "controls") {
                htmlVideo.removeAttribute("controls");
            }
        }
        // remove all classes
        {
            var allElements = document.querySelectorAll(".-pointerbrowser-fullscreen-other, .-pointerbrowser-fullscreen-video, .-pointerbrowser-fullscreen-body, .-pointerbrowser-fullscreen-html");
            for (var i = allElements.length - 1; i >= 0; i--) {
                var e = allElements[i];
                e.classList.remove("-pointerbrowser-fullscreen-video");
                e.classList.remove("-pointerbrowser-fullscreen-body");
                e.classList.remove("-pointerbrowser-fullscreen-html");
                e.classList.remove("-pointerbrowser-fullscreen-other");
            }
        }

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

        if (window.webkit !== undefined) {
            window.webkit.messageHandlers.pointerbrowser.postMessage("exitFullscreen");
        }
    });
}
Document.prototype.webkitExitFullscreen = Document.prototype.exitFullscreen;
Document.prototype.mozCancelFullScreen = Document.prototype.exitFullscreen;
