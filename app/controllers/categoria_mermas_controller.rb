class CategoriaMermasController < ApplicationController
	
  before_action :set_categoria_merma, only: [:edit, :update, :destroy]

  def index
    @categorias_merma = current_user.negocio.categoria_mermas
  end

  def show
  end

  def new
    @categoria_merma = CategoriaMerma.new
  end

  def edit
  end

  def create
    @categoria_merma = CategoriaMerma.new(cat_merma_params)

    respond_to do |format|
      if @categoria_merma.save
        current_user.negocio.categoria_mermas << @categoria_merma
        format.json { head :no_content}
        format.js
      else
        format.json{render json: @categoria_merma.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  def update
    respond_to do |format|
      if @categoria_merma.update(cat_merma_params)
      	format.json { head :no_content}
        format.js
      else
        format.json{render json: @categoria_merma.errors.full_messages, status: :unprocessable_entity}
        format.js { render :edit }
      end
    end
  end

  def destroy
    @categoria_merma.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to categoria_mermas_url, notice: 'La categoría fue eliminada.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_categoria_merma
      @categoria_merma = CategoriaMerma.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cat_merma_params
      params.require(:categoria_merma).permit(:categoria, :descripcion)
    end

end
