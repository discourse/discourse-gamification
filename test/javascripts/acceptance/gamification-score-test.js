import {
  acceptance,
  exists,
  query,
} from "discourse/tests/helpers/qunit-helpers";
import { fixturesByUrl } from "discourse/tests/helpers/create-pretender";
import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import userFixtures from "discourse/tests/fixtures/user-fixtures";
import { cloneJSON } from "discourse-common/lib/object";

acceptance(
  "Discourse Gamification | User Card | Show Gamification Score",
  function (needs) {
    needs.user();
    needs.pretender((server, helper) => {
      const cardResponse = cloneJSON(userFixtures["/u/charlie/card.json"]);
      cardResponse.user.gamification_score = 10;
      server.get("/u/charlie/card.json", () => helper.response(cardResponse));
    });

    test("user card gamification score - score is present", async function (assert) {
      await visit("/t/internationalization-localization/280");
      await click('a[data-user-card="charlie"]');

      assert.ok(exists(".user-card .gamification-score"), "score is present");
      assert.ok(
        query(".user-card .gamification-score").innerText.includes("10"),
        "user card has gamification score"
      );
    });
  }
);

acceptance(
  "Discourse Gamification | User Profile | Show Gamification Score",
  function (needs) {
    needs.user();
    needs.pretender((server, helper) => {
      const profileResponse = cloneJSON(
        fixturesByUrl["/u/charlie/summary.json"]
      );
      profileResponse.user_summary.gamification_score = 10;

      server.get("/u/charlie/summary.json", () =>
        helper.response(profileResponse)
      );
    });

    test("user profile gamification score - score is present", async function (assert) {
      await visit("/u/charlie/summary");

      // find summary value here
    });
  }
);
