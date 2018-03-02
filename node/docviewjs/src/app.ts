import $ = require("jquery")
import Mark from "mark.ts"
import { setTimeout } from "timers";

class Properties {
    perc_height: number
    perc_width: number
    text_length: number
    num_buttons: number
    public score(): number {
        return this.perc_height
    }
}

class Heuristic {
    public maxMarginPaddingAllowed = 25
    public maxWidthAllowed = 100
}

class DocviewStyle {
    public fontsizeLarge = '17pt'
    public fontsizeMedium = '12pt'
    public fontsizeSmall = '12pt'
    public fontsizeCode = '9pt'
}

class Docview {

    nonDiv = ["META", "SCRIPT", "INPUT", "TEXTAREA", "STYLE", "HEAD", "LINK", "TITLE", "NOSCRIPT", "IFRAME", "BUTTON", "SVG"]

    public snapshotHTML(heu: Heuristic = new Heuristic()) {
        console.log("snapshotHTML called")
        const _root = document.body.cloneNode(true) as HTMLBodyElement
        const root = document.body as HTMLBodyElement
        let nodes: Element[] = [root] // nodes in the current depth
        let _nodes: Element[] = [_root]
        while (nodes.length > 0) {
            console.count("iteration")
            const n = nodes.shift()
            const _n = _nodes.shift()
            let _styles = ""
            const styles = window.getComputedStyle(n)
            for (let i = 0; i < styles.length; i++) {
                const k = styles[i]
                const v = styles.getPropertyValue(k)
                if (k.includes("webkit")
                    // || k.includes("border")
                    || k == "background-image"
                    || k == "float") {
                    // do not copy
                } else if ((k == "background-color")) {
                    if (['PRE', 'CODE', 'SPAN'].includes(n.tagName)
                        || styles.fontFamily.includes("monospace")
                        || styles.fontStyle.includes("italic")) {
                        _styles += k + ":" + v + ";"
                    }
                } else if (k.includes("padding") || k.includes("margin")) {
                    if (parseInt(v) < heu.maxMarginPaddingAllowed) {
                        _styles += k + ":" + v + ";"
                    }
                } else if (k == "width" || k == "max-width") {
                    if (parseInt(v) < heu.maxWidthAllowed) {
                        _styles += k + ":" + v + ";"
                    }
                } else if (k == "height" || k == "max-height") {
                    // if (parseInt(v) < 50) {
                    //     _styles += k + ":" + v + ";"
                    // }
                } else if (k == "display") {
                    if (styles["position"] === "sticky") {
                        _styles += k + ":none;"
                    } else {
                        _styles += k + ":" + v + ";"
                    }
                } else if (k == "font-family") {
                    _styles += 'font-family: "Source Sans Pro", sans-serif;'
                } else {
                    _styles += k + ":" + v + ";"
                }
            }
            const contentB = window.getComputedStyle(n, ":before").content
            const contentA = window.getComputedStyle(n, ":after").content
            _n.setAttribute("style", _styles)
            _n.setAttribute("data-before", contentB)
            _n.setAttribute("data-after", contentA)
            // _n.removeAttribute("id")
            // _n.removeAttribute("class")
            let c = n.firstElementChild
            let _c = _n.firstElementChild
            while (c != null) {
                nodes.push(c)
                _nodes.push(_c)
                c = c.nextElementSibling
                _c = _c.nextElementSibling
            }
        }
        document.body = _root
        $('link').remove()
    }

    public guessRoot(root: HTMLElement,
        test: (HTMLElement) => boolean,
        level: number)
        : HTMLElement {
        for (let i = 0; i < level; i++) {
            let nodes: HTMLElement[] = []// nodes in the current depth
            for (const c in root.childNodes) {
                const e = root.childNodes[c]
                if (e.nodeType == Node.ELEMENT_NODE) {
                    nodes.push(e as HTMLElement)
                }
            }
            while (nodes.length > 0) {
                const n = nodes.shift()
                if (test(n)) {
                    root = n
                    break
                }
                for (let c in n.childNodes) {
                    if (n.childNodes[c].nodeType == Node.ELEMENT_NODE) {
                        nodes.push(n.childNodes[c] as HTMLElement)
                    }
                }
            }
        }
        return root
    }

