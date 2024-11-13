import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="preorder-modal"
export default class extends Controller {
  static targets = [ "overlay" ]

  connect() {
    this.show()
  }

  show() {
    this.overlayTarget.style.display = "flex"
  }

  close() {
    this.overlayTarget.style.display = "none"
  }
}
