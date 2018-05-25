class CategoriaMermasController < ApplicationController
	
  before_action :set_categoria_merma, only: [:edit, :update, :destroy]

  def index
    @categorias_merma = current_user.negocio.cat_mermas
  end

  def show
  end

  def new
    @categoria_merma = CatMerma.new
  end

  def edit
  end

  def create
    @categoria_merma = CatMerma.new(cat_merma_params)

    respond_to do |format|
      if @categoria_merma.save
        current_user.negocio.cat_mermas << @categoria_merma
        format.html { redirect_to @categoria_merma, notice: 'La categoria fue creada satisfactoriamente' }
        format.json { render :show, status: :created, location: @categoria_merma }
      else
        format.json{render json: @categoria_merma.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  def update
    respond_to do |format|
      if @categoria_merma.update(cat_merma_params)
      	format.html { redirect_to @categoria_merma, notice: 'La categoria fue actualizada satisfactoriamente' }
        format.json { render :show, status: :ok, location: @categoria_merma }
      else
        format.html { render :edit }
        format.json { render json: @categoria_merma.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @categoria_merma.destroy
    respond_to do |format|
      format.html { redirect_to categoria_mermas_url, notice: 'La categoría fue eliminada.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_categoria_merma
      @categoria_merma = CatMerma.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cat_merma_params
      params.require(:cat_merma).permit(:categoria, :descripcion)
    end

end
