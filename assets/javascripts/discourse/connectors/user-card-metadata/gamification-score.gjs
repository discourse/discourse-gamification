import Component from "@ember/component";
import { classNames, tagName } from "@ember-decorators/component";
import { i18n } from "discourse-i18n";
import gamificationScore from "../../components/gamification-score";

@tagName("div")
@classNames("user-card-metadata-outlet", "gamification-score")
export default class GamificationScore extends Component {
  <template>
    {{#if this.user.gamification_score}}
      <span class="desc">{{i18n "gamification.score"}} </span>
      <span>{{gamificationScore model=this.user}}</span>
    {{/if}}
  </template>
}
