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
      @asunto = @plantillas_email.asunto_email
      @mensaje = @plantillas_email.msg_email
      
      @tipo_comprobante = case params[:comprobante]
        when "fv" then "Plantilla de email para facturas de ventas"
        when "nc" then "Plantilla de email para notas de crédito"
        when "ac" then "Plantilla de email para acuses de cancelación"
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

    @plantillas_email = PlantillasEmail.find(plantillas_email_params[:id])
    @tipo_comprobante = @plantillas_email.comprobante
    accion = params[:commit]
    if accion == "Cancelar"
      asunto = @plantillas_email.asunto_email

      @asunto = ActionView::Base.full_sanitizer.sanitize(asunto)
      @mensaje = @plantillas_email.msg_email
    elsif accion == "Guardar Cambios"
      asunto = plantillas_email_params[:asunto_email]

      @asunto = ActionView::Base.full_sanitizer.sanitize(asunto)
      @mensaje = plantillas_email_params[:summernote]

      @plantillas_email.update(asunto_email: @asunto, msg_email: @mensaje)
    elsif accion == "Usar la plantilla por defecto"
      case @plantillas_email.comprobante
        when "fv" 
          @asunto = "ENVÍO DE LA FACTURA DE VENTA"
          @mensaje = %Q^<p style="text-align: justify; line-height: 1.2;"><span style="font-size: 14px; font-family: Roboto;">﻿</span><span style="background-color: rgb(255, 255, 255); font-weight: normal;"><font face="arial, sans-serif" style=""><span style="font-size: 14px; letter-spacing: 0.12px; font-family: Roboto;">Hola </span></font></span><span style="font-family: Roboto; font-size: 14px;"><i>{{Nombre del cliente}}</i></span><span style="font-family: Roboto; letter-spacing: 0.12px; font-weight: normal; font-size: 14px;">,</span></p><p style="text-align: justify; line-height: 1.2;"><font face="arial, sans-serif" style="font-weight: normal;"><span style="font-size: 14px; font-family: Roboto;">En </span><span style="font-size: 14px; letter-spacing: 0.12px; font-family: Roboto;">el presente correo se adjunta la factura de venta con folio </span></font><span style="font-size: 14px; font-family: Roboto;"><i>{{Folio}}</i></span><font face="arial, sans-serif" style="font-weight: normal;"><span style="font-size: 14px; letter-spacing: 0.12px; font-family: Roboto;">&nbsp;</span></font><span style="font-weight: normal; font-size: 14px; font-family: Roboto;">que fue expedida en nuestra sucursal</span><span style="font-weight: normal; font-size: 12px;"><span style="font-family: Roboto; font-size: 14px;">&nbsp;</span></span><i><span style="font-size: 14px; font-family: Roboto;">{{Nombre de la sucursal}}</span><span style="font-weight: normal; font-size: 14px; font-family: Roboto;">&nbsp;</span></i><span style="font-weight: normal; font-size: 12px;"><span style="font-family: Roboto; font-size: 14px;">&nbsp;el</span><span style="font-family: Roboto; font-size: 14px;">&nbsp;día&nbsp;</span></span><span style="font-size: 12px;"><span style="font-family: Roboto; font-size: 14px;"><i>{{Fecha}}</i></span><span style="font-weight: normal; font-family: Roboto; font-size: 14px;">.</span></span></p><p style="text-align: justify; line-height: 1.2;"><font face="Roboto"><span style="font-size: 14px; font-weight: normal; letter-spacing: 0.12px;">Para&nbsp;cualquier duda o aclaración por favor </span><span style="font-size: 14px; font-weight: 400; letter-spacing: 0.12px;">ponte</span><span style="font-size: 14px; font-weight: normal; letter-spacing: 0.12px;">&nbsp;en contacto a través de cualquiera de los siguientes dos medios de comunicación:</span></font></p><ul><li style="text-align: justify; line-height: 1.2;"><font face="Helvetica" style="font-weight: normal;"><span style="letter-spacing: 0.12px; font-family: Roboto; font-size: 14px;">Teléfono:&nbsp;&nbsp;</span></font><span style="font-family: Roboto; font-size: 14px;"><i>{{Teléfono de contacto}}</i></span><span style="font-weight: normal; font-family: Roboto; font-size: 14px;">&nbsp;</span></li><li style="text-align: justify; line-height: 1.2;"><span style="font-weight: normal; font-family: Roboto; font-size: 14px;">Email: </span><span style="font-family: Roboto; font-size: 14px;"><i>{{Email de contacto}}</i></span></li></ul><p style="text-align: justify; line-height: 1.2;"><span style="font-weight: normal; font-family: Roboto; font-size: 14px;">Atentamente: </span><span style="font-family: Roboto; font-size: 14px;"><i>{{Nombre del negocio}}</i></span></p><p style="text-align: justify; line-height: 1.2;"><span style="font-family: Roboto; font-size: 14px;"><br></span></p><p style="text-align: justify; line-height: 1.2;"><span style="font-family: Roboto; font-size: 14px; font-weight: normal;">Haciendo click sobre el enlace podrás obtener el comprobante mencionado.</span></p><p style="text-align: justify; line-height: 1.2;"><br></p><p style="text-align: justify; line-height: 1.2;"><span style="font-size: 14px; background-color: rgb(255, 255, 0);">VERIFICACIÓN DE TEXTO VARIABLE</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 14px; font-weight: normal; color: rgb(0, 49, 99);">{{Nombre del cliente}} =&gt; Nombre del cliente</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 14px; font-weight: normal; color: rgb(0, 49, 99);">{{Fecha}} =&gt; Fecha</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 14px; font-weight: normal; color: rgb(0, 49, 99);">{{Número}} =&gt; Número</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 14px; font-weight: normal; color: rgb(0, 49, 99);">{{Folio}} =&gt; Folio</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 14px; font-weight: normal; color: rgb(0, 49, 99);">{{Total}} =&gt; Total</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 14px; font-weight: normal; color: rgb(0, 49, 99);">{{Nombre del negocio}} =&gt; Nombre del negocio</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 14px; font-weight: normal; color: rgb(0, 49, 99);">{{Nombre de la sucursal}} =&gt; Nombre de la sucursal</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 14px; font-weight: normal; color: rgb(0, 49, 99);">{{Email de contacto}} =&gt; Email de contacto</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 14px; font-weight: normal; color: rgb(0, 49, 99);">{{Teléfono de contacto}} =&gt; Teléfono de contacto</span><span style="font-size: 12px;"></span></p>^
        when "nc" then "Plantilla de email para notas de crédito"
          @asunto = "ENVÍO DE LA NOTA DE CRÉDITO"
          @mensaje = %Q^<p style="text-align: justify; line-height: 1.2;"><span style="font-size: 14px; font-family: Roboto;">﻿</span><span style="font-weight: normal;"><font face="arial, sans-serif"><span style="font-size: 14px; letter-spacing: 0.12px; font-family: Roboto;">Hola&nbsp;</span></font></span><span style="font-family: Roboto; font-size: 14px;"><i>{{Nombre del cliente}}</i></span><span style="font-family: Roboto; letter-spacing: 0.12px; font-weight: normal; font-size: 14px;">,</span></p><p style="text-align: justify; line-height: 1.2;"><font face="arial, sans-serif" style="font-weight: normal;"><span style="font-size: 14px; font-family: Roboto;">En&nbsp;</span><span style="font-size: 14px; letter-spacing: 0.12px; font-family: Roboto;">el presente correo se adjunta la nota de crédito con folio&nbsp;</span></font><span style="font-size: 14px; font-family: Roboto;"><i>{{Folio}}</i></span><font face="arial, sans-serif" style="font-weight: normal;"><span style="font-size: 14px; letter-spacing: 0.12px; font-family: Roboto;">&nbsp;</span></font><span style="font-weight: normal; font-size: 14px; font-family: Roboto;">que fue expedida en nuestra sucursal</span><span style="font-weight: normal;"><span style="font-family: Roboto; font-size: 14px;">&nbsp;</span></span><span style="font-size: 14px; font-family: Roboto;"><i>{{Nombre de la sucursal}}</i></span><span style="font-weight: normal; font-size: 14px; font-family: Roboto;">&nbsp;</span><span style="font-weight: normal;"><span style="font-family: Roboto; font-size: 14px;">&nbsp;el</span><span style="font-family: Roboto; font-size: 14px;">&nbsp;día&nbsp;</span></span><span style="font-family: Roboto; font-size: 14px;"><i>{{Fecha}}</i></span><span style="font-weight: normal; font-family: Roboto; font-size: 14px;">.</span></p><p style="text-align: justify; line-height: 1.2;"><font face="Roboto"><span style="font-size: 14px; font-weight: normal; letter-spacing: 0.12px;">Para&nbsp;cualquier duda o aclaración por favor&nbsp;</span><span style="font-size: 14px; font-weight: 400; letter-spacing: 0.12px;">ponte</span><span style="font-size: 14px; font-weight: normal; letter-spacing: 0.12px;">&nbsp;en contacto a través de cualquiera de los siguientes dos medios de comunicación:</span></font></p><ul><li style="text-align: justify; line-height: 1.2;"><font face="Helvetica" style="font-weight: normal;"><span style="letter-spacing: 0.12px; font-family: Roboto; font-size: 14px;">Teléfono:&nbsp;&nbsp;</span></font><span style="font-family: Roboto; font-size: 14px;"><i>{{Teléfono de contacto}}</i></span><span style="font-weight: normal; font-family: Roboto; font-size: 14px;">&nbsp;</span></li><li style="text-align: justify; line-height: 1.2;"><span style="font-weight: normal; font-family: Roboto; font-size: 14px;">Email:&nbsp;</span><span style="font-family: Roboto; font-size: 14px;"><i>{{Email de contacto}}</i></span></li></ul><p style="text-align: justify; line-height: 1.2;"><span style="font-weight: normal; font-family: Roboto; font-size: 14px;">Atentamente:&nbsp;</span><span style="font-family: Roboto; font-size: 14px;"><i>{{Nombre del negocio}}</i></span></p><p style="text-align: justify; line-height: 1.2;"><span style="font-family: Roboto; font-size: 14px;"><br></span></p><p style="text-align: justify; line-height: 1.2;"><span style="font-family: Roboto; font-size: 14px; font-weight: normal;">Haciendo click sobre el enlace podrás obtener el comprobante mencionado.</span></p><p style="line-height: 1.2;"><span style="font-size: 12px;"><br></span></p><p style="text-align: justify; line-height: 1.2;"><span style="font-size: 12px; background-color: rgb(255, 255, 0);">VERIFICACIÓN DE TEXTO VARIABLE</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 12px; font-weight: normal; color: rgb(0, 49, 99);">{{Nombre del cliente}} =&gt; Nombre del cliente</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 12px; font-weight: normal; color: rgb(0, 49, 99);">{{Fecha}} =&gt; Fecha</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 12px; font-weight: normal; color: rgb(0, 49, 99);">{{Número}} =&gt; Número</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 12px; font-weight: normal; color: rgb(0, 49, 99);">{{Folio}} =&gt; Folio</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 12px; font-weight: normal; color: rgb(0, 49, 99);">{{Total}} =&gt; Total</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 12px; font-weight: normal; color: rgb(0, 49, 99);">{{Nombre del negocio}} =&gt; Nombre del negocio</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 12px; font-weight: normal; color: rgb(0, 49, 99);">{{Nombre de la sucursal}} =&gt; Nombre de la sucursal</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 12px; font-weight: normal; color: rgb(0, 49, 99);">{{Email de contacto}} =&gt; Email de contacto</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 12px; font-weight: normal; color: rgb(0, 49, 99);">{{Teléfono de contacto}} =&gt; Teléfono de contacto</span></p>^
        when "ac" then "Plantilla de email para acuses de cancelación"
          @asunto = "ENVÍO DEL ACUSE DE CANCELACIÓN"
          @mensaje = %Q^<p style="text-align: justify; line-height: 1.2;"><span style="font-weight: normal;"><font face="arial, sans-serif"><span style="font-size: 14px; letter-spacing: 0.12px; font-family: Roboto;">Hola&nbsp;</span></font></span><span style="font-family: Roboto; font-size: 14px;"><i>{{Nombre del cliente}}</i></span><span style="font-family: Roboto; letter-spacing: 0.12px; font-weight: normal; font-size: 14px;">,</span></p><p style="text-align: justify; line-height: 1.2;"><font face="arial, sans-serif" style="font-weight: normal;"><span style="font-size: 14px; font-family: Roboto;">En&nbsp;</span><span style="font-size: 14px; letter-spacing: 0.12px; font-family: Roboto;">el presente correo se adjunta el acuse de cancelación&nbsp;</span></font><span style="font-weight: normal; font-size: 14px; font-family: Roboto;">que fue expedida en nuestra sucursal</span><span style="font-weight: normal;"><span style="font-family: Roboto; font-size: 14px;">&nbsp;</span></span><span style="font-size: 14px; font-family: Roboto;"><i>{{Nombre de la sucursal}}</i></span><span style="font-weight: normal; font-size: 14px; font-family: Roboto;">&nbsp;</span><span style="font-weight: normal;"><span style="font-family: Roboto; font-size: 14px;">&nbsp;el</span><span style="font-family: Roboto; font-size: 14px;">&nbsp;día&nbsp;</span></span><span style="font-family: Roboto; font-size: 14px;"><i>{{Fecha}}</i></span><span style="font-weight: normal; font-family: Roboto; font-size: 14px;">.</span></p><p style="text-align: justify; line-height: 1.2;"><font face="Roboto"><span style="font-size: 14px; font-weight: normal; letter-spacing: 0.12px;">Para&nbsp;cualquier duda o aclaración por favor&nbsp;</span><span style="font-size: 14px; font-weight: 400; letter-spacing: 0.12px;">ponte</span><span style="font-size: 14px; font-weight: normal; letter-spacing: 0.12px;">&nbsp;en contacto a través de cualquiera de los siguientes dos medios de comunicación:</span></font></p><ul><li style="text-align: justify; line-height: 1.2;"><font face="Helvetica" style="font-weight: normal;"><span style="letter-spacing: 0.12px; font-family: Roboto; font-size: 14px;">Teléfono:&nbsp;&nbsp;</span></font><i><span style="font-family: Roboto; font-size: 14px;">{{Teléfono de contacto}}</span><span style="font-weight: normal; font-family: Roboto; font-size: 14px;">&nbsp;</span></i></li><li style="text-align: justify; line-height: 1.2;"><span style="font-weight: normal; font-family: Roboto; font-size: 14px;">Email:&nbsp;</span><span style="font-family: Roboto; font-size: 14px;"><i>{{Email de contacto}}</i></span></li></ul><p style="text-align: justify; line-height: 1.2;"><span style="font-weight: normal; font-family: Roboto; font-size: 14px;">Atentamente:&nbsp;</span><span style="font-family: Roboto; font-size: 14px;"><i>{{Nombre del negocio}}</i></span></p><p style="text-align: justify; line-height: 1.2;"><span style="font-family: Roboto; font-size: 14px;"><br></span></p><p style="text-align: justify; line-height: 1.2;"><span style="font-family: Roboto; font-size: 14px; font-weight: normal;">Haciendo click sobre el enlace podrás obtener el comprobante mencionado.</span></p><div><span style="font-family: Roboto; font-size: 14px; font-weight: normal;"><br></span></div><p style="text-align: justify; line-height: 1.2;"><span style="font-size: 12px;"><br></span></p><p style="text-align: justify; line-height: 1.2;"><span style="font-size: 12px; background-color: rgb(255, 255, 0);">VERIFICACIÓN DE TEXTO VARIABLE</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 12px; font-weight: normal; color: rgb(0, 49, 99);">{{Nombre del cliente}} =&gt; Nombre del cliente</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 12px; font-weight: normal; color: rgb(0, 49, 99);">{{Fecha}} =&gt; Fecha</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 12px; font-weight: normal; color: rgb(0, 49, 99);">{{Número}} =&gt; Número</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 12px; font-weight: normal; color: rgb(0, 49, 99);">{{Folio}} =&gt; Folio</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 12px; font-weight: normal; color: rgb(0, 49, 99);">{{Total}} =&gt; Total</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 12px; font-weight: normal; color: rgb(0, 49, 99);">{{Nombre del negocio}} =&gt; Nombre del negocio</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 12px; font-weight: normal; color: rgb(0, 49, 99);">{{Nombre de la sucursal}} =&gt; Nombre de la sucursal</span></p><p style="text-align: justify; line-height: 1;"><span style="font-size: 12px; font-weight: normal; color: rgb(0, 49, 99);">{{Email de contacto}} =&gt; Email de contacto</span></p><p style="text-align: justify; line-height: 1.2;"><span style="color: rgb(0, 49, 99); font-size: 12px; font-weight: normal;">{{Teléfono de contacto}} =&gt; Teléfono de contacto</span><span style="font-size: 12px;">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;</span></p>^
      end
      @plantillas_email.update(asunto_email: @asunto, msg_email: @mensaje)
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
      params.permit(:asunto_email, :summernote, :id)
    end
end
