import { inject as service } from "@ember/service";
import DiscourseRoute from "discourse/routes/discourse";

export default class DiscourseGamificationLeaderboardShow extends DiscourseRoute {
  @service adminPluginNavManager;

  model(params) {
    const leaderboardsData = this.modelFor(
      "adminPlugins.show.discourse-gamification-leaderboards"
    );
    const id = parseInt(params.id, 10);
    return leaderboardsData.leaderboards.findBy("id", id);
  }
}
