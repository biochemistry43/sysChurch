class CajaChicasController < ApplicationController
  before_action :set_caja_chica, only: [:edit, :update, :destroy, :show]

  def index
    @movimientos_caja = current_user.sucursal.caja_chicas#.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month)
    entradas = CajaChica.where(sucursal: current_user.sucursal).sum(:entrada)
    salidas = CajaChica.where(sucursal: current_user.sucursal).sum(:salida)
    @saldo = entradas - salidas
    #if current_user.sucursal.caja_chicas.count > 0
     # last = current_user.sucursal.caja_chicas.last
     # @saldo = last.saldo
    #else
    #  @saldo = 0.0
    #end
    @caja_chicas = current_user.sucursal.caja_chicas
  end

  def new
    @caja_chica = CajaChica.new
  end 

  def show
    
    @fechaOperacion = @caja_chica.created_at.strftime("%d/%m/%Y") 
    @importeOperacion = 0
    if @caja_chica.salida
      @importeOperacion = -1 * @caja_chica.salida
    elsif @caja_chica.entrada
      @importeOperacion = @caja_chica.entrada
    end
    @conceptoOperacion = @caja_chica.concepto
    @usuarioOperacion = @caja_chica.user.perfil ? @caja_chica.user.perfil.nombre_completo : @caja_chica.user.email

    @gasto = nil
    @gastoGeneral = nil
    @pagoProveedor = nil
    @pagoDevolucion = nil

    #Devuelve los detalles cuando el movimiento de caja chica fue un gasto de cualquier índole
    if @caja_chica.gasto
      @gasto = @caja_chica.gasto
      
      #Si el gasto que se intenta mostrar es el pago de una devolución...
      if @gasto.pago_devolucion
        @pagoDevolucion = @gasto.pago_devolucion
        @folioVenta = @pagoDevolucion.venta_cancelada.venta.folio
        @fechaVenta = @pagoDevolucion.venta_cancelada.venta.created_at.strftime("%d/%m/%Y") 
        @clienteVenta = @pagoDevolucion.venta_cancelada.venta.cliente ? @pagoDevolucion.venta_cancelada.venta.cliente.nombre_completo : "<ge></ge>neral"
      end

      #Si el movimiento que se quiere mostrar el el pago a un proveedor (sea por compra o por gasto general)
      if @gasto.pago_proveedor
        if @gasto.gasto_general
          @gastoGeneral = @gasto.gasto_general
          @facturaGasto = @gastoGeneral.folio_gasto ? @gastoGeneral.folio_gasto : "No aplica"
          @ticketGasto = @gastoGeneral.ticket_gasto ? @gastoGeneral.ticket_gasto : "No aplica"
          @proveedor = @gastoGeneral.proveedor.nombre
        else
          @pagoProveedor = @gasto.pago_proveedor
          @facturaCompra = @pagoProveedor.compra.folio_compra ? @pagoProveedor.compra.folio_compra : "No aplica"
          @ticketCompra = @pagoProveedor.compra.ticket_compra ? @pagoProveedor.compra.ticket_compra : "No aplica"
          @fechaCompra = @pagoProveedor.compra.created_at.strftime("%d/%m/%Y") 
          @proveedorCompra = @pagoProveedor.compra.proveedor.nombre
          @statusPagoCompra = @pagoProveedor.statusPago
        end
      end

      

    end

  end

  def create
    @caja_chica = CajaChica.new(caja_chica_params)
    
    #actualizando el saldo de la caja chica
    #last = nil
    #if current_user.sucursal.caja_chicas.count > 0
    #  last = current_user.sucursal.caja_chicas.last
    #  saldoActual = last.saldo
    #  entrada = params[:caja_chica][:entrada].to_f
    #  saldoActualizado = entrada + saldoActual
    #  @caja_chica.saldo = saldoActualizado
    #else
    #  @caja_chica.saldo = caja_chica_params[:entrada].to_f
    #end

    #aplicando un concepto genérico
    @caja_chica.concepto = "Reposicion de caja"

    #Relacionando el registro de caja chica con el usuario, negocio y sucursal
    current_user.caja_chicas << @caja_chica
    current_user.negocio.caja_chicas << @caja_chica
    current_user.sucursal.caja_chicas << @caja_chica

    respond_to do |format|
      if @caja_chica.save
      
        format.json { head :no_content}
        format.js
      else
        format.json {render json: @caja_chica.errors.full_messages, status: :unprocessable_entity}
        format.js {render :new} 
      end
    end

  end

  def edit
  end

  def update
    

    respond_to do |format|
      if @caja_chica.update(caja_chica_params)
        format.json { head :no_content}
        format.js
      else
        format.json {render json: @caja_chica.errors.full_messages, status: :unprocessable_entity}
        format.js {render :edit}
      end
    end
  end

  def destroy
    @caja_chica.destroy
    respond_to do |format|
      format.js
      format.json { head :no_content }
    end
  end

  private

    def set_caja_chica
      @caja_chica = CajaChica.find(params[:id])
    end

    def caja_chica_params
      params.require(:caja_chica).permit(:entrada)
    end

end
