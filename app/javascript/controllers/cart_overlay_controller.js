import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "cartLink"]

  show(event) {
    if (event) event.preventDefault();
    this.overlayTarget.classList.add('active');
    document.body.classList.add('cart-active');
  }

  hide() {
    this.overlayTarget.classList.remove('active');
    document.body.classList.remove('cart-active');
  }

  updateQuantity(event) {
    const cartItemId = event.target.dataset.cartItemId;
    const newQuantity = event.target.value;

    fetch(`/cart_items/${cartItemId}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute("content"),
      },
      body: JSON.stringify({ quantity: newQuantity })
    })
    .then(response => response.json())
    .then((data) => {
      if (data.success) {
        const cartLinkElement = document.querySelector('[data-cart-target="link"]');
        if (cartLinkElement) {
          cartLinkElement.innerHTML = `CART (${data.total_items})`;
        }

        const totalPriceElement = document.querySelector('#total-price-display');
        if (totalPriceElement) {
          totalPriceElement.innerHTML = `${data.total_price}`;
        }
        console.log("Quantity updated successfully");
      } else {
        console.error("Failed to update quantity");
      }
    })
    .catch(error => console.error("Error updating quantity:", error));
  }

  incrementQuantity(event) {
    const cartItemId = event.target.dataset.cartItemId;
    const input = document.querySelector(`input[data-cart-item-id="${cartItemId}"]`);
    if (input) {
      input.value = parseInt(input.value) + 1;
      this.updateQuantity({ target: input });
    }
  }

  decrementQuantity(event) {
    const cartItemId = event.target.dataset.cartItemId;
    const input = document.querySelector(`input[data-cart-item-id="${cartItemId}"]`);
    if (input && input.value > 1) {
      input.value = parseInt(input.value) - 1;
      this.updateQuantity({ target: input });
    }
  }
}
