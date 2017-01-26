class PlainpageController < ApplicationController

  def index
    flash[:success ] = "Bienvenido"
    #other alternatives are
    # flash[:warn ] = "Israel don't quite like warnings"
    #flash[:danger ] = "Naomi let the dog out!"
  end

end
