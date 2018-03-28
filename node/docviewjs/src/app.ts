import $ = require("jquery");

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
}


window["Docview"] = new Docview()
window["Docview_html"] = window["Docview"].docviewHTML()
