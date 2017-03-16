class InventariosController < ApplicationController
  
  def index
  end

  def showByCriteria
    @criteria = params[:criteria]
    articulos = Articulo.where('nombre LIKE ? OR clave LIKE ?', @criteria + '%', @criteria  + '%')
    render :json => articulos
  end

end
