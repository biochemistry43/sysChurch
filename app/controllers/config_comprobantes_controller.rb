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
      require 'cfdi'
      require 'timbrado'

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


      #1.-CERTIFICADOS,  LLAVES Y CLAVES
      certificado = CFDI::Certificado.new '/home/daniel/Documentos/prueba/CSD01_AAA010101AAA.cer'
      # Esta se convierte de un archivo .key con:
      # openssl pkcs8 -inform DER -in someKey.key -passin pass:somePassword -out key.pem
      path_llave = "/home/daniel/Documentos/timbox-ruby/CSD01_AAA010101AAA.key.pem"
      password_llave = "12345678a"
      #openssl pkcs8 -inform DER -in /home/daniel/Documentos/prueba/CSD03_AAA010101AAA.key -passin pass:12345678a -out /home/daniel/Documentos/prueba/CSD03_AAA010101AAA.pem
      llave = CFDI::Key.new path_llave, password_llave

      #Lo siguiente no aplica en la configuración de un acuse de cancelación.
      #Se arma el xml con la configuración de la plantilla
      consecutivo = 1
      serie = params[:comprobante] == "f" ? current_user.sucursal.clave + "F" : current_user.sucursal.clave + "NC"
      fecha_expedicion = Time.now
      tipo_comprobante = params[:comprobante] == "f" ? "I" : "E"
      #Información general del comprobate
      comprobante = CFDI::Comprobante.new({
        serie: serie,
            folio: consecutivo,
            fecha: fecha_expedicion,
            #Deberá ser de tipo Egreso
            tipoDeComprobante: tipo_comprobante,
            #La moneda por default es MXN
            FormaPago: "01",
            #condicionesDePago: 'Sera marcada como pagada en cuanto el receptor haya cubierto el pago.',
            metodoDePago: "PUE", #Deberá ser PUE- Pago en una sola exhibición
            lugarExpedicion: current_user.sucursal.datos_fiscales_sucursal.codigo_postal,
            total: 2200.00
      })

      #Dirección del negocio
      datos_fiscales_negocio = current_user.negocio.datos_fiscales_negocio
      direccion_negocio = CFDI::DatosComunes::Domicilio.new({
        calle: datos_fiscales_negocio.calle,
        noExterior: datos_fiscales_negocio.numExterior,
        noInterior: datos_fiscales_negocio.numInterior,
        colonia: datos_fiscales_negocio.colonia,
        localidad: datos_fiscales_negocio.localidad,
        referencia: datos_fiscales_negocio.referencia,
        municipio: datos_fiscales_negocio.municipio,
        estado: datos_fiscales_negocio.estado,
        codigoPostal: datos_fiscales_negocio.codigo_postal
      })

      #Dirección de la sucursal
      datos_fiscales_sucursal = current_user.sucursal.datos_fiscales_sucursal
      if  current_user.sucursal
        direccion_sucursal = CFDI::DatosComunes::Domicilio.new({
          calle: datos_fiscales_sucursal.calle,
          noExterior: datos_fiscales_sucursal.numExt,
          noInterior: datos_fiscales_sucursal.numInt,
          colonia: datos_fiscales_sucursal.colonia,
          localidad: datos_fiscales_sucursal.localidad,
          referencia: datos_fiscales_sucursal.referencia,
          municipio: datos_fiscales_sucursal.municipio,
          estado: datos_fiscales_sucursal.estado,
          codigoPostal: datos_fiscales_sucursal.codigo_postal,
      })
      else
        expedidoEn= CFDI::DatosComunes::Domicilio.new({})
      end

      comprobante.emisor = CFDI::Emisor.new({
        rfc: datos_fiscales_negocio.rfc,
        nombre: datos_fiscales_negocio.nombreFiscal,
        regimenFiscal: datos_fiscales_negocio.regimen_fiscal.cve_regimen_fiscalSAT,
        domicilioFiscal: direccion_negocio,
        expedidoEn: direccion_sucursal
      })

      #Se cargan los mismo datos del receptor, aquí solo se trata de devolución y no de una nota de crédito para enmendar un error.
      #Atributos del receptor
      rfc_receptor = "XAXX010101000"
      nombre_fiscal_receptor = "Juan Pérez Martínez"
      #Al tratarse de un CFDI de egresos, no será un comprobante de deducción para el receptor, ya que se está emitiendo para disminuir el importe de un CFDI relacionado.
      #Por lo tanto el uso sera: G02 - Devoluciones, descuentos o bonificaciones

      comprobante.receptor = CFDI::Receptor.new({
        rfc: rfc_receptor,
        nombre: nombre_fiscal_receptor,
        UsoCFDI: "G02" #G02", #"Devoluciones, descuentos o bonificaciones" Aplica para persona fisica y moral
        #domicilioFiscal: domicilioReceptor
      })

      #Se le hace al cuento de mostrar unos cuantos conceptos con impuestos.
      comprobante.conceptos << CFDI::Concepto.new({
                        ClaveProdServ: "01010101", #Catálogo
                        NoIdentificacion: "PS01",
                        Cantidad: 1,
                        ClaveUnidad: "H87",#Catálogo
                        Unidad: "Pieza", #Es opcional para precisar la unidad de medida propia de la operación del emisor, pero pues...
                        Descripcion: "Producto ejemplo # 1", 
                        ValorUnitario: 1500.00,
                        Importe: 1500.00
                        })
      comprobante.conceptos << CFDI::Concepto.new({
                        ClaveProdServ: "01010101", #Catálogo
                        NoIdentificacion: "PS02",
                        Cantidad: 1,
                        ClaveUnidad: "H87",#Catálogo
                        Unidad: "Pieza", #Es opcional para precisar la unidad de medida propia de la operación del emisor, pero pues...
                        Descripcion: "Producto ejemplo # 2", 
                        ValorUnitario: 700.00,
                        Importe: 700.00
                        })

          #nota_credito.impuestos.traslados << CFDI::Impuesto::Traslado.new(base: base_gravable,

           #       tax: clave_impuesto, type_factor: "Tasa", rate: tasaOCuota, import: importe_impuesto_concepto.round(2), concepto_id: cont)

      if params[:comprobante] == "nc"
        comprobante.uuidsrelacionados << CFDI::Cfdirelacionado.new({
          uuid: "BC326044-500A-46AB-871A-A6649FCB4F20" #solo para hacerle al chango uaaa uaaa jaja
          })
        comprobante.cfdisrelacionados = CFDI::CfdiRelacionados.new({
          tipoRelacion: "03" # Devolución de mercancías sobre facturas o traslados previos
        })
      end

      total_letras = comprobante.total_to_words
      # Esto hace que se le agregue al comprobante el certificado y su número de serie (noCertificado)
      certificado.certifica comprobante
      #Se agrega el sello digital del comprobante, esto implica actulizar la fecha y calcular la cadena original
      xml_certificado_sellado = llave.sella comprobante

      #La configuración del comprobante
      #codigoQR = comprobante.qr_code xml_certificado_sellado
      cadOrigComplemento = " "#nota_credito.complemento.cadena_TimbreFiscalDigital
      logo = current_user.negocio.logo
      #No hay nececidad de darle a escoger el uso del cfdi al usuario.
      uso_cfdi_descripcion = "Devoluciones, descuentos o bonificaciones"
      #cve_descripcion_uso_cfdi_fg = "G02 - Devoluciones, descuentos o bonificaciones"
      cve_nombre_forma_pago = "#{} - #{}"
      #método de pago(clave y descripción)
      #"deberá de ser siempre.. PUE"
      cve_nombre_metodo_pago = "PUE - Pago en una sola exhibición"
      #Regimen fiscal
      cve_regimen_fiscalSAT = current_user.negocio.datos_fiscales_negocio.regimen_fiscal.cve_regimen_fiscalSAT
      nomb_regimen_fiscalSAT = current_user.negocio.datos_fiscales_negocio.regimen_fiscal.nomb_regimen_fiscalSAT
      cve_nomb_regimen_fiscalSAT = "#{cve_regimen_fiscalSAT} - #{nomb_regimen_fiscalSAT}"
      #Para el nombre del changarro feo jajaja
      nombre_negocio = current_user.negocio.nombre

      #Se pasa un hash con la información extra en la representación impresa como: datos de contacto, dirección fiscal y descripcion de la clave de los catálogos del SAT.
      hash_info = {xml_copia: Nokogiri::XML(xml_certificado_sellado),# codigoQR: codigoQR,
       logo: logo, cadOrigComplemento: cadOrigComplemento, 
       uso_cfdi_descripcion: uso_cfdi_descripcion, cve_nombre_forma_pago: cve_nombre_forma_pago, cve_nombre_metodo_pago: cve_nombre_metodo_pago, cve_nomb_regimen_fiscalSAT:cve_nomb_regimen_fiscalSAT, nombre_negocio: nombre_negocio,
        tipo_fuente: @tipo_fuente, tam_fuente: @tam_fuente, color_fondo:@color_fondo, color_banda:@color_banda, color_titulos:@color_titulos,
        tel_negocio: current_user.negocio.telefono, email_negocio: current_user.negocio.email, pag_web_negocio: current_user.negocio.pag_web
      }
         
      hash_info[:tel_sucursal] = current_user.sucursal.telefono
      hash_info[:email_sucursal] = current_user.sucursal.email
        
      #Se genera el pdf paramostrarlo al pulsar el botón de la vista previa
      xml_rep_impresa = comprobante.add_elements_to_xml(hash_info)
      template = Nokogiri::XSLT(File.read('/home/daniel/Vídeos/sysChurch/lib/XSLT.xsl'))
      html_document = template.transform(xml_rep_impresa)
      #File.open('/home/daniel/Documentos/timbox-ruby/CFDImpreso.html', 'w').write(html_document)
      pdf = WickedPdf.new.pdf_from_string(html_document)
      
      #Se guarda el pdf para poder visualizarlo 
      nomb_negocio = current_user.negocio.nombre
      #Se guarda el pdf 
      save_path = Rails.root.join('public',"#{nomb_negocio}.pdf")
      File.open(save_path, 'wb') do |file|
        file << pdf
      end
      
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
    @nomb_negocio = current_user.negocio.nombre

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
