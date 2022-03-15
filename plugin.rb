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
  require_relative 'app/controllers/gamification_scores_controller.rb'

  DiscourseGamification::Engine.routes.draw do
    get '/scores' => 'gamification_scores#index'
  end  
  
  Discourse::Application.routes.append do
    mount ::DiscourseGamification::Engine, at: '/'
  end
end
