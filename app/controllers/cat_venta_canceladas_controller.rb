class CatVentaCanceladasController < ApplicationController
  before_action :set_cat_venta_cancelada, only: [:show, :edit, :update, :destroy]

  # GET /cat_venta_canceladas
  # GET /cat_venta_canceladas.json
  def index
    @cat_venta_canceladas = CatVentaCancelada.all
  end

  # GET /cat_venta_canceladas/1
  # GET /cat_venta_canceladas/1.json
  def show
  end

  # GET /cat_venta_canceladas/new
  def new
    @cat_venta_cancelada = CatVentaCancelada.new
  end

  # GET /cat_venta_canceladas/1/edit
  def edit
  end

  # POST /cat_venta_canceladas
  # POST /cat_venta_canceladas.json
  def create
    @cat_venta_cancelada = CatVentaCancelada.new(cat_venta_cancelada_params)

    respond_to do |format|
      if @cat_venta_cancelada.save
        format.html { redirect_to @cat_venta_cancelada, notice: 'Cat venta cancelada was successfully created.' }
        format.json { render :show, status: :created, location: @cat_venta_cancelada }
      else
        format.html { render :new }
        format.json { render json: @cat_venta_cancelada.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cat_venta_canceladas/1
  # PATCH/PUT /cat_venta_canceladas/1.json
  def update
    respond_to do |format|
      if @cat_venta_cancelada.update(cat_venta_cancelada_params)
        format.html { redirect_to @cat_venta_cancelada, notice: 'Cat venta cancelada was successfully updated.' }
        format.json { render :show, status: :ok, location: @cat_venta_cancelada }
      else
        format.html { render :edit }
        format.json { render json: @cat_venta_cancelada.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cat_venta_canceladas/1
  # DELETE /cat_venta_canceladas/1.json
  def destroy
    @cat_venta_cancelada.destroy
    respond_to do |format|
      format.html { redirect_to cat_venta_canceladas_url, notice: 'Cat venta cancelada was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cat_venta_cancelada
      @cat_venta_cancelada = CatVentaCancelada.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cat_venta_cancelada_params
      params.require(:cat_venta_cancelada).permit(:clave, :descripcion)
    end
end
