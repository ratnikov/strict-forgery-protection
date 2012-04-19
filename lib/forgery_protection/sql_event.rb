require 'active_support'

module ForgeryProtection
  class SqlEvent < ActiveSupport::Notifications::Event
    def read?
      cache? || result.respond_to?(:each)
    end

    def write?
      !read?
    end

    def cache?
      payload[:name] == 'CACHE'
    end

    private

    def result
      payload[:result]
    end

    def sql
      payload[:sql]
    end
  end
end
