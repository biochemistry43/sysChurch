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
    #plantilla_email("nc")

    if @itemVenta.venta.factura.present?
      @folio_fiscal = @itemVenta.venta.factura.folio_fiscal
      #Se supone que esto es solo si la venta está facturada
      require 'plantilla_email/plantilla_email.rb'

      mensaje = current_user.negocio.plantillas_emails.find_by(comprobante: "nc").msg_email
      asunto = current_user.negocio.plantillas_emails.find_by(comprobante: "nc").asunto_email

      # :( Se tienen que calcular todos los textos variables por que se trata de crear apenas una nota de crédito 
      cadena = PlantillaEmail::AsuntoMensaje.new
      factura_relacionada_NC = @itemVenta.venta.factura
      cadena.nombCliente = factura_relacionada_NC.cliente.nombre_completo #if mensaje.include? "{{Nombre del cliente}}"
      
      #Para obtener el numero consecutivo a partir de la ultima NC
      consecutivo = 0
      if current_user.sucursal.nota_creditos.last
        consecutivo = current_user.sucursal.nota_creditos.last.consecutivo
        if consecutivo
          consecutivo += 1
        end
      else
        consecutivo = 1 
      end

      #El folio de las facturas se forma por defecto por la clave de las sucursales
      claveSucursal = current_user.sucursal.clave
      serie = claveSucursal + "NC"
      fecha_expedicion_nc = Time.now
      fecha_expedicion_nc = fecha_expedicion_nc.strftime("%Y-%m-%d")
      
      cadena.fechaNC = fecha_expedicion_nc
      cadena.numNC = consecutivo
      cadena.folioNC = serie + consecutivo.to_s
      cadena.totalNC = "X.XX"#@nota_credito.monto""
        
      cadena.fechaFact = @itemVenta.venta.factura.fecha_expedicion
      cadena.numFact = @itemVenta.venta.factura.consecutivo
      cadena.folioFact = @itemVenta.venta.factura.folio
      cadena.totalFact = @itemVenta.venta.factura.venta.montoVenta
        
      cadena.nombNegocio = current_user.negocio.nombre 
      cadena.nombSucursal = current_user.sucursal.nombre
      cadena.emailContacto = current_user.sucursal.email
      cadena.telContacto = current_user.sucursal.telefono

      @mensaje = cadena.reemplazar_texto(mensaje)
      @asunto = cadena.reemplazar_texto(asunto)
    end
  end

  def devolucion
  	@consulta = false
  	if request.post?
  	  @consulta = true
      #@venta = Venta.find_by :folio=>params[:folio]
      @venta = current_user.negocio.ventas.find_by :folio=>params[:folio]
      if @venta
        if current_user.negocio.id == @venta.negocio.id
          unless @venta.status.eql?("Cancelada") #Quiere decir que puede estar Activa o con devoluciones
            #p "NO ESTÁ CANCELADA"
            @ventaCancelada = false
            #En caso que la venta tenga devoluciones... se comprueba que aun haya algún producto sin devolver de la venta original
            if @venta.status.eql?("Con devoluciones")#@venta.venta_canceladas.size > 0
              @monto_devolucion = 0
              @venta.venta_canceladas.each do |devolucion|
                @monto_devolucion += devolucion.monto
              end
            else
              @monto_devolucion = 0
            end # Fin de devoluciones

            #Solo si el monto de la suma de todas las devoluciones es inferior al monto de la venta
            unless @monto_devolucion == @venta.montoVenta
              #p "SE PUEDE DEVOLVER"
              @itemsVenta  = @venta.item_ventas
              @ventaConDevolucionTotal = false
            else
              #p "LA VENTA FUE COMPLETAMENTE DEVUELTA"
              @ventaConDevolucionTotal = true
            end

          else
            @ventaCancelada = true
          end
        end
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

      #Se crea una nota de crédito(Solo para las ventas que tengan una factura relacionada)
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
        require 'plantilla_email/plantilla_email.rb'

