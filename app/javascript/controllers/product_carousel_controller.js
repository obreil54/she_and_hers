import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "circle", "indicators"]
  static values = {
    interval: { type: Number, default: 5000 }
  }

  connect() {
    const imagesValue = this.imageTarget.getAttribute('data-product-carousel-images-value');
    this.imagesValue = JSON.parse(imagesValue.replace(/&quot;/g, '"'));

    console.log("Parsed Images Value: ", this.imagesValue);

    this.currentIndex = 0
    this.generateIndicators();
    this.showImage();

    this.startSlideshow();
  }

  startSlideshow() {
    this.intervalId = setInterval(() => {
      this.nextImage();
    }, this.intervalValue);
  }

  showImage() {
    const imageUrl = this.imagesValue[this.currentIndex];
    this.imageTarget.style.backgroundImage = `url(${imageUrl})`;

    this.updateCircles();
  }

  nextImage() {
    this.currentIndex = (this.currentIndex + 1) % this.imagesValue.length;
    this.showImage();
  }

  previousImage() {
    this.currentIndex = (this.currentIndex - 1 + this.imagesValue.length) % this.imagesValue.length;
    this.showImage();
  }

  navigateToImage(event) {
    const circleIndex = parseInt(event.currentTarget.dataset.index, 10);
    this.currentIndex = circleIndex;
    this.showImage();
    clearInterval(this.intervalId);
    this.startSlideshow();
  }

  updateCircles() {
    this.circleTargets.forEach((circle, index) => {
      if (index === this.currentIndex) {
        circle.classList.add("active");
      } else {
        circle.classList.remove("active");
      }
    })
  }

  generateIndicators() {
    const indicatorsContainer = this.indicatorsTarget;
    indicatorsContainer.innerHTML = "";

    this.imagesValue.forEach((_, index) => {
      const circle = document.createElement("div");
      circle.classList.add("carousel-circle");
      circle.dataset.index = index;
      circle.dataset.action = "click->product-carousel#navigateToImage";

      circle.setAttribute('data-product-carousel-target', 'circle');

      indicatorsContainer.appendChild(circle);
    });
  }

  disconnect() {
    clearInterval(this.intervalId);
  }
}
