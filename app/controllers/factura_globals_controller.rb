class FacturaGlobalsController < ApplicationController
  before_action :set_factura_global, only: [:show, :edit, :update, :destroy]
  before_action :set_sucursales, only: [:index, :filtro_por_fecha, :filtro_por_folio, :filtro_avanzado]#, :consulta_por_cliente, :generarFacturaGlobal, :mostrarVentas_FacturaGlobal ]


  # GET /factura_globals
  # GET /factura_globals.json
  def index
    @factura_globals = FacturaGlobal.all
  end

  # GET /factura_globals/1
  # GET /factura_globals/1.json
  def show
  end

  # GET /factura_globals/new
  def new
    @factura_global = FacturaGlobal.new
  end

  # GET /factura_globals/1/edit
  def edit
  end

  # POST /factura_globals
  # POST /factura_globals.json
  def create
    @factura_global = FacturaGlobal.new(factura_global_params)

    respond_to do |format|
      if @factura_global.save
        format.html { redirect_to @factura_global, notice: 'Factura global was successfully created.' }
        format.json { render :show, status: :created, location: @factura_global }
      else
        format.html { render :new }
        format.json { render json: @factura_global.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /factura_globals/1
  # PATCH/PUT /factura_globals/1.json
  def update
    respond_to do |format|
      if @factura_global.update(factura_global_params)
        format.html { redirect_to @factura_global, notice: 'Factura global was successfully updated.' }
        format.json { render :show, status: :ok, location: @factura_global }
      else
        format.html { render :edit }
        format.json { render json: @factura_global.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /factura_globals/1
  # DELETE /factura_globals/1.json
  def destroy
    @factura_global.destroy
    respond_to do |format|
      format.html { redirect_to factura_globals_url, notice: 'Factura global was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  #FILTROS DE BÚQUEDA PARA LAS FACTURAS GLOBALES
  def filtro_por_fecha
    @consulta = true
    @fechas=true
    @por_folio=false
    @avanzada = false
    #@por_cliente= false => Todas las facturas globales son al público en general
    if request.post?
      @fechaInicial = DateTime.parse(params[:fecha_inicial]).to_date
      @fechaFinal = DateTime.parse(params[:fecha_final]).to_date
      if can? :create, Negocio
        @factura_globals = current_user.negocio.factura_globals.where(fecha_expedicion: @fechaInicial..@fechaFinal)
      else
        @factura_globals = current_user.sucursal.factura_globals.where(fecha_expedicion: @fechaInicial..@fechaFinal)
      end

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end
  end

  def filtro_por_folio
    @consulta = true
    @fechas = false
    @por_folio = true
    @avanzada = false

    if request.post?
      @folio_fact = params[:folio_fact]
      @facturas = FacturaGlobal.find_by folio: @folio_fact
      if can? :create, Negocio
        @factura_globals = current_user.negocio.factura_globals.where(folio: @folio_fact)
      else
        @factura_globals= current_user.sucursal.factura_globals.where(folio: @folio_fact)
      end
    end
  end


  def filtro_avanzado
    @consulta = true
    @avanzada = true

    @fechas=false
    @por_folio=false

    if request.post?

      @fechaInicial = DateTime.parse(params[:fecha_inicial_avanzado]).to_date
      @fechaFinal = DateTime.parse(params[:fecha_final_avanzado]).to_date

      @estado_factura = params[:estado_factura]

      @suc = params[:suc_elegida]

      unless @suc.empty?
        @sucursal = Sucursal.find(@suc)
      end

      @montoFactura = false
      @condicion_monto_factura = params[:condicion_monto_factura]

      #Se convierte la descripción al operador equivalente
      unless @condicion_monto_factura.empty?
        @montoFactura = true
        operador_monto = case @condicion_monto_factura
           when "menor que" then "<"
           when "mayor que" then ">"
           when "menor o igual que" then "<="
           when "mayor o igual que" then ">="
           when "igual que" then "="
           when "diferente que" then "!=" #o también <> Distinto de
           when "rango desde" then ".." #o también <> Distinto de
        end
      end

      if can? :create, Negocio
        unless @suc.empty?
          #Filtra por monto de la venta facurada.
          if operador_monto
            @monto_factura = params[:monto_factura]
            unless operador_monto == ".." #Cuando se trata de un rango
              #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where("montoVenta #{operador_monto} ?", @monto_factura)) if @monto_factura
              @factura_globals = current_user.negocio.factura_globals.where("monto #{operador_monto} ?", @monto_factura) if @monto_factura
            else
              @monto_factura2 = params[:monto_factura2]
              #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where(montoVenta: @monto_factura..@monto_factura2)) if @monto_factura && @monto_factura2
              @factura_globals = current_user.negocio.factura_globals.where(monto: @monto_factura..@monto_factura2) if @monto_factura && @monto_factura2
            end
            #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
            unless @estado_factura.eql?("Todas")
              @factura_globals = @factura_globals.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura, sucursal: @sucursal)
            else
              @factura_globals = @factura_globals.where(fecha_expedicion: @fechaInicial..@fechaFinal, sucursal: @sucursal)
            end
            #Si el usuario no seleccionó una condición para filtrar por el monto de la factura de la venta.
          else
            #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
            unless @estado_factura.eql?("Todas")
              @factura_globals = current_user.negocio.factura_globals.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura, sucursal: @sucursal)
            else
              @factura_globals = current_user.negocio.factura_globals.where(fecha_expedicion: @fechaInicial..@fechaFinal, sucursal: @sucursal)
            end
          end
    
        #Si el usuario no eligió ninguna sucursal específica, no filtra las ventas por sucursal
        else

          if operador_monto
            @monto_factura = params[:monto_factura]
            unless operador_monto == ".." #Cuando se trata de un rango
              #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where("montoVenta #{operador_monto} ?", @monto_factura)) if @monto_factura
              @factura_globals = current_user.negocio.factura_globals.where("monto #{operador_monto} ?", @monto_factura) if @monto_factura
            else
              @monto_factura2 = params[:monto_factura2]
              #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where(montoVenta: @monto_factura..@monto_factura2)) if @monto_factura && @monto_factura2
              @factura_globals = current_user.negocio.factura_globals.where(monto: @monto_factura..@monto_factura2) if @monto_factura && @monto_factura2
            end
            #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
              unless @estado_factura.eql?("Todas")
            @factura_globals = @factura_globals.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura)
            else
              @factura_globals = @factura_globals.where(fecha_expedicion: @fechaInicial..@fechaFinal)
            end
          else
            #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
            unless @estado_factura.eql?("Todas")
              @factura_globals = current_user.negocio.factura_globals.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura)
            else
              @factura_globals = current_user.negocio.factura_globals.where(fecha_expedicion: @fechaInicial..@fechaFinal)
            end
          end

        end
      end

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_factura_global
      @factura_global = FacturaGlobal.find(params[:id])
    end

    def set_sucursales
      @sucursales = current_user.negocio.sucursals
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def factura_global_params
      params.require(:factura_global).permit(:folio, :fecha_expedicion, :estado_factura, :user_id, :negocio_id, :sucursal_id, :folio_fiscal, :consecutivo, :ruta_storage, :factura_forma_pago_id, :monto)
    end
end
