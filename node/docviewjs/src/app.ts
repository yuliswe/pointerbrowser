import $ = require("jquery");

class Docview {
    public docviewHTML(html: string): string {
        return "test";
    }

    public turnOn(): void {
        window["docview_original_html"] = document.documentElement.innerHTML;
        document.documentElement.innerHTML = this.docviewHTML(document.documentElement.innerHTML)
    }

    public turnOff(): void {
        document.documentElement.innerHTML = window["docview_original_html"]
    }
}


window["Docview"] = new Docview();