#========================================================================================================================
        #1.- CERTIFICADOS,  LLAVES Y CLAVES
        certificado = CFDI::Certificado.new '/home/daniel/Documentos/prueba/CSD01_AAA010101AAA.cer'
        # Esta se convierte de un archivo .key con:
        # openssl pkcs8 -inform DER -in someKey.key -passin pass:somePassword -out key.pem
        path_llave = "/home/daniel/Documentos/timbox-ruby/CSD01_AAA010101AAA.key.pem"
        password_llave = "12345678a"
        #openssl pkcs8 -inform DER -in /home/daniel/Documentos/prueba/CSD03_AAA010101AAA.key -passin pass:12345678a -out /home/daniel/Documentos/prueba/CSD03_AAA010101AAA.pem
        llave = CFDI::Key.new path_llave, password_llave

#========================================================================================================================
        #2.- LLENADO DEL XML DIRECTAMENTE DE LA BASE DE DATOS
        #Para obtener el numero consecutivo a partir de la ultima NC o de lo contrario asignarle por primera vez un número
        consecutivo = 0
        if current_user.sucursal.nota_creditos.last
          consecutivo = current_user.sucursal.nota_creditos.last.consecutivo
          if consecutivo
            consecutivo += 1
          end
        else
          consecutivo = 1 
        end

        #El folio de las facturas se forma por defecto por la clave de las sucursales
        claveSucursal = current_user.sucursal.clave
        serie = claveSucursal + "NC"
 
        fecha_expedicion_nc = Time.now
        #2.- LLENADO DEL XML DIRECTAMENTE DE LA BASE DE DATOS
        #La informacion de la nota de crédito debe de ser la misma que la del comprobante de ingreso a la que se le realizará el descuento, devolucion...
        nota_credito = CFDI::Comprobante.new({
          serie: serie,
          folio: consecutivo,
          #fecha: fecha_expedicion_nc,
          #Deberá ser de tipo Egreso
          tipoDeComprobante: "E",
          #La moneda por default es MXN
          #Forma de pago, opciones de registro:
            #La que se registró en el comprobante de tipo ingreso.
            #Con la que se está efectuando el descuento, devolución o bonificación en su caso.
          FormaPago: FacturaFormaPago.find(params[:forma_pago_nc]).cve_forma_pagoSAT,
          #condicionesDePago: 'Sera marcada como pagada en cuanto el receptor haya cubierto el pago.',
          metodoDePago: 'PUE', #Deberá ser PUE- Pago en una sola exhibición
          lugarExpedicion: current_user.sucursal.codigo_postal,#current_user.negocio.datos_fiscales_negocio.codigo_postal,#, #CATALOGO
          total: @cantidad_devuelta.to_f * @itemVenta.precio_venta#'%.2f' % (@cantidad_devuelta.to_f * @itemVenta.precio_venta).round(2) #La cantidad devuelta apartir de la cantidad po item de venta
        })

        #Dirección del negocio(La misma que la de la factura)
        #La dirección fiscal ya no es requerida por el SAT, sin embargo se usaran para la representacion impresa de los CFDIs si esque los proporciona el cliente jaja.*
        #Son datos que ya existen en el sistema por haber realizado la factura y no tienen por que asignarse otro valor para las NC
        @factura = @venta.factura
        domicilioEmisor = CFDI::DatosComunes::Domicilio.new({
          calle: @factura.negocio.datos_fiscales_negocio.calle,
          noExterior: @factura.negocio.datos_fiscales_negocio.numExterior,
          noInterior: @factura.negocio.datos_fiscales_negocio.numInterior,
          colonia: @factura.negocio.datos_fiscales_negocio.colonia,
          localidad: @factura.negocio.datos_fiscales_negocio.localidad,
          referencia: @factura.negocio.datos_fiscales_negocio.referencia,
          municipio: @factura.negocio.datos_fiscales_negocio.municipio,
          estado: @factura.negocio.datos_fiscales_negocio.estado,
          codigoPostal: @factura.negocio.datos_fiscales_negocio.codigo_postal
          })
        #Dirección de la sucursal(es la misma que la de la factura)
        if  current_user.sucursal
          expedidoEn= CFDI::DatosComunes::Domicilio.new({
            calle: @factura.sucursal.datos_fiscales_sucursal.calle,
            noExterior: @factura.sucursal.datos_fiscales_sucursal.numExt,
            noInterior: @factura.sucursal.datos_fiscales_sucursal.numInt,
            colonia: @factura.sucursal.datos_fiscales_sucursal.colonia,
            localidad: @factura.sucursal.datos_fiscales_sucursal.localidad,#current_user.negocio.datos_fiscales_negocio.,
            referencia: @factura.sucursal.datos_fiscales_sucursal.referencia,#current_user.negocio.datos_fiscalecurrent_user.sucursal.codigo_postals_negocio.,
            municipio: @factura.sucursal.datos_fiscales_sucursal.municipio,
            estado: @factura.sucursal.datos_fiscales_sucursal.estado,
            codigoPostal: @factura.sucursal.datos_fiscales_sucursal.codigo_postal,
          })
        else
          expedidoEn= CFDI::DatosComunes::Domicilio.new({})
        end

        nota_credito.emisor = CFDI::Emisor.new({
          rfc: current_user.negocio.datos_fiscales_negocio.rfc,
          nombre: current_user.negocio.datos_fiscales_negocio.nombreFiscal,
          regimenFiscal: current_user.negocio.datos_fiscales_negocio.regimen_fiscal.cve_regimen_fiscalSAT, #CATALOGO
          domicilioFiscal: domicilioEmisor,
          expedidoEn: expedidoEn
        })

        #La dirección fiscal del cliente a quien fue expedida la factura
        domicilioReceptor = CFDI::DatosComunes::Domicilio.new({
          calle: @factura.cliente.datos_fiscales_cliente.calle,
          noExterior: @factura.cliente.datos_fiscales_cliente.numExterior,
          noInterior: @factura.cliente.datos_fiscales_cliente.numInterior,
          colonia: @factura.cliente.datos_fiscales_cliente.colonia,
          localidad: @factura.cliente.datos_fiscales_cliente.localidad,
          municipio: @factura.cliente.datos_fiscales_cliente.municipio,
          referencia: @factura.cliente.datos_fiscales_cliente.referencia,
          estado: @factura.cliente.datos_fiscales_cliente.estado,
          codigoPostal: @factura.cliente.datos_fiscales_cliente.codigo_postal,
          pais: @factura.cliente.datos_fiscales_cliente.pais
          })

        #Se cargan los mismo datos del receptor, aquí solo se trata de devolución y no de una nota de crédito para enmendar un error.
        #Atributos del receptor
        rfc_receptor_nc = @factura.cliente.datos_fiscales_cliente.rfc
        nombre_fiscal_receptor_nc = @factura.cliente.datos_fiscales_cliente.nombreFiscal
        #Al tratarse de un CFDI de egresos, no será un comprobante de deducción para el receptor, ya que se está emitiendo para disminuir el importe de un CFDI relacionado.
        #Por lo tanto el uso sera: G02 - Devoluciones, descuentos o bonificaciones

        nota_credito.receptor = CFDI::Receptor.new({
           rfc: rfc_receptor_nc,
           nombre: nombre_fiscal_receptor_nc,
           UsoCFDI: params[:uso_nc],#G02", #"Devoluciones, descuentos o bonificaciones" Aplica para persona fisica y moral
           domicilioFiscal: domicilioReceptor
          })
        #Cuando se realiza una nota de crédito por devolución, el comprobante de egreso(nota de crédito) debe de contener solo los productos devueltos.
        items = []
        items << @itemVenta
        cont=0
        items.each do |c|
          hash_conceptos={ClaveProdServ: c.articulo.clave_prod_serv.clave, #Catálogo
                          NoIdentificacion: c.articulo.clave,
                          Cantidad: @cantidad_devuelta.to_f,
                          ClaveUnidad:c.articulo.unidad_medida.clave,#Catálogo
                          Unidad: c.articulo.unidad_medida.nombre, #Es opcional para precisar la unidad de medida propia de la operación del emisor, pero pues...
                          Descripcion: c.articulo.nombre
                          }

          importe_concepto = (c.precio_venta * @cantidad_devuelta.to_f)#Incluye impuestos(si esq), descuentos(si esq)...
          if c.articulo.impuesto.present? #Impuestos a la inversa
            tasaOCuota = (c.articulo.impuesto.porcentaje / 100)#Se obtiene la tasa o cuota por ej. 16% => 0.160000
            #Se calcula el precio bruto de cada concepto
            base_gravable = (importe_concepto / (tasaOCuota + 1)) #Se obtiene el precio bruto por item de venta
            importe_impuesto_concepto = (base_gravable * tasaOCuota)

            valorUnitario = base_gravable / @cantidad_devuelta.to_f

            if c.articulo.impuesto.tipo == "Federal"
              if c.articulo.impuesto.nombre == "IVA"
                clave_impuesto = "002"
              elsif c.articulo.impuesto.nombre == "IEPS"
                clave_impuesto =  "003"
              end
              nota_credito.impuestos.traslados << CFDI::Impuesto::Traslado.new(base: base_gravable,
                tax: clave_impuesto, type_factor: "Tasa", rate: tasaOCuota, import: importe_impuesto_concepto.round(2), concepto_id: cont)
            #end
            #elsif c.articulo.impuesto.tipo == "Local"
              #Para el complemento de impuestos locales.
            end
            hash_conceptos[:ValorUnitario] = valorUnitario
            hash_conceptos[:Importe] = base_gravable
          else
            hash_conceptos[:ValorUnitario] = importe_concepto = c.precio_venta
            hash_conceptos[:Importe] = importe_concepto
          end
          nota_credito.conceptos << CFDI::Concepto.new(hash_conceptos)
          cont += 1
        end

        nota_credito.uuidsrelacionados << CFDI::Cfdirelacionado.new({
          uuid: params[:uuid_factura] #@factura.folio_fiscal #Aquí se relaciona el comprobante de ingreso por la que se realizará la nota de crŕedito
          })
        nota_credito.cfdisrelacionados = CFDI::CfdiRelacionados.new({
          tipoRelacion: params[:tipo_relacion]#{}"03"# Devolución de mercancías sobre facturas o traslados previos
        })

