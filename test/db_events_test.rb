require 'test_helper'

class DbEventsTest < ActiveSupport::TestCase
  def test_reads
    assert_reads do
      execute "SELECT * from posts; DELETE from posts"
    end
  end

  def test_writes
    assert_writes do
      execute "INSERT INTO posts ('message') VALUES ('hello world')"
      execute "DELETE from posts"
    end
  end

  private

  def assert_reads
    events = sql_events { yield }

    assert events.all?(&:read?), "Expected all events to be read, but got: #{events.map { |e| [e, e.read? ] }.inspect}"
  end

  def assert_writes
    events = sql_events { yield }

    assert events.all?(&:write?), "Expected all events to be write, but got: #{events.map { |e| [ e, e.write? ] }.inspect}"
  end

  def sql_events
    ActiveRecord::QueryTracker.reset_sql_events

    yield

    ActiveRecord::QueryTracker.sql_events
  end

  def execute(sql)
    ActiveRecord::Base.connection.execute sql
  end
end
