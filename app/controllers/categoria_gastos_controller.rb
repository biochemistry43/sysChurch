class CategoriaGastosController < ApplicationController
  before_action :set_categoria_gasto, only: [:show, :edit, :update, :destroy]

  # GET /categoria_gastos
  # GET /categoria_gastos.json
  def index
    @categoria_gastos = CategoriaGasto.all
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
  end

  # POST /categoria_gastos
  # POST /categoria_gastos.json
  def create
    @categoria_gasto = CategoriaGasto.new(categoria_gasto_params)

    respond_to do |format|
      if @categoria_gasto.save
        current_user.negocio.categoria_gastos << @categoria_gasto
        format.html { redirect_to @categoria_gasto, notice: 'Categoria gasto was successfully created.' }
        format.json { render :show, status: :created, location: @categoria_gasto }
      else
        format.html { render :new }
        format.json { render json: @categoria_gasto.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categoria_gastos/1
  # PATCH/PUT /categoria_gastos/1.json
  def update
    respond_to do |format|
      if @categoria_gasto.update(categoria_gasto_params)
        format.html { redirect_to @categoria_gasto, notice: 'Categoria gasto was successfully updated.' }
        format.json { render :show, status: :ok, location: @categoria_gasto }
      else
        format.html { render :edit }
        format.json { render json: @categoria_gasto.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categoria_gastos/1
  # DELETE /categoria_gastos/1.json
  def destroy
    @categoria_gasto.destroy
    respond_to do |format|
      format.html { redirect_to categoria_gastos_url, notice: 'Categoria gasto was successfully destroyed.' }
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
      params.require(:categoria_gasto).permit(:nombreCategoria, :descripcionCategoria, :idCategoriaPadre)
    end
end
