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

      @consulta = true
      @config_comprobante = current_user.negocio.config_comprobantes.find_by(comprobante: params[:comprobante])
     
      #Se extraen los valores de la plantilla de impresión
      @tipo_fuente = @config_comprobante.tipo_fuente
      @tam_fuente = @config_comprobante.tam_fuente
      @color_fondo = @config_comprobante.color_fondo
      @color_titulos = @config_comprobante.color_titulos
      @color_banda = @config_comprobante.color_banda

      if @config_comprobante.comprobante == "fv"
        leyenda = "Facturas de ventas"
      elsif @config_comprobante.comprobante == "fg"
        leyenda = "Facturas globales"
      elsif @config_comprobante.comprobante == "nc"
        leyenda = "Notas de crédito"
      elsif @config_comprobante.comprobante == "ac"
        leyenda = "Acuses de cancelación"
      end
      @nombre_plantilla = leyenda

      set_vista_previa(@tipo_fuente, @tam_fuente, @color_fondo, @color_titulos, @color_banda)

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

    if @config_comprobante.comprobante == "fv"
      leyenda = "Facturas de ventas"
    elsif @config_comprobante.comprobante == "fg"
      leyenda = "Facturas globales"
    elsif @config_comprobante.comprobante == "nc"
      leyenda = "Notas de crédito"
    elsif @config_comprobante.comprobante == "ac"
      leyenda = "Acuses de cancelación"
    end
    @nombre_plantilla = leyenda
    @nomb_negocio = current_user.negocio.nombre

    if params[:commit] == "Previsualizar en PDF"

      @color_fondo = params[:color_fondo]
      @color_banda = params[:color_banda]
      @color_titulos = params[:color_titulos]
      @tipo_fuente = params[:tipo_fuente]
      @tam_fuente = params[:tam_fuente]

      set_vista_previa(@tipo_fuente, @tam_fuente, @color_fondo, @color_titulos, @color_banda)

       respond_to do |format|
        format.html { redirect_to action: "mostrar_plantilla", notice: 'La plantilla de impresión fue actualizada correctamente!' }
        format.js
      end

    elsif params[:commit] == "Configuración recomendada"

      @color_fondo = "#323639"
      @color_banda = "#525659"
      @color_titulos = "#ffffff"
      @tipo_fuente = "Times New Roman, Times, serif"
      @tam_fuente = "Normal"

      set_vista_previa(@tipo_fuente, @tam_fuente, @color_fondo, @color_titulos, @color_banda)

      respond_to do |format|
        if @config_comprobante.update(tipo_fuente: @tipo_fuente, tam_fuente: @tam_fuente, color_fondo: @color_fondo, color_titulos: @color_titulos, color_banda: @color_banda )
          format.html { redirect_to action: "mostrar_plantilla", notice: 'Se ha establecido la configuración recomendada para la plantilla de impresión seleccionada!' }
          format.js
        else
          format.html { redirect_to action: "mostrar_plantilla", notice: 'La plantilla de impresión no se pudo guardar!'}
        end
      end

    elsif params[:commit] == "Guardar cambios"

      @color_fondo = params[:color_fondo]
      @color_banda = params[:color_banda]
      @color_titulos = params[:color_titulos]
      @tipo_fuente = params[:tipo_fuente]

      @tam_fuente = params[:tam_fuente]

      set_vista_previa(@tipo_fuente, @tam_fuente, @color_fondo, @color_titulos, @color_banda)

      respond_to do |format|
        if @config_comprobante.update(tipo_fuente: @tipo_fuente, tam_fuente: @tam_fuente, color_fondo: @color_fondo, color_titulos: @color_titulos, color_banda: @color_banda )
          format.html { redirect_to action: "mostrar_plantilla", notice: 'La plantilla de impresión fue actualizada correctamente!' }
          format.js
        else
          format.html { redirect_to action: "mostrar_plantilla", notice: 'La plantilla de impresión no se pudo guardar!'}
        end
      end

    elsif params[:commit] == "Cancelar"
        
      @color_fondo = @config_comprobante.color_fondo
      @color_banda = @config_comprobante.color_banda
      @color_titulos = @config_comprobante.color_titulos
      @tipo_fuente = @config_comprobante.tipo_fuente
      @tam_fuente = @config_comprobante.tam_fuente

      set_vista_previa(@tipo_fuente, @tam_fuente, @color_fondo, @color_titulos, @color_banda)
        
      respond_to do |format|
      #if @config_comprobante.update(tipo_fuente: @tipo_fuente, tam_fuente: @tam_fuente, color_fondo: @color_fondo, color_titulos: @color_titulos, color_banda: @color_banda )
        format.html { redirect_to action: "mostrar_plantilla", notice: 'La plantilla de impresión fue cancelada!' }
        format.js
      end
      #else
        #format.html { redirect_to action: "mostrar_plantilla", notice: 'La plantilla de impresión no se pudo guardar!'}
      #end
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

    def set_vista_previa(tipo_fuente, tam_fuente, color_fondo, color_titulos, color_banda)
      #Lo siguiente no aplica en la configuración de un acuse de cancelación.
      #Se arma el xml con la configuración de la plantilla
      tipo_documento = params[:comprobante]
      if tipo_documento == "fv"
          serie = current_user.sucursal.clave + "FV" 
          tipo_comprobante = "I"
      elsif tipo_documento == "fg"
          serie = current_user.sucursal.clave + "FG" 
          tipo_comprobante = "I"
      elsif tipo_documento == "nc"
          serie = current_user.sucursal.clave + "NC"
          tipo_comprobante = "E"
      elsif tipo_documento == "ac"
          serie = current_user.sucursal.clave + "AC" 
          tipo_comprobante = "I"
      end
     
      unless tipo_documento == "ac"
        consecutivo = 1
        fecha_expedicion = Time.now
        #Información general del comprobate
        comprobante = CFDI::Comprobante.new({
          serie: serie,
              folio: consecutivo,
              fecha: fecha_expedicion,
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

        rfc_receptor = "XAXX010101000"
        nombre_fiscal_receptor = tipo_documento == "fg" ? "Público en general" : "Juan Pérez Martínez" 
        uso_cfdi = tipo_comprobante == "I" ? "P01 - Por definir" : "G02 - Devoluciones, descuentos o bonificaciones"
        comprobante.receptor = CFDI::Receptor.new({
          rfc: rfc_receptor,
          nombre: nombre_fiscal_receptor,
          UsoCFDI: uso_cfdi #G02", #"Devoluciones, descuentos o bonificaciones" Aplica para persona fisica y moral
          #domicilioFiscal: domicilioReceptor
        })

        #Se le hace al cuento de mostrar unos cuantos conceptos con impuestos
        if tipo_documento == "fg" 
          comprobante.conceptos << CFDI::Concepto.new({
            #Clave de Producto o Servicio: 01010101 (Por Definir)
            ClaveProdServ: "01010101", #CATALOGO
            #En un CFDI normal es la clave interna que se le asigna a los productos pero que ni la ocupo por el momento...
            #Peo para un comprobante simplificado ess el Número de Identificación: En él se pondrá el número de folio del ticket de venta o número de operación del comprobante, este puede ser un valor alfanumérico de 1 a 20 dígitos.
            NoIdentificacion: "FV52887",
            #Cantidad: Se debe incluir el valor “1″.
            Cantidad: 1 ,
            #Clave Unidad de Medida: Se debe incluir la clave “ACT” (Actividad).
            ClaveUnidad: "ACT",
            #Unidad de medida: No debe existir el campo.
            #Descripción: Debe tener el texto “Venta“.
            Descripcion: "Venta",
            ValorUnitario: 1500.00,
            Importe: 1500.00
            })

            comprobante.conceptos << CFDI::Concepto.new({
            ClaveProdServ: "01010101", #CATALOGO
            NoIdentificacion: "FV76839",
            Cantidad: 1 ,
            ClaveUnidad: "ACT",
            Descripcion: "Venta",
            ValorUnitario: 700.00,
            Importe: 700.00
            })

        else
          comprobante.conceptos << CFDI::Concepto.new({
                            ClaveProdServ: "01010101",
                            NoIdentificacion: "PS01",
                            Cantidad: 1,
                            ClaveUnidad: "H87",
                            Unidad: "Pieza", 
                            Descripcion: "Producto ejemplo # 1", 
                            ValorUnitario: 1500.00,
                            Importe: 1500.00
                            })

          comprobante.conceptos << CFDI::Concepto.new({
                            ClaveProdServ: "01010101",
                            NoIdentificacion: "PS02",
                            Cantidad: 1,
                            ClaveUnidad: "H87",
                            Unidad: "Pieza",
                            Descripcion: "Producto ejemplo # 2", 
                            ValorUnitario: 700.00,
                            Importe: 700.00
                            })
        end

        #nota_credito.impuestos.traslados << CFDI::Impuesto::Traslado.new(base: base_gravable,
             #tax: clave_impuesto, type_factor: "Tasa", rate: tasaOCuota, import: importe_impuesto_concepto.round(2), concepto_id: cont)

        if @config_comprobante.comprobante == "nc"
          comprobante.uuidsrelacionados << CFDI::Cfdirelacionado.new({
            uuid: "BC326044-500A-46AB-871A-A6649FCB4F20" #solo para hacerle al chango uaaa uaaa jaja
            })
          comprobante.cfdisrelacionados = CFDI::CfdiRelacionados.new({
            tipoRelacion: "03" # Devolución de mercancías sobre facturas o traslados previos
          })
        end

        total_letras = comprobante.total_to_words
        xml_certificado_sellado = comprobante.comprobante_to_xml

        #La configuración del comprobante
        #codigoQR = comprobante.qr_code xml_certificado_sellado
        cadOrigComplemento = " "#nota_credito.complemento.cadena_TimbreFiscalDigital
        logo = current_user.negocio.logo
        #No hay nececidad de darle a escoger el uso del cfdi al usuario.
        uso_cfdi_descripcion = "Devoluciones, descuentos o bonificaciones"
        #cve_descripcion_uso_cfdi_fg = "G02 - Devoluciones, descuentos o bonificaciones"
        cve_nombre_forma_pago = "01 - Efectivo"
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
        hash_info = {xml_copia: Nokogiri::XML(xml_certificado_sellado), codigoQR: "",
         logo: logo, cadOrigComplemento: cadOrigComplemento, 
         uso_cfdi_descripcion: uso_cfdi_descripcion, cve_nombre_forma_pago: cve_nombre_forma_pago, cve_nombre_metodo_pago: cve_nombre_metodo_pago, cve_nomb_regimen_fiscalSAT:cve_nomb_regimen_fiscalSAT, nombre_negocio: nombre_negocio,
          tipo_fuente: @tipo_fuente, tam_fuente: @tam_fuente, color_fondo:@color_fondo, color_banda:@color_banda, color_titulos:@color_titulos,
          tel_negocio: current_user.negocio.telefono, email_negocio: current_user.negocio.email, pag_web_negocio: current_user.negocio.pag_web
        }
           
        hash_info[:tel_sucursal] = current_user.sucursal.telefono
        hash_info[:email_sucursal] = current_user.sucursal.email
          

        #Se genera el pdf paramostrarlo al pulsar el botón de la vista previa
        xml_rep_impresa = comprobante.add_elements_to_xml(hash_info)
        if tipo_documento == "fv"
          template = Nokogiri::XSLT(File.read('/home/daniel/Vídeos/sysChurch/lib/Plantilla de facturas de ventas.xsl'))
        elsif tipo_documento == "fg"
          template = Nokogiri::XSLT(File.read('/home/daniel/Vídeos/sysChurch/lib/Plantilla de facturas globales.xsl'))
        elsif tipo_documento == "nc"
          template = Nokogiri::XSLT(File.read('/home/daniel/Vídeos/sysChurch/lib/Plantilla de notas de crédito.xsl'))
        end
      else
        #Un ejemplo de acuse del ambiente de prueba de TIMBOX para poder generar la represenación impresa del
        acuse = %Q^<Acuse Fecha="2018-08-16T22:56:10" RfcEmisor="AAA010101AAA">
                      <Folios>
                      <UUID>8C366672-968E-4DF9-A089-4FADB0DE27DC</UUID>
                      <EstatusUUID>201</EstatusUUID>
                      </Folios>
                      <Signature xmlns="http://www.w3.org/2000/09/xmldsig#" Id="SelloSAT">
                      <SignedInfo>
                      <CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
                      <SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#hmac-sha512"/>
                      <Reference URI="">
                      <Transforms>
                      <Transform Algorithm="http://www.w3.org/TR/1999/REC-xpath-19991116">
                      <XPath>not(ancestor-or-self::*[local-name()='Signature'])</XPath>
                      </Transform>
                      </Transforms>
                      <DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha512"/>
                      <DigestValue>
                      ML2rVJ79GS6cQNjRI7wmoRu5aFykTgian5alYvohYhR5Dh3QB43LX1RadDFutgMIM3q60LozLGdtmLVDdnhZsg==
                      </DigestValue>
                      </Reference>
                      </SignedInfo>
                      <SignatureValue>
                      lO73l44krAoObyw+HGI/ychDJa3PpxiqDWZ0tLqUrhDj0E4Dv5mWE1t4wzOST26zJENixF4ZBGAk8Jj+fM8Kuw==
                      </SignatureValue>
                      <KeyInfo>
                      <KeyName>00001088888800000016</KeyName>
                      <KeyValue>
                      <RSAKeyValue>
                      <Modulus>
                      xnL2zDPtH5jDsAZDTIfMqbKGrve+At8Kyx2EZvbfXbpK9uVExWS874oMelFzNq69/YqSReT3I7I8wr+joy5O7ouZH+4KWdIGp4Si6lHe0kntxzNmuuKyOPkJ9tMcntnFmQ4bfxFxlg/Ud2hCtuoy3j2xYkIXu5O4pGM98Nz8pAM=
                      </Modulus>
                      <Exponent>AQAB</Exponent>
                      </RSAKeyValue>
                      </KeyValue>
                      </KeyInfo>
                      </Signature>
                      </Acuse>
        ^

        fecha_expedicion = Time.now

        xml_acuse = Nokogiri::XML(acuse)
        Nokogiri::XML::Builder.with(xml_acuse.at('Acuse')) do |xml|
          # ... Use normal builder methods here ...
          xml.RepresentacionImpresa { 
            xml.Plantilla({TipoFuente: tipo_fuente, TamFuente: tam_fuente, ColorFondo: color_fondo, ColorBanda: color_banda, ColorTitulos: color_titulos})
            xml.DatosInternosSistema({Folio: 934287, Serie: "ACFV", FechaExpedicion: fecha_expedicion, Comprobante: "Factura de venta"})
          } # add the "awesome" tag below "some_tag"
        end

        template = Nokogiri::XSLT(File.read('/home/daniel/Vídeos/sysChurch/lib/Plantilla de acuses de cancelación.xsl'))

        xml_rep_impresa = Nokogiri::XML(acuse)
        #Un acuse no necesita demaciada información(direcciones o desglose de la factura cancelada), almenos que algún cliente feo lo solicite, sería raro, pero en este mundo hay de todo jajaja.
        template = Nokogiri::XSLT(File.read('/home/daniel/Vídeos/sysChurch/lib/Plantilla de acuses de cancelación.xsl'))
      end

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

    # Never trust parameters from the scary internet, only allow the white list through.
    def config_comprobante_params
      params.permit(:comprobante, :tipo_fuente, :tam_fuente, :color_fondo, :color_titulos, :color_banda, :negocio_id)
      #params.require(:config_comprobante).permit(:comprobante, :tipo_fuente, :tam_fuente, :color_fondo, :color_titulos, :color_banda, :negocio_id)
    end
end
