import DiscourseRoute from "discourse/routes/discourse";
import { action } from "@ember/object";
import { and } from "@ember/object/computed";
import EmberObject, { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default DiscourseRoute.extend({
  loading: false,
  creatingNew: false,
  newLeaderboardName: "",
  nameValid: and("newLeaderboardName"),

  @action
  createNewLeaderboard() {
    if (this.loading) {
      return;
    }

    this.set("loading", true);
    const data = {
      name: this.newLeaderboardName,
      created_by_id: this.currentUser.id,
    };

    return ajax("/admin/plugins/gamification/leaderboard", { data, type: "POST" })
      .then((leaderboard) => {
        const newLeaderboard = EmberObject.create(leaderboard);
        this.set(
          "model.gamification_leaderboard",
          [newLeaderboard].concat(this.model.gamification_leaderboard)
        );
        this.resetNewLeaderboard();
        this.setProperties({
          loading: false,
        });
      })
      .catch(popupAjaxError);
  },

  @action
  resetNewLeaderboard() {
    this.setProperties({
      creatingNew: false,
      newLeaderboardName: "",
    });
  },
});
