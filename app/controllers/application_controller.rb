class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_filter :authenticate_user!
  
  layout :layout_by_resource
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    
    redirect_to root_url
    flash[:success ] = exception.message.to_s
  end

  private

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end
end
