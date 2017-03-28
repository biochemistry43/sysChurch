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
    @ventas = current_user.sucursal.ventas
    @VentaDelDia = 0
    
    @ventas.each do |venta|
      @VentaDelDia += venta.montoVenta.to_f
    end

    @usuarios = current_user.negocio.users
    @monto = 0

  end
end
