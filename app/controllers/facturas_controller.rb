class FacturasController < ApplicationController
  before_action :set_factura, only: [:show, :edit, :update, :destroy, :readpdf, :enviar_email,:enviar_email_post, :descargar_cfdis, :cancelar_cfdi]
  #before_action :set_facturaDeVentas, only: [:show]
  #before_action :set_cajeros, only: [:index, :consulta_facturas, :consulta_avanzada, :consulta_por_folio, :consulta_por_cliente]
  before_action :set_sucursales, only: [:index, :consulta_facturas, :consulta_avanzada, :consulta_por_folio, :consulta_por_cliente]
  before_action :set_clientes, only: [:index, :consulta_facturas, :consulta_avanzada, :consulta_por_folio, :consulta_por_cliente]

  #sirve para buscar la venta y mostrar los resultados antes de facturar.
  def buscarVentaFacturar
    @consulta = false
    if request.post?
      #si existe una venta con el folio solicitado, despliega una sección con los detalles en la vista
      @venta = Venta.find_by :folio=>params[:folio]
      if @venta
        venta_id = @venta.id
        redirect_to action: "mostrarDetallesVenta", id: venta_id
      else
        redirect_to action:"buscarVentaFacturar"
      end
    end
  end

  def mostrarDetallesVenta
    @venta = Venta.find(params[:id]) if params.key?(:id)

    @@venta = @venta
    @consulta = true #determina si se realizó una consulta
    #EMISOR
    #La venta debe de ser del mismo negocio o mostrará que no hay ventas registradas con X folio de venta
    if @venta && current_user.negocio.id == @venta.negocio.id
      #blank lo contrario de presentar
      #Una venta solo se puede facturar una vez
      @ventaFacturadaNoSi=@venta.factura.blank?
      @ventaCancelada=@venta.status.eql?("Cancelada")

      #Por si a alguien se le ocurre querer facturar una venta cancelada jajaja
      #if @ventaCancelada
       #@fechaVentaCancelada=current_user.negocio.venta_canceladas.where("venta"=>@venta).fecha
      #end
      unless @ventaFacturadaNoSi
        @fechaVentaFacturada = @venta.factura.fecha_expedicion
        @folioVentaFacturada = @venta.factura.folio #Folio de la factura de la venta
      end

      @consecutivo = 0
      if current_user.sucursal.facturas.last
        @consecutivo = current_user.sucursal.facturas.last.consecutivo
        if @consecutivo
          @consecutivo += 1
        end
      else
        @consecutivo = 1 #Se asigna el número a la factura por default o de acuerdo a la configuración del usuario.
      end
      #Temporalmente...
      if current_user.sucursal.clave.present?
        claveSucursal = current_user.sucursal.clave
        @serie = claveSucursal + "F"
      else
        folio_default="F"
        @serie = folio_default
      end
      #RECEPTOR
      @rfc_emisor_present=@venta.cliente.rfc.present?
      @rfc_receptor_f=@venta.cliente.datos_fiscales_cliente.rfc
      @nombre_fiscal_receptor_present=@venta.cliente.nombreFiscal.present?
      @nombre_fiscal_receptor_f=@venta.cliente.datos_fiscales_cliente.nombreFiscal
      @email_receptor = @venta.cliente.email

      @calle_receptor_f = @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.calle : " "
      @noInterior_receptor_f = @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.numInterior : " "
      @noExterior_receptor_f = @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.numExterior : " "
      @colonia_receptor_f = @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.colonia : " "
      @localidad_receptor_f = @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.localidad : " "
      @municipio_receptor_f = @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.municipio : " "
      @estado_receptor_f = @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.estado : " "
      #@referencia_referencia_f =  @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.referencia : " "
      @cp_receptor_f = @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.codigo_postal : " "


      #@nombre_receptor_f=@venta.cliente.nombre_completo
      #@correo_electonico_f=@venta.cliente.enviar_al_correo
      @uso_cfdi_receptor_f=UsoCfdi.all #@venta.cliente.uso_cfdi

      #COMPROBANTE
      #@c_unidadMedida_f=current_user.negocio.unidad_medidas.clave

      #para mostrar el subtotal.
      @subtotal = 0.00
      @iva =0.00
      @ieps = 0.00
      @itemsVenta = @venta.item_ventas
      @itemsVenta.each do |c|
        importe_concepto = (c.precio_venta * c.cantidad) #Incluye impuestos(si esq), descuentos(si esq)...
        if c.articulo.impuesto.present? #No imposta de que tipo de impuestos sean
          tasaOCuota = (c.articulo.impuesto.porcentaje / 100) #Se obtiene la tasa o cuota por ej. 16% => 0.160000
          #Se calcula el precio bruto de cada concepto
          base_gravable = (importe_concepto / (tasaOCuota + 1)) #Se obtiene el precio bruto por item de venta
          importe_impuesto_concepto = (base_gravable * tasaOCuota)
          #valorUnitario = base_gravable / c.cantidad
          @subtotal += base_gravable

          if c.articulo.impuesto.tipo == "Federal"
            if c.articulo.impuesto.nombre == "IVA"
              @iva = @iva += importe_impuesto_concepto
            elsif c.articulo.impuesto.nombre == "IEPS"
              @ieps = importe_impuesto_concepto
            end
            #Los locales que show? luego luego jaja
          end
        else
          @subtotal += importe_concepto
        end
      end
      #@iva = '%.2f' % @iva.round(2)
      #@ieps = '%.2f' % @ieps.round(2)
      @subtotal = '%.2f' % @subtotal.round(2)
      #@descuento_string = '%.2f' % descuento.round(2)
      #por el momento el descuento es:
      descuento = 0.00
      @descuento_string = '%.2f' % descuento.round(2)
      @total_string = '%.2f' % @venta.montoVenta.round(2)

      #decimal = format('%.2f', @venta.montoVenta).split('.')
      decimal = '%.2f' %  @venta.montoVenta.round(2)
      @total_en_letras="( #{@venta.montoVenta.to_words.upcase} PESOS #{decimal[1]}/100 M.N.)"
      @fechaVenta=  @venta.fechaVenta

      #@itemsVenta  = @venta.item_ventas
      @@itemsVenta=@itemsVenta
    else
      @folio = @venta.folio
    end
  end

  def facturarVenta
    #POST
    if request.post?
      require 'cfdi'
      require 'timbrado'
      if params[:commit] == "Cancelar"
        @venta=nil #Se borran los datos por si el usuario le da "atras" en el navegador.
        redirect_to facturas_index_path
      else
        @venta = Venta.find(params[:id]) if params.key?(:id)
        #1.- CERTIFICADOS,  LLAVES Y CLAVES
        certificado = CFDI::Certificado.new '/home/daniel/Documentos/prueba/CSD01_AAA010101AAA.cer'
        # Esta se convierte de un archivo .key con:
        # openssl pkcs8 -inform DER -in someKey.key -passin pass:somePassword -out key.pem
        llave = "/home/daniel/Documentos/timbox-ruby/CSD01_AAA010101AAA.key.pem"
        pass_llave = "12345678a"
        #openssl pkcs8 -inform DER -in /home/daniel/Documentos/prueba/CSD03_AAA010101AAA.key -passin pass:12345678a -out /home/daniel/Documentos/prueba/CSD03_AAA010101AAA.pem
        #llave2 = CFDI::Key.new llave, pass_llave

        #Para obtener el numero consecutivo a partir de la ultima factura o de lo contrario asignarle por primera vez un número
        consecutivo = 0
        if current_user.sucursal.facturas.last
          consecutivo = current_user.sucursal.facturas.last.consecutivo
          if consecutivo
            consecutivo += 1
          end
        else
          consecutivo = 1 #Se asigna el número a la factura por default o de acuerdo a la configuración del usuario.
        end

        if current_user.sucursal.clave.present?
          #El folio de las facturas se forma por defecto por la clave de las sucursales, pero si el usuario quiere establecer sus propias series para otro fin, se tomará la serie que el usuario indique en las configuración de Facturas y Notas
          #claveSucursal = current_user.sucursal.clave
          claveSucursal = current_user.sucursal.clave
          folio_registroBD = claveSucursal + "F"
          folio_registroBD << consecutivo.to_s
          serie = claveSucursal + "F"
        else
          folio_default="F"
          folio_registroBD =folio_default
          #Una serie por default les guste o no les guste, pero útil para que no se produzca un colapso
          serie = folio_default
        end

      fecha_expedicion_f = Time.now
      forma_pago_f = FacturaFormaPago.find(params[:forma_pago_id])
      metodo_pago_f = params[:metodo_pago] == "PUE - Pago en una sola exhibición" ? "PUE" : "PPD"
      #2.- LLENADO DEL XML DIRECTAMENTE DE LA BASE DE DATOS
      factura = CFDI::Comprobante.new({
        serie: serie,
        folio: consecutivo,
        fecha: fecha_expedicion_f,
        #Por defaulf el tipo de comprobante es de tipo "I" Ingreso
        #La moneda por default es MXN
        #formaDePago: @venta.venta_forma_pago.forma_pago.clave
        FormaPago: forma_pago_f.cve_forma_pagoSAT,#CATALOGO Es de tipo string
        condicionesDePago: 'Sera marcada como pagada en cuanto el receptor haya cubierto el pago.',
        metodoDePago: metodo_pago_f, #CATALOGO
        lugarExpedicion: current_user.sucursal.codigo_postal,#current_user.negocio.datos_fiscales_negocio.codigo_postal,#, #CATALOGO
        #total: 27.84#Como que ya es hora de pasarle el monto total de la venta más los impustos jaja para no usar calculadora
        total: '%.2f' % @venta.montoVenta.round(2)
        #total:40.88
        #Descuento:0 #DESCUENTO RAPPEL
      })
      #Estos datos no son requeridos por el SAT, sin embargo se usaran para la representacion impresa de los CFDIs.*
      #DATOS DEL EMISOR
      hash_domicilioEmisor = {}
      if current_user.negocio.datos_fiscales_negocio
        hash_domicilioEmisor[:calle] = current_user.negocio.datos_fiscales_negocio.calle ? current_user.negocio.datos_fiscales_negocio.calle : " "
        hash_domicilioEmisor[:noExterior] = current_user.negocio.datos_fiscales_negocio.numExterior ? current_user.negocio.datos_fiscales_negocio.numExterior : " "
        hash_domicilioEmisor[:noInterior] = current_user.negocio.datos_fiscales_negocio.numInterior ? current_user.negocio.datos_fiscales_negocio.numInterior : " "
        hash_domicilioEmisor[:colonia] = current_user.negocio.datos_fiscales_negocio.colonia ? current_user.negocio.datos_fiscales_negocio.colonia : " "
        #localidad: current_user.negocio.datos_fiscales_negocio.,
        #referencia: current_user.negocio.datos_fiscales_negocio.,
        hash_domicilioEmisor[:municipio] = current_user.negocio.datos_fiscales_negocio.municipio ? current_user.negocio.datos_fiscales_negocio.municipio : " "
        hash_domicilioEmisor[:estado] = current_user.negocio.datos_fiscales_negocio.estado ? current_user.negocio.datos_fiscales_negocio.estado : " "
        #pais: current_user.negocio.datos_fiscales_negocio.,
        hash_domicilioEmisor[:codigoPostal] = current_user.negocio.datos_fiscales_negocio.codigo_postal ? current_user.negocio.datos_fiscales_negocio.estado : " "
      end
      domicilioEmisor = CFDI::DatosComunes::Domicilio.new(hash_domicilioEmisor)

      #III. Sí se tiene más de un local o establecimiento, se deberá señalar el domicilio del local o
      #establecimiento en el que se expidan las Facturas Electrónicas
      #Estos datos no son requeridos por el SAT, sin embargo se usaran para la representacion impresa de los CFDIs.*

      expedidoEn= CFDI::DatosComunes::Domicilio.new({
        #Estos datos los uso como datos fiscales, sin current_user.sucursal.codigo_postalembargo si se hara distinción entre direccion comun y dirección fiscal,
        #se debera corregir.
        calle: current_user.sucursal.calle,
        noExterior: current_user.sucursal.numExterior,
        noInterior: current_user.sucursal.numInterior,
        colonia: current_user.sucursal.colonia,
        #localidad: current_user.negocio.datos_fiscales_negocio.,
        #referencia: current_user.negocio.datos_fiscalecurrent_user.sucursal.codigo_postals_negocio.,
        municipio: current_user.sucursal.municipio,
        estado: current_user.sucursal.estado,
        #pais: current_user.negocio.datos_fiscales_negocio.,
        codigoPostal: current_user.sucursal.codigo_postal
      })

      factura.emisor = CFDI::Emisor.new({
        #rfc: 'AAA010101AAA',
        rfc: current_user.negocio.datos_fiscales_negocio.rfc,
        nombre: current_user.negocio.datos_fiscales_negocio.nombreFiscal,
        regimenFiscal: current_user.negocio.datos_fiscales_negocio.regimen_fiscal, #CATALOGO
        domicilioFiscal: domicilioEmisor,
        expedidoEn: expedidoEn
      })
      #Estos datos no son requeridos por el SAT, sin embargo se usaran para la representacion impresa de los CFDIs.*
      hash_domicilioReceptor = {}
      if @venta.cliente.datos_fiscales_cliente
        hash_domicilioReceptor[:calle] = @venta.cliente.datos_fiscales_cliente.calle ? @venta.cliente.datos_fiscales_cliente.calle : " "
        hash_domicilioReceptor[:noExterior] = @venta.cliente.datos_fiscales_cliente.numExterior ? @venta.cliente.datos_fiscales_cliente.numExterior : " "
        hash_domicilioReceptor[:noInterior] = @venta.cliente.datos_fiscales_cliente.numInterior ? @venta.cliente.datos_fiscales_cliente.numInterior :  " "
        hash_domicilioReceptor[:colonia] = @venta.cliente.datos_fiscales_cliente.colonia ? @venta.cliente.datos_fiscales_cliente.numInterior : " "
        hash_domicilioReceptor[:localidad] = @venta.cliente.datos_fiscales_cliente.localidad ? @venta.cliente.datos_fiscales_cliente.localidad : " "
        #referencia: current_user.negocio.datos_fiscales_negocio.,
        hash_domicilioReceptor[:municipio] = @venta.cliente.datos_fiscales_cliente.municipio ? @venta.cliente.datos_fiscales_cliente.municipio  : " "
        hash_domicilioReceptor[:estado] = @venta.cliente.datos_fiscales_cliente.estado ? @venta.cliente.datos_fiscales_cliente.estado : " "     #pais: current_user.negocio.datos_fiscales_negocio.,
        hash_domicilioReceptor[:codigoPostal] = @venta.cliente.datos_fiscales_cliente.codigo_postal ? @venta.cliente.datos_fiscales_cliente.codigo_postal : " "
      end
      domicilioReceptor = CFDI::DatosComunes::Domicilio.new(hash_domicilioReceptor)

      #Atributos deel receptor
      @usoCfdi = UsoCfdi.find(params[:uso_cfdi_id])
      if @venta.cliente.datos_fiscales_cliente.rfc.present?
        rfc_receptor_f=@venta.cliente.datos_fiscales_cliente.rfc
      else
        #Si no está registrado el R.F.C del cliente, se registra asi de facil jaja
        rfc_receptor_f=params[:rfc_input]
        cliente_id=@venta.cliente.id
        @cliente=Cliente.find(cliente_id)
        @cliente.update(:rfc=>params[:rfc_input])

      end
      #El mismo show q  el rfc, si el sistema detecta que el cliente no está registrado con su nombre fiscal, le pedirá al usuario que lo ingrese.
      if @venta.cliente.datos_fiscales_cliente.nombreFiscal.present?
        nombre_fiscal_receptor_f=@venta.cliente.datos_fiscales_cliente.nombreFiscal
      else
        nombre_fiscal_receptor_f=params[:nombre_fiscal_receptor_f]
        cliente_id=@venta.cliente.id
        @cliente=Cliente.find(cliente_id)
        @cliente.update(:nombreFiscal=>nombre_fiscal_receptor_f)

      end
      factura.receptor = CFDI::Receptor.new({
        rfc: rfc_receptor_f,
         nombre: nombre_fiscal_receptor_f,
         UsoCFDI:@usoCfdi.clave, #CATALOGO
         domicilioFiscal: domicilioReceptor
        })
      #<< para que puedan ser agragados los conceptos que se deseen.
      cont=0
      @@itemsVenta.each do |c|
        hash_conceptos={ClaveProdServ: c.articulo.clave_prod_serv.clave, #Catálogo
                        NoIdentificacion: c.articulo.clave,
                        Cantidad: c.cantidad,
                        ClaveUnidad:c.articulo.unidad_medida.clave,#Catálogo
                        Unidad: c.articulo.unidad_medida.nombre, #Es opcional para precisar la unidad de medida propia de la operación del emisor, pero pues...
                        Descripcion: c.articulo.nombre
                        }
        importe_concepto = (c.precio_venta * c.cantidad).to_f #Incluye impuestos(si esq), descuentos(si esq)...
        if c.articulo.impuesto.present? #Impuestos a la inversa
          tasaOCuota = (c.articulo.impuesto.porcentaje / 100).to_f #Se obtiene la tasa o cuota por ej. 16% => 0.160000
          #Se calcula el precio bruto de cada concepto
          base_gravable = (importe_concepto / (tasaOCuota + 1)).to_f #Se obtiene el precio bruto por item de venta
          importe_impuesto_concepto = (base_gravable * tasaOCuota).to_f

          valorUnitario = base_gravable / c.cantidad

          if c.articulo.impuesto.tipo == "Federal"
            if c.articulo.impuesto.nombre == "IVA"
              clave_impuesto = "002"
            elsif c.articulo.impuesto.nombre == "IEPS"
              clave_impuesto =  "003"
            end
            factura.impuestos.traslados << CFDI::Impuesto::Traslado.new(base: base_gravable,
              tax: clave_impuesto, type_factor: "Tasa", rate: tasaOCuota, import: importe_impuesto_concepto, concepto_id: cont)
          #end
          #elsif c.articulo.impuesto.tipo == "Local"
            #Para el complemento de impuestos locales.
          end
          hash_conceptos[:ValorUnitario] = valorUnitario
          hash_conceptos[:Importe] = base_gravable
        else
          hash_conceptos[:ValorUnitario] = importe_concepto = c.precio_venta
          hash_conceptos[:Importe] = importe_concepto
        end
        factura.conceptos << CFDI::Concepto.new(hash_conceptos)
        cont += 1
      end

