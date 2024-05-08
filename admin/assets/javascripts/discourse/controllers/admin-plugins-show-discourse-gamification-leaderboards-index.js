import Controller from "@ember/controller";
import { action } from "@ember/object";
import { and } from "@ember/object/computed";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import discourseComputed from "discourse-common/utils/decorators";
import I18n from "I18n";
import RecalculateScoresForm from "discourse/plugins/discourse-gamification/discourse/components/modal/recalculate-scores-form";

export default Controller.extend({
  modal: service(),
  dialog: service(),
  toasts: service(),
  loading: false,
  creatingNew: false,
  newLeaderboardName: "",
  nameValid: and("newLeaderboardName"),
  toDate: "",
  fromDate: "",
  visibleGroupIds: [],
  includedGroupIds: [],
  excludedGroupIds: [],

  @discourseComputed("model.leaderboards.@each.updatedAt")
  sortedLeaderboards(leaderboards) {
    return leaderboards?.sortBy("updatedAt").reverse() || [];
  },

  @discourseComputed("selectedLeaderboardId")
  selectedLeaderboard(id) {
    if (!id) {
      return;
    }

    id = parseInt(id, 10);
    const leaderboard = this.model.leaderboards.findBy("id", id);

    this.leaderboardChanged(leaderboard);

    return leaderboard;
  },

  @discourseComputed("site.groups")
  siteGroups(groups) {
    // prevents group "everyone" to be listed
    return groups.filter((g) => g.id !== 0);
  },

  leaderboardChanged(leaderboard) {
    this.set(
      "visibleGroupIds",
      this.filterGroupsById(leaderboard.visible_to_groups_ids)
    );
    this.set(
      "includedGroupIds",
      this.filterGroupsById(leaderboard.included_groups_ids)
    );
    this.set(
      "excludedGroupIds",
      this.filterGroupsById(leaderboard.excluded_groups_ids)
    );
  },

  filterGroupsById(groupIds) {
    if (!groupIds.length) {
      return [];
    }
    const filteredGroups = this.model.groups.filter((group) =>
      groupIds.includes(group.id)
    );
    return filteredGroups.mapBy("id");
  },

  @action
  resetNewLeaderboard() {
    this.setProperties({
      creatingNew: false,
      toDate: "",
      fromDate: "",
      visibleGroupIds: [],
      includedGroupIds: [],
      excludedGroupIds: [],
    });
  },

  @action
  destroyLeaderboard(leaderboard) {
    this.dialog.deleteConfirm({
      message: I18n.t("gamification.leaderboard.confirm_destroy"),
      didConfirm: () => {
        this.set("loading", true);
        return ajax(
          `/admin/plugins/gamification/leaderboard/${leaderboard.id}`,
          {
            type: "DELETE",
          }
        )
          .then(() => {
            this.toasts.success({
              duration: 3000,
              data: {
                message: I18n.t("gamification.leaderboard.delete_success"),
              },
            });
            this.model.leaderboards.removeObject(leaderboard);
            this.set("loading", false);
          })
          .catch(popupAjaxError);
      },
    });
  },

  @action
  recalculateScores() {
    this.modal.show(RecalculateScoresForm, {
      model: this.model,
    });
  },
});
