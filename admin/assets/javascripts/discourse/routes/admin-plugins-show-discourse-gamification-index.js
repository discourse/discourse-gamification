import { inject as service } from "@ember/service";
import DiscourseRoute from "discourse/routes/discourse";

export default class DiscourseGamificationIndexRoute extends DiscourseRoute {
  @service router;
}
