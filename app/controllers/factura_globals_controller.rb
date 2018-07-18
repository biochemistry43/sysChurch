class FacturaGlobalsController < ApplicationController
  before_action :set_factura_global, only: [:show, :edit, :update, :destroy]

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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_factura_global
      @factura_global = FacturaGlobal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def factura_global_params
      params.require(:factura_global).permit(:folio, :fecha_expedicion, :estado_factura, :user_id, :negocio_id, :sucursal_id, :folio_fiscal, :consecutivo, :ruta_storage, :factura_forma_pago_id, :monto)
    end
end
