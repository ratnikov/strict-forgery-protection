require 'forgery_protection/ar_extension'
require 'forgery_protection/query_tracker'

module ActionController
  module StrictForgeryProtection
    class AttemptError < StandardError; end

    def self.included(controller)
      controller.around_filter :verify_strict_authenticity
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

ActionController::Base.send :include, ActionController::StrictForgeryProtection
