import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  addItem(event) {
    event.preventDefault();

    const form = event.target;
    const formData = new FormData(form);
    const url = event.target.action;

    fetch(url, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute("content"),
      },
      body: formData
    })
    .then(response => response.json())
    .then((data) => {
      const cartLinkElement = document.querySelector('[data-cart-target="link"]');
      if (cartLinkElement) {
        cartLinkElement.innerHTML = `CART (${data.total_items})`;
      }

      fetch((`/carts/${data.cart_id}/cart_items_modal`))
        .then(response => response.text())
        .then((html) => {
          const cartItemsContainer = document.querySelector('#cart-items-container');
          if (cartItemsContainer) {
            cartItemsContainer.innerHTML = html;
          }

          console.log("Data", data)
          console.log("Total Price", data.total_price)

          const totalPriceElement = document.querySelector('#total-price-display');
          if (totalPriceElement) {
            totalPriceElement.innerHTML = `${data.total_price}`;
          }

          const cartOverlayController = this.application.getControllerForElementAndIdentifier(
            document.body,
            "cart-overlay"
          );

          if (cartOverlayController) {
            cartOverlayController.show();
          }

          const cartModalBottom = document.querySelector('#cart-modal-bottom');
          if (cartModalBottom) {
            cartModalBottom.classList.remove('d-none');
          }
        })
        .catch((error) => {
          console.error("Error fetching cart items:", error);
        });
    })
    .catch((error) => {
      console.error("Error adding item to cart:", error);
    });
  }
}
