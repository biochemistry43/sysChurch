class FacturaRecurrentesController < ApplicationController
  before_action :set_factura_recurrente, only: [:show, :edit, :update, :destroy]
  before_action :set_facturasRecurrentes, only: [:show]
  before_action :set_cajeros, only: [:index, :consulta_facturas, :consulta_avanzada]
  before_action :set_sucursales, only: [:index, :consulta_facturas, :consulta_avanzada]

  def facturaRecurrentes
    @clientes=Cliente.all
    @usoCfdi=UsoCfdi.all
    @metodoDePago=MetodoPago.all
    @formaPago=FormaPago.all
    if request.post?

      @factura_recurrente = FacturaRecurrente.new

      #El folio de las facturas se forma por defecto por la clave de las sucursales, pero si el usuario quiere establecer sus propias series para otro fin, se tomará la serie que el usuario indique en las configuración de Facturas y Notas


      #@factura_recurrente.fecha_expedicion = Time.now


      #Todas las facturas en alegra se agregan es estado borrador amenos que...
      @factura_recurrente.estado_factura="Borrador"
      current_user.factura_recurrentes<<@factura_recurrente
      current_user.negocio.factura_recurrentes<<@factura_recurrente
      current_user.sucursal.factura_recurrentes<<@factura_recurrente


      #Se factura a nombre del cliente que realizó la compra en el negocio.
      #cliente_id=@@venta.cliente.id
      #Cliente.find(cliente_id).facturas << @factura
      if @factura_recurrente.save
        flash[:notice] = "La factura se guardó exitosamente!"
        redirect_to factura_recurrentes_index_path
      else
        flash[:notice] = "Error al intentar guardar la factura"
        redirect_to factura_recurrentes_index_path
      end


    end
  end

  def consulta_facturas
    @consulta = true
    @avanzada = false
    if request.post?
      @fechaInicial = DateTime.parse(params[:fecha_inicial]).to_date
      @fechaFinal = DateTime.parse(params[:fecha_final]).to_date
      if can? :create, Negocio
        @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal)
      else
        @facturas = current_user.sucursal.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal)
      end

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end
  end

  def consulta_avanzada
    @consulta = true
    @avanzada = true
    if request.post?
      @fechaInicial = DateTime.parse(params[:fecha_inicial_avanzado]).to_date
      @fechaFinal = DateTime.parse(params[:fecha_final_avanzado]).to_date
      perfil_id = params[:perfil_id]
      @cajero = nil
      unless perfil_id.empty?
        @cajero = Perfil.find(perfil_id).user
      end

      @status = params[:status]

      @suc = params[:suc_elegida]

      unless @suc.empty?
        @sucursal = Sucursal.find(@suc)
      end

      #Resultados para usuario administrador o subadministrador
      if can? :create, Negocio
        unless @suc.empty?
          #valida si se eligió un cajero específico para esta consulta
          if @cajero
            #Si el status elegido es todas, entonces no filtra las ventas por el status
            unless @status.eql?("Todas")
              @factura_recurrentes = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, user: @cajero, status: @status, sucursal: @sucursal)
            else
              @factura_recurrentes  = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, user: @cajero, sucursal: @sucursal)
            end

          # Si no se eligió cajero, entonces no filtra las ventas por el cajero vendedor
          else
            #Si el status elegido es todas, entonces no filtra las ventas por el status
            unless @status.eql?("Todas")
              @factura_recurrentes  = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, status: @status, sucursal: @sucursal)
            else
              @factura_recurrentes  = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, sucursal: @sucursal)
            end
          end

        #Si el usuario no eligió ninguna sucursal específica, no filtra las ventas por sucursal
        else
          #valida si se eligió un cajero específico para esta consulta
          if @cajero
            #Si el status elegido es todas, entonces no filtra las ventas por el status
            unless @status.eql?("Todas")
              @factura_recurrentes  = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, user: @cajero, status: @status)
            else
              @factura_recurrentes  = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, user: @cajero)
            end

          # Si no se eligió cajero, entonces no filtra las ventas por el cajero vendedor
          else
            #Si el status elegido es todas, entonces no filtra las ventas por el status
            unless @status.eql?("Todas")
              @factura_recurrentes  = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, status: @status)
            else
              @factura_recurrentes  = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal)
            end
          end
        end

      #Si el usuario no es un administrador o subadministrador
      else

        #valida si se eligió un cajero específico para esta consulta
        if @cajero

          #Si el status elegido es todas, entonces no filtra las ventas por el status
          unless @status.eql?("Todas")
            @facturas = current_user.sucursal.facturas.where(fechaVenta: @fechaInicial..@fechaFinal, user: @cajero, status: @status)
          else
            @factura_recurrentes  = current_user.sucursal.facturas.where(fechaVenta: @fechaInicial..@fechaFinal, user: @cajero)
          end #Termina unless @status.eql?("Todas")

        # Si no se eligió cajero, entonces no filtra las ventas por el cajero vendedor
        else

          #Si el status elegido es todas, entonces no filtra las ventas por el status
          unless @status.eql?("Todas")
            @factura_recurrentes  = current_user.sucursal.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, status: @status)
          else
            @factura_recurrentes  = current_user.sucursal.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal)
          end #Termina unless @status.eql?("Todas")

        end #Termina if @cajero

      end

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end
  end


  def consulta_facturas
    @consulta = true
    @avanzada = false
    if request.post?
      @fechaInicial = DateTime.parse(params[:fecha_inicial]).to_date
      @fechaFinal = DateTime.parse(params[:fecha_final]).to_date
      if can? :create, Negocio
        @factura_recurrentes = current_user.negocio.factura_recurrentes.where(fecha_expedicion: @fechaInicial..@fechaFinal)
      else
        @factura_recurrentes = current_user.sucursal.factura_recurrentes.where(fecha_expedicion: @fechaInicial..@fechaFinal)
      end

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end
  end
  # GET /factura_recurrentes
  # GET /factura_recurrentes.json
  def index
    @factura_recurrentes = FacturaRecurrente.all
  end

  # GET /factura_recurrentes/1
  # GET /factura_recurrentes/1.json
  def show
  end

  # GET /factura_recurrentes/new
  def new
    @factura_recurrente = FacturaRecurrente.new
  end

  # GET /factura_recurrentes/1/edit
  def edit
  end

  # POST /factura_recurrentes
  # POST /factura_recurrentes.json
  def create
    @factura_recurrente = FacturaRecurrente.new(factura_recurrente_params)

    respond_to do |format|
      if @factura_recurrente.save
        format.html { redirect_to @factura_recurrente, notice: 'Factura recurrente was successfully created.' }
        format.json { render :show, status: :created, location: @factura_recurrente }
      else
        format.html { render :new }
        format.json { render json: @factura_recurrente.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /factura_recurrentes/1
  # PATCH/PUT /factura_recurrentes/1.json
  def update
    respond_to do |format|
      if @factura_recurrente.update(factura_recurrente_params)
        format.html { redirect_to @factura_recurrente, notice: 'Factura recurrente was successfully updated.' }
        format.json { render :show, status: :ok, location: @factura_recurrente }
      else
        format.html { render :edit }
        format.json { render json: @factura_recurrente.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /factura_recurrentes/1
  # DELETE /factura_recurrentes/1.json
  def destroy
    @factura_recurrente.destroy
    respond_to do |format|
      format.html { redirect_to factura_recurrentes_url, notice: 'Factura recurrente was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_factura_recurrente
      @factura_recurrente = FacturaRecurrente.find(params[:id])
    end
    def set_cajeros
      @cajeros = []
      if can? :create, Negocio
        current_user.negocio.users.each do |cajero|
          #Llena un array con todos los cajeros del negocio
          #(usuarios del negocio que pueden hacer una venta, no solo el rol de cajero)
          #Siempre y cuando no sean auxiliares o almacenistas pues no tienen acceso a punto de venta
          if cajero.role != "auxiliar" || cajero.role != "almacenista"
            @cajeros.push(cajero.perfil)
          end
        end
      else
        current_user.sucursal.users.each do |cajero|
          #Llena un array con todos los cajeros de la sucursal
          #(usuarios de la sucursal que pueden hacer una venta, no solo el rol de cajero)
          #Siempre y cuando no sean auxiliares o almacenistas pues no tienen acceso a punto de venta
          if cajero.role != "auxiliar" || cajero.role != "almacenista"
            @cajeros.push(cajero.perfil)
          end
        end
      end
    end
    def set_sucursales
      @sucursales = current_user.negocio.sucursals
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def factura_recurrente_params
      params.require(:factura_recurrente).permit(:folio, :fecha_expedicion, :estado_factura, :tiempo_recurrente, :user_id, :negocio_id, :sucursal_id, :cliente_id, :forma_pago_id)
    end
end
