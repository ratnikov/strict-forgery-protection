class ActiveSupport::Notifications::Instrumenter
  def instrument(name, payload={})
    started = Time.now

    begin
      yield.tap { |ret| payload[:return] = ret }
    rescue Exception => e
      payload[:exception] = [e.class.name, e.message]
      raise e
    ensure
      @notifier.publish(name, started, Time.now, @id, payload)
    end
  end
end
