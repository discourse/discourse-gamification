import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default DiscourseRoute.extend({
  model() {
    return ajax(`/leaderboard`)
      .then((model) => {
        model.users = model.users.sortBy("total_score").reverse();
        return model;
      })
      .catch(() => this.replaceWith("/404"));
  },
});
