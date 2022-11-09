import Controller from "@ember/controller";
import EmberObject, { action } from "@ember/object";
import discourseComputed from "discourse-common/utils/decorators";
import { and } from "@ember/object/computed";
import I18n from "I18n";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { inject as service } from "@ember/service";
import { LEADERBOARD_PERIODS } from "discourse/plugins/discourse-gamification/discourse/components/gamification-leaderboard";

export default Controller.extend({
  dialog: service(),
  loading: false,
  creatingNew: false,
  newLeaderboardName: "",
  nameValid: and("newLeaderboardName"),
  toDate: "",
  fromDate: "",
  visibleGroupIds: [],
  includedGroupIds: [],
  excludedGroupIds: [],

  @discourseComputed("model.leaderboards.@each.updated_at")
  sortedLeaderboards(leaderboards) {
    leaderboards.map((leaderboard) => {
      if (Number.isInteger(leaderboard.default_period)) {
        leaderboard.default_period = I18n.t(
          `gamification.leaderboard.period.${
            LEADERBOARD_PERIODS[leaderboard.default_period]
          }`
        );
      }
    });
    return leaderboards?.sortBy("updated_at").reverse() || [];
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
            this.model.leaderboards.removeObject(leaderboard);
            this.set("loading", false);
          })
          .catch(popupAjaxError);
      },
    });
  },

  @action
  saveEdit() {
    this.set("loading", true);
    const data = {
      name: this.selectedLeaderboard.name,
      to_date: this.toDate || this.selectedLeaderboard.to_date,
      from_date: this.fromDate || this.selectedLeaderboard.from_date,
      visible_to_groups_ids: this.visibleGroupIds,
      included_groups_ids: this.includedGroupIds,
      excluded_groups_ids: this.excludedGroupIds,
      default_period: this.selectedLeaderboard.default_period,
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
        if (this.visibleGroupIds) {
          this.selectedLeaderboard.set(
            "visible_to_groups_ids",
            this.visibleGroupIds
          );
        }
        if (this.includedGroupIds) {
          this.selectedLeaderboard.set(
            "included_groups_ids",
            this.includedGroupIds
          );
        }
        if (this.excludedGroupIds) {
          this.selectedLeaderboard.set(
            "excluded_groups_ids",
            this.excludedGroupIds
          );
        }
        this.setProperties({
          loading: false,
          selectedLeaderboardId: null,
          toDate: "",
          fromDate: "",
          visibleGroupIds: [],
          includedGroupIds: [],
          excludedGroupIds: [],
          default_period: "0",
        });
      })
      .catch(popupAjaxError);
  },
});