    public docviewHTML(level: number = 8,
        docSt: DocviewStyle = new DocviewStyle()) {
        console.log("docviewHTML called")
        let root = document.body
        // remove garbage
        let nodes: HTMLElement[] = [root]// nodes in the current depth
        while (nodes.length > 0) {
            const n = nodes.shift()
            // garbage test
            // sidebar
            // if (n.offsetHeight > 0.9 * document.body.offsetHeight
            //     && n.offsetWidth < 0.5 * document.body.offsetWidth) {
            //     n.className += " docview-garbage"
            // } else 
            // navbar
            const nav = /nav|toc|table-of-contents/ig
            if (nav.test(n.className)
                || nav.test(n.id)
                || nav.test(n.tagName)
                || nav.test(n.getAttribute("role"))) {
                n.className += " docview-garbage"
                continue
            }
            // sidebar
            const side = /side.?bar/ig
            if (side.test(n.className)
                || side.test(n.getAttribute("role"))
                || side.test(n.id)) {
                n.className += " docview-garbage"
                continue
            }
            // header|footer
            const header = /head|foot/ig
            if (header.test(n.tagName)
                || header.test(n.id)
                || header.test(n.getAttribute('role'))
                || header.test(n.className)) {
                n.className += " docview-garbage"
                continue
            }
            // controls
            const controls = /input|textarea|button|select/ig
            if (controls.test(n.tagName)) {
                n.className += " docview-garbage"
                continue
            }
            for (let c in n.childNodes) {
                if (n.childNodes[c].nodeType == Node.ELEMENT_NODE) {
                    nodes.push(n.childNodes[c] as HTMLElement)
                }
            }
        }
        const bb = document.createElement("body")
        var link = document.createElement('link');
        link.setAttribute('rel', 'stylesheet');
        link.setAttribute('type', 'text/css');
        link.setAttribute('href', 'https://fonts.googleapis.com/css?family=Source+Code+Pro|Source+Sans+Pro');
        document.head.appendChild(link);
        $(bb).css({ margin: "1em" })
        bb.appendChild(root)
        document.body = bb

        $(bb).find(".docview-garbage").remove()

        for (const s of this.nonDiv) {
            const redun = bb.querySelectorAll(s)
            for (const i in redun) {
                const e = redun[i]
                if (e.nodeType == Node.ELEMENT_NODE) {
                    e.remove()
                }
            }
        }
        const all = $(bb).find("*")
        let avgFontSize: number = 0
        let d: number = 0
        $(bb).find("*:not(:has(*))").each((i, e) => {
            if (e.innerText) {
                const sz = getComputedStyle(e).getPropertyValue("font-size")
                if (sz.includes("px")) {
                    const s = parseInt(sz)
                    if (s) {
                        avgFontSize = (avgFontSize * d + s) / (d + 1)
                        d++
                    }
                }
            }
        })
        // console.log("avgFontSize", avgFontSize)
        // regularize font size
        all.each((i, e) => {
            if (e.innerText) {
                const sz = getComputedStyle(e).getPropertyValue("font-size")
                const s = parseInt(sz)
                if (!s) { return }
                if (s >= avgFontSize * 1.2) {
                    e.style.fontSize = docSt.fontsizeLarge
                } else if (s >= avgFontSize * 0.8) {
                    e.style.fontSize = docSt.fontsizeMedium
                } else {
                    e.style.fontSize = docSt.fontsizeSmall
                }
                // e.style.fontFamily = "Source Sans Pro, sans-serif"
            }
        })
        $(bb).find("pre,code,pre *,code *").css({
            fontSize: docSt.fontsizeCode
            , fontFamily: "Source Code Pro, monospace"
        })
        $(bb).css({ backgroundColor: "white" })
        // $(bb).find("*").each((i,e) => { 
        //     e.id = '' 
        //     e.className = ''
        // })
    }