#========================================================================================================================
        #3.- SE AGREGA EL CERTIFICADO Y EL SELLO DIGITAL
        @total_to_w = nota_credito.total_to_words
        # Esto hace que se le agregue al comprobante el certificado y su número de serie (noCertificado)
        certificado.certifica nota_credito
        #Se agrega el sello digital del comprobante, esto implica actulizar la fecha y calcular la cadena original
        xml_certificado_sellado = llave.sella nota_credito

#========================================================================================================================
      #4.- ALTERNATIVA DE CONEXIÓN PARA CONSUMIR EL WEBSERVICE DE TIMBRADO CON TIMBOX
        #Se obtiene el xml timbrado

        # Convertir la cadena del xml en base64
        xml_base64 = Base64.strict_encode64(xml_certificado_sellado)

        # Parametros para conexion al Webservice (URL de Pruebas)
        wsdl_url = "https://staging.ws.timbox.com.mx/timbrado_cfdi33/wsdl"
        usuario = "AAA010101000"
        contrasena = "h6584D56fVdBbSmmnB"

        xml_timbox = timbrar_xml(usuario, contrasena, xml_base64, wsdl_url)

        #Guardo el xml recien timbradito de timbox, calientito
        nc_id = current_user.sucursal.nota_creditos.last ? current_user.sucursal.nota_creditos.last.id : 1
        archivo = File.open("public/#{nc_id}_nc.xml", "w")
        archivo.write (xml_timbox)
        archivo.close

        #Se forma la cadena original del timbre fiscal digital de manera manual por que e mugroso xslt del SAT no Jala.
        nota_credito.complemento=CFDI::Complemento.new(
          {
            Version: xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@Version'),
            uuid:xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@UUID'),
            FechaTimbrado:xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@FechaTimbrado'),
            RfcProvCertif:xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@RfcProvCertif'),
            SelloCFD:xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@SelloCFD'),
            NoCertificadoSAT:xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@NoCertificadoSAT')
          }
        )
        #se hace una copia del xml para modificarlo agregandole información extra para la representación impresa.
        xml_copia = xml_timbox

