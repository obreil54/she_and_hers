import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["sizeSelect", "addButton", "measurementMessage", "price"];

  connect() {
    this.userLoggedIn = this.data.get("loggedIn") === "true";
    this.userHasMeasurements = this.data.get("hasMeasurements") === "true";

    this.guestMessageElement = document.getElementById("guest-message");
    this.missingMeasurementsMessageElement = document.getElementById("missing-measurements-message");
  }

  handleSizeChange() {
    const selectedSize = this.sizeSelectTarget.value;

    if (selectedSize === "CUSTOM") {
      if (!this.userLoggedIn) {
        this.showMessage(this.guestMessageElement);
        this.disableAddToCart();
        this.updatePriceWithCustomSize();
      } else if (!this.userHasMeasurements) {
        this.showMessage(this.missingMeasurementsMessageElement);
        this.disableAddToCart();
        this.updatePriceWithCustomSize();
      } else {
        this.hideAllMessages();
        this.enableAddToCart();
        this.updatePriceWithCustomSize();
      }
    } else {
      this.hideAllMessages();
      this.enableAddToCart();
      this.resetPrice();
    }
  }

  showMessage(element) {
    this.hideAllMessages();
    element.classList.remove("d-none");
  }

  hideAllMessages() {
    this.guestMessageElement.classList.add("d-none");
    this.missingMeasurementsMessageElement.classList.add("d-none");
  }

  disableAddToCart() {
    this.addButtonTarget.disabled = true;
  }

  enableAddToCart() {
    this.addButtonTarget.disabled = false;
  }

  updatePriceWithCustomSize() {
    const basePrice = parseFloat(this.priceTarget.dataset.basePrice);
    const customPrice = basePrice * 1.2;

    const formattedPrice = Number.isInteger(customPrice) ? `£${customPrice}` : `£${customPrice.toFixed(2)}`;

    this.priceTarget.textContent = formattedPrice;
  }

  resetPrice() {
    const basePrice = parseFloat(this.priceTarget.dataset.basePrice);

    const formattedPrice = Number.isInteger(basePrice) ? `£${basePrice}` : `£${basePrice.toFixed(2)}`;

    this.priceTarget.textContent = formattedPrice;
  }
}
