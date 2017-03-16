class GastosController < ApplicationController
  before_action :set_gasto, only: [:show, :edit, :update, :destroy]

  # GET /gastos
  # GET /gastos.json
  def index
    @gastos = Gasto.all
  end

  # GET /gastos/1
  # GET /gastos/1.json
  def show
  end

  # GET /gastos/new
  def new
    @gasto = Gasto.new
  end

  # GET /gastos/1/edit
  def edit
  end

  # POST /gastos
  # POST /gastos.json
  def create
    @gasto = Gasto.new(gasto_params)

    respond_to do |format|
      if @gasto.save
        current_user.negocio.gasto << @gasto
        #format.html { redirect_to @gasto, notice: 'Gasto was successfully created.' }
        #format.json { render :show, status: :created, location: @gasto }
        format.json { head :no_content}
        format.js
      else
        #format.html { render :new }
        #format.json { render json: @gasto.errors, status: :unprocessable_entity }
        format.json{render json: @gasto.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /gastos/1
  # PATCH/PUT /gastos/1.json
  def update
    respond_to do |format|
      if @gasto.update(gasto_params)
        format.json { head :no_content}
        format.js
        #format.html { redirect_to @gasto, notice: 'Gasto was successfully updated.' }
        #format.json { render :show, status: :ok, location: @gasto }
      else
        #format.html { render :edit }
        #format.json { render json: @gasto.errors, status: :unprocessable_entity }
        format.json{render json: @gasto.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /gastos/1
  # DELETE /gastos/1.json
  def destroy
    @gasto.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to gastos_url, notice: 'Gasto was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gasto
      @gasto = Gasto.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gasto_params
      params.require(:gasto).permit(:montoGasto, :fechaGasto, :descripcionGasto, :lugarCompraGasto, :persona_id, :categoria_gasto_id)
    end
end
