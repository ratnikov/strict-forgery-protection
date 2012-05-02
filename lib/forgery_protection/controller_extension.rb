module ForgeryProtection
  class AttemptError < StandardError; end

  module ControllerExtension
    def self.included(controller)
      controller.around_filter :detect_unverified_db_update

      def controller.permit_unverified_state_changes(*args)
        skip_filter :detect_unverified_db_update, *args
      end
    end

    protected

    def detect_unverified_db_update
      ForgeryProtection::QueryTracker.reset_sql_events

      yield.tap do
	unless valid_forgery_protection_token? || ForgeryProtection::QueryTracker.sql_events.none? { |e| e.write? }
          raise AttemptError, "A database update occurred for an unverified request"
	end
      end
    end

    def valid_forgery_protection_token?
      form_authenticity_token == params[request_forgery_protection_token] ||
      form_authenticity_token == request.headers['X-CSRF-Token']
    end

    def handle_unverified_request
      # Rails allows get requests, so to preserve that behavior
      # doing nothing if unverified request was a GET request.
      request.get? || super
    end
  end
end
