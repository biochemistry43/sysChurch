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
    @ventas = Venta.where({ fechaVenta: (Date.today)})
    @VentaDelDia = 0
    
    @ventas.each do |venta|
      @VentaDelDia += venta.montoVenta.to_f
    end

    @usuarios = User.all
    @monto = 0

  end
end
