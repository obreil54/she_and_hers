import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cart"
export default class extends Controller {
  static targets = ["count"]

  addItem(event) {
    const form = event.target;
    const formData = new FormData(form)
    const url = event.target.action

    fetch(url, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute("content"),
      },
      body: formData
    })
    .then(response => response.json())
    .then((data) => {
      this.countTarget.textContent = data.total_items;
    })
    .catch((error) => {
      console.error("Error adding item to cart:", error);
    });
  }
}
