# frozen_string_literal: true

# name: discourse-gamification
# about: Award users with a score for accomplishments
# version: 0.0.1
# authors: Discourse
# url: https://github.com/janzenisaac/discourse-gamification
# required_version: 2.7.0
# transpile_js: true

enabled_site_setting :discourse_gamification_enabled

after_initialize do
  module ::DiscourseGamification
    PLUGIN_NAME = "discourse-gamification"
  end

  class DiscourseGamification::Engine < Rails::Engine
    engine_name DiscourseGamification::PLUGIN_NAME
    isolate_namespace DiscourseGamification
  end

  require_relative 'app/models/gamification_score.rb'
  require_relative 'lib/directory_integration.rb'
  require_relative 'lib/scorables/scorable.rb'
  require_relative 'lib/scorables/like_received.rb'
  require_relative 'lib/scorables/like_given.rb'
  require_relative 'lib/scorables/user_invited.rb'
  require_relative 'lib/scorables/solutions.rb'
  require_relative 'lib/scorables/time_read.rb'
  require_relative 'lib/scorables/post_read.rb'
  require_relative 'lib/scorables/topic_created.rb'
  require_relative 'lib/scorables/post_created.rb'
  require_relative 'lib/scorables/flag_created.rb'
  require_relative 'lib/scorables/day_visited.rb'
  require_relative 'jobs/scheduled/update_scores_for_today.rb'
  require_relative 'jobs/scheduled/update_scores_for_ten_days.rb'

  if respond_to?(:add_directory_column)
    add_directory_column("gamification_score", query: DiscourseGamification::DirectoryIntegration.query)
  end

  add_to_serializer(:user_card, :gamification_score, false) do
    DiscourseGamification::GamificationScore
      .find_by(user_id: object.id)&.score
  end
end
