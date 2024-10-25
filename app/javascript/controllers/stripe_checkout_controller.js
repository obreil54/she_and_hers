import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"];

  connect() {
    this.stripe = Stripe(this.getPublishableKey());
    this.buttonTarget.addEventListener("click", () => this.redirectToCheckout());
  }

  submitForm() {
    const guestFormId = this.buttonTarget.dataset.formIdGuest;
    const newAddressFormId = this.buttonTarget.dataset.formIdNew;
    const addressSelect = document.getElementById(this.buttonTarget.dataset.formIdExisting);

    let formId;

    if (addressSelect && addressSelect.value !== "") {
      console.log("Here is the address select");
      formId = guestFormId;
    } else if (document.getElementById(newAddressFormId) && document.getElementById(newAddressFormId).parentElement.style.display === "block") {
      console.log("Here is the new address form");
      formId = newAddressFormId;
    } else {
      console.log("Here is the guest form");
      formId = guestFormId;
    }

    const form = document.getElementById(formId);

    if (form) {
      form.submit();
    } else {
      console.error("Form not found.");
    }
  }

  async redirectToCheckout() {
    const response = await fetch('/orders', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        order: {
          total_amount_cents: this.data.get("totalPriceCents")
        }
      })
    });

    const session = await response.json();
    const { error } = await this.stripe.redirectToCheckout({ sessionId: session.id });

    if (error) {
      console.error("Error during redirect:", error.message);
    }
  }

  getPublishableKey() {
    return document.querySelector("meta[name='stripe-publishable-key']").content;
  }
}
