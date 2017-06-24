class DevolucionesController < ApplicationController
   before_action :set_devolucion, only: [:show]
   before_action :set_usuarios, only: [:index, :consulta_por_fecha, :consulta_avanzada, :consulta_por_producto]
   before_action :set_sucursales, only: [:index, :consulta_por_fecha, :consulta_avanzada, :consulta_por_producto]
   before_action :set_categorias, only: [:index, :consulta_por_fecha, :consulta_avanzada, :consulta_por_producto]

  def index
  	if can? :create, Negocio
  		@devoluciones = current_user.negocio.venta_canceladas
  	else
  		@devoluciones = current_user.sucursal.venta_canceladas
  	end
  end

  def show
  end

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
      @cantidad_devuelta = params[:cantidad_devuelta]
      @itemVenta = ItemVenta.find(params[:item_venta])
      @venta =  @itemVenta.venta
      categoria = params[:devolucion]
      @categoriaCancelacion = CatVentaCancelada.find(categoria[:cat_devolucion])
      @observaciones = params[:observaciones]
      @venta.status = "Con devoluciones"
      @itemVenta.status = "Con devoluciones"
      @devolucion = VentaCancelada.new(:articulo=>@itemVenta.articulo, :item_venta=>@itemVenta, :venta=>@venta, :user=>current_user, :negocio=>current_user.negocio, :sucursal=>@itemVenta.articulo.sucursal, :cantidad_devuelta=>@cantidad_devuelta, :observaciones=>@observaciones)
      @categoriaCancelacion.venta_canceladas << @devolucion
      @itemVenta.articulo.existencia += @cantidad_devuelta.to_f
      @itemVenta.cantidad -= @cantidad_devuelta.to_f

      respond_to do |format|
	    if @devolucion.valid?
	      if @devolucion.save && @itemVenta.save && @venta.save     
	        flash[:notice] = "La devolución se realizó con éxito"
	        format.html { redirect_to action: "devolucion" }

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
