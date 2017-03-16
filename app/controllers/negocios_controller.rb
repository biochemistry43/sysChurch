class NegociosController < ApplicationController
  before_action :set_negocio, only: [:edit, :update, :destroy]

  # GET /negocios
  # GET /negocios.json
  def index
    @negocios = Negocio.all
  end

  # GET /negocios/1
  # GET /negocios/1.json
  def show
    @sucursals = Sucursal.where('negocio_id', params[:id])
      @datosFiscales
    unless @negocio.datos_fiscales_negocio
      @datosFiscales = DatosFiscalesNegocio.new(:nombreFiscal => @negocio.nombre, :direccionFiscal=>@negocio.direccion)
      @datosFiscales.save
      @negocio.datos_fiscales_negocio = @datosFiscales
    else
      @datosFiscales = @negocio.datos_fiscales_negocio
    end
  end

  def updateDatosFiscales
    
  end

  # GET /negocios/new
  def new
    @negocio = Negocio.new
  end

  # GET /negocios/1/edit
  def edit
  end

  # POST /negocios
  # POST /negocios.json
  def create
    @negocio = Negocio.new(negocio_params)

    respond_to do |format|
      if @negocio.save
        current_user.negocio << @negocio
        #format.html { redirect_to @negocio, notice: 'Negocio was successfully created.' }
        #format.json { render :show, status: :created, location: @negocio }
        format.json { head :no_content}
        format.js
      else
        #format.html { render :new }
        #format.json { render json: @negocio.errors, status: :unprocessable_entity }
        format.json{render json: @negocio.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /negocios/1
  # PATCH/PUT /negocios/1.json
  def update
    respond_to do |format|
      if @negocio.update(negocio_params)
         format.json { head :no_content}
        format.js
        #format.html { redirect_to @negocio, notice: 'Los datos del negocio fueron actualizados' }
        #format.json { render :show, status: :ok, location: @negocio }
      else
        #format.html { render :edit }
        #format.json { render json: @negocio.errors, status: :unprocessable_entity }
        format.json{render json: @negocio.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /negocios/1
  # DELETE /negocios/1.json
  def destroy
    @negocio.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to negocios_url, notice: 'Negocio was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_negocio
      @negocio = Negocio.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def negocio_params
      params.require(:negocio).permit(:logo, :nombre, :representante, :direccion)
    end
end
