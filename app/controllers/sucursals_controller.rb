class SucursalsController < ApplicationController
  before_action :set_sucursal, only: [:edit, :update, :destroy]

  # GET /sucursals
  # GET /sucursals.json
  def index
    @sucursals = current_user.negocio.sucursals
  end

  # GET /sucursals/1
  # GET /sucursals/1.json
  def show
  end

  # GET /sucursals/new
  def new
    @sucursal = Sucursal.new
  end

  # GET /sucursals/1/edit
  def edit
  end

  # POST /sucursals
  # POST /sucursals.json
  def create
    @sucursal = Sucursal.new(sucursal_params)
    #Datos fiscales de la sucursal
    calle_fiscal = params[:dir_fiscal_calle]
    numExt_fiscal = params[:dir_fiscal_numExt]
    numInt_fiscal = params[:dir_fiscal_numInt]
    colonia_fiscal = params[:dir_fiscal_colonia]
    localidad_fiscal = params[:dir_fiscal_localidad]
    codigo_postal_fiscal = params[:dir_fiscal_codigo_postal]
    municipio_fiscal = params[:dir_fiscal_municipio]
    estado_fiscal = params[:dir_fiscal_estado]
    referencia_fiscal = params[:dir_fiscal_referencia]

    @datos_fiscales_sucursal = DatosFiscalesSucursal.new(calle: calle_fiscal, numExt: numExt_fiscal, numInt: numInt_fiscal, colonia: colonia_fiscal, localidad: localidad_fiscal, codigo_postal: codigo_postal_fiscal, municipio: municipio_fiscal, estado: estado_fiscal, referencia: referencia_fiscal)

    respond_to do |format|
      if @sucursal.valid?
        if @sucursal.save
          @sucursal.datos_fiscales_sucursal = @datos_fiscales_sucursal if @datos_fiscales_sucursal.save
          current_user.negocio.sucursals << @sucursal
          format.js
          format.html { redirect_to @sucursal, notice: 'La sucursal fue creada.' }
          format.json { render :show, status: :created, location: @sucursal }
        else
          format.js { render :new }
          format.html { render :new }
          format.json { render json: @sucursal.errors, status: :unprocessable_entity }
        end
      else
        format.js { render :new }
        format.json {render json: @sucursal.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /sucursals/1
  # PATCH/PUT /sucursals/1.json
  def update
    #Datos fiscales de la sucursal
    calle_fiscal = params[:dir_fiscal_calle]
    numExt_fiscal = params[:dir_fiscal_numExt]
    numInt_fiscal = params[:dir_fiscal_numInt]
    colonia_fiscal = params[:dir_fiscal_colonia]
    localidad_fiscal = params[:dir_fiscal_localidad]
    codigo_postal_fiscal = params[:dir_fiscal_codigo_postal]
    municipio_fiscal = params[:dir_fiscal_municipio]
    estado_fiscal = params[:dir_fiscal_estado]
    referencia_fiscal = params[:dir_fiscal_referencia]

    respond_to do |format|
      if @sucursal.update(sucursal_params)
        @sucursal.datos_fiscales_sucursal.update(calle: calle_fiscal, numExt: numExt_fiscal, numInt: numInt_fiscal, colonia: colonia_fiscal, localidad: localidad_fiscal, codigo_postal: codigo_postal_fiscal, municipio: municipio_fiscal, estado: estado_fiscal, referencia: referencia_fiscal)
        format.json { head :no_content}
        format.js
        #format.html { redirect_to @sucursal, notice: 'Sucursal was successfully updated.' }
        #format.json { render :show, status: :ok, location: @sucursal }
      else
        #format.html { render :edit }
        #format.json { render json: @sucursal.errors, status: :unprocessable_entity }
        format.json {render json: @sucursal.errors.full_messages, status: :unprocessable_entity}
        format.js {render :edit}
      end
    end
  end

  # DELETE /sucursals/1
  # DELETE /sucursals/1.json
  def destroy
    @sucursal.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to sucursals_url, notice: 'La Sucursal fue eliminada.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sucursal
      @sucursal = Sucursal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sucursal_params
      params.require(:sucursal).permit(:nombre, :representante, :calle, :numExterior, :numInterior, :colonia, :codigo_postal, :municipio, :delegacion, :estado, :telefono, :email)
    end
end
