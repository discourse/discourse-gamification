# frozen_string_literal: true

# name: discourse-gamification
# about: Award users with a score for accomplishments
# version: 0.0.1
# authors: Discourse
# url: https://github.com/discourse/discourse-gamification
# required_version: 2.7.0
# transpile_js: true

enabled_site_setting :discourse_gamification_enabled

register_asset "stylesheets/common/leaderboard.scss"
register_asset "stylesheets/desktop/leaderboard.scss", :desktop
register_asset "stylesheets/mobile/leaderboard.scss", :mobile
register_asset "stylesheets/common/leaderboard-info-modal.scss"
register_asset "stylesheets/common/leaderboard-minimal.scss"
register_asset "stylesheets/desktop/leaderboard-info-modal.scss", :desktop
register_asset "stylesheets/mobile/leaderboard-info-modal.scss", :mobile
register_asset "stylesheets/common/leaderboard-admin.scss"

register_svg_icon "crown"
register_svg_icon "award"

module ::DiscourseGamification
  PLUGIN_NAME = "discourse-gamification"
end

require_relative "lib/discourse_gamification/engine"

after_initialize do
  # route: /admin/plugins/gamification
  add_admin_route "gamification.admin.title", "gamification"

  require_relative "jobs/scheduled/update_scores_for_ten_days"
  require_relative "jobs/scheduled/update_scores_for_today"
  require_relative "lib/discourse_gamification/directory_integration"
  require_relative "lib/discourse_gamification/guardian_extension"
  require_relative "lib/discourse_gamification/scorables/scorable"
  require_relative "lib/discourse_gamification/scorables/day_visited"
  require_relative "lib/discourse_gamification/scorables/flag_created"
  require_relative "lib/discourse_gamification/scorables/like_given"
  require_relative "lib/discourse_gamification/scorables/like_received"
  require_relative "lib/discourse_gamification/scorables/post_created"
  require_relative "lib/discourse_gamification/scorables/post_read"
  require_relative "lib/discourse_gamification/scorables/solutions"
  require_relative "lib/discourse_gamification/scorables/time_read"
  require_relative "lib/discourse_gamification/scorables/topic_created"
  require_relative "lib/discourse_gamification/scorables/user_invited"
  require_relative "lib/discourse_gamification/user_extension"

  reloadable_patch do |plugin|
    User.class_eval { prepend DiscourseGamification::UserExtension }
    Guardian.include(DiscourseGamification::GuardianExtension)
  end

  if respond_to?(:add_directory_column)
    add_directory_column(
      "gamification_score",
      query: DiscourseGamification::DirectoryIntegration.query,
    )
  end

  add_to_serializer(:user_card, :gamification_score) { object.gamification_score }
  add_to_serializer(:site, :default_gamification_leaderboard_id) { DiscourseGamification::GamificationLeaderboard.first.id }

  SeedFu.fixture_paths << Rails
    .root
    .join("plugins", "discourse-gamification", "db", "fixtures")
    .to_s
end
