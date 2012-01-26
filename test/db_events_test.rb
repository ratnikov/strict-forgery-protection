require 'test_helper'

class DbEventsTest < ActiveSupport::TestCase
  def test_read_queries
    assert_reads do
      Post.all
      Post.count

      execute "SELECT * from posts"
      execute "SELECT total_changes()"

      Post.find_by_id 42
    end
  end

  def test_record_modification
    assert_writes do
      post = Post.create! :message => 'hello world'
      Post.delete_all
      post.update_attributes :message => 'goodbye'
      post.destroy
    end
  end

  def test_raw_writes
    assert_writes do
      execute "CREATE TABLE foos (foo INT)"
      execute "INSERT INTO foos (foo) VALUES (5)"
      execute "DELETE FROM foos"
      execute "DROP TABLE foos"
    end
  end

  private

  def assert_reads
    previous_changes = total_changes

    events = sql_events { yield }

    assert events.all?(&:read?), "Expected all events to be read, but got: #{events.map { |e| [e, e.read? ] }.inspect}"

    assert_equal 0, total_changes - previous_changes, "Expected no new changes"
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

  def total_changes
    execute("SELECT total_changes()").first['total_changes()']
  end

  def execute(sql)
    ActiveRecord::Base.connection.execute sql
  end
end
