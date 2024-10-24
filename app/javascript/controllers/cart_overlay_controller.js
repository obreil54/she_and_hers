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

        this.updatePrices(data.total_price);

        this.syncQuantity(cartItemId, newQuantity);
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
    const maxValue = input.max ? parseInt(input.max) : Infinity;

    if (input && parseInt(input.value) < maxValue) {
      input.value = parseInt(input.value) + 1;
      this.updateQuantity({ target: input });
    } else {
      console.log(`Maximum quantity of ${maxValue} reached.`);
    }
  }

  decrementQuantity(event) {
    const cartItemId = event.target.dataset.cartItemId;
    const input = document.querySelector(`input[data-cart-item-id="${cartItemId}"]`);
    const minValue = input.min ? parseInt(input.min) : 1;

    if (input && parseInt(input.value) > minValue) {
      input.value = parseInt(input.value) - 1;
      this.updateQuantity({ target: input });
    }
  }

  syncQuantity(cartItemId, newQuantity) {
    const modalInput = document.querySelector(`#cart-overlay input[data-cart-item-id="${cartItemId}"]`);
    if (modalInput) {
      modalInput.value = newQuantity;
    }

    const pageInput = document.querySelector(`#cart-page input[data-cart-item-id="${cartItemId}"]`);
    if (pageInput) {
      pageInput.value = newQuantity;
    }
  }

  updatePrices(totalPrice) {
    const totalPriceElement = document.querySelector('#summary-total p');
    if (totalPriceElement) {
      totalPriceElement.innerHTML = totalPrice;
    }

    const subtotalElement = document.querySelector('#summary-subtotal p');
    if (subtotalElement) {
      subtotalElement.innerHTML = totalPrice;
    }

    const totalModalPriceElement = document.querySelector('#total-price-display');
    if (totalModalPriceElement) {
      totalModalPriceElement.innerHTML = totalPrice;
    }
  }
}
