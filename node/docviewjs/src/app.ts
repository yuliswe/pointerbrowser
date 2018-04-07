import $ = require("jquery")
import Mark from "mark.ts"

class Docview {

    public allSymbols(): string[] {
        const hrefs = $.map($('a'), (x:any)=>x.href)
        const syms = hrefs.map((x:string) => {
            const m = x.match(/\#(.+)$/g)
            return m == null ? "" : m[0]
        })
        return syms.filter((x:string) => x.length > 0)
    }

    public docviewHTML(): string {
        return this.allSymbols().join('\n')
    }

    public turnOn(): void {
        window["docview_original_html"] = document.documentElement.innerHTML
        document.documentElement.innerHTML = window["Docview_html"]
    }

    public turnOff(): void {
        document.documentElement.innerHTML = window["docview_original_html"]
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
                let next;
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
                if (! arr.includes((e[i] as HTMLElement).tagName)) {
                    // console.log("recurs on", (e[i] as HTMLElement).tagName)
                    this._highlightWord(word, e[i].childNodes)
                } else {
                    // console.log("ignored", e[i])
                }
            }
        }
    }
}


window["Docview"] = new Docview()
window["Docview_html"] = window["Docview"].docviewHTML()
