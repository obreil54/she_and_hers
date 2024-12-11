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
    const imageUrl = event.currentTarget.src;

    const img = new Image();
    img.src = imageUrl;

    img.onload = () => {
      const imageAspectRatio = img.width / img.height;


      const maxWidth = window.innerWidth * 0.8;
      const maxHeight = window.innerHeight * 0.7;
      let modalWidth = maxWidth;
      let modalHeight = maxWidth / imageAspectRatio;

      if (modalHeight > maxHeight) {
        modalHeight = maxHeight;
        modalWidth = maxHeight * imageAspectRatio;
      }

      this.modalTarget.style.width = `${modalWidth}px`;
      this.modalTarget.style.height = `${modalHeight}px`;
      console.log(imageUrl);
      this.modalTarget.style.backgroundImage = `url(${imageUrl})`;
      this.modalTarget.style.display = "block";
    };
  }

  close() {
    this.modalTarget.style.display = "none";
  }

}
