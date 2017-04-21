class VentasController < ApplicationController

  before_action :set_venta, only: [:show, :edit, :update, :destroy]
  before_action :set_cajeros, only: [:index, :consulta_ventas, :consulta_avanzada]

  def index
    if can? :create, Negocio
      @ventas = current_user.negocio.ventas
    else
      @ventas = current_user.sucursal.ventas
    end
  end

  def show
    @cliente = @venta.cliente.nombre
    @cliente << " " << @venta.cliente.ape_pat << " " << @venta.cliente.ape_mat
    @sucursal = @venta.sucursal.nombre
    @cajero = @venta.user.perfil ? @venta.user.perfil.nombre : @venta.user.email
    @items = @venta.item_ventas
    @formaPago = @venta.venta_forma_pago.forma_pago.nombre
    @camposFormaPago = @venta.venta_forma_pago.venta_forma_pago_campos


  end

  def new
  end

  def edit
  end

  def create
  end

  def update
    respond_to do |format|
      observaciones = params[:observaciones]
      if @venta.update(:observaciones=>observaciones, :status=>"cancelado")
        format.json { head :no_content}
        format.js
      else
        format.json {render json: @venta.errors.full_messages, status: :unprocessable_entity}
        format.js {render :edit}
      end
    end
  end

  def destroy
  end

  def consulta_ventas
    if request.post?
      fechaInicial = DateTime.parse(params[:fecha_inicial]).to_date
      fechaFinal = DateTime.parse(params[:fecha_final]).to_date
      if can? :create, Negocio
        @resVentas = current_user.negocio.ventas.where(fechaVenta: fechaInicial..fechaFinal)
      else
        @resVentas = current_user.sucursal.ventas.where(fechaVenta: fechaInicial..fechaFinal)
      end

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end
  end

  def consulta_avanzada
    if request.post?
      
    end
  end

  def venta_del_dia

    if request.get?
      @fechaCorrecta = Date.today
      
      @ventasNegocioHoy = current_user.negocio.ventas.where(fechaVenta: Date.today)

      @ventasNegocioMes = current_user.negocio.ventas.where(fechaVenta: Date.today.beginning_of_month..Date.today)

      @ventaDiaNegocio = 0

      @ventaMesNegocio = 0
      
      @ventasNegocioHoy.each do |venta|
        @ventaDiaNegocio += venta.montoVenta.to_f
      end

      @ventasNegocioMes.each do |venta|
        @ventaMesNegocio += venta.montoVenta.to_f
      end

      @sucursales = current_user.negocio.sucursals

      @usuarios = current_user.negocio.users
    
    elsif request.post?
      
      fecha = params[:Fecha]
      @fechaCorrecta = DateTime.parse(fecha).to_date
       
      @ventasNegocioHoy = current_user.negocio.ventas.where(fechaVenta: @fechaCorrecta)

      @ventasNegocioMes = current_user.negocio.ventas.where(fechaVenta: @fechaCorrecta.beginning_of_month..@fechaCorrecta.end_of_month)

      @ventaDiaNegocio = 0

      @ventaMesNegocio = 0
      
      @ventasNegocioHoy.each do |venta|
        @ventaDiaNegocio += venta.montoVenta.to_f
      end

      @ventasNegocioMes.each do |venta|
        @ventaMesNegocio += venta.montoVenta.to_f
      end

      @sucursales = current_user.negocio.sucursals

      @usuarios = current_user.negocio.users

    end


  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_venta
      @venta = Venta.find(params[:id])
    end

    def set_cajeros
      @cajeros = []
      if can? :create, Negocio
        current_user.negocio.users.each do |cajero|
          @cajeros.push(cajero.perfil)
        end
      else
        current_user.sucursal.users.each do |cajero|
          @cajeros.push(cajero.perfil)
        end
      end
    end

end
