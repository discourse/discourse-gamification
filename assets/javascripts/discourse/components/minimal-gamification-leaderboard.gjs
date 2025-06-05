import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { LinkTo } from "@ember/routing";
import { and } from "truth-helpers";
import icon from "discourse/helpers/d-icon";
import number from "discourse/helpers/number";
import { ajax } from "discourse/lib/ajax";
import { i18n } from "discourse-i18n";
import fullnumber from "../helpers/fullnumber";
import MinimalGamificationLeaderboardRow from "./minimal-gamification-leaderboard-row";

export default class extends Component {
  @tracked notTop10 = true;
  @tracked model = null;

  constructor() {
    super(...arguments);

    const count = this.args?.params?.count || 10;

    const data = {
      user_limit: count,
    };

    // used in the right sidebar blocks theme component
    const leaderboardId = this.args?.params?.id || null;
    const endpoint = leaderboardId
      ? `/leaderboard/${leaderboardId}`
      : "/leaderboard";

    ajax(endpoint, { data }).then((model) => {
      this.model = model;
    });
  }

  get currentUserRanking() {
    const user = this.model?.personal;
    if (user) {
      this.notTop10 = user.position > 10;
    }
    return user || null;
  }

  get ranking() {
    this.model?.users?.forEach((user) => {
      if (user.id === this.model.personal?.user?.id) {
        user.isCurrentUser = "true";
      }
      if (this.model.users.indexOf(user) === 0) {
        user.topRanked = true;
      }
    });
    return this.model?.users;
  }

  <template>
    <div class="leaderboard -minimal">
      <div class="page__header">
        <LinkTo
          @route="gamificationLeaderboard.byName"
          @model={{this.model.leaderboard.id}}
        >
          <h3 class="page__title">{{this.model.leaderboard.name}}</h3>
        </LinkTo>
      </div>

      <div class="ranking-col-names">
        <span>{{i18n "gamification.leaderboard.rank"}}</span>
        <span>{{icon "award"}}{{i18n "gamification.score"}}</span>
      </div>
      <div class="ranking-col-names__sticky-border"></div>
      {{#if (and this.currentUserRanking.user this.notTopTen)}}
        <div class="user -self">
          <div class="user__rank">{{this.currentUserRanking.position}}</div>
          <div class="user__name">{{i18n "gamification.you"}}</div>
          <div class="user__score">
            {{#if this.site.mobileView}}
              {{number this.currentUserRanking.user.total_score}}
            {{else}}
              {{fullnumber this.currentUserRanking.user.total_score}}
            {{/if}}
          </div>
        </div>
      {{/if}}

      {{#each this.ranking as |rank index|}}
        <MinimalGamificationLeaderboardRow @rank={{rank}} @index={{index}} />
      {{/each}}
    </div>
  </template>
}
