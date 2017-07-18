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

  #El método update se utiliza para aplicar pagos a los pagos pendientes.
  def update
    @cajas = current_user.sucursal.caja_sucursals
    origen_recurso = params[:select_origen_recurso]
    pago_realizado = params[:pago_aplicar].to_f
    
    respond_to do |format|

      @categoriaGasto = current_user.negocio.categoria_gastos.where("nombre_categoria = ?", "Pagos pendientes").take

      #Si se cumple esta condición, significa que el recurso para el pago de proveedor, provendrá de alguna de las cajas 
      #de venta que tiene la sucursal. La cadena contiene el id de la caja de venta seleccionada.
      if origen_recurso.include? "caja_venta"
        tamano_cadena_origen = origen_recurso.length

        #aquí extraigo el id de la caja de venta contenido en la cadena de texto
        #el número "11" corresponde a la cantidad de caracteres de la cadena "caja_venta_"
        id_caja_sucursal = origen_recurso[11..tamano_cadena_origen]

        #En base al id extraido de la cadena, busco la Caja de Venta en la base de datos
        @cajaVenta = CajaSucursal.find(id_caja_sucursal)

        #Verifico que la caja tenga el saldo necesario para realizar la operación de pago pendiente al proveedor.
        if @cajaVenta.saldo >= pago_realizado
          
          @gasto = Gasto.new(:monto=>pago_realizado, :concepto=>"Pago pendiente realizado a un proveedor", :tipo=>"pago pendiente")      
          
          #creación y relación del registro de pago de la compra al proveedor indicado
          @pagoProveedor = PagoProveedor.new(:monto=>pago_realizado, :compra=>@pago_pendiente.compra, :gasto=>@gasto, :proveedor=>@pago_pendiente.compra.proveedor, :user=>current_user, :sucursal=>current_user.sucursal, :negocio=>current_user.negocio)

          #Se asigna el status correcto pago realizado, ya sea que se haya liquidado el pago pendiente o que se
          #haya realizado sólo un abono.
          if pago_realizado == @pago_pendiente.saldo
            @pagoProveedor.statusPago = "Liquidación de compra"
          else
            @pagoProveedor.statusPago = "Abono"
          end

          #Se relaciona el pago pendiente con el abono o liquidación dado. Esto es, se relaciona el registro del
          #pago pendiente con el registro del pago al proveedor
          @pago_pendiente.pago_proveedores << @pagoProveedor
          
          #Se descuenta saldo del pago pendiente.
          saldo_pendiente = @pago_pendiente.saldo
          @pago_pendiente.saldo = saldo_pendiente - pago_realizado
   
          #relaciones del registro de gasto
          @categoriaGasto.gastos << @gasto
          @cajaVenta.gastos << @gasto
          current_user.gastos << @gasto
          current_user.sucursal.gastos << @gasto
          current_user.negocio.gastos << @gasto

          #Se actualiza el saldo de la caja de venta
          saldo = @cajaVenta.saldo - pago_realizado
          @cajaVenta.saldo = saldo

          #Se registra el movimiento de caja de venta. En este caso, es un movimiento de salida
          @movimientoCaja = MovimientoCajaSucursal.new(:salida=>pago_realizado, :caja_sucursal=>@cajaVenta)
          current_user.movimiento_caja_sucursals << @movimientoCaja
          current_user.sucursal.movimiento_caja_sucursals << @movimientoCaja
          current_user.negocio.movimiento_caja_sucursals << @movimientoCaja

          if @cajaVenta.save && @gasto.save && @pagoProveedor.save && @movimientoCaja.save && @pago_pendiente.save
            
            if @pago_pendiente.saldo == 0
              @pago_pendiente.destroy
              format.json { head :no_content}
              format.js
              flash[:notice] = "Pago realizado correctamente. El pago pendiente fue liquidado."
            else
              format.json { head :no_content}
              format.js
              flash[:notice] = "Se realizó un abono al pago pendiente."
            end

            
          else
            format.json {render json: @pago_pendiente.errors.full_messages, status: :unprocessable_entity}
            format.js
            flash[:notice] = "Hubo un error al momento de guardar el registro de pago. Intente de nuevo."
          end

        else
          format.json {render json: @pago_pendiente.errors.full_messages, status: :unprocessable_entity}
          format.js
          flash[:notice] = "No hay saldo suficiente en la caja #{@cajaVenta.nombre} para hacer el pago. Pago no realizado"
        end

      end

      #Si se cumple esta condición, significa que el recurso provendrá de la caja chica que tiene la sucursal.
      if origen_recurso.include? "caja_chica"

        #Verifica si existen registros de caja chica para esta sucursal
        if current_user.sucursal.caja_chicas

          #Se obtiene el saldo actual de la caja chica haciendo una comparación de sumatorias entre las entradas
          #y las salidas de caja chica.
          entradas = CajaChica.sum(:entrada, :conditions=>["sucursal_id=?", current_user.sucursal.id])
          salidas = CajaChica.sum(:salida, :conditions=>["sucursal_id=?", current_user.sucursal.id])
          @saldoCajaChica = entradas - salidas


          if @saldoCajaChica >= pago_realizado

            saldo_en_caja_chica = @saldoCajaChica

            @gasto = Gasto.new(:monto=>pago_realizado, :concepto=>"Pago pendiente realizado a un proveedor", :tipo=>"pago pendiente")

            #creación y relación del registro de pago de la compra al proveedor indicado
            @pagoProveedor = PagoProveedor.new(:monto=>pago_realizado, :compra=>@pago_pendiente.compra, :gasto=>@gasto, :proveedor=>@pago_pendiente.compra.proveedor, :user=>current_user, :sucursal=>current_user.sucursal, :negocio=>current_user.negocio)
            
            #Se asigna el status correcto pago realizado, ya sea que se haya liquidado el pago pendiente o que se
            #haya realizado sólo un abono.
            if pago_realizado == @pago_pendiente.saldo
              @pagoProveedor.statusPago = "Liquidación de compra"
            else
              @pagoProveedor.statusPago = "Abono"
            end

            #Se relaciona el pago pendiente con el abono o liquidación dado. Esto es, se relaciona el registro del
            #pago pendiente con el registro del pago al proveedor
            @pago_pendiente.pago_proveedores << @pagoProveedor

            #Se descuenta saldo del pago pendiente.
            saldo_pendiente = @pago_pendiente.saldo
            @pago_pendiente.saldo = saldo_pendiente - pago_realizado

            #relaciones del registro de gasto
            @categoriaGasto.gastos << @gasto
            current_user.gastos << @gasto
            current_user.sucursal.gastos << @gasto
            current_user.negocio.gastos << @gasto

            #Se hace un registro en caja chica y se relaciona con el gasto
            @cajaChica = CajaChica.new(:concepto=>"Pago o abono a un proveedor", :salida=>pago_realizado)
            @cajaChica.gasto = @gasto

            #Se hacen las relaciones de pertenencia para la caja chica.
            current_user.caja_chicas << @cajaChica
            current_user.sucursal.caja_chicas << @cajaChica
            current_user.negocio.caja_chicas << @cajaChica

            if @cajaChica.save && @gasto.save && @pagoProveedor.save && @pago_pendiente.save
              if @pago_pendiente.saldo == 0
                @pago_pendiente.destroy
                format.json { head :no_content}
                format.js
                flash[:notice] = "Pago realizado correctamente. El pago pendiente fue liquidado"
              else
                format.json { head :no_content}
                format.js
                flash[:notice] = "Se realizó un abono al pago pendiente."
              end
            else
              format.json {render json: @pago_pendiente.errors.full_messages, status: :unprocessable_entity}
              format.js
              flash[:notice] = "Hubo un error al momento de guardar el registro de pago. Intente de nuevo."
            end

          else
            format.json {render json: @pago_pendiente.errors.full_messages, status: :unprocessable_entity}
            format.js
            flash[:notice] = "No hay saldo suficiente en la caja chica para realizar el pago. Pago no realizado"
          end
        end
      end
    end
  end

  
  def destroy
  end

  private

    def set_pago_pendiente
      @pago_pendiente = PagoPendiente.find(params[:id])
    end
end