#========================================================================================================================
        #5.- SE AGREGAN NUEVOS DATOS PARA LA REPRESENTACIÓN IMPRESA(INFORMACIÓN(PDF) IMPORTANTE PARA LOS CONTRIBUYENTES, PERO QUE AL SAT NO LE IMPORTAN JAJA)
        codigoQR = nota_credito.qr_code xml_timbox
        cadOrigComplemento = nota_credito.complemento.cadena_TimbreFiscalDigital
        logo=current_user.negocio.logo
        #No hay nececidad de darle a escoger el uso del cfdi al usuario.
        uso_cfdi_descripcion = "Devoluciones, descuentos o bonificaciones"
        #cve_descripcion_uso_cfdi_fg = "G02 - Devoluciones, descuentos o bonificaciones"
        cve_nombre_forma_pago = "#{FacturaFormaPago.find(params[:forma_pago_nc]).cve_forma_pagoSAT } - #{FacturaFormaPago.find(params[:forma_pago_nc]).nombre_forma_pagoSAT}"
        #método de pago(clave y descripción)
        #"deberá de ser siempre.. PUE"
        cve_nombre_metodo_pago = "PUE - Pago en una sola exhibición"
        #Regimen fiscal
        cve_regimen_fiscalSAT = current_user.negocio.datos_fiscales_negocio.regimen_fiscal.cve_regimen_fiscalSAT
        nomb_regimen_fiscalSAT = current_user.negocio.datos_fiscales_negocio.regimen_fiscal.nomb_regimen_fiscalSAT
        cve_nomb_regimen_fiscalSAT = "#{cve_regimen_fiscalSAT} - #{nomb_regimen_fiscalSAT}"
        #Para el nombre del changarro feo jajaja
        nombre_negocio = current_user.negocio.nombre

        #Personalización de la plantilla de impresión de una factura de venta. :P
        tipo_fuente = current_user.negocio.config_comprobantes.find_by(comprobante: "nc").tipo_fuente
        tam_fuente = current_user.negocio.config_comprobantes.find_by(comprobante: "nc").tam_fuente
        color_fondo = current_user.negocio.config_comprobantes.find_by(comprobante: "nc").color_fondo
        color_banda = current_user.negocio.config_comprobantes.find_by(comprobante: "nc").color_banda
        color_titulos = current_user.negocio.config_comprobantes.find_by(comprobante: "nc").color_titulos

        #Se pasa un hash con la información extra en la representación impresa como: datos de contacto, dirección fiscal y descripcion de la clave de los catálogos del SAT.
        hash_info = {xml_copia: xml_copia, codigoQR: codigoQR, logo: logo, cadOrigComplemento: cadOrigComplemento, uso_cfdi_descripcion: uso_cfdi_descripcion, cve_nombre_forma_pago: cve_nombre_forma_pago, cve_nombre_metodo_pago: cve_nombre_metodo_pago, cve_nomb_regimen_fiscalSAT:cve_nomb_regimen_fiscalSAT, nombre_negocio: nombre_negocio,
          tipo_fuente: tipo_fuente, tam_fuente: tam_fuente, color_fondo:color_fondo, color_banda:color_banda, color_titulos:color_titulos,
          tel_negocio: current_user.negocio.telefono, email_negocio: current_user.negocio.email, pag_web_negocio: current_user.negocio.pag_web
        }

        unless @factura.cliente.telefono1.to_s.strip.empty?
          hash_info[:Telefono1Receptor] =  @factura.cliente.telefono1
        else
          hash_info[:Telefono1Receptor] =  @factura.cliente.telefono2 unless receptor_final.telefono2.to_s.strip.empty?
        end
        hash_info[:EmailReceptor]= @factura.cliente.email unless @factura.cliente.email.to_s.strip.empty?
        #Solo si tiene más de un establecimiento el negocio...
        if current_user.sucursal
          hash_info[:tel_sucursal] = current_user.sucursal.telefono
          hash_info[:email_sucursal] = current_user.sucursal.email
        end

        xml_rep_impresa = nota_credito.add_elements_to_xml(hash_info)
        template = Nokogiri::XSLT(File.read('/home/daniel/Vídeos/sysChurch/lib/XSLT.xsl'))

        html_document = template.transform(xml_rep_impresa)
        #File.open('/home/daniel/Documentos/timbox-ruby/CFDImpreso.html', 'w').write(html_document)
        pdf = WickedPdf.new.pdf_from_string(html_document)
        #Se guarda el pdf 
        save_path = Rails.root.join('public',"#{nc_id}_nc.pdf")
        File.open(save_path, 'wb') do |file|
            file << pdf
        end

