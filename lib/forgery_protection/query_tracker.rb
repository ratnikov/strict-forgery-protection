require 'forgery_protection/instrumenter_extension'
require 'forgery_protection/sql_event'

module ForgeryProtection
  class QueryTracker
    def self.record_sql_event(event)
      sql_events << event
    end

    def self.sql_events
      Thread.current['active_record_sql_events'] ||= []
    end

    def self.reset_sql_events
      sql_events.clear
    end

    def call(*args)
      self.class.record_sql_event SqlEvent.new(*args)
    end
  end
end
