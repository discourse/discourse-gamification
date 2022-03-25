import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";
import { get } from "@ember/object";

export default DiscourseRoute.extend({
  model(params) {
    return ajax(`/leaderboard/${params.leaderboardName}`).then((scores) => {
      scores.leaderboardName = params.leaderboardName;
      return scores;
    });
  },
});
