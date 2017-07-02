class PagoPendientesController < ApplicationController
  before_action :set_pago_pendiente, only: [:show, :edit, :update, :destroy]
  
  def index
    @pagosPendientes = current_user.sucursal.pago_pendientes
    @proveedores = current_user.negocio.proveedores

  end

  
  def show
    @proveedor = @pago_pendiente.proveedor.nombre
    @facturaTicket = @pago_pendiente.compra.folio_compra + "/ " + @pago_pendiente.compra.ticket_compra
    @fechaVencimiento = @pago_pendiente.fecha_vencimiento.strftime("%d/%m/%Y")
    @adeudoOriginal = @pago_pendiente.compra.monto_compra
    @adeudoPendiente = @pago_pendiente.saldo
    @status = ""
    if Time.now >= @pago_pendiente.fecha_vencimiento
      @status = "Vencido"
    else
      @status = "Activo"
    end

    @pagoProveedores = nil
    
    if @pago_pendiente.pago_proveedores
      @pagoProveedores = @pago_pendiente.pago_proveedores
    end

  end

  
  def edit
    @cajas = current_user.sucursal.caja_sucursals
    
  end

  
  def update
  end

  
  def destroy
  end

  private

    def set_pago_pendiente
      @pago_pendiente = PagoPendiente.find(params[:id])
    end
end
