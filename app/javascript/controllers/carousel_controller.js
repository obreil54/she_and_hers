import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["track", "slide", "leftButton", "rightButton"];

  connect() {
    this.currentIndex = 0; // Track the current visible slide index
    this.slideWidth = this.slideTarget.getBoundingClientRect().width;
    this.totalSlides = this.slideTargets.length;

    // Set initial positions for all slides
    this.setSlidePositions();
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
    if (this.currentIndex < this.totalSlides - 3) { // Ensure at least 3 images remain visible
      this.currentIndex++;
      this.moveToSlide(this.currentIndex);
    }
  }

  previous() {
    if (this.currentIndex > 0) { // Prevent scrolling past the first slide
      this.currentIndex--;
      this.moveToSlide(this.currentIndex);
    }
  }
}
