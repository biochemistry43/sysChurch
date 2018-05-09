class DevolucionesController < ApplicationController
   before_action :set_devolucion, only: [:show]
   before_action :set_usuarios, only: [:index, :consulta_por_fecha, :consulta_avanzada, :consulta_por_producto]
   before_action :set_sucursales, only: [:index, :consulta_por_fecha, :consulta_avanzada, :consulta_por_producto]
   before_action :set_categorias, only: [:index, :consulta_por_fecha, :consulta_avanzada, :consulta_por_producto]

  def index
  	if can? :create, Negocio
  		@devoluciones = current_user.negocio.venta_canceladas.where(created_at: Date.today.beginning_of_month..Date.today.end_of_day)
  	else
  		@devoluciones = current_user.sucursal.venta_canceladas.where(created_at: Date.today.beginning_of_month..Date.today.end_of_day)
  	end
  end

  def show
  end

  #Este método realiza una consulta de las devoluciones realizadas en un rango de fechas y devuelve la consulta a
  #la vista.
  #El usuario administrador consulta las devoluciones de todo el negocio, otro tipo de privilegios, solamente puede
  #consultar las de su propia sucursal.
  def consulta_por_fecha
    @consulta = true
    @avanzada = false
    @fechas = true
    if request.post?
      @fechaInicial = DateTime.parse(params[:fecha_inicial]).to_date
      @fechaFinal = DateTime.parse(params[:fecha_final]).to_date
      if can? :create, Negocio
        @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day)
      else
        @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day)
      end

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end
  end

  def consulta_por_producto
    @consulta = true
    @fechas = false
    @por_producto = true
    @avanzada = false
    if request.post?
      @clave = params[:clave_producto]
      @articulo = Articulo.find_by clave: @clave
      if can? :create, Negocio
        @devoluciones = current_user.negocio.venta_canceladas.where(articulo: @articulo)
      else
        @devoluciones = current_user.sucursal.venta_canceladas.where(articulo: @articulo)
      end
    end
  end

  def consulta_avanzada
    @consulta = true
    @avanzada = true
    if request.post?

      #Recibe el rango de fechas, el perfil del usuario que autorizó
      @fechaInicial = DateTime.parse(params[:fecha_inicial_avanzado]).to_date
      @fechaFinal = DateTime.parse(params[:fecha_final_avanzado]).to_date
      perfil_id = params[:perfil_id]
      @usuario = nil
      @venta = nil
      @producto = nil
      @cat_cancelacion = nil

      #Si el usuario que consultó eligió buscar también por usuario que autorizó la cancelación,
      #entonces, en base al perfil, busca el user.
      unless perfil_id.empty?
        perfil = Perfil.find(perfil_id)
        @usuario = perfil.user
      end

      #Recibe el id de la sucursal elegida si es que el usuario eligió una sucursal.
      @suc = params[:suc_elegida]

      #Si el usuario eligió una sucursal, entonces busca el objeto Sucursal en base a su
      #id recibido.
      unless @suc.empty?
        @sucursal = Sucursal.find(@suc)
      end

      @folio_venta = params[:folio_venta]

      unless @folio_venta.empty?
        @venta = Venta.find_by folio: @folio_venta
      end

      @clave_producto = params[:clave_producto]

      unless @clave_producto.empty?
        @producto = Articulo.find_by clave: @clave_producto
      end

      @categoria = params[:cat_elegida]

      unless @categoria.empty?
        @cat_cancelacion = CatVentaCancelada.find(@categoria)
      end



      #Resultados para usuario administrador o subadministrador
      if can? :create, Negocio

        unless @sucursal && @usuario && @venta && @producto && @cat_cancelacion
          @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day)
        end

        if @sucursal && @usuario && @venta && @producto && @cat_cancelacion
          @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, venta: @venta, cat_venta_cancelada: @cat_cancelacion, user: @usuario, sucursal: @sucursal)
        end

        if @sucursal
          unless @usuario && @venta && @producto && @cat_cancelacion
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, sucursal: @sucursal)
          end

        end

        if @usuario
          unless @sucursal && @venta && @producto && @cat_cancelacion
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, user: @usuario)
          end

        end

        if @venta
          unless @sucursal && @usuario && @producto && @cat_cancelacion
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, venta: @venta)
          end

        end

        if @producto
          unless @sucursal && @usuario && @venta && @cat_cancelacion
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto)
          end
        end

        if @cat_cancelacion
          unless @sucursal && @usuario && @venta && @producto
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, cat_venta_cancelada: @cat_cancelacion)
          end

        end

        if @sucursal && @usuario
          unless @venta && @producto && @cat_cancelacion
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, user: @usuario, sucursal: @sucursal)
          end
        end

        if @sucursal && @venta
          unless @usuario && @producto && @cat_cancelacion
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, sucursal: @sucursal)
          end
        end

        if @sucursal && @producto
          unless @usuario && @venta && @cat_cancelacion
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, sucursal: @sucursal)
          end

        end

        if @sucursal && @cat_cancelacion
          unless @usuario && @venta && @producto
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, cat_venta_cancelada: @cat_cancelacion, sucursal: @sucursal)
          end
        end

        if @usuario && @venta
          unless @sucursal && @producto && @cat_cancelacion
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, venta: @venta, user: @usuario)
          end
        end

        if @usuario && @producto
          unless @sucursal && @venta && @cat_cancelacion
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, cat_venta_cancelada: @cat_cancelacion, user: @usuario)
          end
        end

        if @usuario && @cat_cancelacion
          unless @sucursal && @venta && @producto
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, cat_venta_cancelada: @cat_cancelacion, user: @usuario)
          end
        end

        if @venta && @producto
          unless @sucursal && @usuario && @cat_cancelacion
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, venta: @venta)
          end

        end

        if @venta && @cat_cancelacion
          unless @sucursal && @usuario && @producto
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, venta: @venta, cat_venta_cancelada: @cat_cancelacion)
          end
        end

        if @producto && @cat_cancelacion
          unless @sucursal && @usuario && @venta
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, cat_venta_cancelada: @cat_cancelacion)
          end
        end

        if @sucursal && @usuario && @venta
          unless @producto && @cat_cancelacion
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, venta: @venta, user: @usuario, sucursal: @sucursal)
          end
        end

        if @sucursal && @usuario && @producto
          unless @venta && @cat_cancelacion
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, user: @usuario, sucursal: @sucursal)
          end
        end

        if @sucursal && @usuario && @cat_cancelacion
          unless @venta && @producto
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, cat_venta_cancelada: @cat_cancelacion, user: @usuario, sucursal: @sucursal)
          end
        end

        if @sucursal && @venta && @producto
          unless @usuario && @cat_cancelacion
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, venta: @venta, sucursal: @sucursal)
          end
        end

        if @sucursal && @venta && @cat_cancelacion
          unless @usuario && @producto
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, venta: @venta, cat_venta_cancelada: @cat_cancelacion, sucursal: @sucursal)
          end
        end

        if @sucursal && @producto && @cat_cancelacion
          unless @usuario && @venta
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, cat_venta_cancelada: @cat_cancelacion, sucursal: @sucursal)
          end
        end

        if @usuario && @venta && @producto
          unless @sucursal && @cat_cancelacion
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, venta: @venta, user: @usuario)
          end
        end

        if @usuario && @producto && @cat_cancelacion
          unless @sucursal && @venta
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, cat_venta_cancelada: @cat_cancelacion, user: @usuario)
          end
        end

        if @usuario && @venta && @cat_cancelacion
          unless @sucursal && @producto
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, venta: @venta, cat_venta_cancelada: @cat_cancelacion, user: @usuario)
          end
        end

        if @venta && @producto && @cat_cancelacion
          unless @sucursal && @usuario
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, venta: @venta, cat_venta_cancelada: @cat_cancelacion)
          end
        end

        if @sucursal && @usuario && @venta && @producto
          unless @cat_cancelacion
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, venta: @venta, user: @usuario, sucursal: @sucursal)
          end
        end

        if @sucursal && @usuario && @venta && @cat_cancelacion
          unless @producto
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, venta: @venta, cat_venta_cancelada: @cat_cancelacion, user: @usuario, sucursal: @sucursal)
          end
        end

        if @sucursal && @usuario && @producto && @cat_cancelacion
          unless @venta
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, cat_venta_cancelada: @cat_cancelacion, user: @usuario, sucursal: @sucursal)
          end
        end

        if @sucursal && @venta && @producto && @cat_cancelacion
          unless @usuario
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, venta: @venta, cat_venta_cancelada: @cat_cancelacion, sucursal: @sucursal)
          end
        end

        if @venta && @producto && @cat_cancelacion && @usuarios
          unless @sucursal
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, venta: @venta, cat_venta_cancelada: @cat_cancelacion, user: @usuario)
          end
        end


      #Resultados para usuario sin privilegios de administrador o subadministrador
      else

        unless @sucursal && @usuario && @venta && @producto && @cat_cancelacion
          @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day)
        end

        if @sucursal && @usuario && @venta && @producto && @cat_cancelacion
          @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, venta: @venta, cat_venta_cancelada: @cat_cancelacion, user: @usuario, sucursal: @sucursal)
        end

        if @sucursal
          unless @usuario && @venta && @producto && @cat_cancelacion
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, sucursal: @sucursal)
          end

        end

        if @usuario
          unless @sucursal && @venta && @producto && @cat_cancelacion
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, user: @usuario)
          end

        end

        if @venta
          unless @sucursal && @usuario && @producto && @cat_cancelacion
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, venta: @venta)
          end

        end

        if @producto
          unless @sucursal && @usuario && @venta && @cat_cancelacion
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto)
          end
        end

        if @cat_cancelacion
          unless @sucursal && @usuario && @venta && @producto
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, cat_venta_cancelada: @cat_cancelacion)
          end

        end

        if @sucursal && @usuario
          unless @venta && @producto && @cat_cancelacion
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, user: @usuario, sucursal: @sucursal)
          end
        end

        if @sucursal && @venta
          unless @usuario && @producto && @cat_cancelacion
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, sucursal: @sucursal)
          end
        end

        if @sucursal && @producto
          unless @usuario && @venta && @cat_cancelacion
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, sucursal: @sucursal)
          end

        end

        if @sucursal && @cat_cancelacion
          unless @usuario && @venta && @producto
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, cat_venta_cancelada: @cat_cancelacion, sucursal: @sucursal)
          end
        end

        if @usuario && @venta
          unless @sucursal && @producto && @cat_cancelacion
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, venta: @venta, user: @usuario)
          end
        end

        if @usuario && @producto
          unless @sucursal && @venta && @cat_cancelacion
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, cat_venta_cancelada: @cat_cancelacion, user: @usuario)
          end
        end

        if @usuario && @cat_cancelacion
          unless @sucursal && @venta && @producto
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, cat_venta_cancelada: @cat_cancelacion, user: @usuario)
          end
        end

        if @venta && @producto
          unless @sucursal && @usuario && @cat_cancelacion
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, venta: @venta)
          end

        end

        if @venta && @cat_cancelacion
          unless @sucursal && @usuario && @producto
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, venta: @venta, cat_venta_cancelada: @cat_cancelacion)
          end
        end

        if @producto && @cat_cancelacion
          unless @sucursal && @usuario && @venta
            @devoluciones = current_user.negocio.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, cat_venta_cancelada: @cat_cancelacion)
          end
        end

        if @sucursal && @usuario && @venta
          unless @producto && @cat_cancelacion
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, venta: @venta, user: @usuario, sucursal: @sucursal)
          end
        end

        if @sucursal && @usuario && @producto
          unless @venta && @cat_cancelacion
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, user: @usuario, sucursal: @sucursal)
          end
        end

        if @sucursal && @usuario && @cat_cancelacion
          unless @venta && @producto
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, cat_venta_cancelada: @cat_cancelacion, user: @usuario, sucursal: @sucursal)
          end
        end

        if @sucursal && @venta && @producto
          unless @usuario && @cat_cancelacion
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, venta: @venta, sucursal: @sucursal)
          end
        end

        if @sucursal && @venta && @cat_cancelacion
          unless @usuario && @producto
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, venta: @venta, cat_venta_cancelada: @cat_cancelacion, sucursal: @sucursal)
          end
        end

        if @sucursal && @producto && @cat_cancelacion
          unless @usuario && @venta
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, cat_venta_cancelada: @cat_cancelacion, sucursal: @sucursal)
          end
        end

        if @usuario && @venta && @producto
          unless @sucursal && @cat_cancelacion
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, venta: @venta, user: @usuario)
          end
        end

        if @usuario && @producto && @cat_cancelacion
          unless @sucursal && @venta
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, cat_venta_cancelada: @cat_cancelacion, user: @usuario)
          end
        end

        if @usuario && @venta && @cat_cancelacion
          unless @sucursal && @producto
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, venta: @venta, cat_venta_cancelada: @cat_cancelacion, user: @usuario)
          end
        end

        if @venta && @producto && @cat_cancelacion
          unless @sucursal && @usuario
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, venta: @venta, cat_venta_cancelada: @cat_cancelacion)
          end
        end

        if @sucursal && @usuario && @venta && @producto
          unless @cat_cancelacion
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, venta: @venta, user: @usuario, sucursal: @sucursal)
          end
        end

        if @sucursal && @usuario && @venta && @cat_cancelacion
          unless @producto
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, venta: @venta, cat_venta_cancelada: @cat_cancelacion, user: @usuario, sucursal: @sucursal)
          end
        end

        if @sucursal && @usuario && @producto && @cat_cancelacion
          unless @venta
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, cat_venta_cancelada: @cat_cancelacion, user: @usuario, sucursal: @sucursal)
          end
        end

        if @sucursal && @venta && @producto && @cat_cancelacion
          unless @usuario
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, venta: @venta, cat_venta_cancelada: @cat_cancelacion, sucursal: @sucursal)
          end
        end

        if @venta && @producto && @cat_cancelacion && @usuarios
          unless @sucursal
            @devoluciones = current_user.sucursal.venta_canceladas.where(created_at: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, articulo: @producto, venta: @venta, cat_venta_cancelada: @cat_cancelacion, user: @usuario)
          end
        end
      end

    end

  end

  def new
  	@itemVenta = ItemVenta.find(params[:id])
  	@categorias = current_user.negocio.cat_venta_canceladas
    @cajas = current_user.sucursal.caja_sucursals
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

  #Este método registra la devolución en la base de datos y aumenta la cantidad en inventario
  def hacerDevolucion
  	if request.post?
      @cajaVenta = nil
      @cajaChica = nil
      @gasto = nil
      @pagoProveedor = nil
      @pagoDevolucion = nil
      @movimientoCaja = nil
      @cantidad_devuelta = params[:cantidad_devuelta]


      @itemVenta = ItemVenta.find(params[:item_venta])

      #Se obtiene la venta de donde se hará la devolución
      @venta =  @itemVenta.venta

      #Se obtiene la categoría de devolución elegida por el usuario
      categoria = params[:devolucion]
      @categoriaCancelacion = CatVentaCancelada.find(categoria[:cat_devolucion])

      #Se obtienen las observaciones que el usuario introdujo para realizar la devolución
      @observaciones = params[:observaciones]

      #Los status del item de la venta y de la venta en general, es cambiado a "Con devoluciones"
      @venta.status = "Con devoluciones"
      @itemVenta.status = "Con devoluciones"

      #Se crea el registro de una venta cancelada y se relaciona con su categoría de devolución
      @devolucion = VentaCancelada.new(:articulo=>@itemVenta.articulo, :item_venta=>@itemVenta, :venta=>@venta, :user=>current_user, :negocio=>current_user.negocio, :sucursal=>@itemVenta.articulo.sucursal, :cantidad_devuelta=>@cantidad_devuelta, :observaciones=>@observaciones, :monto=>@itemVenta.precio_venta)
      @categoriaCancelacion.venta_canceladas << @devolucion

      #Dado que se hizo una devolución, se aumenta la existencia en inventarios de dicho producto.
      @itemVenta.articulo.existencia += @cantidad_devuelta.to_f

      #Se disminuye la cantidad devuelta, respecto del item de venta.
      #@itemVenta.cantidad -= @cantidad_devuelta.to_f

      #################################################################################################################
      #################  creando los registros por concepto de gastos por devolucion de productos #####################
      #################################################################################################################

      @categoriaGasto = current_user.negocio.categoria_gastos.where("nombre_categoria = ?", "Devoluciones").take

      #Esta variable recoge el parámetro del origen del recurso con el que se va a pagar la devolución.
      #El origen puede ser las cajas de venta, la caja chica o alguna cuenta bancaria.
      origen = params[:select_origen_recurso]

      #almacena el importe monetario que será devuelto al cliente.
      importe_devolucion = params[:importe_devolucion]

      #Si se cumple esta condición, significa que el recurso para la devolución, provendrá de alguna de las cajas
      #de venta que tiene la sucursal. La cadena contiene el id de la caja de venta seleccionada.
      if origen.include? "caja_venta"
        tamano_cadena_origen = origen.length

        #aquí extraigo el id de la caja de venta contenido en la cadena de texto
        #el número "11" corresponde a la cantidad de caracteres de la cadena "caja_venta_"
        id_caja_sucursal = origen[11..tamano_cadena_origen]

        #En base al id extraido de la cadena, busco la Caja de Venta en la base de datos
        @cajaVenta = CajaSucursal.find(id_caja_sucursal)

        #Verifico que la caja tenga el saldo necesario para realizar la operación de devolución.
        if @cajaVenta.saldo >= importe_devolucion.to_f
          @gasto = Gasto.new(:monto=>importe_devolucion, :concepto=>"devolucion: #{@observaciones}", :tipo=>"devolucion")

          #creación y relación del registro de pago de devolución
          @pagoDevolucion = PagoDevolucion.new(:monto=>importe_devolucion.to_f)
          @gasto.pago_devolucion = @pagoDevolucion
          @devolucion.pago_devolucions << @pagoDevolucion
          current_user.pago_devolucions << @pagoDevolucion
          current_user.sucursal.pago_devolucions << @pagoDevolucion
          current_user.negocio.pago_devolucions << @pagoDevolucion

          #relaciones del registro de gasto
          @categoriaGasto.gastos << @gasto
          @cajaVenta.gastos << @gasto
          current_user.gastos << @gasto
          current_user.sucursal.gastos << @gasto
          current_user.negocio.gastos << @gasto

          #Se actualiza el saldo de la caja de venta
          saldo = @cajaVenta.saldo - importe_devolucion.to_f
          @cajaVenta.saldo = saldo

          #Se registra el movimiento de caja de venta. En este caso, es un movimiento de salida
          @movimientoCaja = MovimientoCajaSucursal.new(:salida=>importe_devolucion.to_f, :caja_sucursal=>@cajaVenta)
          current_user.movimiento_caja_sucursals << @movimientoCaja
          current_user.sucursal.movimiento_caja_sucursals << @movimientoCaja
          current_user.negocio.movimiento_caja_sucursals << @movimientoCaja

        else
          flash[:notice] = "No hay saldo suficiente en esta caja para hacer la devolución"
        end

      end

      #Si se cumple esta condición, significa que el recurso provendrá de la caja chica que tiene la sucursal.
      if origen.include? "caja_chica"
        #Verifica si existen registros de caja chica para esta sucursal
        if current_user.sucursal.caja_chicas
          #Si existen registros de caja chica, toma el último registro de la tabla y se obtiene el importe de
          #dicho registro. En esto se determina si hay saldo suficiente para cubrir la devolución.
          entradas = CajaChica.sum(:entrada, :conditions=>["sucursal_id=?", current_user.sucursal.id])
          salidas = CajaChica.sum(:salida, :conditions=>["sucursal_id=?", current_user.sucursal.id])
          @saldoCajaChica = entradas - salidas


          #@cajaChicaLast = sucursal.caja_chicas.last
          if @saldoCajaChica >= importe_devolucion.to_f

            saldo_en_caja_chica = @saldoCajaChica

            @gasto = Gasto.new(:monto=>importe_devolucion.to_f, :concepto=>"devolucion: #{@observaciones}", :tipo=>"devolucion")

            #creación y relación del registro de pago de devolución
            @pagoDevolucion = PagoDevolucion.new(:monto=>importe_devolucion.to_f)
            @gasto.pago_devolucion = @pagoDevolucion
            @devolucion.pago_devolucions << @pagoDevolucion
            current_user.pago_devolucions << @pagoDevolucion
            current_user.sucursal.pago_devolucions << @pagoDevolucion
            current_user.negocio.pago_devolucions << @pagoDevolucion

            #relaciones del registro de gasto
            @categoriaGasto.gastos << @gasto
            current_user.gastos << @gasto
            current_user.sucursal.gastos << @gasto
            current_user.negocio.gastos << @gasto

            #Se hace un registro en caja chica y se relaciona con el gasto
            @cajaChica = CajaChica.new(:concepto=>"devolucion: #{@observaciones}", :salida=>importe_devolucion.to_f)
            @cajaChica.gasto = @gasto
            #Se actualiza el saldo de la caja chica
            #nvo_saldo_caja_chica = saldo_en_caja_chica - importe_devolucion.to_f
            #@cajaChica.saldo = nvo_saldo_caja_chica

            #Se hacen las relaciones de pertenencia para la caja chica.
            current_user.caja_chicas << @cajaChica
            current_user.sucursal.caja_chicas << @cajaChica
            current_user.negocio.caja_chicas << @cajaChica


            #Se crea una nota de crédito(Sola para las ventas que tengan una factura relacionada)
            if @venta.factura.present?
              #Comprobante de Egreso.- Amparan devoluciones, descuentos y bonificaciones
              #para efectos de deducibilidad y también puede utilizarse para corregir o restar un
              #comprobante de ingresos en cuanto a los montos que documenta, como la
              #aplicación de anticipos. Este comprobante es conocido como nota de crédito.

              #Las Notas de Crédito AJUSTAN operaciones anteriores...No es una ANULACIÓN.

              #De acuerdo con el SAT.
              #II. Emisión de CFDI de Egresos relacionado a un comprobante
              require 'cfdi'
              require 'timbrado'

              #1.- CERTIFICADOS,  LLAVES Y CLAVES
              certificado = CFDI::Certificado.new '/home/daniel/Documentos/prueba/CSD01_AAA010101AAA.cer'
              # Esta se convierte de un archivo .key con:
              # openssl pkcs8 -inform DER -in someKey.key -passin pass:somePassword -out key.pem
              llave = "/home/daniel/Documentos/timbox-ruby/CSD01_AAA010101AAA.key.pem"
              pass_llave = "12345678a"
              #openssl pkcs8 -inform DER -in /home/daniel/Documentos/prueba/CSD03_AAA010101AAA.key -passin pass:12345678a -out /home/daniel/Documentos/prueba/CSD03_AAA010101AAA.pem
              #llave2 = CFDI::Key.new llave, pass_llave

              #Para obtener el numero consecutivo a partir de la ultima factura o de lo contrario asignarle por primera vez un número
              consecutivo = 0
              if current_user.sucursal.nota_creditos.last
                consecutivo = current_user.sucursal.nota_creditos.last.consecutivo
                if consecutivo
                  consecutivo += 1
                end
              else
                consecutivo = 1 #Se asigna el número a la factura por default o de acuerdo a la configuración del usuario.
              end

              if current_user.sucursal.clave.present?
                #El folio de las facturas se forma por defecto por la clave de las sucursales, pero si el usuario quiere establecer sus propias series para otro fin, se tomará la serie que el usuario indique en las configuración de Facturas y Notas
                #claveSucursal = current_user.sucursal.clave
                claveSucursal = current_user.sucursal.clave
                folio_registroBD = claveSucursal + "F"
                folio_registroBD << consecutivo.to_s
                serie = claveSucursal + "F"
              else
                folio_default="F"
                folio_registroBD =folio_default
                #Una serie por default les guste o no les guste, pero útil para que no se produzca un colapso
                serie = folio_default
              end

              fecha_expedicion_f = Time.now
              #2.- LLENADO DEL XML DIRECTAMENTE DE LA BASE DE DATOS
              #La informacion de la nota de crédito debe de ser la misma que la del comprobante de ingreso a la que se le realizará el descuento, devolucion...
              factura = CFDI::Comprobante.new({
                serie: serie,
                folio: consecutivo,
                fecha: fecha_expedicion_f,
                #Deberá ser de tipo Egreso
                tipoDeComprobante: "E",
                #La moneda por default es MXN
                #Forma de pago, opciones de registro:
                  #La que se registró en el comprobante de tipo ingreso.
                  #Con la que se está efectuando el descuento, devolución o bonificación en su caso.
                FormaPago:'01',#CATALOGO Es de tipo string
                condicionesDePago: 'Sera marcada como pagada en cuanto el receptor haya cubierto el pago.',
                metodoDePago: 'PUE', #Deberá de PUE- Pago en una sola exhibición
                lugarExpedicion: current_user.sucursal.codigo_postal,#current_user.negocio.datos_fiscales_negocio.codigo_postal,#, #CATALOGO
                total: 55.68

                #total:40.88
                #Descuento:0 #DESCUENTO RAPPEL
              })
              #Datos del emisor
                #Opción 1: Obtener extraer los datos del xml
                #Opción 2: Obtener los datos por consultas

              #III. Sí se tiene más de un local o establecimiento, se deberá señalar el domicilio del local o
              #establecimiento en el que se expidan las Facturas Electrónicas
              #Estos datos no son requeridos por el SAT, sin embargo se usaran para la representacion impresa de los CFDIs.*
              @factura = @venta.factura
              domicilioEmisor = CFDI::DatosComunes::Domicilio.new({
                calle: @factura.negocio.datos_fiscales_negocio.calle,
                #calle: current_user.negocio.datos_fiscales_negocio.calle,
                noExterior: @factura.negocio.datos_fiscales_negocio.numExterior,
                noInterior: @factura.negocio.datos_fiscales_negocio.numInterior,
                colonia: @factura.negocio.datos_fiscales_negocio.colonia,
                #localidad: current_user.negocio.datos_fiscales_negocio.,
                #referencia: current_user.negocio.datos_fiscales_negocio.,
                municipio: @factura.negocio.datos_fiscales_negocio.municipio,
                estado: @factura.negocio.datos_fiscales_negocio.estado,
                #pais: current_user.negocio.datos_fiscales_negocio.,
                codigoPostal: @factura.negocio.datos_fiscales_negocio.codigo_postal
              })

              expedidoEn= CFDI::DatosComunes::Domicilio.new({
                #Estos datos los uso como datos fiscales, sin current_user.sucursal.codigo_postalembargo si se hara distinción entre direccion comun y dirección fiscal,
                #se debera corregir.
                calle: @factura.sucursal.calle,
                noExterior: @factura.sucursal.numExterior,
                noInterior: @factura.sucursal.numInterior,
                colonia: @factura.sucursal.colonia,
                #localidad: current_user.negocio.datos_fiscales_negocio.,
                #referencia: current_user.negocio.datos_fiscalecurrent_user.sucursal.codigo_postals_negocio.,
                municipio: @factura.sucursal.municipio,
                estado: @factura.sucursal.estado,
                #pais: current_user.negocio.datos_fiscales_negocio.,
                codigoPostal: @factura.sucursal.codigo_postal
              })

              factura.emisor = CFDI::Emisor.new({
                rfc: @factura.negocio.datos_fiscales_negocio.rfc,
                nombre: @factura.negocio.datos_fiscales_negocio.nombreFiscal,
                regimenFiscal: @factura.negocio.datos_fiscales_negocio.regimen_fiscal, #CATALOGO
                domicilioFiscal: domicilioEmisor,
                expedidoEn: expedidoEn
              })

              #La dirección fiscal del cliente para empezar no son requeridos por el SAT, sin embargo se usaran para la representacion impresa de los CFDIs si esque los proporciona el cliente jaja.*
              domicilioReceptor = CFDI::DatosComunes::Domicilio.new({
                calle: @factura.cliente.datos_fiscales_cliente.calle,
                noExterior: @factura.cliente.datos_fiscales_cliente.numExterior,
                noInterior: @factura.cliente.datos_fiscales_cliente.numInterior,
                colonia: @factura.cliente.datos_fiscales_cliente.colonia,
                localidad: @factura.cliente.datos_fiscales_cliente.localidad,
                #referencia: current_user.negocio.datos_fiscales_negocio.,
                municipio: @factura.cliente.datos_fiscales_cliente.municipio,
                estado: @factura.cliente.datos_fiscales_cliente.estado,    #pais: current_user.negocio.datos_fiscales_negocio.,
                codigoPostal: @factura.cliente.datos_fiscales_cliente.codigo_postal
              })

              #Atributos del receptor
              rfc_receptor_f = @factura.cliente.datos_fiscales_cliente.rfc
              nombre_fiscal_receptor_f = @factura.cliente.datos_fiscales_cliente.nombreFiscal
              #Al tratarse de un CFDI de egresos, no será un comprobante de deducción para el receptor, ya que se está emitiendo para disminuir el importe de un CFDI relacionado.
              #Por lo tanto el uso sera: G02 - Devoluciones, descuentos o bonificaciones
              #Solo se mostrará en la vista para que el usuario se sienta satisfecho jaja pero se da por sentado que será ese y solo ese el uso que se le dará.

              @uso_cfdi = "G02 - Devoluciones, descuentos o bonificaciones"

              factura.receptor = CFDI::Receptor.new({
                rfc: rfc_receptor_f,
                 nombre: nombre_fiscal_receptor_f,
                 UsoCFDI: "G02", #Devoluciones, descuentos o bonificaciones.
                 domicilioFiscal: domicilioReceptor
                })

              #Sepa que show con los conceptos. En un lado dice una cosa y en otros otra.
              #Para más... me resolvio la duda un youtubero jaja que la gentecita del SAT jaja
              #ClaveProdServ: "84111506"
              cont=0
              @itemVenta.each do |c| #Solo es una iteración cuando se tratan devolucion individuales
                factura.conceptos << CFDI::Concepto.new({
                  ClaveProdServ: c.articulo.clave_prod_serv.clave,
                  NoIdentificacion: c.articulo.clave,
                  Cantidad: @cantidad_devuelta,
                  ClaveUnidad:c.articulo.unidad_medida.clave,#CATALOGO
                  Unidad: c.articulo.unidad_medida.nombre, #Es opcional para precisar la unidad de medida propia de la operación del emisor, pero pues...
                  Descripcion: c.articulo.nombre,
                  ValorUnitario: c.precio_venta,
                  #El importe se calculo automático
                  #Descuento: 0 #Expresado en porcentaje
                })
                if c.articulo.impuesto.present? && c.articulo.impuesto.tipo == "Federal"
                  if c.articulo.impuesto.nombre == "IVA"
                    clave_impuesto = "002"
                  elsif c.articulo.impuesto.nombre == "IEPS"
                    clave_impuesto =  "003"
                  end
                  factura.impuestos.traslados << CFDI::Impuesto::Traslado.new(base: c.precio_venta * c.cantidad,
                    tax: clave_impuesto, type_factor: "Tasa", rate: format('%.6f',(c.articulo.impuesto.porcentaje/100)).to_f, concepto_id: cont )
                end
                cont += 1
              end

              factura.uuidsrelacionados << CFDI::Cfdirelacionado.new({
                uuid: @factura.folio_fiscal #Aquí se relaciona el comprobante de ingreso por la que se realizará la nota de crŕedito
                })
              factura.cfdisrelacionados = CFDI::CfdiRelacionados.new({
                tipoRelacion: "03"# Devolución de mercancías sobre facturas o traslados previos
              })

              #3.- SE AGREGA EL CERTIFICADO Y SELLO DIGITAL
              @total_to_w = factura.total_to_words
              # Esto hace que se le agregue al comprobante el certificado y su número de serie (noCertificado)
              certificado.certifica factura
              # Esto genera la factura como xml
              xml= factura.comprobante_to_xml
              # Para mandarla a un PAC, necesitamos sellarla, y esto lo hace agregando el sello
              archivo_xml = generar_sello(xml, llave, pass_llave)

              # Convertir la cadena del xml en base64
              xml_base64 = Base64.strict_encode64(archivo_xml)

              # Parametros para conexion al Webservice (URL de Pruebas)
              wsdl_url = "https://staging.ws.timbox.com.mx/timbrado_cfdi33/wsdl"
              usuario = "AAA010101000"
              contrasena = "h6584D56fVdBbSmmnB"

              gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
              storage=gcloud.storage

              bucket = storage.bucket "cfdis"


              #4.- ALTERNATIVA DE CONEXIÓN PARA CONSUMIR EL WEBSERVICE DE TIMBRADO CON TIMBOX
              #Se obtiene el xml timbrado
              xml_timbrado= timbrar_xml(usuario, contrasena, xml_base64, wsdl_url)

              #Se forma la cadena original del timbre fiscal digital de manera manual por que e mugroso xslt del SAT no Jala.
              factura.complemento=CFDI::Complemento.new(
                {
                  Version: xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@Version'),
                  uuid:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@UUID'),
                  FechaTimbrado:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@FechaTimbrado'),
                  RfcProvCertif:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@RfcProvCertif'),
                  SelloCFD:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@SelloCFD'),
                  NoCertificadoSAT:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@NoCertificadoSAT')
                }
              )
              #se hace una copia del xml para modificarlo agregandole información extra para la representación impresa.
              xml_copia=xml_timbrado
              xml_timbrado_storage = factura.comprobante_to_xml #Hasta este punto se le agregó el complemento y con eso es suficiente para el CFDI

              #5.- SE AGREGAN NUEVOS DATOS PARA LA REPRESENTACIÓN IMPRESA(INFORMACIÓN(PDF) IMPORTANTE PARA LOS CONTRIBUYENTES, PERO QUE AL SAT NO LE IMPORTAN JAJA)
              codigoQR = factura.qr_code xml_timbrado
              cadOrigComplemento=factura.complemento.cadena_TimbreFiscalDigital
              logo=current_user.negocio.logo
              #No hay nececidad de darle a escoger el uso del cfdi al usuario.
              uso_cfdi_descripcion = "Devoluciones, descuentos o bonificaciones"

              #Se pasa un hash con la información extra en la representación impresa como: datos de contacto, dirección fiscal y descripcion de la clave de los catálogos del SAT.
              hash_info = {xml_copia: xml_copia, codigoQR: codigoQR, logo: logo, cadOrigComplemento: cadOrigComplemento, uso_cfdi_descripcion: uso_cfdi_descripcion}
              hash_info[:Telefono1Receptor]= @venta.cliente.telefono1 if @venta.cliente.telefono1
              hash_info[:EmailReceptor]= @venta.cliente.email if @venta.cliente.email


              xml_rep_impresa = factura.add_elements_to_xml(hash_info)
              template = Nokogiri::XSLT(File.read('/home/daniel/Documentos/sysChurch/lib/XSLT.xsl'))
              html_document = template.transform(xml_rep_impresa)
              #File.open('/home/daniel/Documentos/timbox-ruby/CFDImpreso.html', 'w').write(html_document)
              pdf = WickedPdf.new.pdf_from_string(html_document)

              #6.- SE ALMACENAN EN GOOGLE CLOUD STORAGE
              #Directorios
              dir_negocio = current_user.negocio.nombre
              dir_cliente = nombre_fiscal_receptor_f

              #Obtiene la fecha del xml timbrado para que no difiera de los comprobantes y del registro de la BD.
              #fecha_xml = xml_timbrado.xpath('//@Fecha')[0]
              fecha_registroBD=Date.parse(fecha_expedicion_f.to_s)
              dir_mes = fecha_registroBD.strftime("%m")
              dir_anno = fecha_registroBD.strftime("%Y")

              fecha_file= fecha_registroBD.strftime("%Y-%m-%d")
              #Nomenclatura para el nombre del archivo: consecutivo + fecha + extención
              file_name="#{consecutivo}_#{fecha_file}"

                #Cosas a tener en cuenta antes de indicarle una ruta:
                  #1.-Un negocio puede o no tener sucursales
                if current_user.sucursal
                  dir_sucursal = current_user.sucursal.nombre
                  ruta_storage = "#{dir_negocio}/#{dir_sucursal}/#{dir_anno}/#{dir_mes}/#{dir_cliente}/#{file_name}"
                else
                  ruta_storage = "#{dir_negocio}/#{dir_anno}/#{dir_mes}/#{dir_cliente}/#{file_name}"
                end

                #Los comprobantes de almacenan en google cloud
                file = bucket.create_file StringIO.new(pdf), "#{ruta_storage}_NotaCrédito.pdf"
                file = bucket.create_file StringIO.new(xml_timbrado_storage.to_s), "#{ruta_storage}_NotaCrédito.xml"

                #El nombre del pdf formado por: consecutivo + fecha_registroBD + nombre + extención
                nombre_pdf="#{consecutivo}_#{fecha_registroBD}_NotaCrédito.pdf"
                save_path = Rails.root.join('public',nombre_pdf)
                File.open(save_path, 'wb') do |file|
                   file << pdf
                end
                #No queda de otra más que guardarlo para el envio por email al cliente
                archivo = File.open("public/#{consecutivo}_#{fecha_registroBD}_CFDI.xml", "w")
                archivo.write (xml)
                archivo.close
