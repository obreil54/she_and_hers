import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cart-discount-code"
export default class extends Controller {
  static targets = ["subtotalPriceDisplay", "totalPriceDisplay", "discountMessage", "discountCodeInput", "applyButton"]

  connect() {
    console.log("CartDiscountCodeController connected");
    this.originalSubtotal = parseFloat(this.subtotalPriceDisplayTarget.textContent.replace(/[^\d.-]/g, ""));
    this.discountApplied = false;
    this.discountPercentage = 0;
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
    const discountAmount = (this.originalSubtotal * discountPercentage) / 100;
    const newSubtotal = this.originalSubtotal - discountAmount;
    this.subtotalPriceDisplayTarget.textContent = `£${newSubtotal.toFixed(2)}`;

    this.updateTotal(newSubtotal);
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
    if (this.discountApplied) {
      this.applyDiscount(this.discountPercentage);
    } else {
      this.updateTotal(this.originalSubtotal);
    }
  }
}