=begin
      factura.uuidsrelacionados << CFDI::Cfdirelacionado.new({
        uuid:"123456789"
        })
      factura.uuidsrelacionados << CFDI::Cfdirelacionado.new({
        uuid:"987654321"
      })

      factura.cfdisrelacionados = CFDI::CfdiRelacionados.new({
        tipoRelacion: "NOTA DE CRÉDITO"#,
        #uuids: folis
      })
=end

      #3.- SE AGREGA EL CERTIFICADO Y SELLO DIGITAL
      @total_to_w= factura.total_to_words
      # Esto hace que se le agregue al comprobante el certificado y su número de serie (noCertificado)
      certificado.certifica factura
      # Esto genera la factura como xml
      p xml= factura.comprobante_to_xml
      # Para mandarla a un PAC, necesitamos sellarla, y esto lo hace agregando el sello
      archivo_xml = generar_sello(xml, llave, pass_llave)

      # Convertir la cadena del xml en base64
      xml_base64 = Base64.strict_encode64(archivo_xml)

      # Parametros para conexion al Webservice (URL de Pruebas)
      wsdl_url = "https://staging.ws.timbox.com.mx/timbrado_cfdi33/wsdl"
      usuario = "AAA010101000"
      contrasena = "h6584D56fVdBbSmmnB"

      gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
      storage=gcloud.storage

      bucket = storage.bucket "cfdis"

      #4.- ALTERNATIVA DE CONEXIÓN PARA CONSUMIR EL WEBSERVICE DE TIMBRADO CON TIMBOX
      #Se obtiene el xml timbrado
      xml_timbrado= timbrar_xml(usuario, contrasena, xml_base64, wsdl_url)

      #Se forma la cadena original del timbre fiscal digital de manera manual por que e mugroso xslt del SAT no Jala.
      factura.complemento=CFDI::Complemento.new(
        {
          Version: xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@Version'),
          uuid:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@UUID'),
          FechaTimbrado:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@FechaTimbrado'),
          RfcProvCertif:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@RfcProvCertif'),
          SelloCFD:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@SelloCFD'),
          NoCertificadoSAT:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@NoCertificadoSAT')
        }
      )
      #se hace una copia del xml para modificarlo agregandole información extra para la representación impresa.
      xml_copia=xml_timbrado
      xml_timbrado_storage = factura.comprobante_to_xml #Hasta este punto se le agregado el complemento con eso es suficiente para el CFDI

      #5.- SE AGREGAN NUEVOS DATOS PARA LA REPRESENTACIÓN IMPRESA(INFORMACIÓN(PDF) IMPORTANTE PARA LOS CONTRIBUYENTES, PERO QUE AL SAT NO LE IMPORTAN JAJA)
      codigoQR=factura.qr_code xml_timbrado
      cadOrigComplemento=factura.complemento.cadena_TimbreFiscalDigital
      logo=current_user.negocio.logo
      uso_cfdi_descripcion=@usoCfdi.descripcion
      cve_nombre_forma_pago = "#{forma_pago_f.cve_forma_pagoSAT } - #{forma_pago_f.nombre_forma_pagoSAT}"
      cve_nombre_metodo_pago = params[:metodo_pago]
      #Se pasa un hash con la información extra en la representación impresa como: datos de contacto, dirección fiscal y descripcion de la clave de los catálogos del SAT.
      hash_info = {xml_copia: xml_copia, codigoQR: codigoQR, logo: logo, cadOrigComplemento: cadOrigComplemento, uso_cfdi_descripcion: uso_cfdi_descripcion, cve_nombre_forma_pago: cve_nombre_forma_pago, cve_nombre_metodo_pago: cve_nombre_metodo_pago}
      hash_info[:Telefono1Receptor]= @venta.cliente.telefono1 if @venta.cliente.telefono1
      hash_info[:EmailReceptor]= @venta.cliente.email if @venta.cliente.email

      xml_rep_impresa = factura.add_elements_to_xml(hash_info)
      #puts xml_rep_impresa
      template = Nokogiri::XSLT(File.read('/home/daniel/Vídeos/sysChurch/lib/XSLT.xsl'))
      html_document = template.transform(xml_rep_impresa)
      #File.open('/home/daniel/Documentos/timbox-ruby/CFDImpreso.html', 'w').write(html_document)
      pdf = WickedPdf.new.pdf_from_string(html_document)

      #6.- SE ALMACENAN EN GOOGLE CLOUD STORAGE
      #Directorios
      dir_negocio = current_user.negocio.nombre
      dir_cliente = nombre_fiscal_receptor_f

      #Obtiene la fecha del xml timbrado para que no difiera de los comprobantes y del registro de la BD.
      #fecha_xml = xml_timbrado.xpath('//@Fecha')[0]
      fecha_registroBD=Date.parse(fecha_expedicion_f.to_s)
      dir_mes = fecha_registroBD.strftime("%m")
      dir_anno = fecha_registroBD.strftime("%Y")

      fecha_file= fecha_registroBD.strftime("%Y-%m-%d")
      #Nomenclatura para el nombre del archivo: consecutivo + fecha + extención
      file_name="#{consecutivo}_#{fecha_file}"

        #Cosas a tener en cuenta antes de indicarle una ruta:
          #1.-Un negocio puede o no tener sucursales
        if current_user.sucursal
          dir_sucursal = current_user.sucursal.nombre
          ruta_storage = "#{dir_negocio}/#{dir_sucursal}/#{dir_anno}/#{dir_mes}/#{dir_cliente}/#{file_name}"
        else
          ruta_storage = "#{dir_negocio}/#{dir_anno}/#{dir_mes}/#{dir_cliente}/#{file_name}"
        end

        #Los comprobantes de almacenan en google cloud
        file = bucket.create_file StringIO.new(pdf), "#{ruta_storage}_RepresentaciónImpresa.pdf"
        file = bucket.create_file StringIO.new(xml_timbrado_storage.to_s), "#{ruta_storage}_CFDI.xml"

        #El nombre del pdf formado por: consecutivo + fecha_registroBD
        nombre_pdf="#{consecutivo}_#{fecha_registroBD}_RepresentaciónImpresa.pdf"
        save_path = Rails.root.join('public',nombre_pdf)
        File.open(save_path, 'wb') do |file|
           file << pdf
        end

        archivo = File.open("public/#{consecutivo}_#{fecha_registroBD}_CFDI.xml", "w")
        archivo.write (xml)
        archivo.close

        #7.- SE ENVIAN LOS COMPROBANTES(pdf y xml timbrado) AL CLIENTE POR CORREO ELECTRÓNICO. :p
        #Se asignan los valores del texto variable de la configuración de las plantillas de email.
        txtVariable_nombCliente = @venta.cliente.nombre_completo # =>nombreCliente
        txtVariable_fechaVenta =  @venta.fechaVenta # => fechaVenta
        txtVariable_consecutivoVenta = @venta.consecutivo # => númeroVenta
        txtVariable_montoVenta = @venta.montoVenta # => totalVenta
        txtVariable_folioVenta = @venta.folio # => folioVenta
        txtVariable_nombNegocio = current_user.negocio.datos_fiscales_negocio.nombreFiscal # => nombreNegocio
        #txtVariable_emailNegocio = current_user.negocio.datos_fiscales_negocio.email # => nombre
        mensaje = current_user.negocio.config_comprobante.msg_email
        #msg = "Hola sr. {{nombreCliente}} le hago llegar por este medio la factura de su compra del día {{fechaVenta}}"
        mensaje_email = mensaje.gsub(/(\{\{nombreCliente\}\})/, "#{txtVariable_nombCliente}")
        mensaje_email = mensaje_email.gsub(/(\{\{fechaVenta\}\})/, "#{txtVariable_fechaVenta}")
        mensaje_email = mensaje_email.gsub(/(\{\{numeroVenta\}\})/, "#{txtVariable_consecutivoVenta}")
        mensaje_email = mensaje_email.gsub(/(\{\{folioVenta\}\})/, "#{txtVariable_folioVenta}")
        mensaje_email = mensaje_email.gsub(/(\{\{nombreNegocio\}\})/, "#{txtVariable_nombNegocio}")
        #mensage_email = mensage_email.gsub(/(\{\{folioVenta\}\})/, "#{txtVariable_emailNegocio}")

        destinatario = params[:destinatario]
        tema = current_user.negocio.config_comprobante.asunto_email
        #file_name = "#{consecutivo}_#{fecha_file}"
        comprobantes = {}
        #Aquí  no se da a elegir si desea enviar pdf o xml porque, porque, porque no jajaja
        comprobantes[:pdf] = "public/#{file_name}_RepresentaciónImpresa.pdf"
        comprobantes[:xml] = "public/#{file_name}_CFDI.xml"

        #FacturasEmail.factura_email(@destinatario, @mensaje, @tema).deliver_now
        FacturasEmail.factura_email(destinatario, mensaje_email, tema, comprobantes).deliver_now
