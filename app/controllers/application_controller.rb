class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  def mixpanel
    @mixpanel ||= Mixpanel::Tracker.new Rails.application.config.mixpanel_token, { :env => request.env }
  end

  include SessionsHelper
  protect_from_forgery with: :null_session
end
