import Controller from "@ember/controller";
import ModalFunctionality from "discourse/mixins/modal-functionality";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import I18n from "I18n";
import { bind } from "discourse-common/utils/decorators";
import discourseComputed from "discourse-common/utils/decorators";

export default Controller.extend(ModalFunctionality, {
  updateRangeValue: 0,
  recalculateFromDate: "",
  haveAvailability: true,

  init() {
    this._super(...arguments);

    this.saveAttrNames = ["update_range"];

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
  },

  onShow() {
    this.setProperties({
      haveAvailability: this.model.recalculate_scores_remaining > 0,
      status: "initial",
    });
    this.messageBus.subscribe("/recalculate_scores", this.onMessage);
  },

  onClose() {
    this.messageBus.unsubscribe("/recalculate_scores", this.onMessage);
  },

  @bind
  onMessage(message) {
    if (message.success) {
      this.setProperties({
        status: "complete",
        "model.recalculate_scores_remaining": message.remaining,
      });
    }
  },

  @discourseComputed("model.recalculate_scores_remaining")
  remainingText(remaining) {
    return I18n.t("gamification.daily_update_scores_availability", {
      count: remaining,
    });
  },

  @discourseComputed(
    "updateRangeValue",
    "haveAvailability",
    "status",
    "recalculateFromDate"
  )
  applyDisabled(
    updateRangeValue,
    haveAvailability,
    status,
    recalculateFromDate
  ) {
    if (!haveAvailability || status !== "initial") {
      return true;
    } else if (
      updateRangeValue === 5 &&
      recalculateFromDate <= moment().locale("en").utc().endOf("day")
    ) {
      return true;
    } else {
      return false;
    }
  },

  @discourseComputed("updateRangeValue")
  dateRange(updateRangeValue) {
    if (updateRangeValue === 4) {
      return;
    }

    let today = moment().locale("en").utc().endOf("day");
    let pastDate = this.dateRangeToDate(updateRangeValue);
    return `${pastDate} - ${today.format(
      I18n.t("dates.long_with_year_no_time")
    )}`;
  },

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
  },

  actions: {
    apply() {
      this.set("status", "loading");
      const data = {
        from_date: this.dateRangeToDate(this.updateRangeValue),
      };

      return ajax(`/admin/plugins/gamification/recalculate-scores.json`, {
        data,
        type: "PUT",
      }).catch(popupAjaxError);
    },
  },
});
