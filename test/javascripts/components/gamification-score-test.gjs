import { render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import { exists } from "discourse/tests/helpers/qunit-helpers";
import GamificationScore from "discourse/plugins/discourse-gamification/discourse/components/gamification-score";

module(
  "Discourse Gamification | Component | gamification-score",
  function (hooks) {
    setupRenderingTest(hooks);

    test("Scores click link to leaderboard", async function (assert) {
      const self = this;

      this.site.default_gamification_leaderboard_id = 1;
      this.set("user", { id: "1", username: "charlie", gamification_score: 1 });

      await render(
        <template><GamificationScore @model={{self.user}} /></template>
      );

      assert.ok(exists(".gamification-score a"), "scores are not clickable");
    });

    test("Scores show up and are not clickable", async function (assert) {
      const self = this;

      this.set("user", { id: "1", username: "charlie", gamification_score: 1 });

      await render(
        <template><GamificationScore @model={{self.user}} /></template>
      );

      assert.ok(exists(".gamification-score"), "scores not showing up");
      assert.notOk(exists(".gamification-score a"), "scores are clickable");
    });
  }
);
