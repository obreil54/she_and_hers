import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["track", "slide", "leftButton", "rightButton", "modalImage", "modal"];

  connect() {
    console.log("Carousel controller connected");

    this.currentIndex = 0;
    this.slideWidth = this.slideTarget.getBoundingClientRect().width;
    this.totalSlides = this.slideTargets.length;

    if (this.totalSlides === 1) {
      this.adjustForSingleSlide();
    } else if (this.totalSlides === 2) {
      this.adjustForTwoSlides();
    } else {
      this.setSlidePositions();
    }

    this.rebindDynamicEvents();

    const closeButton = document.querySelector(".close-button");
    if (closeButton) {
      closeButton.addEventListener("click", () => {
        console.log("Close button clicked!");
        this.close();
      });
    }

    this.startX = 0;
    this.currentX = 0;
    this.isSwiping = false;

    this.trackTarget.addEventListener("touchstart", this.handleTouchStart.bind(this), { passive: true });
    this.trackTarget.addEventListener("touchmove", this.handleTouchMove.bind(this), { passive: true });
    this.trackTarget.addEventListener("touchend", this.handleTouchEnd.bind(this));
  }

  adjustForSingleSlide() {
    this.trackTarget.style.width = "100%";
    this.slideTargets.forEach((slide) => {
      slide.style.flex = "0 0 100%";
    });
  }

  adjustForTwoSlides() {
    this.trackTarget.style.width = "100%";
    this.slideTargets.forEach((slide) => {
      slide.style.flex = "0 0 50%";
    });
  }

  setSlidePositions() {
    this.slideTargets.forEach((slide, index) => {
      slide.style.left = `${index * this.slideWidth}px`;
    });
  }

  moveToSlide(index) {
    if (index < 0) {
      this.currentIndex = 0;
    } else if (index >= this.totalSlides) {
      this.currentIndex = this.totalSlides - 1;
    } else {
      this.currentIndex = index;
    }

    const amountToMove = -this.currentIndex * this.slideWidth;
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


      const maxWidth = window.innerWidth * 0.95;
      const maxHeight = window.innerHeight * 0.95;
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

  handleTouchStart(event) {
    this.startX = event.touches[0].clientX;
    this.isSwiping = true;
  }

  handleTouchMove(event) {
    if (!this.isSwiping) return;

    this.currentX = event.touches[0].clientX;
  }

  handleTouchEnd() {
    if (!this.isSwiping) return;

    const deltaX = this.startX - this.currentX;

    const swipeThreshold = 50;

    if (deltaX > swipeThreshold) {
      this.next();
    } else if (deltaX < -swipeThreshold) {
      this.previous();
    }

    this.isSwiping = false;
    this.startX = 0;
    this.currentX = 0;
  }
}
