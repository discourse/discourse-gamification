import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import { query } from "discourse/tests/helpers/qunit-helpers";
import hbs from "htmlbars-inline-precompile";
import { module, test } from "qunit";
import { render } from "@ember/test-helpers";

function displayName() {
  return query(".winner__name").innerText.trim();
}

module(
  "Discourse Gamification | Component | gamification-leaderboard",
  function (hooks) {
    setupRenderingTest(hooks);

    test("name", async function (assert) {
      this.siteSettings.prioritize_username_in_ux = false;
      this.set("winner", { username: "id", name: "bob" });
      this.set("model", {
        leaderboard: "",
        personal: "",
        users: [this.winner],
      });

      await render(hbs`<GamificationLeaderboard @model={{this.model}} />`);

      assert.strictEqual(displayName(), "bob");
    });

    test("username", async function (assert) {
      this.siteSettings.prioritize_username_in_ux = true;
      this.set("winner", { username: "id", name: "bob" });
      this.set("model", {
        leaderboard: "",
        personal: "",
        users: [this.winner],
      });

      await render(hbs`<GamificationLeaderboard @model={{this.model}} />`);

      assert.strictEqual(displayName(), "id");
    });
  }
);
