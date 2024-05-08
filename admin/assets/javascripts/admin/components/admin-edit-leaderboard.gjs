import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { Input } from "@ember/component";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import { LinkTo } from "@ember/routing";
import { inject as service } from "@ember/service";
import BackButton from "discourse/components/back-button";
import DButton from "discourse/components/d-button";
import DatePicker from "discourse/components/date-picker";
import DatePickerPast from "discourse/components/date-picker-past";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { AUTO_GROUPS } from "discourse/lib/constants";
import i18n from "discourse-common/helpers/i18n";
import GroupChooser from "select-kit/components/group-chooser";
import PeriodInput from "discourse/plugins/discourse-gamification/discourse/components/period-input";

export default class AdminEditLeaderboard extends Component {
  @service currentUser;
  @service site;
  @service toasts;
  @service router;

  @tracked fromDate = "";
  @tracked toDate = "";
  @tracked includedGroupIds = [];
  @tracked visibleToGroupIds = [];
  @tracked excludedGroupIds = [];

  get siteGroups() {
    return this.site.groups.rejectBy("id", AUTO_GROUPS.everyone.id);
  }

  get saveEditDisabled() {
    return !this.args.leaderboard.name;
  }

  @action
  saveEdit() {
    const data = {
      name: this.args.leaderboard.name,
      to_date: this.toDate || this.args.leaderboard.toDate,
      from_date: this.fromDate || this.args.leaderboard.fromDate,
      visible_to_groups_ids: this.visibleGroupIds,
      included_groups_ids: this.includedGroupIds,
      excluded_groups_ids: this.excludedGroupIds,
      default_period: this.args.leaderboard.defaultPeriod,
    };

    return ajax(
      `/admin/plugins/gamification/leaderboard/${this.args.leaderboard.id}`,
      {
        data,
        type: "PUT",
      }
    )
      .then(() => {
        this.toasts.success({
          duration: 3000,
          data: {
            message: i18n("gamification.leaderboard.save_success"),
          },
        });
        this.router.transitionTo(
          "adminPlugins.show.discourse-gamification-leaderboards.index"
        );
      })
      .catch(popupAjaxError);
  }

  <template>
    <BackButton
      @route="adminPlugins.show.discourse-gamification-leaderboards"
      @label="gamification.back"
    />
    <form class="leaderboard-edit form-vertical">
      <div class="control-group">
        <div class="control-group">
          <label class="control-label">
            {{i18n "gamification.leaderboard.name"}}
          </label>
          <Input
            @type="text"
            class="leaderboard-edit__name"
            @value={{@leaderboard.name}}
            placeholder={{i18n "gamification.leaderboard.name"}}
          />
        </div>
        <div class="control-group">
          <label class="control-label">
            {{i18n "gamification.leaderboard.date.range"}}
          </label>
          <div class="controls">
            <DatePickerPast
              @placeholder="yyyy-mm-dd"
              @value={{@leaderboard.fromDate}}
              @onSelect={{fn (mut this.fromDate)}}
              class="leaderboard-edit__from-date date-input"
              class="date-input"
            />
            <DatePicker
              @placeholder="yyyy-mm-dd"
              @value={{@leaderboard.toDate}}
              @onSelect={{fn (mut this.toDate)}}
              class="leaderboard-edit__to-date date-input"
              class="date-input"
            />
            <div>{{i18n "gamification.leaderboard.date.helper"}}</div>
          </div>
        </div>
        <div class="control-group">
          <label class="control-label">
            {{i18n "gamification.leaderboard.included_groups"}}
          </label>
          {{log @leaderboard}}
          <GroupChooser
            @id="leaderboard-edit__included-groups"
            @content={{this.siteGroups}}
            @value={{@leaderboard.includedGroupIds}}
            @labelProperty="name"
            @onChange={{fn (mut this.includedGroupIds)}}
          />
          <div>{{i18n "gamification.leaderboard.included_groups_help"}}</div>
        </div>
        <div class="control-group">
          <label class="control-label">
            {{i18n "gamification.leaderboard.excluded_groups"}}
          </label>
          <GroupChooser
            @id="leaderboard-edit__excluded-groups"
            @content={{this.siteGroups}}
            @value={{@leaderboard.excludedGroupIds}}
            @labelProperty="name"
            @onChange={{fn (mut this.excludedGroupIds)}}
          />
          <div>{{i18n "gamification.leaderboard.excluded_groups_help"}}</div>
        </div>
        <div class="control-group">
          <label class="control-label">
            {{i18n "gamification.leaderboard.visible_to_groups"}}
          </label>
          <GroupChooser
            @id="leaderboard-edit__visible-groups"
            @content={{this.siteGroups}}
            @value={{@leaderboard.visibleToGroupIds}}
            @labelProperty="name"
            @onChange={{fn (mut this.visibleToGroupIds)}}
          />
          <div>{{i18n "gamification.leaderboard.visible_to_groups_help"}}</div>
        </div>
        <div class="control-group">
          <label class="control-label">
            {{i18n "gamification.leaderboard.default_period"}}
          </label>
          <PeriodInput @value={{@leaderboard.defaultPeriod}} />
          <div>{{i18n "gamification.leaderboard.default_period_help"}}</div>
        </div>
      </div>
      <DButton
        class="leaderboard-edit__save btn-primary"
        @label="gamification.save"
        @action={{this.saveEdit}}
        @disabled={{this.saveEditDisabled}}
      />
      <LinkTo
        class="btn-secondary leaderboard-edit__cancel"
        @label="gamification.cancel"
        @route="adminPlugins.show.discourse-gamification-leaderboards"
      />
    </form>
  </template>
}
