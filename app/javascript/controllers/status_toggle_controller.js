import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["regularPriceField", "salePriceFields", "statusSelect"]

  connect() {
    this.toggleFieldsOnLoad()
    console.log("Status toggle controller connected...")
  }

  toggleFields(event) {
    const status = this.statusSelectTarget.value
    this.showOrHideFields(status)
  }

  toggleFieldsOnLoad() {
    const status = this.statusSelectTarget.value
    this.showOrHideFields(status)
  }

  showOrHideFields(status) {
    if (status === "sale") {
      this.regularPriceFieldTarget.style.display = "none"
      this.salePriceFieldsTarget.style.display = ""
    } else {
      this.regularPriceFieldTarget.style.display = ""
      this.salePriceFieldsTarget.style.display = "none"
    }
  }
}
