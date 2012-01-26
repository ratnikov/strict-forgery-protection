require 'test_helper'

class DbEventsTest < ActiveSupport::TestCase
  def test_read_queries
    events =  sql_events { Post.all }

    assert_equal 1, events.count, "Should make only one sql event"
  end

  private

  def sql_events
    ActiveRecord::QueryTracker.reset_sql_events

    yield

    ActiveRecord::QueryTracker.sql_events
  end
end
