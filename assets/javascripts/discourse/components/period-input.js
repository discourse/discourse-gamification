import { computed } from "@ember/object";
import { classNames } from "@ember-decorators/component";
import I18n from "I18n";
import ComboBoxComponent from "select-kit/components/combo-box";
import {
  pluginApiIdentifiers,
  selectKitOptions,
} from "select-kit/components/select-kit";
import { LEADERBOARD_PERIODS } from "discourse/plugins/discourse-gamification/discourse/components/gamification-leaderboard";

@selectKitOptions({
  filterable: true,
  allowAny: false,
})
@pluginApiIdentifiers("period-input")
@classNames("period-input", "period-input")
export default class PeriodInput extends ComboBoxComponent {
  @computed
  get content() {
    let periods = [];

    periods = periods.concat(
      LEADERBOARD_PERIODS.map((period, index) => ({
        name: I18n.t(`gamification.leaderboard.period.${period}`),
        id: index,
      }))
    );

    return periods;
  }
}
