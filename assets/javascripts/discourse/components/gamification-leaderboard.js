import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import { action } from "@ember/object";
import showModal from "discourse/lib/show-modal";
import LoadMore from "discourse/mixins/load-more";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Component.extend(LoadMore, {
  tagName: "",
  eyelineSelector: ".user",
  page: 0

  @discourseComputed("model.users.[]")
  currentUserRanking(users) {
    const user = users.findBy("id", this.currentUser?.id);
    return user
      ? {
          user,
          total_score: user.total_score,
          position: users.indexOf(user) + 1,
        }
      : null;
  },

  @discourseComputed("model.users")
  winners(users) {
    return users.slice(0, 3);
  },

  @discourseComputed("model.users.[]")
  ranking(users) {
    users.forEach((user) => {
      if (user.id === this.currentUser.id) {
        user.isCurrentUser = "true";
      }
    });
    return users.slice(3);
  },

  @action
  showLeaderboardInfo() {
    showModal("leaderboard-info");
  },

  @action
  loadMore() {
    return ajax(`/leaderboard/${this.model.id}?page=${this.page}`, {
      type: "GET",
      cache: false,
    })
      .then((result) => {
        debugger;
      })
      .catch(popupAjaxError);
  },
});
