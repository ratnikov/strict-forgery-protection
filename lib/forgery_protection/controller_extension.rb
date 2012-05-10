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

    def verify_authenticity_token
      super.tap { @forgery_protection_invoked = true }
    end

    def detect_unverified_db_update
      ForgeryProtection::QueryTracker.reset_sql_events

      yield.tap do
        if ForgeryProtection::QueryTracker.sql_events.any? { |e| e.write? }
          raise AttemptError, "A database update occurred for an unverified request" unless valid_forgery_protection_token?
          raise AttemptError, "A database update occured but forgery protection seems disabled" unless forgery_protection_invoked?
        end
      end
    end

    def forgery_protection_invoked?
      !!@forgery_protection_invoked
    end

    def valid_forgery_protection_token?
      form_authenticity_token == params[request_forgery_protection_token] ||
      form_authenticity_token == request.headers['X-CSRF-Token']
    end
  end
end