    public crawler(): {
        links: string[], // what to craw next
        referer: string, // the root of links
        symbols: { string: string }, // symbols on referer
        title: string // referer's title
    } {
        // console.log("finding symbols")
        let hrefs = {}
        $('a').each((i, e) => {
            hrefs[$(e).attr("href")] = e.innerText
        })
        let symbols = {} as { string: string }
        let links = {}
        for (let k in hrefs) {
            const url = new URL(k, location.href)
            const txt = hrefs[k]
            // const i = k.indexOf("#")
            if (url.hash.length > 1 // the first char is always #
                && url.hash.length < 36 // longer than 35 might be an md5 hash 
                && (!url.hash.includes('%')) // no space in hash
                && url.pathname === location.pathname // on the same page
                && url.hostname == location.hostname
                && /^[\x00-\x7F]+$/.test(url.hash) // confirm ascii 
                // these symbols are not popular unless appear with brackets
                && (/^[^\s\*\&\?\!\@\#\%\^\+\=\|\/\,\;\'\"\`\~\\]+$/.test(txt)
                    || txt.includes("(")
                    || txt.includes("{"))
                // must start with an alphabet or _, 
                // optionally preceded by $ or brackets
                && /^[\$,\(,\{]*[a-z,A-Z,\_]/.test(txt)
                // ignore symbols of just one character
                && 1 < txt.length
                // also symbols that are too long might be an md5 hash
                && txt.length < 36
                // confirm ascii
                && /^[\x00-\x7F]+$/.test(txt)) {
                /* These are taken as symbols */
                symbols[url.hash.substr(1)] = txt
            } else if (url.hostname == location.hostname
                && url.pathname !== location.pathname) {
                /* These are to be crawled */
                links[url.origin + url.pathname] = 1
            }
        }
        return {
            symbols: symbols,
            links: Object.keys(links),
            referer: location.origin + location.pathname,
            title: document.title
        }
    }

    public prefixes(word: string, len: number): string[] {
        let i = 0
        let subs = []
        while (i < word.length) {
            subs.push(word.substring(i, Math.min(i + len, word.length)))
            i++
        }
        return subs
    }

    // public keys(len: number): string[] {
    //     let mapping = {}
    //     this.symbols().map((v) => {
    //         this.prefixes(v,len).forEach((v) => {
    //             mapping[v] = 1;
    //         })
    //     })
    //     return Object.keys(mapping)
    // }

    public clearHighlight(): void {
        const span = $(".docview-highlighted")
        span.each(function () {
            $(this).replaceWith($(this).text())
        })
    }

    public countHighlight(): number {
        return $(".docview-highlighted span").length
    }

    public scrollToNthHighlight(n: number): void {
        console.log("docview.js:scrollToNthHighlight " + n)
        $(".docview-highlighted span")
            .css({ backgroundColor: "yellow" })
            .eq(n).css({ backgroundColor: "orange" })[0]
            .scrollIntoView({ block: "center", inline: "nearest" })
    }

    public highlightWord(word: string): number {
        this.clearHighlight()
        word = word.toLocaleLowerCase() // case insensitive
        this._highlightWord(word)
        this.scrollToNthHighlight(0)
        return this.countHighlight()
    }

    private _highlightWord(word: string, e: NodeList = document.querySelectorAll("body")): any {
        const rgx = new RegExp(word, 'ig')
        for (let i in e) {
            if (e[i].nodeType == Node.TEXT_NODE) {
                const str = e[i].nodeValue.toLocaleLowerCase()
                let changed = false
                let newstr = ""
                let next
                let prev = 0;
                while ((next = str.indexOf(word, prev)) >= 0) {
                    changed = true
                    newstr += e[i].nodeValue.substring(prev, next);
                    newstr += "<span style='background-color:yellow'>"
                    newstr += e[i].nodeValue.substr(next, word.length);
                    newstr += "</span>"
                    prev = next + word.length;
                    // console.log("replaced", e[i], "of parent", e[i].parentElement, "by", span)
                }
                if (changed) {
                    newstr += e[i].nodeValue.substring(prev)
                    const span = document.createElement("span")
                    span.innerHTML = newstr
                    span.setAttribute("class", "docview-highlighted")
                    e[i].parentNode.replaceChild(span, e[i])
                }
            } else if (e[i].nodeType == Node.ELEMENT_NODE) {
                const arr = ["META", "SCRIPT", "INPUT", "TEXTAREA", "STYLE", "HEAD", "LINK", "TITLE", "NOSCRIPT"]
                const html = e[i] as HTMLElement;
                if (html.scrollHeight > 0 && html.offsetWidth > 0) {
                    if (!arr.includes(html.tagName)) {
                        // console.log("recurs on", (e[i] as HTMLElement).tagName)
                        this._highlightWord(word, e[i].childNodes)
                    }
                }
            }
        }
    }

    public docviewOn(heu: Heuristic = new Heuristic(),
        st: DocviewStyle = new DocviewStyle()) {
        this.snapshotHTML(heu)
        this.docviewHTML(8, st)
    }
}

window["Docview"] = new Docview();