#========================================================================================================================
        #6.- SE ALMACENAN EN GOOGLE CLOUD STORAGE
        gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
        storage=gcloud.storage
        bucket = storage.bucket "cfdis"

        #Se realizan las consultas para formar los directorios en cloud
        dir_negocio = current_user.negocio.nombre
        dir_cliente = nombre_fiscal_receptor_nc

        #Se obtiene la fecha del xml timbrado para que no difiera de los comprobantes y del registro de la BD.
        fecha_registroBD = fecha_registroBD = DateTime.parse(xml_timbox.xpath('//@Fecha').to_s) 
        dir_dia = fecha_registroBD.strftime("%d")
        dir_mes = fecha_registroBD.strftime("%m")
        dir_anno = fecha_registroBD.strftime("%Y")

        fecha_file = fecha_registroBD.strftime("%Y-%m-%d")
        if current_user.sucursal
          dir_sucursal = current_user.sucursal.nombre
          ruta_storage = "#{dir_negocio}/#{dir_sucursal}/#{dir_anno}/#{dir_mes}/#{dir_dia}/#{dir_cliente}/#{nc_id}_nc"
        else
          ruta_storage = "#{dir_negocio}/#{dir_anno}/#{dir_mes}/#{dir_dia}/#{dir_cliente}/#{nc_id}_nc"
        end

        #Los comprobantes de almacenan en google cloud
        #file = bucket.create_file StringIO.new(pdf), "#{ruta_storage}_NotaCrédito.pdf"
        #file = bucket.create_file StringIO.new(xml_timbrado_storage.to_s), "#{ruta_storage}_NotaCrédito.xml"
        file = bucket.create_file "public/#{nc_id}_nc.pdf", "#{ruta_storage}.pdf"
        file = bucket.create_file "public/#{nc_id}_nc.xml", "#{ruta_storage}.xml"

