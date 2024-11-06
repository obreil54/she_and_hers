import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  static targets = ["close"]

  connect() {
    setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  dismiss() {
    this.element.style.transition = "opacity 0.5s"
    this.element.style.opacity = "0"
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }

  close(event) {
    event.preventDefault()
    this.dismiss()
  }
}