=begin

        #8.- SE SALVA EN LA BASE DE DATOS
          #Se crea un objeto del modelo Factura y se le asignan a los atributos los valores correspondientes para posteriormente guardarlo como un registo en la BD.
          folio_fiscal_xml = xml_timbrado.xpath('//@UUID')
          @factura = Factura.new(folio: folio_registroBD, fecha_expedicion: fecha_file, consecutivo: consecutivo, estado_factura:"Activa")

          @factura.folio_fiscal = folio_fiscal_xml
          @factura.ruta_storage =  ruta_storage

          if @factura.save
          current_user.facturas<<@factura
          current_user.negocio.facturas<<@factura
          current_user.sucursal.facturas<<@factura

          #Se factura a nombre del cliente que realizó la compra en el negocio.
          cliente_id=@venta.cliente.id
          Cliente.find(cliente_id).facturas << @factura

          venta_id=@venta.id
          Venta.find(venta_id).factura = @factura #relación uno a uno
          end
=end
          #fecha_expedicion=@factura.fecha_expedicion
          file_name="#{consecutivo}_#{fecha_file}_RepresentaciónImpresa.pdf"
          file=File.open( "public/#{file_name}")

          if params[:commit] == "Facturar y crear nueva"
            enviar = params[:enviar_al_correo]
            if "yes" == params[:imprimir]
              send_file( file, :disposition => "inline", :type => "application/pdf")
            else
              respond_to do |format|
              format.html { redirect_to action: "facturaDeVentas", notice: 'La factura fue registrada existoxamente!' }
              end
            end
          else
            if "yes" == params[:imprimir]
              send_file( file, :disposition => "inline", :type => "application/pdf")
            else
              respond_to do |format|
                format.html { redirect_to facturas_index_path, notice: 'La factura fue registrada existoxamente!' }
              end
            end
          end

      end #fin de else que permiten facturar
    end #Fin del méodo post
  end #Fin del controlador

  #NOTAS DE CRÉDITO
  def nota_credito
    #Comprobante de Egreso.- Amparan devoluciones, descuentos y bonificaciones
    #para efectos de deducibilidad y también puede utilizarse para corregir o restar un
    #comprobante de ingresos en cuanto a los montos que documenta, como la
    #aplicación de anticipos. Este comprobante es conocido como nota de crédito.
    require 'cfdi'
    require 'timbrado'

    if request.post?
      if params[:commit] == "Cancelar"

      else
        #1.- CERTIFICADOS,  LLAVES Y CLAVES
        certificado = CFDI::Certificado.new '/home/daniel/Documentos/prueba/CSD01_AAA010101AAA.cer'
        # Esta se convierte de un archivo .key con:
        # openssl pkcs8 -inform DER -in someKey.key -passin pass:somePassword -out key.pem
        llave = "/home/daniel/Documentos/timbox-ruby/CSD01_AAA010101AAA.key.pem"
        pass_llave = "12345678a"
        #openssl pkcs8 -inform DER -in /home/daniel/Documentos/prueba/CSD03_AAA010101AAA.key -passin pass:12345678a -out /home/daniel/Documentos/prueba/CSD03_AAA010101AAA.pem
        #llave2 = CFDI::Key.new llave, pass_llave

        #Para obtener el numero consecutivo a partir de la ultima factura o de lo contrario asignarle por primera vez un número
        consecutivo = 0
        if current_user.sucursal.nota_creditos.last
          consecutivo = current_user.sucursal.nota_creditos.last.consecutivo
          if consecutivo
            consecutivo += 1
          end
        else
          consecutivo = 1 #Se asigna el número a la factura por default o de acuerdo a la configuración del usuario.
        end

        if current_user.sucursal.clave.present?
          #El folio de las facturas se forma por defecto por la clave de las sucursales, pero si el usuario quiere establecer sus propias series para otro fin, se tomará la serie que el usuario indique en las configuración de Facturas y Notas
          #claveSucursal = current_user.sucursal.clave
          claveSucursal = current_user.sucursal.clave
          folio_registroBD = claveSucursal + "F"
          folio_registroBD << consecutivo.to_s
          serie = claveSucursal + "F"
        else
          folio_default="F"
          folio_registroBD =folio_default
          #Una serie por default les guste o no les guste, pero útil para que no se produzca un colapso
          serie = folio_default
        end

      fecha_expedicion_f = Time.now
      #2.- LLENADO DEL XML DIRECTAMENTE DE LA BASE DE DATOS
      factura = CFDI::Comprobante.new({
        serie: serie,
        folio: consecutivo,
        fecha: fecha_expedicion_f,
        #Deberá ser de tipo Egreso
        tipoDeComprobante: "E",
        #La moneda por default es MXN
        #Forma de pago, opciones de registro:
          #La que se registró en el comprobante de tipo ingreso.
          #Con la que se está efectuando el descuento, devolución o bonificación en su caso.
        FormaPago:'01',#CATALOGO Es de tipo string
        condicionesDePago: 'Sera marcada como pagada en cuanto el receptor haya cubierto el pago.',
        metodoDePago: 'PUE', #CATALOGO
        lugarExpedicion: current_user.sucursal.codigo_postal,#current_user.negocio.datos_fiscales_negocio.codigo_postal,#, #CATALOGO
        #total: 27.84#Como que ya es hora de pasarle el monto total de la venta más los impustos jaja para no usar calculadora
        total: 55.68
        #total:40.88
        #Descuento:0 #DESCUENTO RAPPEL
      })
      #Estos datos no son requeridos por el SAT, sin embargo se usaran para la representacion impresa de los CFDIs.*
      #DATOS DEL EMISOR
      domicilioEmisor = CFDI::DatosComunes::Domicilio.new({
        calle: current_user.negocio.datos_fiscales_negocio.calle,
        noExterior: current_user.negocio.datos_fiscales_negocio.numExterior,
        noInterior: current_user.negocio.datos_fiscales_negocio.numInterior,
        colonia: current_user.negocio.datos_fiscales_negocio.colonia,
        #localidad: current_user.negocio.datos_fiscales_negocio.,
        #referencia: current_user.negocio.datos_fiscales_negocio.,
        municipio: current_user.negocio.datos_fiscales_negocio.municipio,
        estado: current_user.negocio.datos_fiscales_negocio.estado,
        #pais: current_user.negocio.datos_fiscales_negocio.,
        codigoPostal: current_user.negocio.datos_fiscales_negocio.codigo_postal
      })
      #III. Sí se tiene más de un local o establecimiento, se deberá señalar el domicilio del local o
      #establecimiento en el que se expidan las Facturas Electrónicas
      #Estos datos no son requeridos por el SAT, sin embargo se usaran para la representacion impresa de los CFDIs.*
      expedidoEn= CFDI::DatosComunes::Domicilio.new({
        #Estos datos los uso como datos fiscales, sin current_user.sucursal.codigo_postalembargo si se hara distinción entre direccion comun y dirección fiscal,
        #se debera corregir.
        calle: current_user.sucursal.calle,
        noExterior: current_user.sucursal.numExterior,
        noInterior: current_user.sucursal.numInterior,
        colonia: current_user.sucursal.colonia,
        #localidad: current_user.negocio.datos_fiscales_negocio.,
        #referencia: current_user.negocio.datos_fiscalecurrent_user.sucursal.codigo_postals_negocio.,
        municipio: current_user.sucursal.municipio,
        estado: current_user.sucursal.estado,
        #pais: current_user.negocio.datos_fiscales_negocio.,
        codigoPostal: current_user.sucursal.codigo_postal
      })

      factura.emisor = CFDI::Emisor.new({
        rfc: current_user.negocio.datos_fiscales_negocio.rfc,
        nombre: current_user.negocio.datos_fiscales_negocio.nombreFiscal,
        regimenFiscal: current_user.negocio.datos_fiscales_negocio.regimen_fiscal, #CATALOGO
        domicilioFiscal: domicilioEmisor,
        expedidoEn: expedidoEn
      })
      #Estos datos no son requeridos por el SAT, sin embargo se usaran para la representacion impresa de los CFDIs.*
      domicilioReceptor = CFDI::DatosComunes::Domicilio.new({
        calle: @@venta.cliente.datos_fiscales_cliente.calle,
        noExterior: @@venta.cliente.datos_fiscales_cliente.numExterior,
        noInterior: @@venta.cliente.datos_fiscales_cliente.numInterior,
        colonia: @@venta.cliente.datos_fiscales_cliente.colonia,
        localidad: @@venta.cliente.datos_fiscales_cliente.localidad,
        #referencia: current_user.negocio.datos_fiscales_negocio.,
        municipio: @@venta.cliente.datos_fiscales_cliente.municipio,
        estado: @@venta.cliente.datos_fiscales_cliente.estado,    #pais: current_user.negocio.datos_fiscales_negocio.,
        codigoPostal: @@venta.cliente.datos_fiscales_cliente.codigo_postal
      })

      #Atributos del receptor
      rfc_receptor_f=@@venta.cliente.datos_fiscales_cliente.rfc
      nombre_fiscal_receptor_f=@@venta.cliente.datos_fiscales_cliente.nombreFiscal
      #Al tratarse de un CFDI de egresos, no será un comprobante de deducción para el receptor, ya que se está emitiendo para disminuir el importe de un CFDI relacionado.
      #Por lo tanto el uso sera: G02 - Devoluciones, descuentos o bonificaciones
      factura.receptor = CFDI::Receptor.new({
        rfc: rfc_receptor_f,
         nombre: nombre_fiscal_receptor_f,
         UsoCFDI: "G02", #Devoluciones, descuentos o bonificaciones
         domicilioFiscal: domicilioReceptor
        })

      #<< para que puedan ser agragados los conceptos que se deseen.
      cont=0
      @@itemsVenta.each do |c|
        factura.conceptos << CFDI::Concepto.new({
          ClaveProdServ: c.articulo.clave_prod_serv.clave, #CATALOGO
          NoIdentificacion: c.articulo.clave,
          Cantidad: c.cantidad,
          ClaveUnidad:c.articulo.unidad_medida.clave,#CATALOGO
          Unidad: c.articulo.unidad_medida.nombre, #Es opcional para precisar la unidad de medida propia de la operación del emisor, pero pues...
          Descripcion: c.articulo.nombre,
          ValorUnitario: c.precio_venta, #el importe se calcula solo
          #Descuento: 0 #Expresado en porcentaje
        })
