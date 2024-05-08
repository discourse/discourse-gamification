import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { Input } from "@ember/component";
import { action } from "@ember/object";
import { and } from "@ember/object/computed";
import { inject as service } from "@ember/service";
import { not } from "truth-helpers";
import DButton from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import i18n from "discourse-common/helpers/i18n";

export default class extends Component {
  @service currentUser;
  @service router;
  @service toasts;

  @tracked newLeaderboardName = "";
  @tracked loading = false;

  @and("newLeaderboardName") nameValid;

  @action
  createNewLeaderboard() {
    if (this.loading) {
      return;
    }

    this.loading = true;

    const data = {
      name: this.newLeaderboardName,
      created_by_id: this.currentUser.id,
    };

    return ajax("/admin/plugins/gamification/leaderboard", {
      data,
      type: "POST",
    })
      .then((leaderboard) => {
        this.toasts.success({
          duration: 3000,
          data: {
            message: i18n("gamification.leaderboard.create_success"),
          },
        });
        this.router.transitionTo(
          "adminPlugins.show.discourse-gamification-leaderboards.show",
          leaderboard.id
        );
      })
      .catch(popupAjaxError)
      .finally(() => {
        this.loading = false;
      });
  }

  <template>
    <div class="new-leaderboard-container">
      <Input
        @type="text"
        class="new-leaderboard__name"
        @value={{this.newLeaderboardName}}
        placeholder={{i18n "gamification.leaderboard.name_placeholder"}}
      />
      <DButton
        @label="gamification.create"
        @title="gamification.create"
        class="btn-primary new-leaderboard__create"
        @disabled={{not this.nameValid}}
        @action={{this.createNewLeaderboard}}
      />
      <DButton
        class="new-leaderboard__cancel"
        @label="gamification.cancel"
        @title="gamification.cancel"
        @action={{@onCancel}}
      />
    </div>
  </template>
}
