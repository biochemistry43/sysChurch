class GastoCorrientesController < ApplicationController
  before_action :set_gasto_corriente, only: [:edit, :update, :destroy]
  before_action :set_categorias_gasto, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_proveedores, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_cajas, only: [:new, :create, :edit, :update, :destroy]

  # GET /gastos
  # GET /gastos.json
  def index
    @gasto_corrientes = current_user.sucursal.gasto_corrientes
  end

  # GET /gastos/1
  # GET /gastos/1.json
  def show
  end

  # GET /gastos/new
  def new
    @gasto_corriente = GastoCorriente.new
  end

  # GET /gastos/1/edit
  def edit
  end

  # POST /gastos
  # POST /gastos.json
  def create
    
    @gasto_corriente = GastoCorriente.new(gasto_params)
    @cajaChica = nil
    @cajaVenta = nil
    @movimientoCaja = nil
    @gasto = nil

    
    #Esta variable recoge el parámetro del origen del recurso con el que se va a pagar la devolución.
    #El origen puede ser las cajas de venta, la caja chica o alguna cuenta bancaria.
    origen = params[:select_origen_recurso]

    categoria_gasto = params[:categoria_gasto]

    proveedor_id = params[:proveedor]

    @categoriaGasto = CategoriaGasto.find(categoria_gasto)

    @proveedor = Proveedor.find(proveedor_id)

    #almacena el importe monetario que será devuelto al cliente.
    monto_gasto = gasto_params[:monto].to_f

    concepto = gasto_params[:concepto]

    #Si se cumple esta condición, significa que el recurso para la devolución, provendrá de alguna de las cajas 
    #de venta que tiene la sucursal. La cadena contiene el id de la caja de venta seleccionada.
    if origen.include? "caja_venta"
      ActiveRecord::Base.transaction do
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

        #Se actualiza el saldo de la caja de venta
        saldo = @cajaVenta.saldo - monto_gasto
        @cajaVenta.saldo = saldo

        #Relación del proveedor con el gasto
        @proveedor.gasto_corrientes << @gasto_corriente

        #Relación del gasto con el gasto corriente
        @gasto.gasto_corriente = @gasto_corriente

        #Se registra el movimiento de caja de venta. En este caso, es un movimiento de salida
        @movimientoCaja = MovimientoCajaSucursal.new(:salida=>monto_gasto, :caja_sucursal=>@cajaVenta)
        current_user.movimiento_caja_sucursals << @movimientoCaja
        current_user.sucursal.movimiento_caja_sucursals << @movimientoCaja
        current_user.negocio.movimiento_caja_sucursals << @movimientoCaja


      else
        flash[:notice] = "No hay saldo suficiente en esta caja para hacer la devolución"
      end
    end
    end #Termina la condición caja venta

    #Si se cumple esta condición, significa que el recurso provendrá de la caja chica que tiene la sucursal.
    if origen.include? "caja_chica"
      ActiveRecord::Base.transaction do
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

          #Se hace un registro en caja chica y se relaciona con el gasto
          @cajaChica = CajaChica.new(:concepto=>concepto, :salida=>monto_gasto)
          @cajaChica.gasto = @gasto

          #Se actualiza el saldo de la caja chica
          nvo_saldo_caja_chica = saldo_en_caja_chica - monto_gasto
          @cajaChica.saldo = nvo_saldo_caja_chica

          #Se hacen las relaciones de pertenencia para la caja chica.
          current_user.caja_chicas << @cajaChica
          current_user.sucursal.caja_chicas << @cajaChica
          current_user.negocio.caja_chicas << @cajaChica

          #Relación del proveedor con el gasto
          @proveedor.gasto_corrientes << @gasto_corriente

          #Relación del gasto con el gasto corriente
          @gasto.gasto_corriente = @gasto_corriente

        else
          flash[:notice] = "No hay saldo suficiente en la caja chica para hacer la devolución"
        end
      end
      end
    end
    
    respond_to do |format|
      ActiveRecord::Base.transaction do
      if  @movimientoCaja && @cajaVenta
        if @gasto_corriente.save && @gasto.save && @movimientoCaja.save && @cajaVenta.save && @categoriaGasto.save
          format.json { head :no_content}
          format.js
          flash[:notice] = "Se registró el gasto correctamente. El importe fue pagado desde la caja #{@cajaVenta.nombre}"
        else
          format.json{render json: @gasto_corriente.errors.full_messages, status: :unprocessable_entity}
          format.js {render :new} 
        end
      elsif @cajaChica
        if @gasto_corriente.save && @gasto.save && @cajaChica.save && @categoriaGasto.save
          format.json { head :no_content}
          format.js
          flash[:notice] = "Se registró el gasto correctamente. El importe fue pagado desde la caja chica de la sucursal"
        else

          
        end
      end
    end
    end

  end

  # PATCH/PUT /gastos/1
  # PATCH/PUT /gastos/1.json
  def update
    respond_to do |format|
      if @gasto_corriente.update(gasto_params)
        format.json { head :no_content}
        format.js
        #format.html { redirect_to @gasto, notice: 'Gasto was successfully updated.' }
        #format.json { render :show, status: :ok, location: @gasto }
      else
        #format.html { render :edit }
        #format.json { render json: @gasto.errors, status: :unprocessable_entity }
        format.json{render json: @gasto_corriente.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /gastos/1
  # DELETE /gastos/1.json
  def destroy
    @gasto_corriente.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to gasto_corrientes_url, notice: 'Gasto was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gasto_corriente
      @gasto_corriente = GastoCorriente.find(params[:id])
    end

    def set_categorias_gasto
      @categorias = current_user.negocio.categoria_gastos
    end

    def set_proveedores
      @proveedores = current_user.sucursal.proveedores
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gasto_params
      params.require(:gasto_corriente).permit(:monto, :concepto, :folio_gasto, :ticket_gasto, :proveedor)
    end

    def set_cajas
      @cajas = current_user.sucursal.caja_sucursals
    end
end
