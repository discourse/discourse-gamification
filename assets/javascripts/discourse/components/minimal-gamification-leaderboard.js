import Component from "@glimmer/component";
import { ajax } from "discourse/lib/ajax";
import { tracked } from "@glimmer/tracking";

export default class extends Component {
  @tracked notTop10 = true;
  @tracked model = null;

  constructor() {
    super(...arguments);

    const data = {
      user_limit: 10,
    };
    ajax(`/leaderboard`, { data }).then((model) => {
      this.model = model;
    });
  }

  get currentUserRanking() {
    const user = this.model?.personal;
    if (user) {
      this.notTop10 = user.position > 10;
    }
    return user || null;
  }

  get ranking() {
    this.model?.users?.forEach((user) => {
      if (user.id === this.model.personal?.user?.id) {
        user.isCurrentUser = "true";
      }
      if (user.id === 1) {
        user.topRanked = true;
      }
    });
    return this.model?.users;
  }
}
