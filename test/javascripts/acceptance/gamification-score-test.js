import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import userFixtures from "discourse/tests/fixtures/user-fixtures";
import { fixturesByUrl } from "discourse/tests/helpers/create-pretender";
import {
  acceptance,
  exists,
  query,
} from "discourse/tests/helpers/qunit-helpers";
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
  "Discourse Gamification | User Metadata | Show Gamification Score",
  function (needs) {
    needs.user();
    needs.pretender((server, helper) => {
      const userResponse = cloneJSON(fixturesByUrl["/u/charlie.json"]);
      userResponse.user.gamification_score = 10;

      server.get("/u/charlie.json", () => helper.response(userResponse));
    });

    test("user profile gamification score - score is present", async function (assert) {
      await visit("/u/charlie/summary");

      assert.ok(
        exists(".user-profile-secondary-outlet.gamification-score"),
        "score is present"
      );
      assert.ok(
        query(
          ".user-profile-secondary-outlet.gamification-score"
        ).innerText.includes("10"),
        "user metadata has gamification score"
      );
    });
  }
);
