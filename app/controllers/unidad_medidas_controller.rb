class UnidadMedidasController < ApplicationController
  before_action :set_unidad_medida, only: [:show, :edit, :update, :destroy]

  # GET /unidad_medidas
  # GET /unidad_medidas.json
  def index

    #@unidad_medidas = UnidadMedida.all
    @unidad_medidas=current_user.negocio.unidad_medidas
  end

  # GET /unidad_medidas/1
  # GET /unidad_medidas/1.json
  def show
  end

  # GET /unidad_medidas/new
  def new
    @unidad_medida = UnidadMedida.new
  end

  # GET /unidad_medidas/1/edit
  def edit
  end

  # POST /unidad_medidas
  # POST /unidad_medidas.json
  def create
    @unidad_medida = UnidadMedida.new(unidad_medida_params)

    respond_to do |format|
      if @unidad_medida.valid?
        if @unidad_medida.save

          current_user.negocio.unidad_medidas << @unidad_medida
          format.json { head :no_content}
          format.js
          #format.html { redirect_to @unidad_medida, notice: 'Unidad medida was successfully created.' }
          #format.json { render :show, status: :created, location: @unidad_medida }
        else
          format.json{render json: @unidad_medida.errors.full_messages, status: :unprocessable_entity}
          #format.html { render :new }
          #format.json { render json: @unidad_medida.errors, status: :unprocessable_entity }
        end
      else
        format.js { render :new }
        format.json { render json: @unidad_medida.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /unidad_medidas/1
  # PATCH/PUT /unidad_medidas/1.json
  def update
    respond_to do |format|
      if @unidad_medida.update(unidad_medida_params)
        format.json { head :no_content}
        format.js
        #format.html { redirect_to @unidad_medida, notice: 'Unidad medida was successfully updated.' }
        #format.json { render :show, status: :ok, location: @unidad_medida }
      else
        format.json{render json: @cat_articulo.errors.full_messages, status: :unprocessable_entity}
        format.js { render :edit }
        #format.html { render :edit }
        #format.json { render json: @unidad_medida.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /unidad_medidas/1
  # DELETE /unidad_medidas/1.json
  def destroy
    @unidad_medida.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to unidad_medidas_url, notice: 'La unidad de medida fue eliminada.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_unidad_medida
      @unidad_medida = UnidadMedida.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def unidad_medida_params
      params.require(:unidad_medida).permit(:clave, :nombre, :descripcion, :simbolo)
    end
end
