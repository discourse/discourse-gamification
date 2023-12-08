import DModal from "discourse/components/d-modal";
import i18n from "discourse-common/helpers/i18n";
import icon from "discourse-common/helpers/d-icon";
import { htmlSafe } from "@ember/template";

const LeaderboardInfo = <template>
  <DModal
    @title={{i18n "gamification.leaderboard.modal.title"}}
    @closeModal={{@closeModal}}
    class="leaderboard-info-modal"
  >
    <:body>
      {{icon "award"}}
      {{htmlSafe (i18n "gamification.leaderboard.modal.text")}}
    </:body>
  </DModal>
</template>;

export default LeaderboardInfo;
