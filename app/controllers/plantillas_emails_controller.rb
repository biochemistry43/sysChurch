class PlantillasEmailsController < ApplicationController
  before_action :set_plantillas_email, only: [:show, :edit, :destroy]

  # GET /plantillas_emails
  # GET /plantillas_emails.json
  def index
    @plantillas_emails = PlantillasEmail.all
  end

  def mostrar_plantilla
    @consulta = false
    if request.post?
      @consulta =true
      @plantillas_email = current_user.negocio.plantillas_emails.find_by(comprobante: params[:comprobante])
      
      @tipo_comprobante = case params[:comprobante]
        when "fv" then "Facturas de ventas"
        when "fg" then "Facturas globales"
        when "nc_fv" then "Notas de crédito de facturas de ventas"
        when "nc_fg" then "Notas de crédito de facturas globales"
        when "ac_fv" then "Acuses de cancelación de facturas de ventas"
        when "ac_fg" then "Acuses de cancelación de facturas globales" #o también <> Distinto de
        when "ac_nc_fv" then "Acuses de cancelación de notas de crédito para facturas de ventas" #o también <> Distinto de
        when "ac_nc_fg" then "Acuses de cancelación de notas de crédito para facturas globales" #o también <> Distinto de
      end
    end
  end 

  # GET /plantillas_emails/1
  # GET /plantillas_emails/1.json
  def show
  end

  # GET /plantillas_emails/new
  def new
    @plantillas_email = PlantillasEmail.new
  end

  # GET /plantillas_emails/1/edit
  def edit
  end

  # POST /plantillas_emails
  # POST /plantillas_emails.json
  def create
    @plantillas_email = PlantillasEmail.new(plantillas_email_params)

    respond_to do |format|
      if @plantillas_email.save
        format.html { redirect_to @plantillas_email, notice: 'Plantillas email was successfully created.' }
        format.json { render :show, status: :created, location: @plantillas_email }
      else
        format.html { render :new }
        format.json { render json: @plantillas_email.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plantillas_emails/1
  # PATCH/PUT /plantillas_emails/1.json
  def update
    @consulta = true
    asunto = ActionView::Base.full_sanitizer.sanitize(params[:asunto_email])
    mensaje = params[:summernote]
    @plantillas_email = PlantillasEmail.find(params[:id])

    respond_to do |format|
    if @plantillas_email.update(asunto_email: asunto, msg_email: mensaje)
      format.html { redirect_to action: "mostrar_plantilla", notice: 'La plantilla de email fue actualizada correctamente!' }
      format.js
    else
      format.html { redirect_to action: "mostrar_plantilla", notice: 'La plantilla de email no se pudo guardar!'}
    end
  end
=begin
    respond_to do |format|
      asunto = ActionView::Base.full_sanitizer.sanitize(params[:asunto_email])

      if @plantillas_email.update(plantillas_email_params)
        @plantillas_email.update(asunto_email: asunto)
        format.html { redirect_to @plantillas_email, notice: 'La plantilla de email fue actualizada correctamente.' }
        format.json { render :show, status: :ok, location: @plantillas_email }
      else
        format.html { render :edit }
        format.json { render json: @plantillas_email.errors, status: :unprocessable_entity }
      end
    end
=end
  end

  # DELETE /plantillas_emails/1
  # DELETE /plantillas_emails/1.json
  def destroy
    @plantillas_email.destroy
    respond_to do |format|
      format.html { redirect_to plantillas_emails_url, notice: 'Plantillas email was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plantillas_email
      @plantillas_email = PlantillasEmail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plantillas_email_params
      params.require(:plantillas_email).permit(:asunto_email, :msg_email, :comprobante, :negocio_id)
    end
end
