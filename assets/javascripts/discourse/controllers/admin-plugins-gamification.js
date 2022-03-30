import DiscourseRoute from "discourse/routes/discourse";
import EmberObject, { action } from "@ember/object";
import discourseComputed from "discourse-common/utils/decorators";
import { and } from "@ember/object/computed";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default DiscourseRoute.extend({
  loading: false,
  creatingNew: false,
  newLeaderboardName: "",
  nameValid: and("newLeaderboardName"),

  @discourseComputed("model.leaderboards.@each.created_at")
  sortedLeaderboards(leaderboards) {
    return leaderboards?.sortBy("created_at").reverse() || [];
  },

  @discourseComputed("selectedLeaderboardId")
  selectedLeaderboard(id) {
    if (!id) {
      return;
    }

    id = parseInt(id, 10);
    return this.model.leaderboards.findBy("id", id);
  },

  @action
  createNewLeaderboard() {
    if (this.loading) {
      return;
    }

    this.set("loading", true);
    const data = {
      name: this.newLeaderboardName,
      created_by_id: this.currentUser.id,
    };

    return ajax("/admin/plugins/gamification/leaderboard", {
      data,
      type: "POST",
    })
      .then((leaderboard) => {
        const newLeaderboard = EmberObject.create(leaderboard);
        this.set(
          "model.gamification_leaderboard",
          [newLeaderboard].concat(this.model.gamification_leaderboard)
        );
        this.resetNewLeaderboard();
        this.setProperties({
          loading: false,
        });
      })
      .catch(popupAjaxError);
  },

  @action
  resetNewLeaderboard() {
    this.setProperties({
      creatingNew: false,
      newLeaderboardName: "",
    });
  },

  @action
  destroyLeaderboard(leaderboard) {
    bootbox.confirm(
      I18n.t("gamification.leaderboard.confirm_destroy"),
      (confirm) => {
        if (!confirm) {
          return;
        }

        this.set("loading", true);
        return ajax(`/admin/plugins/gamification/leaderboard/${leaderboard.name}`, {
          type: "DELETE",
        })
          .then(() => {
            this.model.leaderboards.removeObject(leaderboard);
            this.set("loading", false);
          })
          .catch(popupAjaxError);
      }
    );
  },
});
