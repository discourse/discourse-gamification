import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { bind } from "discourse-common/utils/decorators";
import I18n from "I18n";

export default class RecalculateScoresForm extends Component {
  @service messageBus;
  @tracked updateRangeValue = 0;
  @tracked recalculateFromDate = "";
  @tracked haveAvailability = true;
  @tracked remaining;
  @tracked status = "initial";

  constructor() {
    super(...arguments);

    this.updateRange = [
      {
        name: I18n.t("gamification.update_range.last_10_days"),
        value: 0,
        calculation: { count: 10, type: "days" },
      },
      {
        name: I18n.t("gamification.update_range.last_30_days"),
        value: 1,
        calculation: { count: 30, type: "days" },
      },
      {
        name: I18n.t("gamification.update_range.last_90_days"),
        value: 2,
        calculation: { count: 90, type: "days" },
      },
      {
        name: I18n.t("gamification.update_range.last_year"),
        value: 3,
        calculation: { count: 1, type: "year" },
      },
      { name: I18n.t("gamification.update_range.all_time"), value: 4 },
      { name: I18n.t("gamification.update_range.custom_date_range"), value: 5 },
    ];

    this.haveAvailability = this.args.model.recalculate_scores_remaining > 0;
    this.remaining = this.args.model.recalculate_scores_remaining;
    this.messageBus.subscribe("/recalculate_scores", this.onMessage);
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this.messageBus.unsubscribe("/recalculate_scores", this.onMessage);
  }

  @bind
  onMessage(message) {
    if (message.success) {
      this.status = "complete";
      this.args.model.recalculate_scores_remaining = message.remaining;
      this.remaining = message.remaining;
    }
  }

  get remainingText() {
    return I18n.t("gamification.daily_update_scores_availability", {
      count: this.remaining,
    });
  }

  get applyDisabled() {
    if (!this.haveAvailability || this.status !== "initial") {
      return true;
    } else if (
      this.updateRangeValue === 5 &&
      this.recalculateFromDate <= moment().locale("en").utc().endOf("day")
    ) {
      return true;
    } else {
      return false;
    }
  }

  get dateRange() {
    if (this.updateRangeValue === 4) {
      return;
    }

    let today = moment().locale("en").utc().endOf("day");
    let pastDate = this.dateRangeToDate(this.updateRangeValue);
    return `${pastDate} - ${today.format(
      I18n.t("dates.long_with_year_no_time")
    )}`;
  }

  @bind
  dateRangeToDate(updateRangeValue) {
    if (updateRangeValue === 4) {
      return "2014-8-26";
    }

    if (updateRangeValue === 5) {
      return this.recalculateFromDate;
    }

    let today = moment().locale("en").utc().endOf("day");
    let updateRange = this.updateRange.find((obj) => {
      return obj.value === updateRangeValue;
    });
    let pastDate = today
      .clone()
      .subtract(updateRange.calculation.count, updateRange.calculation.type);

    return pastDate.format(I18n.t("dates.long_with_year_no_time"));
  }

  @action
  apply() {
    this.status = "loading";
    const data = {
      from_date: this.dateRangeToDate(this.updateRangeValue),
    };

    return ajax(`/admin/plugins/gamification/recalculate-scores.json`, {
      data,
      type: "PUT",
    }).catch(popupAjaxError);
  }
}
