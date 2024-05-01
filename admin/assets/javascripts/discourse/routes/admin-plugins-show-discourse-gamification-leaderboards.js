import EmberObject from "@ember/object";
import { inject as service } from "@ember/service";
import DiscourseRoute from "discourse/routes/discourse";

export default class DiscourseGamificationLeaderboards extends DiscourseRoute {
  @service adminPluginNavManager;

  model() {
    if (!this.currentUser?.admin) {
      return { model: null };
    }
    const gamificationPlugin = this.adminPluginNavManager.currentPlugin;
    gamificationPlugin.extras.gamification_leaderboards =
      gamificationPlugin.extras.gamification_leaderboards.map((leaderboard) =>
        EmberObject.create(leaderboard)
      );
    return gamificationPlugin;
  }
}
