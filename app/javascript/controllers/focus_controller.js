import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { focus: String };

  connect() {
    if (this.focusValue == "now") {
      this.element.focus();
    }
  }
}
