import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import { query, exists } from "discourse/tests/helpers/qunit-helpers";
import hbs from "htmlbars-inline-precompile";
import { module, test } from "qunit";
import { render } from "@ember/test-helpers";

module(
  "Discourse Gamification | Component | gamification-score",
  function (hooks) {
    setupRenderingTest(hooks);

    test("Scores click link to leaderboard", async function (assert) {
      this.site.default_gamification_leaderboard_id = 1;
      this.set("user", { id: "1", username: "charlie", gamification_score: 1 });

      await render(hbs`<GamificationScore @model={{this.user}} />`);

      assert.ok(exists(".gamification-score a"), "scores are not clickable");
    });

    test("Scores show up and are not clickable", async function (assert) {
      this.set("user", { id: "1", username: "charlie", gamification_score: 1 });

      await render(hbs`<GamificationScore @model={{this.user}} />`);

      assert.ok(exists(".gamification-score"), "scores not showing up");
      assert.notOk(exists(".gamification-score a"), "scores are clickable");
    });
  }
);