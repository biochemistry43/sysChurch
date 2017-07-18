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
      if can? :create, Negocio
        @categorias = current_user.negocio.cat_venta_canceladas
      else
        @categorias = current_user.sucursal.cat_venta_canceladas
      end
      
    end

end
