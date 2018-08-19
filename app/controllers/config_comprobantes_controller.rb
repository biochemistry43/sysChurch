class ConfigComprobantesController < ApplicationController
  before_action :set_config_comprobante, only: [:show, :edit, :update, :destroy]

  # GET /config_comprobantes
  # GET /config_comprobantes.json
  def index
    @config_comprobantes = ConfigComprobante.all
    #@config_comprobantes = ConfigComprobante.all
  end


  def mostrar_plantilla

    @consulta = false

    if request.post?
      @consulta =true
      @config_comprobante = current_user.negocio.config_comprobantes.find_by(comprobante: params[:comprobante])
     
      #Se extraen los valores de la plantilla de impresión
      @tipo_fuente = @config_comprobante.tipo_fuente
      @tam_fuente = @config_comprobante.tam_fuente
      @color_fondo = @config_comprobante.color_fondo
      @color_titulos = @config_comprobante.color_titulos
      @tipo_fuente = @config_comprobante.tipo_fuente
      @color_banda = @config_comprobante.color_banda

      if @config_comprobante.comprobante == "f"
        leyenda = "Facturas"
      elsif @config_comprobante.comprobante == "nc"
        leyenda = "Notas de crédito"
      elsif @config_comprobante.comprobante == "ac"
        leyenda = "Acuses de cancelación"
      end
      @nombre_plantilla = leyenda
    end
  end 


  # GET /config_comprobantes/1
  # GET /config_comprobantes/1.json
  def show

  end

  # GET /config_comprobantes/new
  def new
    @config_comprobante = ConfigComprobante.new
  end

  # GET /config_comprobantes/1/edit
  def edit
  end

  # POST /config_comprobantes
  # POST /config_comprobantes.json
  def create
    @config_comprobante = ConfigComprobante.new(config_comprobante_params)

    respond_to do |format|
      if @config_comprobante.save
        format.html { redirect_to @config_comprobante, notice: 'Config comprobante was successfully created.' }
        format.json { render :show, status: :created, location: @config_comprobante }
      else
        format.html { render :new }
        format.json { render json: @config_comprobante.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /config_comprobantes/1
  # PATCH/PUT /config_comprobantes/1.json
  def update

    @consulta = true

    @color_fondo = params[:color_fondo]
    @color_banda = params[:color_banda]
    @color_titulos = params[:color_titulos]
    @tipo_fuente = params[:tipo_fuente]
    @tam_fuente = params[:tam_fuente]

    if @config_comprobante.comprobante == "f"
      leyenda = "Facturas"
    elsif @config_comprobante.comprobante == "nc"
      leyenda = "Notas de crédito"
    elsif @config_comprobante.comprobante == "ac"
      leyenda = "Acuses de cancelación"
    end
    @nombre_plantilla = leyenda

    respond_to do |format|
    if @config_comprobante.update(tipo_fuente: @tipo_fuente, tam_fuente: @tam_fuente, color_fondo: @color_fondo, color_titulos: @color_titulos, color_banda: @color_banda )
      format.html { redirect_to action: "mostrar_plantilla", notice: 'La plantilla de email fue actualizada correctamente!' }
      format.js
    else
      format.html { redirect_to action: "mostrar_plantilla", notice: 'La plantilla de email no se pudo guardar!'}
    end
  end
=begin
    #@config_comprobante = ConfigComprobante.find_by(negocio_id: current_user.negocio.id)
    respond_to do |format|
      #if @config_comprobante.update(config_comprobante_params)
      if @config_comprobante.update(tipo_fuente: tipo_fuente, tam_fuente: tam_fuente, color_fondo: color_fondo, color_titulos:color_titulos, color_banda:color_banda )
        format.html { redirect_to @config_comprobante, notice: 'La configuración de la plantilla de impresión se ha guardado exitosamente.' }
        format.json { render :show, status: :ok, location: @config_comprobante }
      else
        format.html { render :edit }
        format.json { render json: @config_comprobante.errors, status: :unprocessable_entity }
      end
    end
=end
  end

  # DELETE /config_comprobantes/1
  # DELETE /config_comprobantes/1.json
  def destroy
    @config_comprobante.destroy
    respond_to do |format|
      format.html { redirect_to config_comprobantes_url, notice: 'Config comprobante was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_config_comprobante
      #id_negocio = current_user.negocio.id
      #@config_comprobante = ConfigComprobante.find_by(negocio_id: id_negocio)
      @config_comprobante = ConfigComprobante.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def config_comprobante_params
      params.permit(:comprobante, :tipo_fuente, :tam_fuente, :color_fondo, :color_titulos, :color_banda, :negocio_id)
      #params.require(:config_comprobante).permit(:comprobante, :tipo_fuente, :tam_fuente, :color_fondo, :color_titulos, :color_banda, :negocio_id)
    end
end
