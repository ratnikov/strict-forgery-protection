class ActiveRecord::QueryTracker
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

ActiveSupport::Notifications.notifier.subscribe 'sql.active_record', ActiveRecord::QueryTracker.new
