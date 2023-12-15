import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default DiscourseRoute.extend({
  router: service(),

  model() {
    return ajax(`/leaderboard`)
      .then((response) => {
        return response;
      })
      .catch(() => this.router.replaceWith("/404"));
  },
});
