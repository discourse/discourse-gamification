import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default DiscourseRoute.extend({
  model(params) {
    return ajax(`/leaderboard/${params.leaderboardId}`)
      .then((scores) => {
        return scores;
      })
      .catch(() => this.replaceWith("/404"));
  },
});
