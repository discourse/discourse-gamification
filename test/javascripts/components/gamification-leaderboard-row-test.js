import { render } from "@ember/test-helpers";
import hbs from "htmlbars-inline-precompile";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import { query } from "discourse/tests/helpers/qunit-helpers";

function displayName() {
  return query(".user__name").innerText.trim();
}

module(
  "Discourse Gamification | Component | gamification-leaderboard-row",
  function (hooks) {
    setupRenderingTest(hooks);

    test("Display name prioritizes name", async function (assert) {
      this.siteSettings.prioritize_username_in_ux = false;
      this.set("rank", { username: "id", name: "bob" });

      await render(hbs`<GamificationLeaderboardRow @rank={{this.rank}} />`);

      assert.strictEqual(displayName(), "bob");
    });

    test("Display name prioritizes username", async function (assert) {
      this.siteSettings.prioritize_username_in_ux = true;
      this.set("rank", { username: "id", name: "bob" });

      await render(hbs`<GamificationLeaderboardRow @rank={{this.rank}} />`);

      assert.strictEqual(displayName(), "id");
    });

    test("Display name prioritizes username when name is empty", async function (assert) {
      this.siteSettings.prioritize_username_in_ux = false;
      this.set("rank", { username: "id", name: "" });

      await render(hbs`<GamificationLeaderboardRow @rank={{this.rank}} />`);

      assert.strictEqual(displayName(), "id");
    });
  }
);
