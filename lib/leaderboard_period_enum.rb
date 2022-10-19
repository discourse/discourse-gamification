# frozen_string_literal: true

require 'enum_site_setting'

class LeaderboardPeriodEnum < EnumSiteSetting

  def self.valid_value?(val)
    values.any? { |v| v[:value].to_s == val.to_s }
  end

  def self.values
    DiscourseGamification::GamificationLeaderboard.periods.map do |p|
      { name: I18n.t("leaderboard.period.#{p[0]}"), value: p[1] }
    end
  end

end
