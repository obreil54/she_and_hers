import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="menu"
export default class extends Controller {
  static targets = ["links", "icon"];

  toggle() {
    this.linksTarget.classList.toggle("active");
    this.iconTarget.classList.toggle("active");
    document.body.classList.toggle("menu-open");
  }
}
