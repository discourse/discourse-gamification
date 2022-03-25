import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default DiscourseRoute.extend({
  model(params) {
    params.leaderboardName ||= "default";

    return ajax(`/leaderboard/${params.leaderboardName}`).then((model) => {
      model.leaderboardName = params.leaderboardName
      return model;
    });
  },
});
