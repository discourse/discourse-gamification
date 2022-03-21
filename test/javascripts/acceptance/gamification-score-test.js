import { acceptance, exists, query } from "discourse/tests/helpers/qunit-helpers";
import { click, visit } from "@ember/test-helpers";
import User from "discourse/models/user";
import { test } from "qunit";
import userFixtures from "discourse/tests/fixtures/user-fixtures";
import { cloneJSON } from "discourse-common/lib/object";

acceptance("Discourse Gamification | User Card | Show Gamification Score", function (needs) {
  needs.user();
  needs.pretender((server, helper) => {
    const cardResponse = cloneJSON(userFixtures["/u/charlie/card.json"]);
    cardResponse.user.gamification_score = 10
    server.get("/u/charlie/card.json", () => helper.response(cardResponse));
  });

  test("user card gamification score - score is present", async function (assert) {
    await visit("/t/internationalization-localization/280");
    await click('a[data-user-card="charlie"]');

    debugger
    assert.ok(
      exists(".user-card .gamification-score"),
      "score is present"

    );
    assert.ok(
      query(".user-card .gamification-score").innerText.includes("10"),
      "user card has gamification score"
    );
  });
});
