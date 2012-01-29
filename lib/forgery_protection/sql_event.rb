require 'active_support'

module ForgeryProtection
  class SqlEvent < ActiveSupport::Notifications::Event
    def read?
      result.respond_to?(:each)
    end

    def write?
      !read?
    end

    private

    def result
      payload[:return]
    end

    def sql
      payload[:sql]
    end
  end
end
