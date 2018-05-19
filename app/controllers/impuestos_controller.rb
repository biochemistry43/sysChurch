class ImpuestosController < ApplicationController
  before_action :set_impuesto, only: [:show, :edit, :update, :destroy]

  # GET /impuestos
  # GET /impuestos.json
  def index
        #@unidad_medidas=current_user.negocio.unidad_medidas
    #@impuestos = Impuesto.all
    @impuestos=current_user.negocio.impuestos
  end

  # GET /impuestos/1
  # GET /impuestos/1.json
  def show
  end

  # GET /impuestos/new
  def new
    @impuesto = Impuesto.new
  end

  # GET /impuestos/1/edit
  def edit
  end

  # POST /impuestos
  # POST /impuestos.json
  def create
    @impuesto = Impuesto.new(impuesto_params)

    respond_to do |format|
      if @impuesto.valid?
        if @impuesto.save

          current_user.negocio.impuestos << @impuesto
          format.json { head :no_content}
          format.js
          #format.html { redirect_to @impuesto, notice: 'Unidad medida was successfully created.' }
          #format.json { render :show, status: :created, location: @impuesto }
        else
          format.json{render json: @impuesto.errors.full_messages, status: :unprocessable_entity}
          #format.html { render :new }
          #format.json { render json: @impuesto.errors, status: :unprocessable_entity }
        end
      else
        format.js { render :new }
        format.json { render json: @impuesto.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /impuestos/1
  # PATCH/PUT /impuestos/1.json
  def update
    respond_to do |format|
      if @impuesto.update(impuesto_params)
        format.json { head :no_content}
        format.js
        #format.html { redirect_to @impuesto, notice: 'Impuesto was successfully updated.' }
        #format.json { render :show, status: :ok, location: @impuesto }
      else
        format.json{render json: @impuesto.errors.full_messages, status: :unprocessable_entity}
        format.js { render :edit }
        #format.html { render :edit }
        #format.json { render json: @impuesto.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /impuestos/1
  # DELETE /impuestos/1.json
  def destroy

    @impuesto.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to impuestos_url, notice: 'El Impuesto fue eliminado correctamente' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_impuesto
      @impuesto = Impuesto.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def impuesto_params
      params.require(:impuesto).permit(:nombre, :tipo, :porcentaje, :descripcion)
    end
end
