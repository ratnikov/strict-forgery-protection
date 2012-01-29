require 'forgery_protection/ar_extension'
require 'forgery_protection/query_tracker'
require 'forgery_protection/controller_extension'

ActionController::Base.send :include, ForgeryProtection::ControllerExtension
