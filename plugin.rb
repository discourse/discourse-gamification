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

    WITH x AS (SELECT
      u.id user_id,
      COUNT(DISTINCT gs.id) AS gs_score
      FROM users AS u
      LEFT OUTER JOIN gamification_scores AS gs ON gs.user_id = u.id AND COALESCE(gs.date, :since) > :since
      WHERE u.active
        AND u.silenced_till IS NULL
        AND u.id > 0
      GROUP BY u.id
    )
    UPDATE directory_items di SET
      score = gs_score
    FROM x
    WHERE x.user_id = di.user_id
    AND di.period_type = :period_type
    AND di.score <> gs_score
  "

  if respond_to?(:add_directory_column)
    add_directory_column("score", query: query)
  end
end