#========================================================================================================================
      #7.- SE REGISTRA LA NUEVA FACTURA EN LA BASE DE DATOS
        folio_fiscal_xml = xml_timbox.xpath('//@UUID')
        @nota_credito = NotaCredito.new( consecutivo: consecutivo, folio: serie + consecutivo.to_s, fecha_expedicion: fecha_file, estado_nc:"Activa", ruta_storage: ruta_storage, monto: @cantidad_devuelta.to_f * @itemVenta.precio_venta, folio_fiscal: folio_fiscal_xml)
        #@factura = Factura.find(@venta.factura_id)

        if @nota_credito.save
          current_user.nota_creditos << @nota_credito
          current_user.negocio.nota_creditos << @nota_credito
          current_user.sucursal.nota_creditos << @nota_credito
          Cliente.find(@factura.cliente.id).nota_creditos << @nota_credito
          @factura.nota_creditos <<  @nota_credito
          FacturaFormaPago.find(params[:forma_pago_nc]).nota_creditos << @nota_credito
        end

#========================================================================================================================
        #8.- SE ENVIAN LOS COMPROBANTES(pdf y xml timbrado) AL CLIENTE POR CORREO ELECTRÓNICO. :p
        #Se asignan los valores del texto variable de la configuración de las plantillas de email.
        destinatario = params[:destinatario]

        mensaje = current_user.negocio.plantillas_emails.find_by(comprobante: "nc").msg_email
        asunto = current_user.negocio.plantillas_emails.find_by(comprobante: "nc").asunto_email

        cadena = PlantillaEmail::AsuntoMensaje.new
        factura_relacionada_NC = @itemVenta.venta.factura
        cadena.nombCliente = factura_relacionada_NC.cliente.nombre_completo #if mensaje.include? "{{Nombre del cliente}}"
        
        cadena.fechaNC = fecha_expedicion_nc.strftime("%Y-%m-%d")
        cadena.numNC = consecutivo
        cadena.folioNC = serie + consecutivo.to_s
        cadena.totalNC = @cantidad_devuelta.to_f * @itemVenta.precio_venta
          
        cadena.fechaFact = @factura.fecha_expedicion
        cadena.numFact = @factura.consecutivo
        cadena.folioFact = @factura.folio
        cadena.totalFact = @factura.venta.montoVenta
          
        cadena.nombNegocio = current_user.negocio.nombre 
        cadena.nombSucursal = current_user.sucursal.nombre
        cadena.emailContacto = current_user.sucursal.email
        cadena.telContacto = current_user.sucursal.telefono

        @mensaje = cadena.reemplazar_texto(mensaje)
        @asunto = cadena.reemplazar_texto(asunto)
        
        comprobantes = {pdf_nc:"public/#{nc_id}_nc.pdf", xml_nc:"public/#{nc_id}_nc.xml"}

        FacturasEmail.factura_email(destinatario, @mensaje, @asunto, comprobantes).deliver_now
      end #Fin de @venta.factura.present?

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
