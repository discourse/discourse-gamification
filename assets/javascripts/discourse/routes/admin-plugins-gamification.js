import DiscourseRoute from "discourse/routes/discourse";
import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";

export default DiscourseRoute.extend({
  model() {
    if (!this.currentUser?.admin) {
      return { model: null };
    }

    return ajax("/admin/plugins/gamification.json").then((model) => {
      model.leaderboards = model.leaderboards.map((leaderboard) =>
        EmberObject.create(leaderboard)
      );
      return model;
    });
  },
});
