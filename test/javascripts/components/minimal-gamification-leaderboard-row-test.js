import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import { query } from "discourse/tests/helpers/qunit-helpers";
import hbs from "htmlbars-inline-precompile";
import { module, test } from "qunit";
import { render } from "@ember/test-helpers";

function displayName() {
  return query(".user__name").innerText.trim();
}

module(
  "Discourse Gamification | Component | minimal-gamification-leaderboard-row",
  function (hooks) {
    setupRenderingTest(hooks);

    test("name", async function (assert) {
      this.siteSettings.prioritize_username_in_ux = false;
      this.set("rank", { username: "id", name: "bob" });

      await render(
        hbs`<MinimalGamificationLeaderboardRow @rank={{this.rank}} />`
      );

      assert.strictEqual(displayName(), "bob");
    });

    test("username", async function (assert) {
      this.siteSettings.prioritize_username_in_ux = true;
      this.set("rank", { username: "id", name: "bob" });

      await render(
        hbs`<MinimalGamificationLeaderboardRow @rank={{this.rank}} />`
      );

      assert.strictEqual(displayName(), "id");
    });
  }
);
