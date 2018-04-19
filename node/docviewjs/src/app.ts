﻿import $ = require("jquery")
import Mark from "mark.ts"

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
    public maxMarginPaddingAllowed = 50
    public maxWidthAllowed = 100
}

class DocviewStyle {
    public fontsizeLarge = '17px'
    public fontsizeMedium = '14px'
    public fontsizeSmall = '12px'
    public fontsizeCode = '12px'
}

class Docview {

    nonDiv = ["META", "SCRIPT", "INPUT", "TEXTAREA", "STYLE", "HEAD", "LINK", "TITLE", "NOSCRIPT", "IFRAME", "BUTTON", "SVG"]

    public snapshotHTML(heu: Heuristic = new Heuristic()): HTMLElement {
        const _root = $(document.body).clone()[0]
        let root = document.body
        let nodes: HTMLElement[] = [root] // nodes in the current depth
        while (nodes.length > 0) {
            const n = nodes.shift()
            let newStyles = ""
            const styles = window.getComputedStyle(n)
            for (let i = 0; i < styles.length; i++) {
                const k = styles[i]
                const v = styles.getPropertyValue(k)
                if (! k.includes("webkit")) {
                    if (k.includes("padding") || k.includes("margin")) {
                        if (parseInt(v) < heu.maxMarginPaddingAllowed) {
                            newStyles += k + ":" + v + "!important;"
                        }
                    } else if (k.includes("width")) {
                        if (parseInt(v) < heu.maxWidthAllowed) {
                            newStyles += k + ":" + v + "!important;"
                        }
                    } else if (k.includes("height")) {
                        // if (parseInt(v) < 50) {
                        //     newStyles += k + ":" + v + "!important;"
                        // }
                    } else {
                        newStyles += k + ":" + v + "!important;"
                    }
                }
            }
            // const stylesBefore = window.getComputedStyle(n, ":before").content
            // const stylesAfter = window.getComputedStyle(n, ":after").content
            // $(n).attr('data-before', stylesBefore).attr('data-after', stylesAfter)
            n.setAttribute("style", newStyles)
            for (const c in n.childNodes) {
                if (n.childNodes[c].nodeType == Node.ELEMENT_NODE) {
                    nodes.push(n.childNodes[c] as HTMLElement)
                }
            }
        }
        // window["Docview_htmlSnapshot"] = root
        document.body = _root
        return root
    }

