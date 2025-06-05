import { render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import { query } from "discourse/tests/helpers/qunit-helpers";
import GamificationLeaderboardRow from "discourse/plugins/discourse-gamification/discourse/components/gamification-leaderboard-row";

function displayName() {
  return query(".user__name").innerText.trim();
}

module(
  "Discourse Gamification | Component | gamification-leaderboard-row",
  function (hooks) {
    setupRenderingTest(hooks);

    test("Display name prioritizes name", async function (assert) {
      const self = this;

      this.siteSettings.prioritize_username_in_ux = false;
      this.set("rank", { username: "id", name: "bob" });

      await render(
        <template><GamificationLeaderboardRow @rank={{self.rank}} /></template>
      );

      assert.strictEqual(displayName(), "bob");
    });

    test("Display name prioritizes username", async function (assert) {
      const self = this;

      this.siteSettings.prioritize_username_in_ux = true;
      this.set("rank", { username: "id", name: "bob" });

      await render(
        <template><GamificationLeaderboardRow @rank={{self.rank}} /></template>
      );

      assert.strictEqual(displayName(), "id");
    });

    test("Display name prioritizes username when name is empty", async function (assert) {
      const self = this;

      this.siteSettings.prioritize_username_in_ux = false;
      this.set("rank", { username: "id", name: "" });

      await render(
        <template><GamificationLeaderboardRow @rank={{self.rank}} /></template>
      );

      assert.strictEqual(displayName(), "id");
    });
  }
);
