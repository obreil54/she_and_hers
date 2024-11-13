import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.shippingRateSelectTarget = document.getElementById("shipping-rate-select");
    this.totalPriceDisplayTarget = document.querySelector('#summary-total p');
  }

  async calculateShippingRates() {
    let form;

    const addressSelect = "existing-address-form";
    const newAddressFormId = "address-form";
    const guestFormId = "guest-address-form";

    if (document.getElementById("address-select") && document.getElementById("address-select").value) {
      console.log("Existing address selected.");
      form = document.getElementById(addressSelect);
    } else if (document.getElementById(newAddressFormId) && document.getElementById(newAddressFormId).parentElement.style.display === "block") {
      console.log("New address form visible.");
      form = document.getElementById(newAddressFormId);
    } else if (document.getElementById(guestFormId)) {
      console.log("Guest form visible.");
      form = document.getElementById(guestFormId);
    } else {
      console.error("Address form not found.");
      return;
    }

    if (!form) {
      console.error("Address form not found.");
      return;
    }

    if(!this.validateForm(form)) {
      alert("Please fill in all required fields before calculating shipping rates.");
      return;
    }

    const formData = new FormData(form);
    console.log("Form data being sent:", Object.fromEntries(formData.entries())); // Debugging line

    const response = await fetch('/shipping_rates', {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify(Object.fromEntries(formData))
    });

    if (response.ok) {
      const rates = await response.json();
      this.populateShippingRates(rates);
    } else {
      console.error("Failed to fetch shipping rates.");
    }
  }

  populateShippingRates(rates) {
    const shippingRatesContainer = document.getElementById("shipping-rates-container");

    if (!shippingRatesContainer) {
      console.error("Shipping rates container element not found in the DOM.");
      return;
    }

    shippingRatesContainer.style.display = "block";

    const shippingRateSelect = document.getElementById("shipping-rate-select");

    if (!shippingRateSelect) {
      console.error("Shipping rate select element not found in the DOM.");
      return;
    }

    shippingRateSelect.innerHTML = "";

    const defaultOption = document.createElement("option");
    defaultOption.value = "";
    defaultOption.textContent = "SELECT SHIPPING OPTION";
    defaultOption.selected = true;
    defaultOption.disabled = true;
    shippingRateSelect.appendChild(defaultOption);

    rates.forEach(rate => {
      console.log("Rate:", rate);
      const option = document.createElement("option");
      option.value = rate.amount;
      option.dataset.provider = rate.provider;
      option.dataset.service_level = rate.service_level;
      option.textContent = `${rate.provider} (${rate.service_level || "Standard"}): ${rate.amount} ${rate.currency}`;
      shippingRateSelect.appendChild(option);
    });
  }


  updateTotal() {
    this.shippingRateSelectTarget = document.getElementById("shipping-rate-select");
    this.totalPriceDisplayTarget = document.querySelector('#summary-total p');

    console.log("Total price display target:", this.totalPriceDisplayTarget.innerText);

    console.log("updateTotal called");

    if (!this.shippingRateSelectTarget) {
      console.error("Shipping rate select element not found.");
      return;
    }

    const selectedOption = this.shippingRateSelectTarget.options[this.shippingRateSelectTarget.selectedIndex];
    console.log("Selected option:", selectedOption);

    const shippingCost = parseFloat(selectedOption.value);
    console.log("Shipping cost:", shippingCost);


    const subtotalText = document.querySelector("#summary-subtotal-products p").innerText;
    console.log("Subtotal text:", subtotalText);
    const subtotal = parseFloat(subtotalText.replace(/[^0-9.-]+/g, ""));
    console.log("Subtotal:", subtotal);

    if (isNaN(subtotal) || isNaN(shippingCost)) {
      console.error("Unable to parse subtotal or shipping cost.");
      return;
    }

    const newTotal = subtotal + shippingCost;
    console.log("New total:", newTotal);

    if (this.totalPriceDisplayTarget) {
      this.totalPriceDisplayTarget.innerHTML = `£${newTotal.toFixed(2)}`;
      console.log("Total price updated in DOM");
    } else {
      console.error("Total price display element not found.");
    }
  }

  validateForm(form) {
    let isValid = true;
    form.querySelectorAll("[required]").forEach((field) => {
      if(!field.value.trim()) {
        field.classList.add("is-invalid");
        isValid = false;
      } else {
        field.classList.remove("is-invalid");
      }
    });
    return isValid;
  }
}
