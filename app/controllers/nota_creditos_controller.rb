class NotaCreditosController < ApplicationController
  before_action :set_nota_credito, only: [:show, :edit, :update, :destroy, :imprimirpdf]
  #before_action :set_sucursales, only: [:index, :consulta_avanzada]


  # GET /nota_creditos
  # GET /nota_creditos.json
  def index
    @consulta = false
    @avanzada = false

    if request.get?
      if can? :create, Negocio
        @nota_creditos = current_user.negocio.nota_creditos.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
      else
        @nota_creditos = current_user.sucursal.nota_creditos.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
      end
    end
  end

  # GET /nota_creditos/1
  # GET /nota_creditos/1.json
  def show
  end

  # GET /nota_creditos/new
  def new
    @nota_credito = NotaCredito.new
  end

  # GET /nota_creditos/1/edit
  def edit
  end

  # POST /nota_creditos
  # POST /nota_creditos.json
  def create
    @nota_credito = NotaCredito.new(nota_credito_params)

    respond_to do |format|
      if @nota_credito.save
        format.html { redirect_to @nota_credito, notice: 'Nota credito was successfully created.' }
        format.json { render :show, status: :created, location: @nota_credito }
      else
        format.html { render :new }
        format.json { render json: @nota_credito.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nota_creditos/1
  # PATCH/PUT /nota_creditos/1.json
  def update
    respond_to do |format|
      if @nota_credito.update(nota_credito_params)
        format.html { redirect_to @nota_credito, notice: 'Nota credito was successfully updated.' }
        format.json { render :show, status: :ok, location: @nota_credito }
      else
        format.html { render :edit }
        format.json { render json: @nota_credito.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nota_creditos/1
  # DELETE /nota_creditos/1.json
  def destroy
    @nota_credito.destroy
    respond_to do |format|
      format.html { redirect_to nota_creditos_url, notice: 'Nota credito was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  #CONSULTAS

  def consulta_por_fecha
    @consulta = true
    @fechas=true
    @por_folio=false
    @avanzada = false
    @por_cliente= false

    if request.post?
      @fechaInicial = DateTime.parse(params[:fecha_inicial]).to_date
      @fechaFinal = DateTime.parse(params[:fecha_final]).to_date
      if can? :create, Negocio
        @nota_creditos = current_user.negocio.nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal)
      else
        @nota_creditos = current_user.sucursal.nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal)
      end

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end
  end



  #Acción para imprimir la nota de crédito
  def imprimirpdf

    gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
    storage=gcloud.storage

    bucket = storage.bucket "cfdis"

    fecha_expedicion= @nota_credito.fecha_expedicion
    consecutivo = @nota_credito.consecutivo

    ruta_storage = @nota_credito.ruta_storage

    #Se descarga el pdf de la nube y se guarda en el disco
    file_name="#{consecutivo}_#{fecha_expedicion}_NotaCrédito.pdf"

    file_download_storage = bucket.file "#{ruta_storage}_NotaCrédito.pdf"
    file_download_storage.download "public/#{file_name}"


    #Se comprueba que el archivo exista en la carpeta publica de la aplicación
    if File::exists?( "public/#{file_name}")
      file=File.open( "public/#{file_name}")
      send_file( file, :disposition => "inline", :type => "application/pdf")
      #File.delete("public/#{file_name}")
    else
      respond_to do |format|
        format.html { redirect_to action: "index" }
        flash[:notice] = "No se encontró la factura, vuelva a intentarlo!"
        #format.html { redirect_to facturas_index_path, notice: 'No se encontró la factura, vuelva a intentarlo!' }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nota_credito
      @nota_credito = NotaCredito.find(params[:id])
    end
    def set_sucursales
      @sucursales = current_user.negocio.sucursals
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def nota_credito_params
      params.require(:nota_credito).permit(:folio, :fecha_expedicion, :monto_devolucion, :motivo, :user_id, :cliente_id, :sucursal_id, :negocio_id)
    end
end
