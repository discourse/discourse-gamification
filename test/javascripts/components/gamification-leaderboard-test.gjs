import { render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import { query } from "discourse/tests/helpers/qunit-helpers";
import GamificationLeaderboard from "discourse/plugins/discourse-gamification/discourse/components/gamification-leaderboard";

function displayName() {
  return query(".winner__name").innerText.trim();
}

module(
  "Discourse Gamification | Component | gamification-leaderboard",
  function (hooks) {
    setupRenderingTest(hooks);

    test("Display name prioritizes name", async function (assert) {
      const self = this;

      this.siteSettings.prioritize_username_in_ux = false;
      this.set("winner", { username: "id", name: "bob" });
      this.set("model", {
        leaderboard: "",
        personal: "",
        users: [this.winner],
      });

      await render(
        <template><GamificationLeaderboard @model={{self.model}} /></template>
      );

      assert.strictEqual(displayName(), "bob");
    });

    test("Display name prioritizes username", async function (assert) {
      const self = this;

      this.siteSettings.prioritize_username_in_ux = true;
      this.set("winner", { username: "id", name: "bob" });
      this.set("model", {
        leaderboard: "",
        personal: "",
        users: [this.winner],
      });

      await render(
        <template><GamificationLeaderboard @model={{self.model}} /></template>
      );

      assert.strictEqual(displayName(), "id");
    });

    test("Display name prioritizes username when name is empty", async function (assert) {
      const self = this;

      this.siteSettings.prioritize_username_in_ux = false;
      this.set("winner", { username: "id", name: "" });
      this.set("model", {
        leaderboard: "",
        personal: "",
        users: [this.winner],
      });

      await render(
        <template><GamificationLeaderboard @model={{self.model}} /></template>
      );

      assert.strictEqual(displayName(), "id");
    });
  }
);
