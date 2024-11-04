import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"];

  connect() {
    this.stripe = Stripe(this.getPublishableKey());
  }

  async submitForm() {
    const guestFormId = this.buttonTarget.dataset.formIdGuest;
    const newAddressFormId = this.buttonTarget.dataset.formIdNew;
    const addressSelect = this.buttonTarget.dataset.formIdExisting;

    let formId;
    if (document.getElementById(addressSelect) && document.getElementById("address-select").value) {
      console.log("Existing address selected.");
      formId = addressSelect;
    } else if (document.getElementById(newAddressFormId) && document.getElementById(newAddressFormId).parentElement.style.display === "block") {
      console.log("New address form visible.");
      formId = newAddressFormId;
    } else {
      console.log("Guest form visible.");
      formId = guestFormId;
    }

    const form = document.getElementById(formId);
    if (!form) {
      console.error("Form not found.");
      return;
    }

    if(!this.validateForm(form)) {
      alert("Please fill in all required fields before checking out.");
      return;
    }

    const formData = new FormData(form);
    const shippingRateSelect = document.getElementById("shipping-rate-select");
    if (!shippingRateSelect || !shippingRateSelect.value) {
      alert("Please select a shipping rate.");
      return;
    }
    const selectedShippingRate = shippingRateSelect.options[shippingRateSelect.selectedIndex].value;
    console.log("Selected shipping rate:", shippingRateSelect.options[shippingRateSelect.selectedIndex]);
    formData.append("order[shipping_cost]", selectedShippingRate);
    formData.append("order[selected_provider]", shippingRateSelect.options[shippingRateSelect.selectedIndex].dataset.provider);
    formData.append("order[selected_service_level]", shippingRateSelect.options[shippingRateSelect.selectedIndex].dataset.service_level);

    console.log(Object.fromEntries(formData.entries()));

    const response = await fetch('/orders', {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        order: Object.fromEntries(
          Array.from(formData.entries()).map(([key, value]) => [key.replace(/^order\[(.+)\]$/, "$1"), value])
        ),
        total_amount_cents: this.data.get("totalPriceCents")
      })
    });

    if (!response.ok) {
      console.error("Failed to create order.");
      return;
    }

    const session = await response.json();
    const { error } = await this.stripe.redirectToCheckout({ sessionId: session.id });

    if (error) {
      console.error("Error during redirect:", error.message);
    }
  }

  getPublishableKey() {
    return document.querySelector("meta[name='stripe-publishable-key']").content;
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
