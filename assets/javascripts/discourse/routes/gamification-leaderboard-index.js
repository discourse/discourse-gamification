import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default DiscourseRoute.extend({
  model(params) {
    // return default leaderboard for the index route
    params.leaderboardName = "Global Leaderboard";
    return ajax(`/leaderboard/${params.leaderboardName}`).then((model) => {
      model.leaderboardName = params.leaderboardName;
      return model;
    });
  },
});
