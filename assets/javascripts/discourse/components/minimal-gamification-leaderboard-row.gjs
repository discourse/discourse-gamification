import Component from "@ember/component";
import { or } from "truth-helpers";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";
import number from "discourse/helpers/number";
import { i18n } from "discourse-i18n";
import sum from "../helpers/sum";

export default class MinimalGamificationLeaderboardRow extends Component {
  <template>
    <div
      class="user {{if this.rank.isCurrentUser 'user-highlight'}}"
      id="leaderboard-user-{{this.rank.id}}"
    >
      <div class="user__rank {{if this.rank.topRanked '-winner'}}">{{#if
          this.rank.topRanked
        }}
          {{icon "crown"}}
        {{else}} {{sum this.index 1}}{{/if}}</div>
      <div
        class="user__avatar clickable"
        role="button"
        data-user-card={{this.rank.username}}
      >
        {{avatar this.rank imageSize="small"}}
        {{#if this.rank.isCurrentUser}}
          <span class="user__name">{{i18n "gamification.you"}}</span>
        {{else}}
          <span class="user__name">
            {{#if this.siteSettings.prioritize_username_in_ux}}
              {{this.rank.username}}
            {{else}}
              {{or this.rank.name this.rank.username}}
            {{/if}}
          </span>
        {{/if}}
      </div>
      <div class="user__score">
        {{number this.rank.total_score}}
      </div>
    </div>
  </template>
}
