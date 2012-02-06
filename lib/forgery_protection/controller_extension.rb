module ForgeryProtection
  class AttemptError < StandardError; end

  module ControllerExtension
    def self.included(controller)
      controller.around_filter :verify_strict_authenticity

      def controller.skip_forgery_protection(*args)
        skip_filter :verify_authenticity_token, *args
        skip_filter :verify_strict_authenticity, *args
      end
    end

    private

    def verify_strict_authenticity
      ForgeryProtection::QueryTracker.reset_sql_events

      yield.tap do
	provided_tokens = [ request.headers['X-CSRF-Token'], params[request_forgery_protection_token] ].compact
	if ForgeryProtection::QueryTracker.sql_events.any? { |e| e.write? } && !provided_tokens.include?(form_authenticity_token) 
	  handle_unverified_request
	end
      end
    end

    def handle_unverified_request
      raise AttemptError
    end
  end
end
