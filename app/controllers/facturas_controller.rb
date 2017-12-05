class FacturasController < ApplicationController
  before_action :set_factura, only: [:show, :edit, :update, :destroy]
  #before_action :set_facturaDeVentas, only: [:show]
  before_action :set_cajeros, only: [:index, :consulta_facturas, :consulta_avanzada, :consulta_por_folio, :consulta_por_cliente]
  before_action :set_sucursales, only: [:index, :consulta_facturas, :consulta_avanzada, :consulta_por_folio, :consulta_por_cliente]

  def facturaDeVentas
    @consulta = false
    if request.post?
      @consulta = true #determina si se realizó una consulta
      @venta = Venta.find_by :folio=>params[:folio] #si existe una venta con el folio solicitado, despliega una sección con los detalles en la vista

      if @venta
        @itemsVenta  = @venta.item_ventas
      else
        @folio = params[:folio]
      end
    end
  end

  def consulta_facturas
    @consulta = true
    @fechas=true
    @por_folio=false
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


  def consulta_por_folio
    @consulta = true
    @fechas = false
    @por_folio = true
    @avanzada = false


    if request.post?
      @folio_fact = params[:folio_fact]
      @facturas = Factura.find_by folio: @folio_fact
      if can? :create, Negocio
        @facturas = current_user.negocio.facturas.where(folio: @folio_fact)
      else
        @facturas = current_user.sucursal.facturas.where(folio: @folio_fact)
      end
    end
  end

  def consulta_por_cliente
    @consulta = true
    @fechas = false
    @por_folio = false
    @avanzada = false
    @por_cliente= true

    if request.post?
      @rfc = params[:rfc]
      cliente=Cliente.find_by rfc: @rfc
      @facturas = Factura.find_by cliente_id:cliente
      if can? :create, Negocio
        @facturas = current_user.negocio.facturas.where(cliente_id: cliente)
      else
        @facturas = current_user.sucursal.facturas.where(cliente_id: cliente)
      end
    end
  end

  def consulta_avanzada
    @consulta = true
    @avanzada = true

    @fechas=false
    @por_folio=false
    if request.post?
      @fechaInicial = DateTime.parse(params[:fecha_inicial_avanzado]).to_date
      @fechaFinal = DateTime.parse(params[:fecha_final_avanzado]).to_date
      perfil_id = params[:perfil_id]
      @cajero = nil
      unless perfil_id.empty?
        @cajero = Perfil.find(perfil_id).user
      end

      @estado_factura = params[:estado_factura]

      @suc = params[:suc_elegida]

      unless @suc.empty?
        @sucursal = Sucursal.find(@suc)
      end

      #Resultados para usuario administrador o subadministrador
      if can? :create, Negocio
        unless @suc.empty?
          #valida si se eligió un cajero específico para esta consulta
          if @cajero
            #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
            unless @estado_factura.eql?("Todas")
              @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, user: @cajero, estado_factura: @estado_factura, sucursal: @sucursal)
            else
              @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, user: @cajero, sucursal: @sucursal)
            end

          # Si no se eligió cajero, entonces no filtra las ventas por el cajero vendedor
          else
            #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
            unless @estado_factura.eql?("Todas")
              @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura, sucursal: @sucursal)
            else
              @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, sucursal: @sucursal)
            end
          end

        #Si el usuario no eligió ninguna sucursal específica, no filtra las ventas por sucursal
        else
          #valida si se eligió un cajero específico para esta consulta
          if @cajero
            #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
            unless @estado_factura.eql?("Todas")
              @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, user: @cajero, estado_factura: @estado_factura)
            else
              @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, user: @cajero)
            end

          # Si no se eligió cajero, entonces no filtra las ventas por el cajero vendedor
          else
            #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
            unless @estado_factura.eql?("Todas")
              @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura)
            else
              @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal)
            end
          end
        end

      #Si el usuario no es un administrador o subadministrador
      else

        #valida si se eligió un cajero específico para esta consulta
        if @cajero

          #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
          unless @estado_factura.eql?("Todas")
            @facturas = current_user.sucursal.facturas.where(fechaVenta: @fechaInicial..@fechaFinal, user: @cajero, estado_factura: @estado_factura)
          else
            @facturas = current_user.sucursal.facturas.where(fechaVenta: @fechaInicial..@fechaFinal, user: @cajero)
          end #Termina unless @estado_factura.eql?("Todas")

        # Si no se eligió cajero, entonces no filtra las ventas por el cajero vendedor
        else

          #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
          unless @estado_factura.eql?("Todas")
            @facturas = current_user.sucursal.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura)
          else
            @facturas = current_user.sucursal.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal)
          end #Termina unless @estado_factura.eql?("Todas")

        end #Termina if @cajero

      end

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end
  end


  # GET /facturas
  # GET /facturas.json
  def index
    @consulta = false
    @avanzada = false

    if request.get?
      if can? :create, Negocio
        @facturas = current_user.negocio.facturas.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
      else
        @facturas = current_user.sucursal.facturas.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
      end
    end
  end

  # GET /facturas/1
  # GET /facturas/1.json
  def show
    @items  = @factura.venta.item_ventas
  end

  # GET /facturas/new
  def new
    @factura = Factura.new
  end

  # GET /facturas/1/edit
  def edit
  end

  # POST /facturas
  # POST /facturas.json
  def create
    @factura = Factura.new(factura_params)

    respond_to do |format|
      if @factura.save
        format.html { redirect_to @factura, notice: 'Factura was successfully created.' }
        format.json { render :show, estado_factura: :created, location: @factura }
      else
        format.html { render :new }
        format.json { render json: @factura.errors, estado_factura: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /facturas/1
  # PATCH/PUT /facturas/1.json
  def update
    respond_to do |format|
      if @factura.update(factura_params)
        format.html { redirect_to @factura, notice: 'Factura was successfully updated.' }
        format.json { render :show, estado_factura: :ok, location: @factura }
      else
        format.html { render :edit }
        format.json { render json: @factura.errors, estado_factura: :unprocessable_entity }
      end
    end
  end

  # DELETE /facturas/1
  # DELETE /facturas/1.json
  def destroy
    @factura.destroy
    respond_to do |format|
      format.html { redirect_to facturas_url, notice: 'Factura was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def devolucion
    @consulta = false
    if request.post?
      @consulta = true
      @venta = Venta.find_by :folio=>params[:folio]
      if @venta
        @itemsVenta  = @venta.item_ventas
      else
        @folio = params[:folio]
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_factura
      @factura = Factura.find(params[:id])
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
    def factura_params
      params.require(:factura).permit(:folio, :fecha_expedicion, :estado_factura, :venta_id, :user_id, :negocio_id, :sucursal_id, :cliente_id, :forma_pago_id)
    end
end
