class PlainpageController < ApplicationController
  #load_and_authorize_resource
  def index
    
    if current_user.perfil
      flash[:success ] = "Bienvenido"
      @empresa = current_user.negocio.nombre
      @sucursal = current_user.sucursal.nombre
      @negocio = current_user.negocio
    else
      redirect_to new_perfil_path
    end
    #other alternatives are
    # flash[:warn ] = "Israel don't quite like warnings"
    #flash[:danger ] = "Naomi let the dog out!"
  end

end
