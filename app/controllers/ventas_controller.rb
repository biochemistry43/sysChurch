class VentasController < ApplicationController

  def index
    @ventas = Venta.all

  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end

  def venta_del_dia

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

  end
end
