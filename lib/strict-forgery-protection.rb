require 'forgery_protection/query_tracker'
require 'forgery_protection/controller_extension'

ActiveSupport.on_load(:active_record) do
  ActiveSupport::Notifications.notifier.subscribe 'sql.active_record', ForgeryProtection::QueryTracker.new
end

ActiveSupport.on_load(:action_controller) do
  include ForgeryProtection::ControllerExtension
end

