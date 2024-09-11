import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { and } from "@ember/object/computed";
import { inject as service } from "@ember/service";
import DButton from "discourse/components/d-button";
import Form from "discourse/components/form";
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

  get formData() {
    return { name: "", created_by_id: this.currentUser.id };
  }

  @action
  async createNewLeaderboard(data) {
    if (this.loading) {
      return;
    }

    this.loading = true;

    try {
      const leaderboard = await ajax(
        "/admin/plugins/gamification/leaderboard",
        {
          data,
          type: "POST",
        }
      );
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
    } catch (err) {
      popupAjaxError(err);
    } finally {
      this.loading = false;
    }
  }

  <template>
    <div class="new-leaderboard-container">
      <Form
        @data={{this.formData}}
        @onSubmit={{this.createNewLeaderboard}}
        as |form|
      >
        <form.Row>
          <form.Field
            @name="name"
            @title={{i18n "gamification.leaderboard.name"}}
            @showTitle={{false}}
            class="new-leaderboard__name"
            @validation="required"
            as |field|
          >
            <field.Input
              placeholder={{i18n "gamification.leaderboard.name_placeholder"}}
            />
          </form.Field>
          <form.Submit />&nbsp;
          <DButton
            class="new-leaderboard__cancel form-kit__button"
            @label="gamification.cancel"
            @title="gamification.cancel"
            @action={{@onCancel}}
          />
        </form.Row>
      </Form>
    </div>
  </template>
}
