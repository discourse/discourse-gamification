# frozen_string_literal: true

DiscourseGamification::Engine.routes.draw do
  get "/" => "gamification_leaderboard#respond"
  get "/:id" => "gamification_leaderboard#respond"
end

Discourse::Application.routes.draw do
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

Discourse::Application.routes.draw do
  get "/admin/plugins/gamification/score_events" =>
        "discourse_gamification/admin_gamification_score_event#show",
      :constraints => StaffConstraint.new
  post "/admin/plugins/gamification/score_events" =>
         "discourse_gamification/admin_gamification_score_event#create",
       :constraints => StaffConstraint.new
  put "/admin/plugins/gamification/score_events" =>
        "discourse_gamification/admin_gamification_score_event#update",
      :constraints => StaffConstraint.new
end
