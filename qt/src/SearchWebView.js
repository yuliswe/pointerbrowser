
// We're using a global variable to store the number of occurrences
var pointerSearchResultCount = -1;

// helper function, recursively searches in elements and their child nodes
function pointerHighlightAllOccurencesOfStringForElement(element,keyword) {
    if (! keyword) {
        return;
    }
    if (element) {
        if (element.nodeType === 3) // Text node
        {
            while (true) {
                var value = element.nodeValue;  // Search for keyword in text node
                var idx = value.toLowerCase().indexOf(keyword);

                if (idx < 0) break;             // not found, abort

                var span = document.createElement("span");
                var text = document.createTextNode(value.substr(idx,keyword.length));
                span.appendChild(text);
                span.setAttribute("class","pointer-highlight");
                span.style.backgroundColor="yellow";
                span.style.color="black";
                text = document.createTextNode(value.substr(idx+keyword.length));
                element.deleteData(idx, value.length - idx);
                var next = element.nextSibling;
                element.parentNode.insertBefore(span, next);
                element.parentNode.insertBefore(text, next);
                element = text;
                pointerSearchResultCount++;	// update the counter
            }
        } else if (element.nodeType === 1) // Element node
        {
            var bound = element.getBoundingClientRect();
            if (element.nodeName.toLowerCase() !== 'select'
                    && bound.height > 0
                    && bound.width > 0) {
                for (var i=element.childNodes.length-1; i>=0; i--) {
                    pointerHighlightAllOccurencesOfStringForElement(element.childNodes[i],keyword);
                }
            }
        }
    }
}

// the main entry point to start the search
function pointerHighlightAllOccurencesOfString(keyword) {
    pointerRemoveAllHighlights();
    pointerSearchResultCount = 0;
    pointerHighlightAllOccurencesOfStringForElement(document.body, keyword.toLowerCase());
}

function pointerScrollToNthHighlight(n)
{
    var current = document.getElementsByClassName("pointer-highlight-current");
    if (current.length > 0) {
        current[0].style.backgroundColor="yellow";
        current[0].setAttribute("class","pointer-highlight");
    }
    var nodeList = document.getElementsByClassName("pointer-highlight");
    if (0 <= n && n < nodeList.length) {
        nodeList[n].scrollIntoViewIfNeeded();
        nodeList[n].style.backgroundColor="orange";
        nodeList[n].setAttribute("class","pointer-highlight-current");
    }
}

// helper function, recursively removes the highlights in elements and their childs
function pointerRemoveAllHighlightsForElement(element) {
    if (element) {
        if (element.nodeType === 1) {
            if (element.getAttribute("class") === "pointer-highlight"
                    || element.getAttribute("class") === "pointer-highlight-current") {
                var text = element.removeChild(element.firstChild);
                element.parentNode.insertBefore(text,element);
                element.parentNode.removeChild(element);
                return true;
            } else {
                var normalize = false;
                for (var i=element.childNodes.length-1; i>=0; i--) {
                    if (pointerRemoveAllHighlightsForElement(element.childNodes[i])) {
                        normalize = true;
                    }
                }
                if (normalize) {
                    element.normalize();
                }
            }
        }
    }
    return false;
}

// the main entry point to remove the highlights
function pointerRemoveAllHighlights() {
    pointerSearchResultCount = -1;
    pointerRemoveAllHighlightsForElement(document.body);
}
