# frozen_string_literal: true

# name: discourse-gamification
# about: Award users with a score for accomplishments
# version: 0.0.1
# authors: Discourse
# url: https://github.com/janzenisaac/discourse-gamification
# required_version: 2.7.0
# transpile_js: true

enabled_site_setting :plugin_name_enabled

after_initialize do
  module ::DiscourseGamification
    PLUGIN_NAME = "discourse-gamification"
  end

  class DiscourseGamification::Engine < Rails::Engine
    engine_name DiscourseGamification::PLUGIN_NAME
    isolate_namespace DiscourseGamification
  end

  require_relative 'app/models/gamification_score.rb'

  query = "
    UPDATE directory_items
    SET score = gs.score 
    FROM directory_items di
    INNER JOIN gamification_scores gs
    ON di.user_id = gs.user_id AND COALESCE(gs.date, :since) > :since
    WHERE di.user_id = gs.user_id
    AND di.period_type = :period_type
    AND di.score <> gs.score
  "

  if respond_to?(:add_directory_column)
    add_directory_column("score", query: query)
  end

  add_to_serializer(:user_card, :gamification_score, false) do
    DiscourseGamification::GamificationScore
      .find_by(user_id: object.id)
      .score
  end
end

