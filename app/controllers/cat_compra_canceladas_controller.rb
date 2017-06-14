class CatCompraCanceladasController < ApplicationController
  before_action :set_cat_compra_cancelada, only: [:show, :edit, :update, :destroy]

  # GET /cat_compra_canceladas
  # GET /cat_compra_canceladas.json
  def index
    if can? :create, Negocio
      @cat_compra_canceladas = current_user.negocio.cat_compra_canceladas
    end
  end

  # GET /cat_compra_canceladas/1
  # GET /cat_compra_canceladas/1.json
  def show
  end

  # GET /cat_compra_canceladas/new
  def new
    @cat_compra_cancelada = CatCompraCancelada.new
  end

  # GET /cat_compra_canceladas/1/edit
  def edit
  end

  # POST /cat_compra_canceladas
  # POST /cat_compra_canceladas.json
  def create
    @cat_compra_cancelada = CatCompraCancelada.new(cat_compra_cancelada_params)
    @cat_compra_cancelada.negocio = current_user.negocio

    respond_to do |format|
      if @cat_compra_cancelada.valid?
        if @cat_compra_cancelada.save

          format.json { head :no_content }
          format.js
        else

          format.json { render json: @cat_compra_cancelada.errors, status: :unprocessable_entity }
        end
      else
        format.js { render :new }
        format.json { render json: @cat_compra_cancelada.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cat_compra_canceladas/1
  # PATCH/PUT /cat_compra_canceladas/1.json
  def update
    respond_to do |format|
      if @cat_compra_cancelada.update(cat_compra_cancelada_params)
        format.json { head :no_content}
      else
        format.json { render json: @cat_compra_cancelada.errors, status: :unprocessable_entity }
        format.js { render :edit }
      end
    end
  end

  # DELETE /cat_compra_canceladas/1
  # DELETE /cat_compra_canceladas/1.json
  def destroy
    @cat_compra_cancelada.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to cat_compra_canceladas_url, notice: 'La categoría ha sido eliminada.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cat_compra_cancelada
      @cat_compra_cancelada = CatCompraCancelada.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cat_compra_cancelada_params
      params.require(:cat_compra_cancelada).permit(:clave, :descripcion)
    end

end
