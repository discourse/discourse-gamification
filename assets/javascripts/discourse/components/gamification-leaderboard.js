import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import { action } from "@ember/object";
import showModal from "discourse/lib/show-modal";

export default Component.extend({
  tagName: "",

  @discourseComputed("model.users.[]")
  currentUserRanking(users) {
    const user = users.findBy("id", this.currentUser?.id);
    return user
      ? {
          user,
          total_score: user.total_score,
          position: users.indexOf(user) + 1,
        }
      : null;
  },

  @discourseComputed("model.users")
  winners(users) {
    return [
      { user: users[1], class: "second", position: 2 },
      { user: users[0], class: "first", position: 1 },
      { user: users[2], class: "third", position: 3 },
    ];
  },

  @discourseComputed("model.users.[]", "winners.length")
  ranking(users, winnersLength) {
    return users.slice(3).map((user, index) => {
      return { user, position: index + 1 + winnersLength };
    });
  },

  @action
  showLeaderboardInfo() {
    showModal("leaderboard-info");
  },
});
