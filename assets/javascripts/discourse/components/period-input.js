import { computed } from "@ember/object";
import I18n from "I18n";
import ComboBoxComponent from "select-kit/components/combo-box";
import { LEADERBOARD_PERIODS } from "discourse/plugins/discourse-gamification/discourse/components/gamification-leaderboard";

export default ComboBoxComponent.extend({
  pluginApiIdentifiers: ["period-input"],
  classNames: ["period-input", "period-input"],

  selectKitOptions: {
    filterable: true,
    allowAny: false,
  },

  content: computed(function () {
    let periods = [];

    periods = periods.concat(
      LEADERBOARD_PERIODS.map((period, index) => ({
        name: I18n.t(`gamification.leaderboard.period.${period}`),
        id: index,
      }))
    );

    return periods;
  }),
});