=begin
        if c.articulo.impuesto.present? && c.articulo.impuesto.tipo == "Federal"
          if c.articulo.impuesto.nombre == "IVA"
            clave_impuesto = "002"
          elsif c.articulo.impuesto.nombre == "IEPS"
            clave_impuesto =  "003"
          end
          factura.impuestos.traslados << CFDI::Impuesto::Traslado.new(base: c.precio_venta * c.cantidad,
            tax: clave_impuesto, type_factor: "Tasa", rate: format('%.6f',(c.articulo.impuesto.porcentaje/100)).to_f, concepto_id: cont )
        end
=end
        cont += 1
      end

      factura.uuidsrelacionados << CFDI::Cfdirelacionado.new({
        uuid:"123456789"
        })

      factura.cfdisrelacionados = CFDI::CfdiRelacionados.new({
        tipoRelacion: "NOTA DE CRÉDITO"#,
        #uuids: folis
      })

      #3.- SE AGREGA EL CERTIFICADO Y SELLO DIGITAL
      @total_to_w= factura.total_to_words
      # Esto hace que se le agregue al comprobante el certificado y su número de serie (noCertificado)
      certificado.certifica factura
      # Esto genera la factura como xml
      xml= factura.comprobante_to_xml
      # Para mandarla a un PAC, necesitamos sellarla, y esto lo hace agregando el sello
      archivo_xml = generar_sello(xml, llave, pass_llave)

      # Convertir la cadena del xml en base64
      xml_base64 = Base64.strict_encode64(archivo_xml)

      # Parametros para conexion al Webservice (URL de Pruebas)
      wsdl_url = "https://staging.ws.timbox.com.mx/timbrado_cfdi33/wsdl"
      usuario = "AAA010101000"
      contrasena = "h6584D56fVdBbSmmnB"

      gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
      storage=gcloud.storage

      bucket = storage.bucket "cfdis"


      #4.- ALTERNATIVA DE CONEXIÓN PARA CONSUMIR EL WEBSERVICE DE TIMBRADO CON TIMBOX
      #Se obtiene el xml timbrado
      xml_timbrado= timbrar_xml(usuario, contrasena, xml_base64, wsdl_url)

      #Se forma la cadena original del timbre fiscal digital de manera manual por que e mugroso xslt del SAT no Jala.
      factura.complemento=CFDI::Complemento.new(
        {
          Version: xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@Version'),
          uuid:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@UUID'),
          FechaTimbrado:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@FechaTimbrado'),
          RfcProvCertif:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@RfcProvCertif'),
          SelloCFD:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@SelloCFD'),
          NoCertificadoSAT:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@NoCertificadoSAT')
        }
      )
      #se hace una copia del xml para modificarlo agregandole información extra para la representación impresa.
      xml_copia=xml_timbrado
      xml_timbrado_storage = factura.comprobante_to_xml #Hasta este punto se le agregado el complemento con eso es suficiente para el CFDI

      #5.- SE AGREGAN NUEVOS DATOS PARA LA REPRESENTACIÓN IMPRESA(INFORMACIÓN(PDF) IMPORTANTE PARA LOS CONTRIBUYENTES, PERO QUE AL SAT NO LE IMPORTAN JAJA)
      codigoQR=factura.qr_code xml_timbrado
      cadOrigComplemento=factura.complemento.cadena_TimbreFiscalDigital
      logo=current_user.negocio.logo
      uso_cfdi_descripcion=@usoCfdi.descripcion

      #Se pasa un hash con la información extra en la representación impresa como: datos de contacto, dirección fiscal y descripcion de la clave de los catálogos del SAT.
      hash_info = {xml_copia: xml_copia, codigoQR: codigoQR, logo: logo, cadOrigComplemento: cadOrigComplemento, uso_cfdi_descripcion: uso_cfdi_descripcion}
      hash_info[:Telefono1Receptor]= @@venta.cliente.telefono1 if @@venta.cliente.telefono1
      hash_info[:EmailReceptor]= @@venta.cliente.email if @@venta.cliente.email


      xml_rep_impresa = factura.add_elements_to_xml(hash_info)
      #puts xml_rep_impresa
      template = Nokogiri::XSLT(File.read('/home/daniel/Documentos/sysChurch/lib/XSLT.xsl'))
      html_document = template.transform(xml_rep_impresa)
      #File.open('/home/daniel/Documentos/timbox-ruby/CFDImpreso.html', 'w').write(html_document)
      pdf = WickedPdf.new.pdf_from_string(html_document)

      #6.- SE ALMACENAN EN GOOGLE CLOUD STORAGE
      #Directorios
      dir_negocio = current_user.negocio.nombre
      dir_cliente = nombre_fiscal_receptor_f

      #Obtiene la fecha del xml timbrado para que no difiera de los comprobantes y del registro de la BD.
      #fecha_xml = xml_timbrado.xpath('//@Fecha')[0]
      fecha_registroBD=Date.parse(fecha_expedicion_f.to_s)
      dir_mes = fecha_registroBD.strftime("%m")
      dir_anno = fecha_registroBD.strftime("%Y")

      fecha_file= fecha_registroBD.strftime("%Y-%m-%d")
      #Nomenclatura para el nombre del archivo: consecutivo + fecha + extención
      file_name="#{consecutivo}_#{fecha_file}"

        #Cosas a tener en cuenta antes de indicarle una ruta:
          #1.-Un negocio puede o no tener sucursales
        if current_user.sucursal
          dir_sucursal = current_user.sucursal.nombre
          ruta_storage = "#{dir_negocio}/#{dir_sucursal}/#{dir_anno}/#{dir_mes}/#{dir_cliente}/#{file_name}"
        else
          ruta_storage = "#{dir_negocio}/#{dir_anno}/#{dir_mes}/#{dir_cliente}/#{file_name}"
        end

        #Los comprobantes de almacenan en google cloud
        file = bucket.create_file StringIO.new(pdf), "#{ruta_storage}_RepresentaciónImpresa.pdf"
        file = bucket.create_file StringIO.new(xml_timbrado_storage.to_s), "#{ruta_storage}_CFDI.xml"

        #El nombre del pdf formado por: consecutivo + fecha_registroBD + nombre + extención
        nombre_pdf="#{consecutivo}_#{fecha_registroBD}_RepresentaciónImpresa.pdf"
        save_path = Rails.root.join('public',nombre_pdf)
        File.open(save_path, 'wb') do |file|
           file << pdf
        end

        archivo = File.open("public/#{consecutivo}_#{fecha_registroBD}_CFDI.xml", "w")
        archivo.write (xml)
        archivo.close

        #7.- SE ENVIAN LOS COMPROBANTES(pdf y xml timbrado) AL CLIENTE POR CORREO ELECTRÓNICO. :p
        destinatario = params[:destinatario]
        mensaje = current_user.negocio.config_comprobante.msg_email
        tema = current_user.negocio.config_comprobante.asunto_email
        #file_name = "#{consecutivo}_#{fecha_file}"
        comprobantes = {}
        #Aquí  no se da a elegir si desea enviar pdf o xml porque, porque, porque no jajaja
        comprobantes[:pdf] = "public/#{file_name}_RepresentaciónImpresa.pdf"
        comprobantes[:xml] = "public/#{file_name}_CFDI.xml"

        #FacturasEmail.factura_email(@destinatario, @mensaje, @tema).deliver_now
        #FacturasEmail.factura_email(destinatario, mensaje, tema, comprobantes).deliver_now


        #8.- SE SALVA EN LA BASE DE DATOS
          #Se crea un objeto del modelo Factura y se le asignan a los atributos los valores correspondientes para posteriormente guardarlo como un registo en la BD.
          folio_fiscal_xml = xml_timbrado.xpath('//@UUID')
          @factura = Factura.new(folio: folio_registroBD, fecha_expedicion: fecha_file, consecutivo: consecutivo, estado_factura:"Activa")

          @factura.folio_fiscal = folio_fiscal_xml
          @factura.ruta_storage =  ruta_storage
