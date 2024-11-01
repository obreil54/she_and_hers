import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="wishlist"
export default class extends Controller {
  static values = { productId: Number };

  async toggle(event) {
    event.preventDefault();
    const productId = this.productIdValue;

    try {
      const response = await fetch(`/wishlists/${productId}/toggle`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute("content"),
        },
        body: JSON.stringify({ product_id: productId }),
      });

      const data = await response.json();
      if (data.added) {
        this.element.innerHTML = '<i class="fa-solid fa-heart"></i>';
      } else {
        this.element.innerHTML = '<i class="fa-regular fa-heart"></i>';
      }
    } catch (error) {
      console.error("Error toggling wishlist:", error);
    }
  }
}
