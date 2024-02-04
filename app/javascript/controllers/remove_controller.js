import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["element"];

  connect() {}

  remove(e) {
    e.preventDefault();
    this.elementTarget.classList.add("animate-fade-out");
    setTimeout(() => this.elementTarget.remove(), 200);
  }
}
