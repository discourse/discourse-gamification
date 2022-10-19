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
register_asset "stylesheets/desktop/leaderboard-info-modal.scss", :desktop
register_asset "stylesheets/mobile/leaderboard-info-modal.scss", :mobile
register_asset "stylesheets/common/leaderboard-admin.scss"

register_svg_icon "crown"
register_svg_icon "award"

after_initialize do
  module ::DiscourseGamification
    PLUGIN_NAME = "discourse-gamification"
  end

  class DiscourseGamification::Engine < Rails::Engine
    engine_name DiscourseGamification::PLUGIN_NAME
    isolate_namespace DiscourseGamification
  end

  # route: /admin/plugins/gamification
  add_admin_route "gamification.admin.title", "gamification"

  require_relative "app/models/gamification_score.rb"
  require_relative "app/models/gamification_leaderboard.rb"
  require_relative "app/controllers/admin/admin_gamification_leaderboard_controller.rb"
  require_relative "app/controllers/gamification_leaderboard_controller.rb"
  require_relative "app/serializers/user_score_serializer.rb"
  require_relative "app/serializers/leaderboard_serializer.rb"
  require_relative "app/serializers/leaderboard_view_serializer.rb"
  require_relative "app/serializers/admin_gamification_index_serializer.rb"
  require_relative "lib/directory_integration.rb"
  require_relative "lib/guardian.rb"
  require_relative "lib/scorables/scorable.rb"
  require_relative "lib/scorables/like_received.rb"
  require_relative "lib/scorables/like_given.rb"
  require_relative "lib/scorables/user_invited.rb"
  require_relative "lib/scorables/solutions.rb"
  require_relative "lib/scorables/time_read.rb"
  require_relative "lib/scorables/post_read.rb"
  require_relative "lib/scorables/topic_created.rb"
  require_relative "lib/scorables/post_created.rb"
  require_relative "lib/scorables/flag_created.rb"
  require_relative "lib/scorables/day_visited.rb"
  require_relative "lib/user_extension.rb"
  require_relative "jobs/scheduled/update_scores_for_today.rb"
  require_relative "jobs/scheduled/update_scores_for_ten_days.rb"

  reloadable_patch do |plugin|
    User.class_eval { prepend DiscourseGamification::UserExtension }
    Guardian.include(DiscourseGamification::Guardian)
  end

  if respond_to?(:add_directory_column)
    add_directory_column(
      "gamification_score",
      query: DiscourseGamification::DirectoryIntegration.query,
    )
  end

  add_to_serializer(:user_card, :gamification_score, false) { object.gamification_score }

  DiscourseGamification::Engine.routes.draw do
    get "/" => "gamification_leaderboard#respond"
    get "/:id" => "gamification_leaderboard#respond"
  end

  Discourse::Application.routes.append do
    mount ::DiscourseGamification::Engine, at: "/leaderboard"
    get "/admin/plugins/gamification" =>
          "discourse_gamification/admin_gamification_leaderboard#index",
        :constraints => StaffConstraint.new
    post "/admin/plugins/gamification/leaderboard" =>
           "discourse_gamification/admin_gamification_leaderboard#create",
         :constraints => StaffConstraint.new
    put "/admin/plugins/gamification/leaderboard/:id" =>
          "discourse_gamification/admin_gamification_leaderboard#update",
        :constraints => StaffConstraint.new
    delete "/admin/plugins/gamification/leaderboard/:id" =>
             "discourse_gamification/admin_gamification_leaderboard#destroy",
           :constraints => StaffConstraint.new
  end

  SeedFu.fixture_paths << Rails
    .root
    .join("plugins", "discourse-gamification", "db", "fixtures")
    .to_s
end
