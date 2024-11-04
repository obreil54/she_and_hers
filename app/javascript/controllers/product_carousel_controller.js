import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "mainInfo", "secondaryInfo", "circle", "indicators"]

  connect() {
    const imagesValue = this.imageTarget.getAttribute('data-product-carousel-images-value');
    this.imagesValue = JSON.parse(imagesValue.replace(/&quot;/g, '"'));

    this.currentIndex = 0;

    this.generateIndicators();

    this.updateAllImages();
  }

  updateAllImages() {
    this.imageTarget.style.backgroundImage = `url(${this.imagesValue[this.currentIndex]})`;
    this.mainInfoTarget.style.backgroundImage = `url(${this.imagesValue[(this.currentIndex + 1) % this.imagesValue.length]})`;
    this.secondaryInfoTarget.style.backgroundImage = `url(${this.imagesValue[(this.currentIndex + 2) % this.imagesValue.length]})`;

    this.updateCircles();
  }

  navigateToImage(event) {
    const circleIndex = parseInt(event.currentTarget.dataset.index, 10);
    this.currentIndex = circleIndex;

    this.updateAllImages();
  }

  updateCircles() {
    this.circleTargets.forEach((circle, index) => {
      if (index === this.currentIndex) {
        circle.classList.add("active");
      } else {
        circle.classList.remove("active");
      }
    });
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
}
