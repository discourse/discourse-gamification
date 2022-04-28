# frozen_string_literal: true

module Gamification
  class Query
    def initialize(filters = {})
      @filters = filters
      @limit = 30
    end

    def load_more_url
      filters = []

      filters.push("tags=#{@filters[:tags]}") if @filters[:tags].present?
      filters.push("category=#{@filters[:category]}") if @filters[:category].present?
      filters.push("solved=#{@filters[:solved]}") if @filters[:solved].present?
      filters.push("search=#{@filters[:search_term]}") if @filters[:search_term].present?
      filters.push("sort=#{@filters[:sort]}") if @filters[:sort].present?

      if @filters[:page].present?
        filters.push("page=#{@filters[:page].to_i + 1}")
      else
        filters.push('page=1')
      end

      "/docs.json?#{filters.join('&')}"
    end
  end
end
