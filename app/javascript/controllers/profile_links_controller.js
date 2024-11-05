import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="profile-links"
export default class extends Controller {
  static targets = ["link", "section"]

  connect() {
    console.log("ProfileLinksController connected")
  }

  switch(event) {
    event.preventDefault();

    const measurementInstructions = document.getElementById("how-to-measure-content")
    measurementInstructions.classList.add("d-none");

    const sectionToShow = event.currentTarget.dataset.section;

    this.linkTargets.forEach(link => link.classList.remove("active"));
    event.currentTarget.classList.add("active");

    this.sectionTargets.forEach(section => {
      if (section.dataset.section === sectionToShow) {
        section.style.display = "flex";
      } else {
        section.style.display = "none";
      }
    });
  }
}
