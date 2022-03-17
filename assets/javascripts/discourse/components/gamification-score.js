import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend({
  classNames: "gamification-score",

  init() {
    this._super();
    this.set("tagName", this.get("isCard") ? "h3" : "div");
  },

  didInsertElement() {
    Ember.run.scheduleOnce("afterRender", () => {
      let parent = this.get("isCard")
        ? ".card-content .metadata"
        : ".user-main .secondary dl";
      this.$().prependTo(parent);
    });
  },

  @discourseComputed("context")
  isCard(context) {
    return context === "card";
  },
});
