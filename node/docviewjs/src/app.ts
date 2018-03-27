import $ = require("jquery");

class Docview {
    public docviewHTML(): string {
        $('a').filter()
        return "test"
    }

    public turnOn(): void {
        window["docview_original_html"] = document.documentElement.innerHTML
        document.documentElement.innerHTML = this.docviewHTML()

    }

    public turnOff(): void {
        document.documentElement.innerHTML = window["docview_original_html"]
    }
}


window["Docview"] = new Docview();
