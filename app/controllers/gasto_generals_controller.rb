class GastoGeneralsController < ApplicationController
  before_action :set_gasto_general, only: [:show, :edit, :update, :destroy]
  before_action :set_categorias_gasto, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_proveedores, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_cajas, only: [:new, :create, :edit, :update, :destroy]

  # GET /gasto_generals
  # GET /gasto_generals.json
  def index
    @gasto_generals = current_user.sucursal.gasto_generals
  end

  # GET /gasto_generals/1
  # GET /gasto_generals/1.json
  def show
  end

  # GET /gasto_generals/new
  def new
    @gasto_general = GastoGeneral.new
  end

  # GET /gasto_generals/1/edit
  def edit
    @gasto = @gasto_general.gasto
  end

  # POST /gasto_generals
  # POST /gasto_generals.json
  def create
    @gasto_general = GastoGeneral.new(gasto_general_params)

    @cajaChica = nil
    @cajaVenta = nil
    @movimientoCaja = nil
    @gasto = nil
    @pagoProveedor = nil

    
    #Esta variable recoge el parámetro del origen del recurso con el que se va a pagar la devolución.
    #El origen puede ser las cajas de venta, la caja chica o alguna cuenta bancaria.
    origen = params[:select_origen_recurso]

    categoria_gasto = params[:categoria_gasto_id]

    proveedor_id = params[:proveedor]

    @categoriaGasto = CategoriaGasto.find(categoria_gasto)

    @proveedor = Proveedor.find(proveedor_id)

    #almacena el importe monetario que será devuelto al cliente.
    monto_gasto = gasto_general_params[:monto].to_f

    concepto = gasto_general_params[:concepto]

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
      if @cajaVenta.saldo >= monto_gasto
        @gasto = Gasto.new(:monto=>monto_gasto, :concepto=>concepto, :tipo=>"Gasto general")

        #relaciones del registro de gasto
        @categoriaGasto.gastos << @gasto
        @cajaVenta.gastos << @gasto
        current_user.gastos << @gasto
        current_user.sucursal.gastos << @gasto
        current_user.negocio.gastos << @gasto

        current_user.gasto_generals << @gasto_general
        current_user.sucursal.gasto_generals << @gasto_general
        current_user.negocio.gasto_generals << @gasto_general

        #Se actualiza el saldo de la caja de venta
        saldo = @cajaVenta.saldo - monto_gasto
        @cajaVenta.saldo = saldo

        #Relación del proveedor con el gasto
        @proveedor.gasto_generals << @gasto_general

        #Relación del gasto con el gasto corriente
        @gasto.gasto_general = @gasto_general

        #Se registra el movimiento de caja de venta. En este caso, es un movimiento de salida
        @movimientoCaja = MovimientoCajaSucursal.new(:salida=>monto_gasto, :caja_sucursal=>@cajaVenta)
        current_user.movimiento_caja_sucursals << @movimientoCaja
        current_user.sucursal.movimiento_caja_sucursals << @movimientoCaja
        current_user.negocio.movimiento_caja_sucursals << @movimientoCaja

        #Relación del gasto con el movimiento de caja de sucursal
        @gasto.movimiento_caja_sucursal = @movimientoCaja

        #Relación del gasto con el gasto corriente
        @gasto.gasto_general = @gasto_general

        @pagoProveedor = PagoProveedor.new(:monto=>monto_gasto, :gasto=>@gasto)
        @proveedor.pago_proveedores << @pagoProveedor
        current_user.pago_proveedores << @pagoProveedor
        current_user.sucursal.pago_proveedores << @pagoProveedor
        current_user.negocio.pago_proveedores << @pagoProveedor


      else
        flash[:notice] = "No hay saldo suficiente en la caja #{@cajaVenta.nombre} para hacer el pago"
      end

    end #Termina la condición caja venta

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
        if @saldoCajaChica >= monto_gasto

          saldo_en_caja_chica = @saldoCajaChica
        
          @gasto = Gasto.new(:monto=>monto_gasto, :concepto=>concepto, :tipo=>"Gasto general")

          #relaciones del registro de gasto
          @categoriaGasto.gastos << @gasto
          current_user.gastos << @gasto
          current_user.sucursal.gastos << @gasto
          current_user.negocio.gastos << @gasto

          current_user.gasto_generals << @gasto_general
          current_user.sucursal.gasto_generals << @gasto_general
          current_user.negocio.gasto_generals << @gasto_general

          #Se hace un registro en caja chica y se relaciona con el gasto
          @cajaChica = CajaChica.new(:concepto=>concepto, :salida=>monto_gasto)
          @cajaChica.gasto = @gasto

          #Se hacen las relaciones de pertenencia para la caja chica.
          current_user.caja_chicas << @cajaChica
          current_user.sucursal.caja_chicas << @cajaChica
          current_user.negocio.caja_chicas << @cajaChica

          #Relación del proveedor con el gasto
          @proveedor.gasto_generals << @gasto_general

          #Relación del gasto con el gasto corriente
          @gasto.gasto_general = @gasto_general

          @pagoProveedor = PagoProveedor.new(:monto=>monto_gasto, :gasto=>@gasto)
          @proveedor.pago_proveedores << @pagoProveedor
          current_user.pago_proveedores << @pagoProveedor
          current_user.sucursal.pago_proveedores << @pagoProveedor
          current_user.negocio.pago_proveedores << @pagoProveedor

        else
          flash[:notice] = "No hay saldo suficiente en la caja chica para hacer el pago"
        end
      end
    end

    respond_to do |format|
      if @gasto_general.valid?
        if @cajaChica && @gasto && @pagoProveedor
          if @gasto_general.save && @cajaChica.save && @gasto.save && @pagoProveedor.save
            format.js
            format.json { head :no_content}
            flash[:notice] = "Gasto registrado"
          else
            format.js {render :new} 
            format.json{render json: @gasto_general.errors.full_messages, status: :unprocessable_entity}
          end
        elsif @cajaVenta && @gasto && @movimientoCaja && @pagoProveedor
          if @gasto_general.save && @cajaVenta.save && @gasto.save && @movimientoCaja.save && @pagoProveedor.save
            format.js
            format.json { head :no_content}
            flash[:notice] = "Gasto registrado"
          else
            format.js {render :new} 
            format.json{render json: @gasto_general.errors.full_messages, status: :unprocessable_entity}
          end
        else
          format.html { redirect_to gasto_generals_path}
        end
      else
        format.js {render :new} 
        format.json{render json: @gasto_general.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /gasto_generals/1
  # PATCH/PUT /gasto_generals/1.json
  def update
    @cajaChica = nil
    @cajaVenta = nil
    @movimientoCaja = nil
    @gasto = nil
    @pagoProveedor = nil

    
    #Esta variable recoge el parámetro del origen del recurso con el que se va a pagar la devolución.
    #El origen puede ser las cajas de venta, la caja chica o alguna cuenta bancaria.
    origen = params[:select_origen_recurso]

    categoria_gasto = params[:categoria_gasto_id]

    proveedor_id = params[:proveedor_id]

    @categoriaGasto = CategoriaGasto.find(categoria_gasto)

    @proveedor = Proveedor.find(proveedor_id)

    #almacena el importe monetario que será devuelto al cliente.
    monto_gasto = gasto_general_params[:monto].to_f

    concepto = gasto_general_params[:concepto]

    #Si se cumple esta condición, significa que el recurso para actualizar los datos del gasto, 
    #provendrán de alguna de las cajas de sucursal.La cadena contiene el id de la caja de venta seleccionada.
    
    if origen.include? "caja_venta"
      tamano_cadena_origen = origen.length

      #aquí extraigo el id de la caja de venta contenido en la cadena de texto
      #el número "11" corresponde a la cantidad de caracteres de la cadena "caja_venta_"
      id_caja_sucursal = origen[11..tamano_cadena_origen]

      #En base al id extraido de la cadena, busco la Caja de Venta en la base de datos
      @cajaVenta = CajaSucursal.find(id_caja_sucursal)

      @cajaVentaOriginal = @gasto_general.gasto.caja_sucursal.id

      comparandoOrigen = (@cajaVentaOriginal == @cajaVenta.id)

      if comparandoOrigen
        saldo_a_comparar = @cajaVenta.saldo + @gasto_general.monto
      else
        saldo_a_comparar = @cajaVenta.saldo
      end

      #Verifico que la caja tenga el saldo necesario para realizar la operación de devolución.
      #Sin embargo, dado que existe la posibilidad de que el monto del gasto haya sido cambiado, sumo momentaneamente
      #el gasto original
      if saldo_a_comparar >= monto_gasto

        @gasto = @gasto_general.gasto
        @gasto.monto = monto_gasto
        @gasto.concepto = concepto
        @gasto.categoria_gasto = @categoriaGasto

        #Se actualiza el saldo de la caja de venta
        saldo = saldo_a_comparar - monto_gasto
        @cajaVenta.saldo = saldo

        #Relación del proveedor con el gasto
        @gasto_general.proveedor = @proveedor

        #Se registra el movimiento de caja de venta. En este caso, es un movimiento de salida
        @movimientoCaja = @gasto.movimiento_caja_sucursal 
        @movimientoCaja.salida = monto_gasto
        @movimientoCaja.caja_sucursal = @cajaVenta
        
        @pagoProveedor = @gasto.pago_proveedor
        @pagoProveedor.monto = monto_gasto

      else
        flash[:notice] = "No hay saldo suficiente en la caja #{@cajaVenta.nombre} para hacer el pago"
      end

    end #Termina la condición caja venta

    #Si se cumple esta condición, significa que el recurso provendrá de la caja chica que tiene la sucursal.
    if origen.include? "caja_chica"
      #Verifica si existen registros de caja chica para esta sucursal
      if current_user.sucursal.caja_chicas
        #Si existen registros de caja chica, toma el último registro de la tabla y se obtiene el importe de
        #dicho registro. En esto se determina si hay saldo suficiente para cubrir la devolución.
        entradas = CajaChica.sum(:entrada, :conditions=>["sucursal_id=?", current_user.sucursal.id])
        salidas = CajaChica.sum(:salida, :conditions=>["sucursal_id=?", current_user.sucursal.id])
        @saldoCajaChica = entradas - salidas + @gasto_general.monto


        #@cajaChicaLast = sucursal.caja_chicas.last
        if @saldoCajaChica >= monto_gasto

          saldo_en_caja_chica = @saldoCajaChica
        
          #Obtengo el registro de gasto relacionado con el gasto general y actualizo sus valores
          @gasto = @gasto_general.gasto
          @gasto.monto = monto_gasto
          @gasto.categoria_gasto = @categoria_gasto

          #relaciones del registro de gasto
          @gasto.categoria_gasto = @categoriaGasto

          #Se obtiene el registro de caja chica en base al gasto
          @cajaChica = @gasto.caja_chica

          @gasto_general.proveedor = @proveedor

          @pagoProveedor = @gasto.pago_proveedor
          @pagoProveedor.monto = monto_gasto

        else
          flash[:notice] = "No hay saldo suficiente en la caja chica para hacer el pago"
        end
      end
    end

    respond_to do |format|
      if @cajaChica && @gasto && @pagoProveedor

        if @gasto_general.update(gasto_general_params) && @cajaChica.save && @gasto.save && @pagoProveedor.save
          format.json { head :no_content}
          format.js
        else
          format.json {render json: @gasto_general.errors.full_messages, status: :unprocessable_entity}
          format.js {render :edit}
        end

      elsif @cajaVenta && @gasto && @movimientoCaja && @pagoProveedor
        
        if @gasto_general.update(gasto_general_params) && @cajaVenta.save && @gasto.save && @movimientoCaja.save && @pagoProveedor.save
          format.json { head :no_content}
          format.js
        else
          format.json {render json: @gasto_general.errors.full_messages, status: :unprocessable_entity}
          format.js {render :edit}
        end

      else
        format.html { redirect_to gasto_generals_path}
      end
    end

  end

  # DELETE /gasto_generals/1
  # DELETE /gasto_generals/1.json
  def destroy
    if @gasto_general.gasto.caja_chica
      @gasto_general.gasto.caja_chica.destroy
    end

    if @gasto_general.gasto.caja_sucursal
      @gasto_general.gasto.movimiento_caja_sucursal.destroy
    end

    @gasto_general.gasto.pago_proveedor.destroy
    @gasto_general.gasto.destroy
    @gasto_general.destroy

    respond_to do |format|
      format.js
      format.html { redirect_to gasto_general_url, notice: 'El gasto fue eliminado completamente' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gasto_general
      @gasto_general = GastoGeneral.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gasto_general_params
      params.require(:gasto_general).permit(:folio_gasto, :ticket_gasto, :monto, :concepto, :gasto_id, :user_id, :sucursal_id, :negocio_id, :categoria_gasto_id)
    end

    def set_categorias_gasto
      @categorias = current_user.negocio.categoria_gastos
    end

    def set_proveedores
      @proveedores = current_user.sucursal.proveedores
    end

    def set_cajas
      @cajas = current_user.sucursal.caja_sucursals
    end
end
