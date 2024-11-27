import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["track", "slide", "leftButton", "rightButton", "modalImage", "modal"];

  connect() {
    console.log("Carousel controller connected");

    this.currentIndex = 0;
    this.slideWidth = this.slideTarget.getBoundingClientRect().width;
    this.totalSlides = this.slideTargets.length;

    this.setSlidePositions();

    this.rebindDynamicEvents();

    const closeButton = document.querySelector(".close-button");
    if (closeButton) {
      closeButton.addEventListener("click", () => {
        console.log("Close button clicked!");
        this.close();
      });
    }
  }

  setSlidePositions() {
    this.slideTargets.forEach((slide, index) => {
      slide.style.left = `${index * this.slideWidth}px`;
    });
  }

  moveToSlide(index) {
    const amountToMove = -index * this.slideWidth;
    this.trackTarget.style.transform = `translateX(${amountToMove}px)`;
  }

  next() {
    if (this.currentIndex < this.totalSlides - 3) {
      this.currentIndex++;
      this.moveToSlide(this.currentIndex);
    }
  }

  previous() {
    if (this.currentIndex > 0) {
      this.currentIndex--;
      this.moveToSlide(this.currentIndex);
    }
  }

  rebindDynamicEvents() {
    console.log("Rebinding dynamically loaded images...");

    const images = this.element.querySelectorAll("[data-action='carousel#open']");

    images.forEach((image) => {
      image.addEventListener("click", (event) => this.open(event));
    });

    console.log(`Rebound ${images.length} images`);
  }

  open(event) {
    console.log("Open modal triggered");

    const imageUrl = event.currentTarget.src;

    this.modalImageTarget.src = imageUrl;

    this.modalTarget.style.display = "block";
  }

  close(event) {
    console.log("Close modal triggered");

    if (!this.modalTarget) {
      console.error("Modal target not found!");
      return;
    }

    this.modalTarget.style.display = "none";
  }
}
