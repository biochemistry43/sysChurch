class FacturasController < ApplicationController
  before_action :set_factura, only: [:show, :edit, :update, :destroy]
  before_action :set_facturaDeVentas, only: [:show]


  def facturaDeVentas
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
        format.json { render :show, status: :created, location: @factura }
      else
        format.html { render :new }
        format.json { render json: @factura.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /facturas/1
  # PATCH/PUT /facturas/1.json
  def update
    respond_to do |format|
      if @factura.update(factura_params)
        format.html { redirect_to @factura, notice: 'Factura was successfully updated.' }
        format.json { render :show, status: :ok, location: @factura }
      else
        format.html { render :edit }
        format.json { render json: @factura.errors, status: :unprocessable_entity }
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def factura_params
      params.require(:factura).permit(:folio, :fecha_expedicion, :estado_factura, :venta_id, :user_id, :negocio_id, :sucursal_id, :cliente_id, :forma_pago_id)
    end
end
