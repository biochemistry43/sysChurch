class DevolucionesController < ApplicationController
  def index
  end

  def show
  end

  def consultaVenta
  	if request.post?
      @venta = Venta.find(params[:folio])
      @itemsVenta = @venta.item_ventas
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

end
