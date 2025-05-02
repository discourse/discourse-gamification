import Component from "@ember/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { tagName } from "@ember-decorators/component";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import discourseComputed from "discourse/lib/decorators";
import LeaderboardInfo from "./modal/leaderboard-info";

export const LEADERBOARD_PERIODS = [
  "all_time",
  "yearly",
  "quarterly",
  "monthly",
  "weekly",
  "daily",
];
function periodString(periodValue) {
  switch (periodValue) {
    case 0:
      return "all";
    case 1:
      return "yearly";
    case 2:
      return "quarterly";
    case 3:
      return "monthly";
    case 4:
      return "weekly";
    case 5:
      return "daily";
    default:
      return "all";
  }
}

@tagName("")
export default class GamificationLeaderboard extends Component {
  @service router;
  @service modal;

  eyelineSelector = ".user";
  page = 1;
  loading = false;
  canLoadMore = true;
  period = "all";

  init() {
    super.init(...arguments);
    const default_leaderboard_period = periodString(
      this.model.leaderboard.default_period
    );
    this.set("period", default_leaderboard_period);
  }

  @discourseComputed("model.reason")
  isNotReady(reason) {
    return reason !== undefined;
  }

  @discourseComputed("model.users")
  currentUserRanking() {
    const user = this.model.personal;
    return user || null;
  }

  @discourseComputed("model.users")
  winners(users) {
    return users.slice(0, 3);
  }

  @discourseComputed("model.users.[]")
  ranking(users) {
    users.forEach((user) => {
      if (user.id === this.currentUser?.id) {
        user.isCurrentUser = "true";
      }
    });
    return users.slice(3);
  }

  @action
  showLeaderboardInfo() {
    this.modal.show(LeaderboardInfo);
  }

  @action
  loadMore() {
    if (this.loading || !this.canLoadMore) {
      return;
    }

    this.set("loading", true);

    return ajax(
      `/leaderboard/${this.model.leaderboard.id}?page=${this.page}&period=${this.period}`
    )
      .then((result) => {
        if (result.users.length === 0) {
          this.set("canLoadMore", false);
        }
        this.set("page", (this.page += 1));
        this.set("model.users", this.model.users.concat(result.users));
      })
      .finally(() => this.set("loading", false))
      .catch(popupAjaxError);
  }

  @action
  changePeriod(period) {
    this.set("period", period);
    return ajax(
      `/leaderboard/${this.model.leaderboard.id}?period=${this.period}`
    )
      .then((result) => {
        if (result.users.length === 0) {
          this.set("canLoadMore", false);
          this.set("model.reason", result.reason);
        }
        this.set("page", 1);
        this.set("model.users", result.users);
        this.set("model.personal", result.personal);
      })
      .finally(() => this.set("loading", false))
      .catch(popupAjaxError);
  }

  @action
  refresh() {
    this.router.refresh();
  }
}
