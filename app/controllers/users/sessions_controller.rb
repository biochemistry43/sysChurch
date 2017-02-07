class Users::SessionsController < Devise::SessionsController
  #prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel ]
  #before_action :configure_sign_in_params, only: [:create]
  # GET /resource/sign_in
  #def new
    #super
    #redirect_to punto_venta_index_path

  #end

  # POST /resource/sign_in
  #def create
    #super
    #redirect_to punto_venta_index_path
  #end

  # DELETE /resource/sign_out
  # def destroy
    #super
  #  redirect_to punto_venta_index_path
  # end

   #protected

  # If you have extra params to permit, append them to the sanitizer.
   #def configure_sign_in_params
   #  devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
   #end
end
