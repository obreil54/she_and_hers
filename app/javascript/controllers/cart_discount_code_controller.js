import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cart-discount-code"
export default class extends Controller {
  static targets = ["subtotalPriceDisplay", "totalPriceDisplay", "discountMessage", "discountCodeInput", "applyButton"]

  connect() {
    console.log("CartDiscountCodeController connected");
    this.discountApplied = false;
    this.discountPercentage = 0;
    this.discountedSubtotal = null;
  }

  applyDiscountCode() {
    const discountCode = this.discountCodeInputTarget.value.trim();

    fetch(`/discount_codes/validate?code=${discountCode}`)
      .then(response => {
        if (!response.ok) throw new Error("INVALID OR USED DISCOUNT CODE");
        return response.json();
      })
      .then(data => {
        if (data.valid) {
          this.discountPercentage = data.discount_percentage;
          this.applyDiscount(this.discountPercentage);
          this.showDiscountMessage(`DISCOUNT APPLIED: ${this.discountPercentage}% OFF`);
          this.lockDiscountField();
        } else {
          this.showDiscountMessage("INVALID DISCOUNT CODE", true);
        }
      })
      .catch(error => {
        console.error("Error:", error);
        this.showDiscountMessage(error.message, true);
      });
  }

  lockDiscountField() {
    this.discountCodeInputTarget.disabled = true;
    this.applyButtonTarget.disabled = true;
    this.discountApplied = true;
  }

  applyDiscount(discountPercentage) {
    const currentSubtotal = parseFloat(this.subtotalPriceDisplayTarget.textContent.replace(/[^\d.-]/g, ""));
    const discountAmount = (currentSubtotal * discountPercentage) / 100;
    this.discountedSubtotal = currentSubtotal - discountAmount;
    this.subtotalPriceDisplayTarget.textContent = `£${this.discountedSubtotal.toFixed(2)}`;

    this.updateTotal(this.discountedSubtotal);
  }

  updateTotal(subtotal) {
    const shippingCost = this.getShippingCost();
    const newTotal = subtotal + shippingCost;
    this.totalPriceDisplayTarget.textContent = `£${newTotal.toFixed(2)}`;
  }

  getShippingCost() {
    const shippingRateSelect = document.getElementById("shipping-rate-select");
    const selectedShippingCost = shippingRateSelect && shippingRateSelect.value ? parseFloat(shippingRateSelect.value) : 0;
    return isNaN(selectedShippingCost) ? 0 : selectedShippingCost;
  }

  showDiscountMessage(message, isError = false) {
    this.discountMessageTarget.textContent = message;
    this.discountMessageTarget.style.display = "block";
  }

  resetDiscount() {
    this.discountCodeInputTarget.disabled = false;
    this.applyButtonTarget.disabled = false;
    this.discountMessageTarget.style.display = "none";
    this.subtotalPriceDisplayTarget.textContent = `£${this.originalSubtotal.toFixed(2)}`;
    this.updateTotal(this.originalSubtotal);
    this.discountApplied = false;
    this.discountPercentage = 0;
  }

  adjustPrices() {
    const subtotal = this.discountApplied && this.discountedSubtotal !== null
      ? this.discountedSubtotal
      : parseFloat(this.subtotalPriceDisplayTarget.textContent.replace(/[^\d.-]/g, ""));
    this.updateTotal(subtotal);
  }
}