=begin
          if @factura.save
          current_user.facturas<<@factura
          current_user.negocio.facturas<<@factura
          current_user.sucursal.facturas<<@factura

          #Se factura a nombre del cliente que realizó la compra en el negocio.
          cliente_id=@@venta.cliente.id
          Cliente.find(cliente_id).facturas << @factura

          venta_id=@@venta.id
          Venta.find(venta_id).factura = @factura #relación uno a uno
          end
=end
          #fecha_expedicion=@factura.fecha_expedicion
          file_name="#{consecutivo}_#{fecha_file}_RepresentaciónImpresa.pdf"
          file=File.open( "public/#{file_name}")

          if params[:commit] == "Facturar y crear nueva"
            enviar = params[:enviar_al_correo]
            if "yes" == params[:imprimir]
              send_file( file, :disposition => "inline", :type => "application/pdf")
            else
              respond_to do |format|
              format.html { redirect_to action: "buscarVentaFacturar", notice: 'La factura fue registrada existoxamente!' }
              end
            end
          else
            if "yes" == params[:imprimir]
              send_file( file, :disposition => "inline", :type => "application/pdf")
            else
              respond_to do |format|
                format.html { redirect_to facturas_index_path, notice: 'La factura fue registrada existoxamente!' }
              end
            end
          end

      end
    end
  end



  def readpdf

    gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
    storage=gcloud.storage

    bucket = storage.bucket "cfdis"

    fecha_expedicion=@factura.fecha_expedicion
    consecutivo =@factura.consecutivo

    ruta_storage = @factura.ruta_storage

    #Se descarga el pdf de la nube y se guarda en el disco
    file_name="#{consecutivo}_#{fecha_expedicion}_RepresentaciónImpresa.pdf"

    file_download_storage = bucket.file "#{ruta_storage}_RepresentaciónImpresa.pdf"
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

  def enviar_email_post
    #Se optienen los datos que se ingresen o en su caso los datos de la configuracion del mensaje de los correos.
    if request.post?
      destinatario = params[:destinatario]
      #SE ENVIAN LOS COMPROBANTES(pdf y/o xml timbrado) AL CLIENTE POR CORREO ELECTRÓNICO. :p
      #Se asignan los valores del texto variable de la configuración de las plantillas de email.
      txtVariable_nombCliente = @factura.venta.cliente.nombre_completo # =>nombreCliente
      txtVariable_fechaVenta =  @factura.venta.fechaVenta # => fechaVenta
      txtVariable_consecutivoVenta = @factura.venta.consecutivo # => númeroVenta
      txtVariable_montoVenta = @factura.venta.montoVenta # => totalVenta
      txtVariable_folioVenta = @factura.venta.folio # => folioVenta
      txtVariable_nombNegocio = current_user.negocio.datos_fiscales_negocio.nombreFiscal # => nombreNegocio
      #txtVariable_emailNegocio = current_user.negocio.datos_fiscales_negocio.email # => nombre
      mensaje = current_user.negocio.config_comprobante.msg_email
      #msg = "Hola sr. {{nombreCliente}} le hago llegar por este medio la factura de su compra del día {{fechaVenta}}"
      mensaje_email = mensaje.gsub(/(\{\{nombreCliente\}\})/, "#{txtVariable_nombCliente}")
      mensaje_email = mensaje_email.gsub(/(\{\{fechaVenta\}\})/, "#{txtVariable_fechaVenta}")
      mensaje_email = mensaje_email.gsub(/(\{\{numeroVenta\}\})/, "#{txtVariable_consecutivoVenta}")
      mensaje_email = mensaje_email.gsub(/(\{\{folioVenta\}\})/, "#{txtVariable_folioVenta}")
      mensaje_email = mensaje_email.gsub(/(\{\{nombreNegocio\}\})/, "#{txtVariable_nombNegocio}")
      #mensage_email = mensage_email.gsub(/(\{\{folioVenta\}\})/, "#{txtVariable_emailNegocio}")

      #@tema = params[:tema]
      tema = current_user.negocio.config_comprobante.asunto_email

      ruta_storage = @factura.ruta_storage

      #Se descargan los archivos que el usuario haya indicado que se enviarán como archivos adjuntos
      gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
      storage=gcloud.storage

      bucket = storage.bucket "cfdis"

      fecha_expedicion=@factura.fecha_expedicion
      consecutivo =@factura.consecutivo
      file_name = "#{consecutivo}_#{fecha_expedicion}"
      comprobantes = {}
      if params[:pdf] == "yes"
        comprobantes[:pdf] = "public/#{file_name}_RepresentaciónImpresa.pdf"
        file_download_storage_xml = bucket.file "#{ruta_storage}_RepresentaciónImpresa.pdf"
        file_download_storage_xml.download "public/#{file_name}_RepresentaciónImpresa.pdf"
      end
      if params[:xml] == "yes"
        comprobantes[:xml] = "public/#{file_name}_CFDI.xml"
        file_download_storage_xml = bucket.file "#{ruta_storage}_CFDI.xml"
        file_download_storage_xml.download "public/#{file_name}_CFDI.xml"
      end

      #FacturasEmail.factura_email(@destinatario, @mensaje, @tema).deliver_now
      FacturasEmail.factura_email(destinatario, mensaje_email, tema, comprobantes).deliver_now

      respond_to do |format|
        format.html { redirect_to action: "index"}
        flash[:notice] = "Los comprobantes se han enviado a #{destinatario}!"
        #format.html { redirect_to facturas_index_path, notice: 'No se encontró la factura, vuelva a intentarlo!' }
      end

    end
  end

  def enviar_email #get
    #Solo se muestran los datos
    @destinatario = @factura.cliente.email
    @mensaje = current_user.negocio.config_comprobante.msg_email
    @tema = current_user.negocio.config_comprobante.asunto_email

  end

  def descargar_cfdis
    gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
    storage=gcloud.storage

    bucket = storage.bucket "cfdis"

    fecha_expedicion=@factura.fecha_expedicion
    consecutivo =@factura.consecutivo

    ruta_storage = @factura.ruta_storage

    #Se descarga el pdf de la nube y se guarda en el disco
    file_name = "#{consecutivo}_#{fecha_expedicion}_CFDI.xml"

    file_download_storage_xml = bucket.file "#{ruta_storage}_CFDI.xml"

    file_download_storage_xml.download "public/#{file_name}"

    xml = File.open( "public/#{file_name}")
    send_file(
      xml,
      filename: "CFDI.xml",
      type: "application/xml"
    )
  end

  def cancelar_cfdi
    require 'timbrado'
    require 'nokogiri'
    require 'byebug'

    gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
    storage=gcloud.storage

    bucket = storage.bucket "cfdis"

    fecha_expedicion=@factura.fecha_expedicion
    consecutivo =@factura.consecutivo

    ruta_storage = @factura.ruta_storage

    #Se descarga el xml
    file_name = "#{consecutivo}_#{fecha_expedicion}"

    file_download_storage_xml = bucket.file "#{ruta_storage}_CFDI.xml"

    file_download_storage_xml.download "public/#{file_name}"

    #Se comprueba que el archivo exista en la carpeta publica de la aplicación
    if File::exists?("public/#{file_name}")
      xml_cfdi=File.open("public/#{file_name}")
      xml_a_cancelar = Nokogiri::XML(xml_cfdi)
    else
      respond_to do |format|
        format.html { redirect_to action: "index" }
        flash[:notice] = "No se encontró ningun CFDI con el nombre de: #{file_name}"
        #format.html { redirect_to facturas_index_path, notice: 'No se encontró la factura, vuelva a intentarlo!' }
      end
    end
    # Parametros para la conexión al Webservice
    wsdl_url = "https://staging.ws.timbox.com.mx/timbrado_cfdi33/wsdl"
    usuario = "AAA010101000"
    contrasena = "h6584D56fVdBbSmmnB"

    # Parametros para la cancelación del CFDI
    uuid = xml_a_cancelar.xpath('/cfdi:Comprobante/cfdi:Complemento//@UUID')
    uuid = uuid.to_s
    rfc = "AAA010101AAA"
    pfx_path = '/home/daniel/Documentos/timbox-ruby/archivoPfx.pfx'
    bin_file = File.binread(pfx_path)
    pfx_base64 = Base64.strict_encode64(bin_file)
    pfx_password = "12345678a"

    xml_cancelado = cancelar_cfdis usuario, contrasena, rfc, uuid, pfx_base64, pfx_password, wsdl_url
    #se extrae el acuse de cancelación del xml cancelado
    acuse = xml_cancelado.xpath("//acuse_cancelacion").text

    file = bucket.create_file StringIO.new(acuse.to_s), "#{ruta_storage}_AcuseDeCancelación.xml"
    #acuse = StringIO.new(acuse.to_s)
    #a = File.open("public/#{file_name}_AcuseDeCancelación", "w")
    #a.write (acuse)
    #a.close

    estado_factura="Cancelada"
    @factura.update(:estado_factura=>estado_factura) #Pasa de activa a cancelada

    #xml_acuse = File.open( "public/#{file_name}_AcuseDeCancelación.xml")
    #Refresca la pagina
    redirect_to :back
    #send_file(
    #  xml_acuse,
    #  filename: "AcuseDeCancelación.xml",
    #  type: "application/xml"
    #)
  end
  def consulta_facturas
    @consulta = true
    @fechas=true
    @por_folio=false
    @avanzada = false
    if request.post?
      @fechaInicial = DateTime.parse(params[:fecha_inicial]).to_date
      @fechaFinal = DateTime.parse(params[:fecha_final]).to_date
      if can? :create, Negocio
        @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal)
      else
        @facturas = current_user.sucursal.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal)
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


    if request.post?
      @folio_fact = params[:folio_fact]
      @facturas = Factura.find_by folio: @folio_fact
      if can? :create, Negocio
        @facturas = current_user.negocio.facturas.where(folio: @folio_fact)
      else
        @facturas = current_user.sucursal.facturas.where(folio: @folio_fact)
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
          clientes_ids = []
          datos_fiscales_cliente.each do |dfc|
            clientes_ids << dfc.cliente_id
          end
          #Se le pasa un arreglo con los ids para obtener las facturas de todos los clientes con el RFC =
          @facturas = current_user.negocio.facturas.where(cliente_id: clientes_ids)
          #cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
        elsif params[:rbtn] == "rbtn_nombreFiscal"
          #En el caso de la búsqueda por nombre fiscal... el resutado serán todas las facturas de un único cliente.
          datos_fiscales_cliente = DatosFiscalesCliente.find params[:cliente_id]
          @nombreFiscal = datos_fiscales_cliente.nombreFiscal
          cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
          @facturas = current_user.negocio.facturas.where(cliente_id: cliente)
        end

      else
        if params[:rbtn] == "rbtn_rfc"
          #Se puede presentar el caso en el que un negocio tenga clientes con el mismo RFC y/o nombres fiscales iguales como datos de facturción.
          #El resultado de la búsqueda serían todas las facturas de los diferentes clientes con el RFC igual. (incluyendo el XAXX010101000)
          @rfc = params[:rfc]
          datos_fiscales_cliente = DatosFiscalesCliente.where rfc: @rfc
          clientes_ids = []
          datos_fiscales_cliente.each do |dfc|
            clientes_ids << dfc.cliente_id
          end
          @facturas = current_user.sucursal.facturas.where(cliente_id: clientes_ids)
          #cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
        elsif params[:rbtn] == "rbtn_nombreFiscal"
          #En el caso de la búsqueda por nombre fiscal... el resutado serán todas las facturas de un único cliente.
          datos_fiscales_cliente = DatosFiscalesCliente.find params[:cliente_id]
          @nombreFiscal = datos_fiscales_cliente.nombreFiscal
          cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
          @facturas = current_user.sucursal.facturas.where(cliente_id: cliente)
        end
      end
    end
  end

  def consulta_avanzada
    @consulta = true
    @avanzada = true

    @fechas=false
    @por_folio=false

    #@clientes = current_user.negocio.clientes.nombre

    if request.post?
      @fechaInicial = DateTime.parse(params[:fecha_inicial_avanzado]).to_date
      @fechaFinal = DateTime.parse(params[:fecha_final_avanzado]).to_date
      #cliente_id = params[:cliente_id]
      #@cajero = nil
      #@cliente = nil

      #unless cliente_id.empty?
      #  @cliente = Cliente.find(cliente_id).id #id, nombre_completo
      #end
      clientes_ids = []
      if params[:opcion_busqueda_cliente] == "Buscar por R.F.C."
        #Se puede presentar el caso en el que un negocio tenga clientes con el mismo RFC y/o nombres fiscales iguales como datos de facturción.
        #El resultado de la búsqueda serían todas las facturas de los diferentes clientes con el RFC igual. (incluyendo el XAXX010101000)
        @rfc = params[:rfc]
        @por_cliente = true if @rfc
        datos_fiscales_cliente = DatosFiscalesCliente.where rfc: @rfc

        datos_fiscales_cliente.each do |dfc|
          clientes_ids << dfc.cliente_id
        end
        #Se le pasa un arreglo con los ids para obtener las facturas de todos los clientes con el RFC =
        #@facturas = current_user.negocio.facturas.where(cliente_id: clientes_ids)
        #cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
      elsif params[:opcion_busqueda_cliente] == "Buscar por nombre fiscal"

        #En el caso de la búsqueda por nombre fiscal... el resutado serán todas las facturas de un único cliente.
        datos_fiscales_cliente = DatosFiscalesCliente.find params[:cliente_id]
        @por_cliente = true
        @nombreFiscal = datos_fiscales_cliente.nombreFiscal
        clientes_ids << datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
        #@facturas = current_user.negocio.facturas.where(cliente_id: cliente)
      end

      @estado_factura = params[:estado_factura]

      @suc = params[:suc_elegida]

      unless @suc.empty?
        @sucursal = Sucursal.find(@suc)
      end
      @montoFactura = false
      @condicion_monto_factura = params[:condicion_monto_factura]

      #Se convierte la descripción al operador equivalente
      unless @condicion_monto_factura.empty?
        @montoFactura = true
        operador_monto = case @condicion_monto_factura
           when "menor que" then "<"
           when "mayor que" then ">"
           when "menor o igual que" then "<="
           when "mayor o igual que" then ">="
           when "igual que" then "="
           when "diferente que" then "!=" #o también <> Distinto de
           when "rango desde" then ".." #o también <> Distinto de

        end
      end

      if can? :create, Negocio
        unless @suc.empty?
          #valida si se eligió un cliente específico para esta consulta
          if @rfc || @nombreFiscal#@cliente
            #Filtra por monto de la venta facurada.
            if operador_monto
              @monto_factura = params[:monto_factura]
              unless operador_monto == ".." #Cuando se trata de un rango
                @facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where("montoVenta #{operador_monto} ?", @monto_factura)) if @monto_factura
              else
                @monto_factura2 = params[:monto_factura2]
                @facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where(montoVenta: @monto_factura..@monto_factura2)) if @monto_factura && @monto_factura2
              end
              #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
              unless @estado_factura.eql?("Todas")
                @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, estado_factura: @estado_factura, sucursal: @sucursal)
              else
                @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, sucursal: @sucursal)
              end
            else
              #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
              unless @estado_factura.eql?("Todas")
                @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, estado_factura: @estado_factura, sucursal: @sucursal)
              else
                @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, sucursal: @sucursal)
              end
            end
          # Si no se eligió cliente, entonces no filtra las ventas por el cliente al que se expidió la factura.
          else
            #Filtra por monto de la venta facurada.
            if operador_monto
              @monto_factura = params[:monto_factura]
              unless operador_monto == ".." #Cuando se trata de un rango
                @facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where("montoVenta #{operador_monto} ?", @monto_factura)) if @monto_factura
              else
                @monto_factura2 = params[:monto_factura2]
                @facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where(montoVenta: @monto_factura..@monto_factura2)) if @monto_factura && @monto_factura2
              end
              #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
              unless @estado_factura.eql?("Todas")
                @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura, sucursal: @sucursal)
              else
                @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, sucursal: @sucursal)
              end
              #Si el usuario no seleccionó una condición para filtrar por el monto de la factura de la venta.
            else
              #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
              unless @estado_factura.eql?("Todas")
                @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura, sucursal: @sucursal)
              else
                @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, sucursal: @sucursal)
              end
            end
          end
        #Si el usuario no eligió ninguna sucursal específica, no filtra las ventas por sucursal
        else
          #valida si se eligió un cliente
          if @rfc || @nombreFiscal#@cliente
            #Filtra por monto de la venta facurada.
            if operador_monto
              @monto_factura = params[:monto_factura]
              unless operador_monto == ".." #Cuando se trata de un rango
                @facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where("montoVenta #{operador_monto} ?", @monto_factura)) if @monto_factura
              else
                @monto_factura2 = params[:monto_factura2]
                @facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where(montoVenta: @monto_factura..@monto_factura2)) if @monto_factura && @monto_factura2
              end
              #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
              unless @estado_factura.eql?("Todas")
                @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, estado_factura: @estado_factura)
              else
                @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids)
              end
            else
              #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
              unless @estado_factura.eql?("Todas")
                @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, estado_factura: @estado_factura)
              else
                @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids)
              end
            end
          # Si no se eligió cliente, entonces no filtra las ventas por el cliente
          else
            if operador_monto
              @monto_factura = params[:monto_factura]
              unless operador_monto == ".." #Cuando se trata de un rango
                @facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where("montoVenta #{operador_monto} ?", @monto_factura)) if @monto_factura
              else
                @monto_factura2 = params[:monto_factura2]
                @facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where(montoVenta: @monto_factura..@monto_factura2)) if @monto_factura && @monto_factura2
              end
              #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
              unless @estado_factura.eql?("Todas")
                @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura)
              else
                @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal)
              end
            else
              #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
              unless @estado_factura.eql?("Todas")
                @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura)
              else
                @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal)
              end
            end

          end
        end

      #Si el usuario no es un administrador o subadministrador
      else

        #valida si se eligió un cliente específico para esta consulta
        if @rfc || @nombreFiscal#@cliente

          #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
          unless @estado_factura.eql?("Todas")
            @facturas = current_user.sucursal.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, estado_factura: @estado_factura)
          else
            @facturas = current_user.sucursal.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids)
          end #Termina unless @estado_factura.eql?("Todas")

        # Si no se eligió cliente, entonces no filtra las ventas por el cliente
        else

          #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
          unless @estado_factura.eql?("Todas")
            @facturas = current_user.sucursal.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura)
          else
            @facturas = current_user.sucursal.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal)
          end #Termina unless @estado_factura.eql?("Todas")

        end #Termina if @cajero

      end

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end
  end


  # GET /facturas
  # GET /facturas.json
  def index

    @consulta = false
    @avanzada = false

    if request.get?
      if can? :create, Negocio
        @facturas = current_user.negocio.facturas.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
      else
        @facturas = current_user.sucursal.facturas.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
      end
    end
  end

  # GET /facturas/1
  # GET /facturas/1.json
  def show
    @items  = @factura.venta.item_ventas
    @nombreFiscal =  @factura.cliente.datos_fiscales_cliente ?  @factura.cliente.datos_fiscales_cliente.nombreFiscal : "Púlico general"
    @rfc =  @factura.cliente.datos_fiscales_cliente ?  @factura.cliente.datos_fiscales_cliente.rfc : "XAXX010101000"

  end

  # GET /facturas/new
  def new
    @factura = Factura.new
  end

  # GET /facturas/1/edit
  def edit
  end

  # POST /facturas
  # POST /facturas.json
  def create
    @factura = Factura.new(factura_params)

    respond_to do |format|
      if @factura.save
        format.html { redirect_to @factura, notice: 'Factura was successfully created.' }
        format.json { render :show, estado_factura: :created, location: @factura }
      else
        format.html { render :new }
        format.json { render json: @factura.errors, estado_factura: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /facturas/1
  # PATCH/PUT /facturas/1.json
  def update
    respond_to do |format|
      if @factura.update(factura_params)
        format.html { redirect_to @factura, notice: 'Factura was successfully updated.' }
        format.json { render :show, estado_factura: :ok, location: @factura }
      else
        format.html { render :edit }
        format.json { render json: @factura.errors, estado_factura: :unprocessable_entity }
      end
    end
  end

  # DELETE /facturas/1
  # DELETE /facturas/1.json
  def destroy
    @factura.destroy
    respond_to do |format|
      format.html { redirect_to facturas_url, notice: 'Factura was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def devolucion
    @consulta = false
    if request.post?
      @consulta = true
      @venta = Venta.find_by :folio=>params[:folio]
      if @venta
        @itemsVenta  = @venta.item_ventas
      else
        @folio = params[:folio]
      end
    end
  end


  def factura_global_publico_gral
    #Una factura global es simplemente un Comprobante Fiscal que se emite por ventas que no están amparadas por un CFDI, se emite por que el contribuyente está obligado a reportar todos sus ingresos al SAT, no solo por los ingresos en la que los clientes exigieron una factura electrónica.
    require 'cfdi'
    require 'timbrado'

    certificado = CFDI::Certificado.new '/home/daniel/Documentos/prueba/CSD01_AAA010101AAA.cer'
    # Esta se convierte de un archivo .key con:
    # openssl pkcs8 -inform DER -in someKey.key -passin pass:somePassword -out key.pem
    llave = "/home/daniel/Documentos/timbox-ruby/CSD01_AAA010101AAA.key.pem"
    pass_llave = "12345678a"
    #Para obtener el numero consecutivo a partir de la ultima factura o de lo contrario asignarle por primera vez un número
    consecutivo = 0
    if current_user.sucursal.facturas.last
      consecutivo = current_user.sucursal.facturas.last.consecutivo
      if consecutivo
        consecutivo += 1
      end
    else
      consecutivo = 1 #Se asigna el número a la factura por default o de acuerdo a la configuración del usuario.
    end

    if current_user.sucursal.clave.present?
      #El folio de las facturas se forma por defecto por la clave de las sucursales, pero si el usuario quiere establecer sus propias series para otro fin, se tomará la serie que el usuario indique en las configuración de Facturas y Notas
      #claveSucursal = current_user.sucursal.clave
      claveSucursal = current_user.sucursal.clave
      folio_registroBD = claveSucursal + "F"
      folio_registroBD << consecutivo.to_s
      serie = claveSucursal + "F"
    else
      folio_default="F"
      folio_registroBD =folio_default
      #Una serie por default les guste o no les guste, pero útil para que no se produzca un colapso
      serie = folio_default
    end

#YA SE AGREGARON LA MAYORIA DE CAMPOS PREEDEFINIDOS Y MODIFICABLES SOLO FALAL VERIFICAR ALGUNOS...
=begin
    Lo que NO debe de contener el CFDI de ventas al público en general:
    Residencia Fiscal (Extranjero)
    ID de Registro (Extranjero)
=end

=begin
    Lo que SI debe de incluir:
    Forma de pago: Se debe incluír la forma de pago que predomine en el total de la factura. Sí existen dos o más formas de pago predominantes, se debe elegir la que consideren más conveniente. No esta permitido utilizar la clave “99-por definir”.
    Campos Predefinidos en el Concepto
      Datos que deben de contener los campos para que el SAT identifique que se trata de un CFDI Global:
    Campos modificables en el Concepto
      Los únicos campos del concepto que SI se pueden modificar son:
      Tipo de Cambio.
      Descuento (si existiera)
=end

    #Según la periodicidad en la que se expedirán facturas simplificadas(tomada de la configuración de facturación)
    hoy = Time.now.strftime("%Y-%m-%d")
    #inicio_semana
    #fin_semana
    #inicio_mes
    #fin_mes

    #begin
    #No usar rescue Exception => e. En su lugar, usar rescue => e o mejor aún, identificar la excepción que queremos capturar, como rescue ActiveRecord::RecordNotSaved.
    @ventas_del_dia = current_user.negocio.ventas.where(fechaVenta: hoy )
    #Se guardan en un arreglo solo las ventas que no están amparadas por un CFDI ( del dia, de la semana...)

    unless @ventas_del_dia.empty?

      @ventas=[]
      @ventas_del_dia.each do |v|
        if v.factura.blank?
            @ventas.push(v)
        end
      end
      #Se obtiene el nombre de la forma de pago (Que no es el nombre correcto pero bueno...)
      folio =  @ventas.max_by(&:montoVenta).venta_forma_pago.forma_pago.nombre

      #LLENADO DEL XML DIRECTAMENTE DE LA BASE DE DATOS
      fecha_expedicion_f = Time.now
      factura = CFDI::Comprobante.new({
        serie: serie,
        folio: consecutivo,
        fecha: fecha_expedicion_f,
        #Por defaulf el tipo de comprobante es de tipo "I" Ingreso
        #Moneda: MXN Peso Mexicano, USD Dólar Americano, Etc…
        #La moneda por default es MXN
        FormaPago:'01',
        #El campo Condiciones de pago no debe de existir
        #Método de pago: SIEMPRE debe ser la clave “PUE” (Pago en una sola exhibición); en el caso de que se venda a parcialidades o diferido, se deberá proceder a emitir el CFDI con complemento de pagos, detallando los datos del cliente que los realiza; en pocas palabras, no esta permitido emitir un CFDI global con ventas a parcialidades o diferidas.
        metodoDePago: 'PUE',
        #El código postal de la matriz o sucursal
        lugarExpedicion: current_user.sucursal.codigo_postal,#current_user.negocio.datos_fiscales_negocio.codigo_postal,#, #CATALOGO
        #total: 27.84#Como que ya es hora de pasarle el monto total de la venta más los impustos jaja para no usar calculadora
        #total:55.68
        #total: 83.52
        #total: 124.4 #Las tres ventas del día
        #total: 40.88
        total:96.56
        #Descuento:0 #DESCUENTO RAPPEL
      })
      #Estos datos no son requeridos por el SAT, sin embargo se usaran para la representacion impresa de los CFDIs.*
      #DATOS DEL EMISOR(Direción de la Matriz y son los que aparecen en el encabezado del comprobante)
      hash_domicilioEmisor = {}
      if current_user.negocio.datos_fiscales_negocio
        hash_domicilioEmisor[:calle] = current_user.negocio.datos_fiscales_negocio.calle ? current_user.negocio.datos_fiscales_negocio.calle : " "
        hash_domicilioEmisor[:noExterior] = current_user.negocio.datos_fiscales_negocio.numExterior ? current_user.negocio.datos_fiscales_negocio.numExterior : " "
        hash_domicilioEmisor[:noInterior] = current_user.negocio.datos_fiscales_negocio.numInterior ? current_user.negocio.datos_fiscales_negocio.numInterior : " "
        hash_domicilioEmisor[:colonia] = current_user.negocio.datos_fiscales_negocio.colonia ? current_user.negocio.datos_fiscales_negocio.colonia : " "
        #localidad: current_user.negocio.datos_fiscales_negocio.,
        #referencia: current_user.negocio.datos_fiscales_negocio.,
        hash_domicilioEmisor[:municipio] = current_user.negocio.datos_fiscales_negocio.municipio ? current_user.negocio.datos_fiscales_negocio.municipio : " "
        hash_domicilioEmisor[:estado] = current_user.negocio.datos_fiscales_negocio.estado ? current_user.negocio.datos_fiscales_negocio.estado : " "
        #pais: current_user.negocio.datos_fiscales_negocio.,
        hash_domicilioEmisor[:codigoPostal] = current_user.negocio.datos_fiscales_negocio.codigo_postal ? current_user.negocio.datos_fiscales_negocio.estado : " "
      end
      domicilioEmisor = CFDI::DatosComunes::Domicilio.new(hash_domicilioEmisor)
      #III. Sí se tiene más de un local o establecimiento, se deberá señalar el domicilio del local o
      #establecimiento en el que se expidan las Facturas Electrónicas
      #Estos datos no son requeridos por el SAT, sin embargo se usaran para la representacion impresa de los CFDIs.*
      expedidoEn= CFDI::DatosComunes::Domicilio.new({
        #Estos datos los uso como datos fiscales, sin current_user.sucursal.codigo_postalembargo si se hara distinción entre direccion comun y dirección fiscal,
        #se debera corregir.
        calle: current_user.sucursal.calle,
        noExterior: current_user.sucursal.numExterior,
        noInterior: current_user.sucursal.numInterior,
        colonia: current_user.sucursal.colonia,
        #localidad: current_user.negocio.datos_fiscales_negocio.,
        #referencia: current_user.negocio.datos_fiscalecurrent_user.sucursal.codigo_postals_negocio.,
        municipio: current_user.sucursal.municipio,
        estado: current_user.sucursal.estado,
        #pais: current_user.negocio.datos_fiscales_negocio.,
        codigoPostal: current_user.sucursal.codigo_postal
      })

      #ATRIBUTOS DEL EMISOR
      factura.emisor = CFDI::Emisor.new({
        #rfc: 'AAA010101AAA',
        rfc: current_user.negocio.datos_fiscales_negocio.rfc,
        nombre: current_user.negocio.datos_fiscales_negocio.nombreFiscal,
        regimenFiscal: current_user.negocio.datos_fiscales_negocio.regimen_fiscal, #CATALOGO
        domicilioFiscal: domicilioEmisor,
        expedidoEn: expedidoEn
      })
=begin
      #Estos datos no son requeridos por el SAT, sin embargo se usaran para la representacion impresa de los CFDIs.*
      domicilioReceptor = CFDI::DatosComunes::Domicilio.new({
        calle: @venta.cliente.datos_fiscales_cliente.calle,
        noExterior: @venta.cliente.datos_fiscales_cliente.numExterior,
        noInterior: @venta.cliente.datos_fiscales_cliente.numInterior,
        colonia: @venta.cliente.datos_fiscales_cliente.colonia,
        localidad: @venta.cliente.datos_fiscales_cliente.localidad,
        #referencia: current_user.negocio.datos_fiscales_negocio.,
        municipio: @venta.cliente.datos_fiscales_cliente.municipio,
        estado:@@venta.cliente.datos_fiscales_cliente.estado,    #pais: current_user.negocio.datos_fiscales_negocio.,
        codigoPostal: @venta.cliente.datos_fiscales_cliente.codigo_postal
      })
=end
      #ATRIBUTOS EL RECEPTOR
      factura.receptor = CFDI::Receptor.new({
         #RFC receptor: Debe contener el RFC genérico (XAXX010101000) y el campo “Nombre” no debe existir.
         rfc: "XAXX010101000",
         #nombre: "Dan",
         #El Uso del CFDI es un campo obligatorio, se registra la clave P01 (por definir).
         UsoCFDI: "P01"#,
         #domicilioFiscal: domicilioReceptor
        })

      cont = 0 #Para marcar los impuestos que le pertenecen a una venta
      @ventas.each do |v|
        factura.conceptos << CFDI::Concepto.new({
          #Clave de Producto o Servicio: 01010101 (Por Definir)
          ClaveProdServ: "01010101", #CATALOGO
          #En un CFDI normal es la clave interna que se le asigna a los productos pero que ni la ocupo por el momento...
          #Peo para un comprobante simplificado ess el Número de Identificación: En él se pondrá el número de folio del ticket de venta o número de operación del comprobante, este puede ser un valor alfanumérico de 1 a 20 dígitos.
          NoIdentificacion: v.folio,
          #Cantidad: Se debe incluir el valor “1″.
          Cantidad: 1 ,
          #Clave Unidad de Medida: Se debe incluir la clave “ACT” (Actividad).
          ClaveUnidad: "ACT",
          #Unidad de medida: No debe existir el campo.
          #Descripción: Debe tener el texto “Venta“.
          Descripcion: "Venta",
          #Valor unitario: El precio sin impuestos del concepto a facturar.()
          #En este campo se debe de registrarel subtotal del comprobante de operaciones con el público en gral.
          ValorUnitario: v.montoVenta,
          #El importe siempre será la tabla del 1 jaja 1x1=1 1x2=2...
          #Descuento: 0 #Expresado en porcentaje
        })
        #Impuestos Trasladados (IVA o IEPS)
        #Impuestos trasladados: Deben indicar:
          #la base
          #el tipo de impuestos
          #si es tasa o cuota,
          #el valor de esta de la tasa o cuota
          #el impuesto que trasladan por cada comprobante simplificado.
        @itemsVenta = v.item_ventas

        @itemsVenta.each do |c|

          if c.articulo.impuesto.present? && c.articulo.impuesto.tipo == "Federal"
            if c.articulo.impuesto.nombre == "IVA"
              clave_impuesto = "002"
            elsif c.articulo.impuesto.nombre == "IEPS"
              clave_impuesto =  "003"
            end
            factura.impuestos.traslados << CFDI::Impuesto::Traslado.new(base: c.precio_venta * c.cantidad,
              tax: clave_impuesto, type_factor: "Tasa", rate: format('%.6f',(c.articulo.impuesto.porcentaje/100)).to_f, concepto_id: cont)
          end
          #Los montos del IVA e IEPS deberán estar desglosados en forma expresa y por separado en cada uno de los CFDI globales.
        end
        cont += 1
      end

      #3.- SE AGREGA EL CERTIFICADO Y SELLO DIGITAL
      @total_to_w= factura.total_to_words
      # Esto hace que se le agregue al comprobante el certificado y su número de serie (noCertificado)
      certificado.certifica factura
      # Esto genera la factura como xml
      puts xml= factura.comprobante_to_xml
      # Para mandarla a un PAC, necesitamos sellarla, y esto lo hace agregando el sello
      archivo_xml = generar_sello(xml, llave, pass_llave)

      # Convertir la cadena del xml en base64
      xml_base64 = Base64.strict_encode64(archivo_xml)

      # Parametros para conexion al Webservice (URL de Pruebas)
      wsdl_url = "https://staging.ws.timbox.com.mx/timbrado_cfdi33/wsdl"
      usuario = "AAA010101000"
      contrasena = "h6584D56fVdBbSmmnB"

      gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
      storage=gcloud.storage

      bucket = storage.bucket "cfdis"


      #4.- ALTERNATIVA DE CONEXIÓN PARA CONSUMIR EL WEBSERVICE DE TIMBRADO CON TIMBOX
      #Se obtiene el xml timbrado
      xml_timbrado= timbrar_xml(usuario, contrasena, xml_base64, wsdl_url)

      #Se forma la cadena original del timbre fiscal digital de manera manual por que e mugroso xslt del SAT no Jala.
      factura.complemento=CFDI::Complemento.new(
        {
          Version: xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@Version'),
          uuid:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@UUID'),
          FechaTimbrado:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@FechaTimbrado'),
          RfcProvCertif:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@RfcProvCertif'),
          SelloCFD:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@SelloCFD'),
          NoCertificadoSAT:xml_timbrado.xpath('/cfdi:Comprobante/cfdi:Complemento//@NoCertificadoSAT')
        }
      )
      #se hace una copia del xml para modificarlo agregandole información extra para la representación impresa.
      xml_copia=xml_timbrado
      xml_timbrado_storage = factura.comprobante_to_xml #Hasta este punto se le agregado el complemento con eso es suficiente para el CFDI

      #5.- SE AGREGAN NUEVOS DATOS PARA LA REPRESENTACIÓN IMPRESA(INFORMACIÓN(PDF) IMPORTANTE PARA LOS CONTRIBUYENTES, PERO QUE AL SAT NO LE IMPORTAN JAJA)
      codigoQR=factura.qr_code xml_timbrado
      cadOrigComplemento=factura.complemento.cadena_TimbreFiscalDigital
      logo=current_user.negocio.logo
      #uso_cfdi_descripcion=@usoCfdi.descripcion

      #Se pasa un hash con la información extra en la representación impresa como: datos de contacto, dirección fiscal y descripcion de la clave de los catálogos del SAT.
      hash_info = {xml_copia: xml_copia, codigoQR: codigoQR, logo: logo, cadOrigComplemento: cadOrigComplemento, uso_cfdi_descripcion: "Por definir"}
      #hash_info[:Telefono1Receptor]= @@venta.cliente.telefono1 if @@venta.cliente.telefono1
      #hash_info[:EmailReceptor]= @@venta.cliente.email if @@venta.cliente.email


      xml_rep_impresa = factura.add_elements_to_xml(hash_info)
      #puts xml_rep_impresa
      template = Nokogiri::XSLT(File.read('/home/daniel/Documentos/sysChurch/lib/XSLT.xsl'))
      html_document = template.transform(xml_rep_impresa)
      #File.open('/home/daniel/Documentos/timbox-ruby/CFDImpreso.html', 'w').write(html_document)
      pdf = WickedPdf.new.pdf_from_string(html_document)

      #6.- SE ALMACENAN EN GOOGLE CLOUD STORAGE
      #Directorios
      dir_negocio = current_user.negocio.nombre
      dir_cliente = "Público en general"

      #Obtiene la fecha del xml timbrado para que no difiera de los comprobantes y del registro de la BD.
      #fecha_xml = xml_timbrado.xpath('//@Fecha')[0]
      fecha_registroBD=Date.parse(fecha_expedicion_f.to_s)
      dir_mes = fecha_registroBD.strftime("%m")
      dir_anno = fecha_registroBD.strftime("%Y")

      fecha_file= fecha_registroBD.strftime("%Y-%m-%d")
      #Nomenclatura para el nombre del archivo: consecutivo + fecha + extención
      file_name="#{consecutivo}_#{fecha_file}"

        #Cosas a tener en cuenta antes de indicarle una ruta:
          #1.-Un negocio puede o no tener sucursales
        if current_user.sucursal
          dir_sucursal = current_user.sucursal.nombre
          ruta_storage = "#{dir_negocio}/#{dir_sucursal}/#{dir_anno}/#{dir_mes}/#{dir_cliente}/#{file_name}"
        else
          ruta_storage = "#{dir_negocio}/#{dir_anno}/#{dir_mes}/#{dir_cliente}/#{file_name}"
        end

        #Los comprobantes de almacenan en google cloud
        file = bucket.create_file StringIO.new(pdf), "#{ruta_storage}_RepresentaciónImpresa.pdf"
        file = bucket.create_file StringIO.new(xml_timbrado_storage.to_s), "#{ruta_storage}_CFDI.xml"

        #El nombre del pdf formado por: consecutivo + fecha_registroBD
        nombre_pdf="#{consecutivo}_#{fecha_registroBD}_RepresentaciónImpresa.pdf"
        save_path = Rails.root.join('public',nombre_pdf)
        File.open(save_path, 'wb') do |file|
           file << pdf
        end

        archivo = File.open("public/#{consecutivo}_#{fecha_registroBD}_CFDI.xml", "w")
        archivo.write (xml)
        archivo.close

        #7.- SE ENVIAN LOS COMPROBANTES(pdf y xml timbrado) AL CLIENTE POR CORREO ELECTRÓNICO. :p
        destinatario = params[:destinatario]
        mensaje = current_user.negocio.config_comprobante.msg_email
        tema = current_user.negocio.config_comprobante.asunto_email
        #file_name = "#{consecutivo}_#{fecha_file}"
        comprobantes = {}
        #Aquí  no se da a elegir si desea enviar pdf o xml porque, porque, porque no jajaja
        comprobantes[:pdf] = "public/#{file_name}_RepresentaciónImpresa.pdf"
        comprobantes[:xml] = "public/#{file_name}_CFDI.xml"

        #FacturasEmail.factura_email(@destinatario, @mensaje, @tema).deliver_now
        #FacturasEmail.factura_email(destinatario, mensaje, tema, comprobantes).deliver_now


        #8.- SE SALVA EN LA BASE DE DATOS
          #Se crea un objeto del modelo Factura y se le asignan a los atributos los valores correspondientes para posteriormente guardarlo como un registo en la BD.
          folio_fiscal_xml = xml_timbrado.xpath('//@UUID')
          @factura = Factura.new(folio: folio_registroBD, fecha_expedicion: fecha_file, consecutivo: consecutivo, estado_factura:"Activa")

          @factura.folio_fiscal = folio_fiscal_xml
          @factura.ruta_storage =  ruta_storage
=begin
          if @factura.save
          current_user.facturas<<@factura
          current_user.negocio.facturas<<@factura
          current_user.sucursal.facturas<<@factura

          #Se factura a nombre del cliente que realizó la compra en el negocio.
          cliente_id=@@venta.cliente.id
          Cliente.find(cliente_id).facturas << @factura

          venta_id=@@venta.id
          Venta.find(venta_id).factura = @factura #relación uno a uno
          end
=end
          #fecha_expedicion=@factura.fecha_expedicion
          #file_name="#{consecutivo}_#{fecha_file}_RepresentaciónImpresa.pdf"
          #file=File.open( "public/#{file_name}")

          #Se comprueba que el archivo exista en la carpeta publica de la aplicación
          if File::exists?( "public/#{file_name}_RepresentaciónImpresa.pdf")
            file=File.open( "public/#{file_name}_RepresentaciónImpresa.pdf")
            send_file( file, :disposition => "inline", :type => "application/pdf")
            #File.delete("public/#{file_name}")
          else
            respond_to do |format|
              format.html { redirect_to action: "index" }
              flash[:notice] = "No se encontró la factura, vuelva a intentarlo!"
              #format.html { redirect_to facturas_index_path, notice: 'No se encontró la factura, vuelva a intentarlo!' }
            end
          end
      else
          redirect_to :back
          flash[:notice] = "No existe ninguna venta del día de hoy!"
      end
      #puts folio
    #rescue => e
      #puts "FECHA: #{hoy}"
      #puts "NO HAY VENTAS CON ESTA FECHA"
      #puts e
      #respond_to do |format|
      #  format.html { redirect_to facturas_index_path, notice: 'La factura fue registrada existoxamente!' }
      #end
    #end


  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_factura
      @factura = Factura.find(params[:id])
    end

    def set_sucursales
      @sucursales = current_user.negocio.sucursals
    end
    def set_clientes
      #
      @nombreFiscalClientes = DatosFiscalesCliente.where(cliente_id: current_user.negocio.clientes.where(negocio_id: current_user.negocio.id))
      #@clientes = current_user.negocio.clientes
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def factura_params
      params.require(:factura).permit(:uso_cfdi_id)
      #params.require(:factura).permit(:folio, :fecha_expedicion, :estado_factura,:venta_id, :user_id, :negocio_id, :sucursal_id, :cliente_id,:forma_pago_id, :folio_fiscal, :consecutivo)
    end
end
