class CatArticulosController < ApplicationController
  before_action :set_cat_articulo, only: [:show, :edit, :update, :destroy]

  # GET /cat_articulos
  # GET /cat_articulos.json
  def index
    @cat_articulos = CatArticulo.all
  end

  # GET /cat_articulos/1
  # GET /cat_articulos/1.json
  def show
  end

  # GET /cat_articulos/new
  def new
    @cat_articulo = CatArticulo.new
  end

  # GET /cat_articulos/1/edit
  def edit
  end

  # POST /cat_articulos
  # POST /cat_articulos.json
  def create
    @cat_articulo = CatArticulo.new(cat_articulo_params)

    respond_to do |format|
      if @cat_articulo.save
        format.html { redirect_to @cat_articulo, notice: 'Cat articulo was successfully created.' }
        format.json { render :show, status: :created, location: @cat_articulo }
      else
        format.html { render :new }
        format.json { render json: @cat_articulo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cat_articulos/1
  # PATCH/PUT /cat_articulos/1.json
  def update
    respond_to do |format|
      if @cat_articulo.update(cat_articulo_params)
        format.html { redirect_to @cat_articulo, notice: 'Cat articulo was successfully updated.' }
        format.json { render :show, status: :ok, location: @cat_articulo }
      else
        format.html { render :edit }
        format.json { render json: @cat_articulo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cat_articulos/1
  # DELETE /cat_articulos/1.json
  def destroy
    @cat_articulo.destroy
    respond_to do |format|
      format.html { redirect_to cat_articulos_url, notice: 'Cat articulo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cat_articulo
      @cat_articulo = CatArticulo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cat_articulo_params
      params.require(:cat_articulo).permit(:nombreCatArticulo, :descripcionCatArticulo, :idCategoriaPadre)
    end
end
