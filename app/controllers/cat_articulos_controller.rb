class CatArticulosController < ApplicationController
  before_action :set_categoria, only: [:edit, :update, :destroy]
  # GET /cat_articulos
  # GET /cat_articulos.json
  def index
    @cat_articulos = current_user.negocio.cat_articulos#select("cat_articulos.id,cat_articulos.nombreCatArticulo,cat_articulos.descripcionCatArticulo,b.nombreCatArticulo as padre").joins('INNER JOIN cat_articulos b on cat_articulos.idCategoriaPadre=b.id')
  end

  # GET /cat_articulos/1
  # GET /cat_articulos/1.json
  def show
    #@cat_articulo = CatArticulo.select("cat_articulos.id,cat_articulos.nombreCatArticulo,cat_articulos.descripcionCatArticulo,b.nombreCatArticulo as padre").joins('INNER JOIN cat_articulos b on cat_articulos.idCategoriaPadre=b.id').where("cat_articulos.id=?",params[:id])
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
      if @cat_articulo.valid?
        if @cat_articulo.save
          current_user.negocio.cat_articulos << @cat_articulo
          #format.html { redirect_to @cat_articulo, notice: 'La categoria fue creada satisfactoriamente' }
          #format.json { render :show, status: :created, location: @cat_articulo }
          format.json { head :no_content}
          format.js
        else
          #format.html { render :new }
          #format.json { render json: @cat_articulo.errors, status: :unprocessable_entity }
          format.json{render json: @cat_articulo.errors.full_messages, status: :unprocessable_entity}
        end
      else
        format.js { render :new }
        format.json { render json: @cat_articulo.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cat_articulos/1
  # PATCH/PUT /cat_articulos/1.json
  def update
    respond_to do |format|
      if @cat_articulo.update(cat_articulo_params)
        format.json { head :no_content}
        format.js
        #format.html { redirect_to @cat_articulo, notice: 'La categoria fue actualizada satisfactoriamente' }
        #format.json { render :show, status: :ok, location: @cat_articulo }
      else
        #format.html { render :edit }
        #format.json { render json: @cat_articulo.errors, status: :unprocessable_entity }
        format.json{render json: @cat_articulo.errors.full_messages, status: :unprocessable_entity}
        format.js { render :edit }
      end
    end
  end

  # DELETE /cat_articulos/1
  # DELETE /cat_articulos/1.json
  def destroy

    @cat_articulo.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to cat_articulos_url, notice: 'La categoria fue eliminada' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_categoria
      @cat_articulo = CatArticulo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cat_articulo_params
      params.require(:cat_articulo).permit(:nombreCatArticulo, :descripcionCatArticulo, :cat_articulo_id)
    end
end
