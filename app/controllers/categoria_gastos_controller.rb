class CategoriaGastosController < ApplicationController
  before_action :set_categoria_gasto, only: [:edit, :update, :destroy]

  # GET /categoria_gastos
  # GET /categoria_gastos.json
  def index
    @categoria_gastos = current_user.negocio.categoria_gastos
  end

  # GET /categoria_gastos/1
  # GET /categoria_gastos/1.json
  def show
  end

  # GET /categoria_gastos/new
  def new
    @categoria_gasto = CategoriaGasto.new
  end

  # GET /categoria_gastos/1/edit
  def edit
    @categorias = current_user.negocio.categoria_gastos
  end

  # POST /categoria_gastos
  # POST /categoria_gastos.json
  def create
    @categoria_gasto = CategoriaGasto.new(categoria_gasto_params)

    respond_to do |format|
      if @categoria_gasto.valid?
        if @categoria_gasto.save
          current_user.negocio.categoria_gastos << @categoria_gasto
          format.json { head :no_content}
          format.js
        else
          format.json{render json: @categoria_gasto.errors.full_messages, status: :unprocessable_entity}
        end
      else
        format.js { render :new }
        format.json{render json: @categoria_gasto.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /categoria_gastos/1
  # PATCH/PUT /categoria_gastos/1.json
  def update
    respond_to do |format|
      if @categoria_gasto.update(categoria_gasto_params)
        format.json { head :no_content}
        format.js
      else
        format.json{render json: @categoria_gasto.errors.full_messages, status: :unprocessable_entity}
        format.js { render :edit }
      end
    end
  end

  # DELETE /categoria_gastos/1
  # DELETE /categoria_gastos/1.json
  def destroy
    @categoria_gasto.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to categoria_gastos_url, notice: 'La categoría fue eliminada.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_categoria_gasto
      @categoria_gasto = CategoriaGasto.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def categoria_gasto_params
      params.require(:categoria_gasto).permit(:nombre_categoria, :descripcionCategoria, :idCategoriaPadre)
    end
end