    public guessRoot(root: HTMLElement,
                     test: (HTMLElement) => boolean,
                     level: number)
        : HTMLElement
    {
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
                    // && ((n.innerText||"").length > (0.75 * contentLength))) {
                    root = n
                    console.log("pruning at", n)
                    // $(n).siblings().remove()
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

    public docviewHTML(root: HTMLElement = this.snapshotHTML(),
                       level: number = 8,
                       docSt: DocviewStyle = new DocviewStyle())
        : HTMLBodyElement
    {
        let _root = document.body
        document.body = root
        // let root = document.body
        for (let i = 0; i < level; i++) {
            // prone every node that has more than X controls
            // use the first node that has > 80% page content as root
            let attempt1 =
                this.guessRoot(
                    root,
                    (n) => (! this.nonDiv.includes(n.tagName))
                            && (n.scrollHeight > 0.90 * root.scrollHeight)
                            && (n.scrollWidth > 0.60 * root.scrollWidth)
                            && (n.innerText.length > 0.5 * root.innerText.length),
                    1
                )
            if (root != attempt1) {
                root = attempt1
                continue
            }
            let attempt3 =
                this.guessRoot(
                    root,
                    (n) => (! this.nonDiv.includes(n.tagName))
                            && (n.scrollHeight > 0.75 * root.scrollHeight)
                            && (n.scrollWidth > 0.60 * root.scrollWidth)
                            && (n.innerText.length > 0.5 * root.innerText.length),
                    1
                )
            if (root != attempt3) {
                root = attempt3
                continue
            }
            let attempt2 =
                this.guessRoot(
                    root,
                    (n) => (! this.nonDiv.includes(n.tagName))
                            && (n.scrollHeight > 0.90 * root.scrollHeight)
                            && (n.innerText.length > 0.5 * root.innerText.length),
                    1
                )
            if (root != attempt2) {
                root = attempt2
                continue
            }
            let attempt4 =
                this.guessRoot(
                    root,
                    (n) => (! this.nonDiv.includes(n.tagName))
                            && (n.scrollHeight > 0.75 * root.scrollHeight)
                            && (n.innerText.length > 0.5 * root.innerText.length),
                    1
                )
            if (root != attempt4) {
                root = attempt4
                continue
            }
        }
        console.log("root", root)
        const bb = document.createElement("body")
        var link = document.createElement('link');
        link.setAttribute('rel', 'stylesheet');
        link.setAttribute('type', 'text/css');
        link.setAttribute('href', 'https://fonts.googleapis.com/css?family=Source+Code+Pro|Source+Sans+Pro');
        document.head.appendChild(link);
        $(bb).css({margin: "1em"})
        bb.appendChild(root)
        document.body = bb

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
        $(bb).find("*:not(:has(*))").each((i,e) => {
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
        console.log("avgFontSize", avgFontSize)
        // regularize font size
        all.each((i,e) => {
            if (e.innerText) {
                const sz = getComputedStyle(e).getPropertyValue("font-size")
                const s = parseInt(sz)
                if (! s) { return }
                if (s >= avgFontSize * 1.2) {
                    e.style.fontSize = docSt.fontsizeLarge
                } else if (s >= avgFontSize * 0.8) {
                    e.style.fontSize = docSt.fontsizeMedium
                } else {
                    e.style.fontSize = docSt.fontsizeSmall
                }
                e.style.fontFamily = "Source Sans Pro, sans-serif"
                e.removeAttribute("class")
                e.removeAttribute("id")
            }
        })
        $(bb).find("pre,code,pre *,code *").css({
              fontSize: docSt.fontsizeCode
            , fontFamily: "Source Code Pro, monospace"
        })
        document.body = _root
        return bb
    }

    public symbols(): string[] {
        let hrefs = {}
        $('a').each((i,e)=> {
            hrefs[$(e).attr("href")] = $(e).text()
        })
        let mapping = {}
        for (let k in hrefs) {
            const m = k.match(/\#(.+)$/g)
            if (m !== null) {
                const treatment = [""]
                let link = m[0].substr(1)
                let txt = hrefs[k]
                treatment.forEach((t) => {
                    link.replace(t, "")
                    txt.replace(t, "")
                })
                // mapping[link] = 1
                mapping[txt] = 1
            }
        }
        return Object.keys(mapping)
    }

    public prefixes(word: string, len: number): string[] {
        let i = 0
        let subs = []
        while (i < word.length) {
            subs.push(word.substring(i, Math.min(i+len, word.length)))
            i++
        }
        return subs
    }

    public keys(len: number): string[] {
        let mapping = {}
        this.symbols().map((v) => {
            this.prefixes(v,len).forEach((v) => {
                mapping[v] = 1;
            })
        })
        return Object.keys(mapping)
    }

    public turnOn(): void {
        window["Docview_original_body"] = document.body
        document.body = window["Docview_body"]
    }

    public turnOff(): void {
        document.body = window["Docview_original_body"]
    }

    public clearHighlight(): void {
        const span = $(".docview-highlighted")
        span.each(function() {
            $(this).replaceWith($(this).text())
        })
    }

    public countHighlight(): number {
        return $(".docview-highlighted span").length
    }

    public scrollToNthHighlight(n: number): void {
        console.log("docview.js:scrollToNthHighlight "+ n)
        $(".docview-highlighted span")
        .css({backgroundColor: "yellow"})
        .eq(n).css({backgroundColor: "orange"})[0]
        .scrollIntoView({block: "center", inline: "nearest"})
    }

    public highlightWord(word:string): number {
        this.clearHighlight()
        word = word.toLocaleLowerCase() // case insensitive
        this._highlightWord(word)
        this.scrollToNthHighlight(0)
        return this.countHighlight()
    }

    private _highlightWord(word:string, e:NodeList = document.querySelectorAll("body")): any {
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
                    if (! arr.includes(html.tagName)) {
                        // console.log("recurs on", (e[i] as HTMLElement).tagName)
                        this._highlightWord(word, e[i].childNodes)
                    }
                }
            }
        }
    }

    public static setup(heu: Heuristic = new Heuristic(),
                        st: DocviewStyle = new DocviewStyle())
    {
        let instance = new Docview()
        window["Docview"] = instance
        window["Docview_original_body"] = document.body
        window["Docview_body"] = instance.docviewHTML(instance.snapshotHTML(), 8, st)
    }
}

Docview.setup();
