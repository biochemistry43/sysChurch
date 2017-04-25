class DevolucionesController < ApplicationController
   before_action :set_devolucion, only: [:show]

  def index
  	if can? :create, Negocio
  		@devoluciones = current_user.negocio.venta_canceladas
  	else
  		@devoluciones = current_user.sucursal.venta_canceladas
  	end
  end

  def show
  end

  def devolucion
  	@consulta = false
  	if request.post?
  	  @consulta = true
      @venta = Venta.find_by :folio=>params[:folio]
      if @venta
        @itemsVenta  = @venta.item_ventas
      else
        @folio = params[:folio]
      end
  	end
  end

  def hacerDevolucion
  	if request.post?
      @cantidad_devuelta = params[:cantidad_devuelta]
      @itemVenta = ItemVenta.find(params[:item_venta])
      @venta = Venta.find(params[:folio])
      @categoriaCancelacion = CatVentaCancelada.find(params[:cat_cancelacion])
      @observaciones = params[:observaciones]
      @venta.status = "Con devoluciones"
      @itemVenta.status = "Con devoluciones"
      @devolucion = VentaCancelada.new(:articulo=>@itemVenta.articulo, :item_venta=>@itemVenta, :venta=>@venta, :cat_venta_cancelada=>@categoriaCancelacion, :user=>current_user, :negocio=>current_user.negocio, :sucursal=>current_user.sucursal, :cantidad_devuelta=>@cantidad_devuelta)

  	end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_devolucion
      @devolucion = VentaCancelada.find(params[:id])
    end

end
