import Component from "@ember/component";
import { classNames, tagName } from "@ember-decorators/component";
import { i18n } from "discourse-i18n";
import GamificationScore from "../../components/gamification-score";

@tagName("")
@classNames("user-profile-secondary-outlet", "gamification-score")
export default class GamificationScoreConnector extends Component {
  <template>
    {{#if this.model.gamification_score}}
      <div>
        <dt>
          {{i18n "gamification.score"}}
        </dt>
        <dd>
          <GamificationScore @model={{this.model}} />
        </dd>
      </div>
    {{/if}}
  </template>
}
