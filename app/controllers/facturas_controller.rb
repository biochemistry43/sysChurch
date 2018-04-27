class FacturasController < ApplicationController
  before_action :set_factura, only: [:show, :edit, :update, :destroy, :readpdf, :enviar_email,:enviar_email_post, :descargar_cfdis, :cancelar_cfdi]
  #before_action :set_facturaDeVentas, only: [:show]
  before_action :set_cajeros, only: [:index, :consulta_facturas, :consulta_avanzada, :consulta_por_folio, :consulta_por_cliente]
  before_action :set_sucursales, only: [:index, :consulta_facturas, :consulta_avanzada, :consulta_por_folio, :consulta_por_cliente]

  #sirve para buscar la venta y mostrar los resultados antes de facturar.
  def facturaDeVentas
    @consulta = false
    if request.post?
      @consulta = true #determina si se realizó una consulta
      @venta = Venta.find_by :folio=>params[:folio] #si existe una venta con el folio solicitado, despliega una sección con los detalles en la vista
      @@venta=@venta

      #EMISOR
      @rfc_emisor_f= current_user.negocio.datos_fiscales_negocio.rfc #el rfc del emisor
      @nombre_fiscal_emisor_f=current_user.negocio.datos_fiscales_negocio.nombreFiscal

      #AQUÍ CONDICIONES PARA QUE MUESTRE EL NOMBRE Y NO LA CLAVE DEL REGIMEN.
      @regimen_fiscal_emisor_f=current_user.negocio.datos_fiscales_negocio.regimen_fiscal

      if @venta
        #blank lo contrario de presentar
        #Una venta solo se puede facturar una vez
        @ventaFacturadaNoSi=Venta.find_by(:folio=>params[:folio]).factura.blank?
        @ventaCancelada=@venta.status.eql?("Cancelada")

        #Por si a alguien se le ocurre querer facturar una venta cancelada jajaja
        #if @ventaCancelada
         #@fechaVentaCancelada=current_user.negocio.venta_canceladas.where("venta"=>@venta).fecha
        #end

        unless @ventaFacturadaNoSi
          @fechaVentaFacturada=Venta.find_by(:folio=>params[:folio]).factura.fecha_expedicion
          @folioVentaFacturada=Venta.find_by(:folio=>params[:folio]).factura.folio #Folio de la factura de la venta

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
        @rfc_receptor_f=@venta.cliente.rfc
        @nombre_fiscal_receptor_present=@venta.cliente.nombreFiscal.present?
        @nombre_fiscal_receptor_f=@venta.cliente.nombreFiscal

        #@nombre_receptor_f=@venta.cliente.nombre_completo
        @correo_electonico_f=@@venta.cliente.enviar_al_correo
        @uso_cfdi_receptor_f=UsoCfdi.all #@venta.cliente.uso_cfdi

        #COMPROBANTE
        #@c_unidadMedida_f=current_user.negocio.unidad_medidas.clave
        @total=@venta.montoVenta
        #@rfc_receptor=
        decimal = format('%.2f', @total).split('.')
        @total_en_letras="( #{@total.to_words.upcase} PESOS #{decimal[1]}/100 M.N.)"
        @fechaVenta=  @venta.fechaVenta

        @itemsVenta  = @venta.item_ventas

        @@itemsVenta=@itemsVenta

      else
        @folio = params[:folio]
      end
    end
  end

  def facturando
    require 'cfdi'
    require 'timbrado'

    if request.post?
      if params[:commit] == "Cancelar"
        @@venta=nil #Se borran los datos por si el usuario le da "atras" en el navegador.
        redirect_to facturas_index_path
      else
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
    #LLENADO DEL XML DIRECTAMENTE DE LA BASE DE DATOS
    #puts "Forma PAGOS"
    #puts @camposFormaPago = @@venta.venta_forma_pago.venta_forma_pago_campos
    factura = CFDI::Comprobante.new({
      serie: serie,
      folio: consecutivo,
      fecha: Time.now,
      #Por defaulf el tipo de comprobante es de tipo "I" Ingreso
      #La moneda por default es MXN
      #formaDePago: @@venta.venta_forma_pago.forma_pago.clave
      FormaPago:'01',#CATALOGO Es de tipo string
      condicionesDePago: 'Sera marcada como pagada en cuanto el receptor haya cubierto el pago.',
      metodoDePago: 'PUE', #CATALOGO
      lugarExpedicion: current_user.sucursal.codigo_postal,#current_user.negocio.datos_fiscales_negocio.codigo_postal,#, #CATALOGO
      total: 27.84#Como que ya es hora de pasarle el monto total de la venta más los impustos jaja para no usar calculadora
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

    #ATRIBUTOS DEL EMISOR
    factura.emisor = CFDI::Emisor.new({
      #rfc: 'AAA010101AAA',
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

    #ATRIBUTOS EL RECEPTOR
    @usoCfdi = UsoCfdi.find(params[:uso_cfdi_id])
    if @@venta.cliente.datos_fiscales_cliente.rfc.present?
      rfc_receptor_f=@@venta.cliente.datos_fiscales_cliente.rfc
    else
      #Si no está registrado el R.F.C del cliente, se registra asi de facil jaja
      rfc_receptor_f=params[:rfc_input]
      cliente_id=@@venta.cliente.id
      @cliente=Cliente.find(cliente_id)
      @cliente.update(:rfc=>params[:rfc_input])

    end
    #El mismo show q  el rfc, si el sistema detecta que el cliente no está registrado con su nombre fiscal, le pedirá al usuario que lo ingrese.
    if @@venta.cliente.datos_fiscales_cliente.nombreFiscal.present?
      nombre_fiscal_receptor_f=@@venta.cliente.datos_fiscales_cliente.nombreFiscal
    else
      nombre_fiscal_receptor_f=params[:nombre_fiscal_receptor_f]
      cliente_id=@@venta.cliente.id
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
    #@cont=0
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

      if c.articulo.impuesto.present? && c.articulo.impuesto.tipo == "Federal"

        if c.articulo.impuesto.nombre == "IVA"
          clave_impuesto = "002"
        elsif c.articulo.impuesto.nombre == "IEPS"
          clave_impuesto =  "003"
        end

        factura.impuestos.traslados << CFDI::Impuesto::Traslado.new(base: c.precio_venta * c.cantidad,
          tax: clave_impuesto, type_factor: "Tasa", rate: format('%.6f',(c.articulo.impuesto.porcentaje/100)).to_f )
      else
        #Me muero de programador jajaja pero con ésta salgo de apuros
        factura.impuestos.traslados << CFDI::Impuesto::Traslado.new(base: 0.0,
          tax: "Ninguno", type_factor: "Nada", rate: 0.0)
      end
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

    @total_to_w= factura.total_to_words
    # Esto hace que se le agregue al comprobante el certificado y su número de serie (noCertificado)
    certificado.certifica factura
    # Esto genera la factura como xml
    xml= factura.comprobante_to_xml

    #ALTERNATIVA DE CONEXIÓN PARA CONSUMIR EL WEBSERVICE DE TIMBRADO CON TIMBOX

    #Si se presiona el botón Guardar como borrador:
      #No se se sellará, ni se timbrará y mucho menos se generará la representación impresa
    #unless params[:commit] == "Guardar como borrador"

      # Para mandarla a un PAC, necesitamos sellarla, y esto lo hace agregando el sello
      archivo_xml = generar_sello(xml, llave, pass_llave)
      # Convertir la cadena del xml en base64
      xml_base64 = Base64.strict_encode64(archivo_xml)
      #Se obtiene el xml timbrado


      # Parametros para conexion al Webservice (URL de Pruebas)
      wsdl_url = "https://staging.ws.timbox.com.mx/timbrado_cfdi33/wsdl"
      usuario = "AAA010101000"
      contrasena = "h6584D56fVdBbSmmnB"

      xml_timbrado= timbrar_xml(usuario, contrasena, xml_base64, wsdl_url)

      #archivo = File.open("/home/daniel/Documentos/timbox-ruby/xml__33.xml", "w")
      #archivo.write (xml_timbrado)
      #archivo.close

      #File.open('/home/daniel/Documentos/timbox-ruby/xmlT33.xml', 'w').write(xml_timbrado)

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
      xml_timbrado_storage=xml_copia

      #Los nuevos datos para la representación impresa.
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
      #pdf =  WickedPdf.new.pdf_from_html_file(html_document)
      # Guardan los CFDI como representacion impresa en...
      save_path = Rails.root.join('/home/daniel/Documentos/timbox-ruby/','RepresentaciónImpresaCFDI_33.pdf')
      File.open(save_path, 'wb') do |file|
         file << pdf
      end

    #end

    gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
    storage=gcloud.storage

    bucket = storage.bucket "cfdis"

    #Directorios
    dir_negocio = current_user.negocio.nombre
    dir_cliente = nombre_fiscal_receptor_f

    #t = Time.now
    #Obtiene la fecha del xml timbrado para que no difiera de los comprobantes y del registro de la BD.
    fecha_xml = xml_timbrado.xpath('//@Fecha')[0]
    fecha_registroBD=Date.parse(fecha_xml.to_s)
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

    #Se crea un objeto del modelo Factura y se le asignan a los atributos los valores correspondientes para posteriormente guardarlo como un registo en la BD.
    @factura = Factura.new
    @factura.folio= folio_registroBD

    fecha_registroBD=Date.parse(fecha_xml.to_s)
    @factura.fecha_expedicion = fecha_registroBD#Time.parse(fecha_registroBD.to_s)

    #Condición para que agregue el consecutivo de acuerdo a la numeración establecida por el usuario en la configuración de la numeración de Facturas y Notas o aplicar la númeración por default.
    @factura.consecutivo=consecutivo
    @factura.ruta_storage = "#{ruta_storage}"

    #Los estados de las facturas pueden ser:
        #Borrador, Activa, Detenida, Cancelada
    @factura.estado_factura="Activa"

    #El nombre del pdf formado por: consecutivo + fecha_registroBD
    nombre_pdf="#{consecutivo}_#{fecha_registroBD}_RepresentaciónImpresa.pdf"
    save_path = Rails.root.join('public',nombre_pdf)
    File.open(save_path, 'wb') do |file|
       file << pdf
    end
=begin
    #Enviando un correo electrónico al cliente con los comprobantes adjuntos.
    if @@venta.cliente.email.present?
      correo_receptor = @@venta.cliente.email
      enviar = params[:enviar_al_correo]
      if "yes" == enviar
        email_negocio=current_user.negocio.email #== 'leinadlm95@gmail.com'
        Gmail.connect!('leinadlm95@gmail.com', 'ZGFuaQ==') {|gmail|
        #Vaya a la sección "Aplicaciones menos seguras" de mi cuenta .
        #https://myaccount.google.com/lesssecureapps
        gmail.deliver do
          to correo_receptor
          subject "TE ENVIO LA FACTURA!"
          text_part do
            body "Text of plaintext message."
          end
          html_part do
            content_type 'text/html; charset=UTF-8'
            body "<p>Text of <em>html</em> message.</p>"
          end

          add_file "public/#{nombre_pdf}"
        end
        }
      end
    else
      correo_electonico_receptor = params[:correo_electonico]
        email_negocio=current_user.negocio.email #== 'leinadlm95@gmail.com'
        Gmail.connect!('leinadlm95@gmail.com', 'ZGFuaQ==') {|gmail|
        #Vaya a la sección "Aplicaciones menos seguras" de mi cuenta .
        #https://myaccount.google.com/lesssecureapps
        gmail.deliver do
          to correo_electonico_receptor
          subject "TE ENVIO LA FACTURA!"
          text_part do
            body "Text of plaintext message."
          end
          html_part do
            content_type 'text/html; charset=UTF-8'
            body "<p>Text of <em>html</em> message.</p>"
          end
          add_file StringIO.new(pdf)
        end
        }
    end
=end
    #Se crea un nuevo registro en la BD.
    current_user.facturas<<@factura
    current_user.negocio.facturas<<@factura
    current_user.sucursal.facturas<<@factura

    folio_fiscal_xml = xml_timbrado.xpath('//@UUID')
    @factura.folio_fiscal=folio_fiscal_xml.to_s

    #Se factura a nombre del cliente que realizó la compra en el negocio.
    cliente_id=@@venta.cliente.id
    Cliente.find(cliente_id).facturas << @factura

    venta_id=@@venta.id
    Venta.find(venta_id).factura = @factura #relación uno a uno

    #La forma de pago pendiente...
    #forma_pago_id=@@venta.

      #Condicionar si:
          #si se pudo timbrar el xml
          #se pudo guardar en la nube
          #si se logró enviar por corre electronico
      if @factura.save
        fecha_expedicion=@factura.fecha_expedicion
        file_name="#{consecutivo}_#{fecha_expedicion}_RepresentaciónImpresa.pdf"
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
            #flash[:notice] = "La factura #{folio_registroBD} se guardó exitosamente!"
            #
          else
            respond_to do |format|
            format.html { redirect_to facturas_index_path, notice: 'La factura fue registrada existoxamente!' }
            end
          end

        end
      else
        flash[:notice] = "Error al intentar guardar la factura"
        redirect_to facturas_index_path
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
      @destinatario = params[:destinatario]
      @mensaje = params[:summernote]
      @tema = params[:tema]

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
      FacturasEmail.factura_email(@destinatario, @mensaje, @tema, comprobantes).deliver_now

      respond_to do |format|
        format.html { redirect_to action: "index"}
        flash[:notice] = "Los comprobantes se han enviado a #{@destinatario}!"
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
      @rfc = params[:rfc]
      cliente=Cliente.find_by rfc: @rfc
      @facturas = Factura.find_by cliente_id:cliente
      if can? :create, Negocio
        @facturas = current_user.negocio.facturas.where(cliente_id: cliente)
      else
        @facturas = current_user.sucursal.facturas.where(cliente_id: cliente)
      end
    end
  end

  def consulta_avanzada
    @consulta = true
    @avanzada = true

    @fechas=false
    @por_folio=false
    if request.post?
      @fechaInicial = DateTime.parse(params[:fecha_inicial_avanzado]).to_date
      @fechaFinal = DateTime.parse(params[:fecha_final_avanzado]).to_date
      perfil_id = params[:perfil_id]
      @cajero = nil
      unless perfil_id.empty?
        @cajero = Perfil.find(perfil_id).user
      end

      @estado_factura = params[:estado_factura]

      @suc = params[:suc_elegida]

      unless @suc.empty?
        @sucursal = Sucursal.find(@suc)
      end

      #Resultados para usuario administrador o subadministrador
      if can? :create, Negocio
        unless @suc.empty?
          #valida si se eligió un cajero específico para esta consulta
          if @cajero
            #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
            unless @estado_factura.eql?("Todas")
              @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, user: @cajero, estado_factura: @estado_factura, sucursal: @sucursal)
            else
              @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, user: @cajero, sucursal: @sucursal)
            end

          # Si no se eligió cajero, entonces no filtra las ventas por el cajero vendedor
          else
            #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
            unless @estado_factura.eql?("Todas")
              @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura, sucursal: @sucursal)
            else
              @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, sucursal: @sucursal)
            end
          end

        #Si el usuario no eligió ninguna sucursal específica, no filtra las ventas por sucursal
        else
          #valida si se eligió un cajero específico para esta consulta
          if @cajero
            #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
            unless @estado_factura.eql?("Todas")
              @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, user: @cajero, estado_factura: @estado_factura)
            else
              @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, user: @cajero)
            end

          # Si no se eligió cajero, entonces no filtra las ventas por el cajero vendedor
          else
            #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
            unless @estado_factura.eql?("Todas")
              @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura)
            else
              @facturas = current_user.negocio.facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal)
            end
          end
        end

      #Si el usuario no es un administrador o subadministrador
      else

        #valida si se eligió un cajero específico para esta consulta
        if @cajero

          #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
          unless @estado_factura.eql?("Todas")
            @facturas = current_user.sucursal.facturas.where(fechaVenta: @fechaInicial..@fechaFinal, user: @cajero, estado_factura: @estado_factura)
          else
            @facturas = current_user.sucursal.facturas.where(fechaVenta: @fechaInicial..@fechaFinal, user: @cajero)
          end #Termina unless @estado_factura.eql?("Todas")

        # Si no se eligió cajero, entonces no filtra las ventas por el cajero vendedor
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_factura
      @factura = Factura.find(params[:id])
    end
    def set_cajeros
      @cajeros = []
      if can? :create, Negocio
        current_user.negocio.users.each do |cajero|
          #Llena un array con todos los cajeros del negocio
          #(usuarios del negocio que pueden hacer una venta, no solo el rol de cajero)
          #Siempre y cuando no sean auxiliares o almacenistas pues no tienen acceso a punto de venta
          if cajero.role != "auxiliar" || cajero.role != "almacenista"
            @cajeros.push(cajero.perfil)
          end
        end
      else
        current_user.sucursal.users.each do |cajero|
          #Llena un array con todos los cajeros de la sucursal
          #(usuarios de la sucursal que pueden hacer una venta, no solo el rol de cajero)
          #Siempre y cuando no sean auxiliares o almacenistas pues no tienen acceso a punto de venta
          if cajero.role != "auxiliar" || cajero.role != "almacenista"
            @cajeros.push(cajero.perfil)
          end
        end
      end
    end
    def set_sucursales
      @sucursales = current_user.negocio.sucursals
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def factura_params
      params.require(:factura).permit(:uso_cfdi_id)
      #params.require(:factura).permit(:folio, :fecha_expedicion, :estado_factura,:venta_id, :user_id, :negocio_id, :sucursal_id, :cliente_id,:forma_pago_id, :folio_fiscal, :consecutivo)
    end
end