=begin
                #7.- SE ENVIAN LOS COMPROBANTES(pdf y xml timbrado) AL CLIENTE POR CORREO ELECTRÓNICO. :p
                #Se debe de tomar el mensaje y el tema de la configuración de las plantillas de email del negocio correspondiente.
                destinatario = params[:destinatario]
                mensaje = current_user.negocio.config_comprobante.msg_email
                tema = current_user.negocio.config_comprobante.asunto_email
                #file_name = "#{consecutivo}_#{fecha_file}"
                comprobantes = {}
                #Aquí  no se da a elegir si desea enviar pdf o xml porque, simplemente se le enviarán al cliente la representación impresa de la nota de crédito y su CFDI(xml).
                comprobantes[:pdf_nc] = "public/#{file_name}_NotaCrédito.pdf"
                comprobantes[:xml_nc] = "public/#{file_name}_NotaCrédito.xml"

                #FacturasEmail.factura_email(@destinatario, @mensaje, @tema).deliver_now
                #FacturasEmail.factura_email(destinatario, mensaje, tema, comprobantes).deliver_now
=end
=begin
              #8.- SE SALVA EN LA BASE DE DATOS
                #Se crea un objeto del modeloNotaCredito y se le asignan a los atributos los valores correspondientes para posteriormente guardarlo como un registo en la BD.
                folio_fiscal_xml = xml_timbrado.xpath('//@UUID')
                @nota_credito = NotaCredito.new(folio: folio_registroBD, fecha_expedicion: fecha_file, consecutivo: consecutivo, estado_factura:"Activa")

                @nota_credito.folio_fiscal = folio_fiscal_xml
                @nota_credito.ruta_storage =  ruta_storage

                if @factura.save
                current_user.facturas<<@factura
                current_user.negocio.facturas<<@factura
                current_user.sucursal.facturas<<@factura

                #Se factura a nombre del cliente que realizó la compra en el negocio.
                cliente_id=@@venta.cliente.id
                Cliente.find(cliente_id).facturas << @factura

                venta_id=@@venta.id
                Venta.find(venta_id).factura = @factura #relación uno a uno
                end
