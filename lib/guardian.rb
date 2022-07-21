# frozen_string_literal: true

module DiscourseGamification
  module Guardian
    def can_see_leaderboard?(leaderboard)
      return true if leaderboard.visible_to_groups_ids.empty?
      return true if self.is_admin?
      return true if self.user && !(leaderboard.visible_to_groups_ids & self.user.group_ids).empty?

      false
    end
  end
end
