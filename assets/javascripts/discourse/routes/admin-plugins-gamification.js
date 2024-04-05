import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default DiscourseRoute.extend({
  model() {
    if (!this.currentUser?.admin) {
      return { model: null };
    }

    return ajax("/admin/plugins/gamification.json").then((model) => {
      model.leaderboards = model.gamification_leaderboards.map((leaderboard) =>
        EmberObject.create(leaderboard)
      );
      return model;
    });
  },
});
