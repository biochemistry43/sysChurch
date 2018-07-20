class NotaCreditosController < ApplicationController
  before_action :set_nota_credito, only: [:show, :edit, :update, :destroy, :imprimirpdf, :descargar_nota_credito, :mostrar_email_nota_credito, :enviar_nota_credito, :mostrar_email_cancelacion_nc, :cancelar_nota_credito]
  #before_action :set_sucursales, only: [:index, :consulta_avanzada]
  before_action :set_clientes, only: [:index, :consulta_por_fecha, :consulta_por_folio, :consulta_por_cliente]

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

  def consulta_por_folio
    @consulta = true
    @fechas = false
    @por_folio = true
    @avanzada = false
    @por_cliente= false

    if request.post?
      @folio_nc = params[:folio_nc]
      #@facturas = Factura.find_by folio: @folio_nc
      if can? :create, Negocio
        @nota_creditos = current_user.negocio.nota_creditos.where(folio: @folio_nc)
      else
        @nota_creditos = current_user.sucursal.nota_creditos.where(folio: @folio_nc)
      end
    end
  end

  def consulta_por_cliente
    @consulta = true
    @fechas = false
    @por_folio = false
    @avanzada = false
    @por_cliente= true

    if request.post?

      if can? :create, Negocio
        #@facturas = current_user.negocio.facturas.where(cliente_id: current_user.negocio.clientes.where(id:(DatosFiscalesCliente.find_by rfc: @rfc).cliente_id))
        if params[:rbtn] == "rbtn_rfc"
          #Se puede presentar el caso en el que un negocio tenga clientes con el mismo RFC y/o nombres fiscales iguales como datos de facturción.
          #El resultado de la búsqueda serían todas las facturas de los diferentes clientes con el RFC igual. (incluyendo el XAXX010101000)
          @rfc = params[:rfc]
          datos_fiscales_cliente = DatosFiscalesCliente.where rfc: @rfc
          #datos_fiscales_cliente = current_user.negocio.clientes.where(datos_fiscales_clientes rfc: @rfc
          clientes_ids = []
          datos_fiscales_cliente.each do |dfc|
            clientes_ids << dfc.cliente_id
          end
          #Se le pasa un arreglo con los ids para obtener las facturas de todos los clientes con el RFC =
          @nota_creditos = current_user.negocio.nota_creditos.where(cliente_id: clientes_ids)
          #cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
        elsif params[:rbtn] == "rbtn_nombreFiscal"
          #En el caso de la búsqueda por nombre fiscal... el resutado serán todas las facturas de un único cliente.
          datos_fiscales_cliente = DatosFiscalesCliente.find params[:cliente_id]
          @nombreFiscal = datos_fiscales_cliente.nombreFiscal
          cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
          @nota_creditos = current_user.negocio.nota_creditos.where(cliente_id: cliente)
        end

      else
        if params[:rbtn] == "rbtn_rfc"
          #Se puede presentar el caso en el que un negocio tenga clientes con el mismo RFC y/o nombres fiscales iguales como datos de facturción.
          #El resultado de la búsqueda serían todas las facturas de los diferentes clientes con el RFC igual. (incluyendo el XAXX010101000)
          @rfc = params[:rfc]
          datos_fiscales_cliente = current_user.sucursal.clientes.datos_fiscales_cliente.where rfc: @rfc
          clientes_ids = []
          datos_fiscales_cliente.each do |dfc|
            clientes_ids << dfc.cliente_id
          end
          @nota_creditos = current_user.sucursal.nota_creditos.where(cliente_id: clientes_ids)
          #cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
        elsif params[:rbtn] == "rbtn_nombreFiscal"
          #En el caso de la búsqueda por nombre fiscal... el resutado serán todas las facturas de un único cliente.
          datos_fiscales_cliente = DatosFiscalesCliente.find params[:cliente_id]
          @nombreFiscal = datos_fiscales_cliente.nombreFiscal
          cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
          @nota_creditos = current_user.sucursal.nota_creditos.where(cliente_id: cliente)
        end
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


    def descargar_nota_credito
      gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
      storage=gcloud.storage

      bucket = storage.bucket "cfdis"

      fecha_expedicion=@nota_credito.fecha_expedicion
      consecutivo =@nota_credito.consecutivo

      ruta_storage = @nota_credito.ruta_storage

      #Se descarga el pdf de la nube y se guarda en el disco
      file_name = "#{consecutivo}_#{fecha_expedicion}_NotaCrédito.xml"

      file_download_storage_xml = bucket.file "#{ruta_storage}_NotaCrédito.xml"

      file_download_storage_xml.download "public/#{file_name}"

      xml = File.open( "public/#{file_name}")
      send_file(
        xml,
        filename: "CFDI.xml",
        type: "application/xml"
      )
    end

    def enviar_nota_credito
      #Se optienen los datos que se ingresen o en su caso los datos de la configuracion del mensaje de los correos.
      if request.post?
        destinatario_final = params[:destinatario]

        if @nota_credito.estado_nc == "Activa"
           plantilla_email("nc")
        elsif @nota_credito.estado_nc == "Cancelada"
           plantilla_email("ac_nc")
        end

        ruta_storage_nc = @nota_credito.ruta_storage
        ruta_storage_fv = @nota_credito.factura.ruta_storage
        #Se descargan los archivos que el usuario haya indicado que se enviarán como archivos adjuntos
        gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
        storage=gcloud.storage

        bucket = storage.bucket "cfdis"

        fecha_expedicion_nc=@nota_credito.fecha_expedicion
        consecutivo_nc =@nota_credito.consecutivo
        file_name_nc = "#{consecutivo_nc}_#{fecha_expedicion_nc}"
        #Se dice que cundo se envia una nota de credito también se debe de enviar los comprobates de ingreso(facturas de vetas), para que el cliente compruebe la diferencia entre los montos.
        fecha_expedicion_fv= @nota_credito.factura.fecha_expedicion
        consecutivo_fv = @nota_credito.factura.consecutivo
        file_name_fv = "#{consecutivo_fv}_#{fecha_expedicion_fv}"


        comprobantes = {}
        if params[:pdf_nc] == "yes"
          comprobantes[:pdf_nc] = "public/#{file_name_nc}_NotaCrédito.pdf"
          file_download_storage_xml = bucket.file "#{ruta_storage_nc}_NotaCrédito.pdf"
          file_download_storage_xml.download "public/#{file_name_nc}_NotaCrédito.pdf"
        end

        if params[:xml_nc] == "yes"
          comprobantes[:xml_nc] = "public/#{file_name_nc}_NotaCrédito.xml"
          file_download_storage_xml = bucket.file "#{ruta_storage_nc}_NotaCrédito.xml"
          file_download_storage_xml.download "public/#{file_name_nc}_NotaCrédito.xml"
        end

        #Para enviar las facturas de ventas.
        if params[:pdf] == "yes"
          comprobantes[:pdf] = "public/#{file_name_fv}_RepresentaciónImpresa.pdf"
          file_download_storage_xml = bucket.file "#{ruta_storage_fv}_RepresentaciónImpresa.pdf"
          file_download_storage_xml.download "public/#{file_name_fv}_RepresentaciónImpresa.pdf"
        end
        if params[:xml] == "yes"
          comprobantes[:xml] = "public/#{file_name_fv}_CFDI.xml"
          file_download_storage_xml = bucket.file "#{ruta_storage_fv}_CFDI.xml"
          file_download_storage_xml.download "public/#{file_name_fv}_CFDI.xml"
        end
        #Solo cuando este cancelada
        if params[:xml_Ac_nc] == "yes"
          comprobantes[:xml_nc] = "public/#{file_name}_NotaCrédito.xml"
          file_download_storage_xml = bucket.file "#{ruta_storage}_NotaCrédito.xml"
          file_download_storage_xml.download "public/#{file_name}_NotaCrédito.xml"
        end


        #FacturasEmail.factura_email(@destinatario, @mensaje, @tema).deliver_now
        FacturasEmail.factura_email(destinatario_final, @mensaje, @asunto, comprobantes).deliver_now

        respond_to do |format|
          format.html { redirect_to action: "index"}
          flash[:notice] = "Los comprobantes se han enviado a #{destinatario}!"
          #format.html { redirect_to facturas_index_path, notice: 'No se encontró la factura, vuelva a intentarlo!' }
        end

      end
    end

    def mostrar_email_nota_credito
      #Solo se muestran los datos
      @destinatario = @nota_credito.cliente.email

      if @nota_credito.estado_nc == "Activa"
         plantilla_email("nc")
      elsif @nota_credito.estado_nc == "Cancelada"
         plantilla_email("ac_nc")
      end

    end

    #Para cancelar una nota de crédito de una perteneciente a una factura.
    def mostrar_email_cancelacion_nc
      plantilla_email("ac_nc")
      #@categorias_devolucion = current_user.negocio.cat_venta_canceladas
    end

    def cancelar_nota_credito
      #Primero se procede a cancelar y enviar el acuse de cancelación
      # Parametros para la conexión al Webservice
      wsdl_url = "https://staging.ws.timbox.com.mx/timbrado_cfdi33/wsdl"
      usuario = "AAA010101000"
      contrasena = "h6584D56fVdBbSmmnB"

      # Parametros para la cancelación del CFDI
      uuid = @nota_credito.folio_fiscal
      rfc = "AAA010101AAA"
      pfx_path = '/home/daniel/Documentos/timbox-ruby/archivoPfx.pfx'
      bin_file = File.binread(pfx_path)
      pfx_base64 = Base64.strict_encode64(bin_file)
      pfx_password = "12345678a"
      #Se cancela
      xml_cancelado = cancelar_cfdis usuario, contrasena, rfc, uuid, pfx_base64, pfx_password, wsdl_url
      #se extrae el acuse de cancelación del xml cancelado
      acuse = xml_cancelado.xpath("//acuse_cancelacion").text

      gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
      storage=gcloud.storage
      bucket = storage.bucket "cfdis"
      #Consultas
      ruta_storage = @nota_credito.ruta_storage
      fecha_expedicion=@nota_credito.fecha_expedicion
      consecutivo =@nota_credito.consecutivo
      file_name = "#{consecutivo}_#{fecha_expedicion}"
      #Se guarda el Acuse en la nube
      file = bucket.create_file StringIO.new(acuse.to_s), "#{ruta_storage}_AcuseDeCancelaciónNotaCrédito.xml"
      #Se cambia el estado de la factura de Activa a Cancelada. Las facturas con acciones
      @nota_credito.update( estado_nc: "Cancelada") #Pasa de activa a cancelada
      acuse = Nokogiri::XML(acuse)
      a = File.open("public/#{file_name}_AcuseDeCancelaciónNotaCrédito", "w")
      a.write (acuse)
      a.close

      #Se envia el acuse de cancelación al correo electrónico del fulano zutano perengano
      destinatario = params[:destinatario]
      #Aquí el mensaje de la configuración...
      mensaje = "HOLA cara de bola"
      tema = "Acuse de cancelación"
      comprobantes = {xml_Ac_nc: "public/#{file_name}_AcuseDeCancelaciónNotaCrédito"}

      FacturasEmail.factura_email(destinatario, mensaje, tema, comprobantes).deliver_now

      respond_to do |format| # Agregar mensajes después de las transacciones
        format.html { redirect_to nota_creditos_index_path, notice: "La nota de crédito con folio: #{@nota_credito.folio} ha sido cancelada y se ha enviado el acuse por email exitosamente!" }
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
    def set_clientes
      #
      @nombreFiscalClientes = DatosFiscalesCliente.where(cliente_id: current_user.negocio.clientes.where(negocio_id: current_user.negocio.id))
      #@clientes = current_user.negocio.clientes
    end
    #Esta función sirve para optener la plantilla de email de los comprobantes, según sus estatus
    #Solo funciona para facturas de ventas y para el envío de los acuses de cancelación de las mismas.
    def plantilla_email(opc)
      require 'plantilla_email/plantilla_email.rb'
      #Las 4 opciones posibles son:
        #fv => factura de venta
        #ac_fv => acuse de cancelación de factura de venta (Las facturas globales quedan excluidas)
        #ac_nc => acuse de cancelación de nota de crédito
        #nc => nota de crédito
    
      mensaje = current_user.negocio.plantillas_emails.find_by(comprobante: opc).msg_email
      asunto = current_user.negocio.plantillas_emails.find_by(comprobante: opc).asunto_email

      cadena = PlantillaEmail::AsuntoMensaje.new
      cadena.nombCliente = @nota_credito.cliente.nombre_completo #if mensaje.include? "{{Nombre del cliente}}"
      
      cadena.fechaNC = @nota_credito.fecha_expedicion
      cadena.numNC = @nota_credito.consecutivo
      cadena.folioNC = @nota_credito.folio
      cadena.totalNC = @nota_credito.monto
      
      cadena.fechaFact = @nota_credito.factura.fecha_expedicion
      cadena.numFact = @nota_credito.factura.consecutivo
      cadena.folioFact = @nota_credito.factura.folio
      cadena.totalFact = @nota_credito.factura.venta.montoVenta
      
      cadena.nombNegocio = @nota_credito.negocio.nombre 
      cadena.nombSucursal = @nota_credito.sucursal.nombre
      cadena.emailContacto = @nota_credito.sucursal.email
      cadena.telContacto = @nota_credito.sucursal.telefono

      @mensaje = cadena.reemplazar_texto(mensaje)
      @asunto = cadena.reemplazar_texto(asunto)

    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def nota_credito_params
      params.require(:nota_credito).permit(:folio, :fecha_expedicion, :monto_devolucion, :motivo, :user_id, :cliente_id, :sucursal_id, :negocio_id)
    end
end