=end


            end #Fin de @venta.factura.present?

          else
            flash[:notice] = "No hay saldo suficiente en la caja chica para hacer la devolución"
          end
        end
      end



      respond_to do |format|
	    if @devolucion.valid?
	      if @devolucion.save && @itemVenta.save && @venta.save

          if @cajaVenta && @cajaVenta.save && @gasto.save && @pagoDevolucion.save && @movimientoCaja && @movimientoCaja.save
	          flash[:notice] = "La devolución se realizó con éxito"
	          format.html { redirect_to action: "devolucion" }
          elsif @cajaChica && @cajaChica.save && @gasto.save && @pagoDevolucion.save
            flash[:notice] = "La devolución se realizó con éxito"
            format.html { redirect_to action: "devolucion" }
          end

	      else
	        format.html { redirect_to devoluciones_devolucion_path, notice: 'Ocurrió un error al realizar la devolución' }

	      end
	    else
	      format.html { redirect_to devoluciones_devolucion_path, notice: 'Ocurrió un error al realizar la devolución' }
	    end
	  end
  	end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_devolucion
      @devolucion = VentaCancelada.find(params[:id])
    end

    def set_usuarios
      @usuarios = []
      if can? :create, Negocio
        current_user.negocio.users.each do |usuario|
          #Llena un array con todos los usuarios del negocio con privilegios para hacer una devolución
          #Siempre y cuando no sean auxiliares o almacenistas o cajeros pues no tienen acceso a las devoluciones
          unless usuario.role == "auxiliar" || usuario.role == "almacenista" || usuario.role == "cajero"
            @usuarios.push(usuario.perfil)
          end
        end
      else
        current_user.sucursal.users.each do |usuario|
          #Llena un array con todos los cajeros de la sucursal
          #(usuarios de la sucursal que pueden hacer una venta, no solo el rol de usuario)
          #Siempre y cuando no sean auxiliares o almacenistas pues no tienen acceso a punto de venta
          unless usuario.role == "auxiliar" || usuario.role == "almacenista" || usuario.role == "cajero"
            @usuarios.push(usuario.perfil)
          end
        end
      end
    end

    def set_sucursales
      @sucursales = current_user.negocio.sucursals
    end

    def set_categorias
      @categorias = current_user.negocio.cat_venta_canceladas
    end

end
