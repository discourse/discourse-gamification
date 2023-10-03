import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default DiscourseRoute.extend({
  model() {
    return ajax(`/leaderboard`)
      .then((response) => {
        return response;
      })
      .catch(() => this.replaceWith("/404"));
  },
});
