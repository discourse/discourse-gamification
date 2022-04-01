import Controller from "@ember/controller";
import EmberObject, { action } from "@ember/object";
import bootbox from "bootbox";
import discourseComputed from "discourse-common/utils/decorators";
import { and } from "@ember/object/computed";
import I18n from "I18n";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Controller.extend({
  loading: false,
  creatingNew: false,
  newLeaderboardName: "",
  nameValid: and("newLeaderboardName"),
  toDate: "",
  fromDate: "",

  @discourseComputed("model.leaderboards.@each.updated_at")
  sortedLeaderboards(leaderboards) {
    return leaderboards?.sortBy("updated_at").reverse() || [];
  },

  @discourseComputed("selectedLeaderboardId")
  selectedLeaderboard(id) {
    if (!id) {
      return;
    }

    id = parseInt(id, 10);
    return this.model.leaderboards.findBy("id", id);
  },

  @discourseComputed("selectedLeaderboard.name")
  saveEditDisabled(name) {
    return !name;
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
          "model.leaderboards",
          [newLeaderboard].concat(this.model.leaderboards)
        );
        this.resetNewLeaderboard();
        this.setProperties({
          loading: false,
          selectedLeaderboardId: leaderboard.id,
        });
      })
      .catch(popupAjaxError);
  },

  @action
  resetNewLeaderboard() {
    this.setProperties({
      creatingNew: false,
      newLeaderboardName: "",
      newLeaderboardId: null,
      toDate: "", 
      fromDate: "",
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
        return ajax(
          `/admin/plugins/gamification/leaderboard/${leaderboard.id}`,
          {
            type: "DELETE",
          }
        )
          .then(() => {
            this.model.leaderboards.removeObject(leaderboard);
            this.set("loading", false);
          })
          .catch(popupAjaxError);
      }
    );
  },

  @action
  saveEdit() {
    this.set("loading", true);
    const data = {
      name: this.selectedLeaderboard.name,
      to_date: this.toDate,
      from_date: this.fromDate,
    };

    return ajax(
      `/admin/plugins/gamification/leaderboard/${this.selectedLeaderboard.id}`,
      {
        data,
        type: "PUT",
      }
    )
      .then(() => {
        this.selectedLeaderboard.set("updated_at", new Date());
        this.setProperties({
          loading: false,
          selectedLeaderboardId: null,
          toDate: "",
          fromDate: "",
        });
      })
      .catch(popupAjaxError);
  },
});
