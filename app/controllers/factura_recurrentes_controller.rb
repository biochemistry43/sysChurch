class FacturaRecurrentesController < ApplicationController
  before_action :set_factura_recurrente, only: [:show, :edit, :update, :destroy]

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

    # Never trust parameters from the scary internet, only allow the white list through.
    def factura_recurrente_params
      params.require(:factura_recurrente).permit(:folio, :fecha_expedicion, :estado_factura, :tiempo_recurrente, :user_id, :negocio_id, :sucursal_id, :cliente_id, :forma_pago_id)
    end
end
