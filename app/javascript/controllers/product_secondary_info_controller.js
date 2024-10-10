import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"];

  toggle(event) {
    const contentId = event.currentTarget.dataset.targetId;
    const contentElement = document.getElementById(contentId);

    this.contentTargets.forEach((target) => {
      if (target !== contentElement) {
        target.classList.add("d-none");
      }
    });

    contentElement.classList.toggle("d-none");
  }
}
