class FacturasController < ApplicationController
  before_action :set_factura, only: [:mostrar_detalles, :edit, :update, :destroy, :visualizar_pdf, :enviar_email,:enviar_email_post, :descargar_cfdis, :descargar_acuses, :cancelar_factura, :cancelaFacturaVenta2]
  #before_action :set_facturaDeVentas, only: [:show]
  #before_action :set_cajeros, only: [:index, :consulta_facturas, :consulta_avanzada, :consulta_por_folio, :consulta_por_cliente]
  before_action :set_sucursales, only: [:index_facturas_ventas, :index_facturas_globales, :consulta_por_fecha, :consulta_avanzada, :consulta_por_folio, :consulta_por_cliente, :generarFacturaGlobal, :mostrarVentas_FacturaGlobal]
  before_action :set_clientes, only: [:index_facturas_ventas, :consulta_por_fecha, :consulta_avanzada, :consulta_por_folio, :consulta_por_cliente]

  # GET /facturas
  # GET /facturas.json
  def index_facturas_ventas
    @consulta = false
    @avanzada = false

    if request.get?
      #Con tipo_factura = "fv" obtengo solo las facturas de ventas
      if can? :create, Negocio
        @facturas = current_user.negocio.facturas.where(tipo_factura: params[:tipo_factura]).order(created_at: :desc).limit(500) # , created_at: Date.today.beginning_of_month..Date.today.end_of_month
      else
        @facturas = current_user.sucursal.facturas.where(tipo_factura: params[:tipo_factura]).order(created_at: :desc).limit(500)
      end
    end
  end

  def index_facturas_globales
    @consulta = false
    @avanzada = false

    if request.get?
      @tipo_factura = params[:tipo_factura]
      #Con tipo_factura = "fg" obtenengo solo las facturas globales
      if can? :create, Negocio
        @facturas = current_user.negocio.facturas.where(tipo_factura: params[:tipo_factura]).order(created_at: :desc).limit(500)
      else
        @facturas = current_user.sucursal.facturas.where(tipo_factura: params[:tipo_factura]).order(created_at: :desc).limit(500)
      end
    end
  end

  #sirve para buscar la venta y mostrar los resultados antes de facturar.
  def buscar_venta
    @consulta = false
    #if request.post?
      if can? :create, Negocio
        @venta = current_user.negocio.ventas.find_by :folio=>params[:folio]
      else
        @venta = current_user.sucursal.ventas.find_by :folio=>params[:folio]
      end
      @consulta = true
      #si existe una venta con el folio solicitado, despliega una sección con los detalles en la vista
      if @venta #&& current_user.negocio.id == @venta.negocio.id
        unless @venta.status.eql?("Cancelada") #Quiere decir que puede estar Activa o con devoluciones
          @ventaCancelada = false
          @monto_devolucion = 0
          #Puede ser el caso que una venta tenga devoluciones, si tiene devoluciones de monto menor al de la venta si se puede facturar.
          if @venta.status.eql?("Con devoluciones")#@venta.venta_canceladas.size > 0
            @monto_devolucion = 0
            @venta.venta_canceladas.each do |devolucion|
              @monto_devolucion += devolucion.monto
            end
          else
            @monto_devolucion = 0
          end #Fin de comprobación de venta con devoluciones

          #Solo si el monto de la suma de todas las devoluciones es inferior al monto de la venta
          if @monto_devolucion < @venta.montoVenta
            @ventaConDevolucionTotal = false
            @ventaFacturada = false
            @ventaParaFacturar = false
            if @venta.factura.present?
              @ventaFacturada = true
              if @venta.factura.estado_factura == "Activa"
                @ventaFacturaActiva = true
                #Las fechas solo para mostrar descripción de que la venta ya está facturada...
                @fechaVentaFacturada = @venta.factura.fecha_expedicion
                @folioVentaFacturada = @venta.factura.folio
              else
                @ventaFacturaActiva = false
              end #Fin de comprobación de venta con factura en estado activa
            end

            #Pudo haberse facturado anteriormente pero se canceló la factura sin cancelar la venta.
            #puede presentar devoluciones siempre y cuando el monto de las devoluciones no sea igual al al monto de la venta
            #O puede ser una venta que no haya sido facturada ninguna vez.
            if (@ventaFacturaActiva == false && @ventaFacturada ) || @ventaFacturada == false
              @ventaParaFacturar = true
              @consecutivo = 0
              if current_user.sucursal.facturas.last
                @consecutivo = current_user.sucursal.facturas.last.consecutivo
                if @consecutivo
                  @consecutivo += 1
                end
              else
                @consecutivo = 1 #Se asigna el número a la factura por default o de acuerdo a la configuración del usuario.
              end
              @serie = current_user.sucursal.clave

              #Datos del receptor (principalmente el rfc y el nombre fiscal)
              @email_receptor = @venta.cliente.email #Dirección para el envío de los comprobantes
              #Datos requeridos por el SAT por eso son de ley para la factura, pero cuando se trata de facturar una venta echa al publico en genera resulta que no existen datos fiscales.
              
              if @venta.cliente.datos_fiscales_cliente.present?
                datos_fiscales_cliente = @venta.cliente.datos_fiscales_cliente
                @rfc_receptor_f = datos_fiscales_cliente.rfc 
                @nombre_fiscal_receptor_f = datos_fiscales_cliente.nombreFiscal

                @calle_receptor_f = datos_fiscales_cliente.calle
                @noInterior_receptor_f = datos_fiscales_cliente.numInterior
                @noExterior_receptor_f = datos_fiscales_cliente.numExterior
                @colonia_receptor_f = datos_fiscales_cliente.colonia
                @localidad_receptor_f = datos_fiscales_cliente.localidad
                @municipio_receptor_f = datos_fiscales_cliente.municipio
                @estado_receptor_f = datos_fiscales_cliente.estado
                @referencia_receptor_f = datos_fiscales_cliente.referencia
                @cp_receptor_f = datos_fiscales_cliente.codigo_postal
                @pais_receptor_f = datos_fiscales_cliente.pais
                @uso_cfdi_receptor_f = UsoCfdi.all
              end

              @total_string = '%.2f' % @venta.montoVenta
              decimal = '%.2f' %  @venta.montoVenta.round(2)
              @total_en_letras="( #{@venta.montoVenta.to_words.upcase} PESOS #{decimal[1]}/100 M.N.)"
            end
          else
            @ventaConDevolucionTotal = true
          end
        else
          @ventaCancelada = true
        end
      else #Fin de la comprobación de existencia del folio de la venta del negocio
        @folioVenta = params[:folio]
      end
    #end
  end














  def facturar_venta
    if request.post?
      require 'cfdi' #Mi pequeña libreria para armar los CFDI (.xml) en la v. 3.3
      require 'timbrado' #Los  servicios de Timbox
      servicio = Timbox::Servicios.new 

      if params[:commit] == "Cancelar"
        redirect_to facturas_index_facturas_ventas_path(:tipo_factura => "fv")
      elsif params[:commit] == "Facturar ahora"
        #Se crea un objeto de nuestro contenedor de google cloud
        project_id = "cfdis-196902"
        credentials = File.open("public/CFDIs-0fd739cbe697.json")
        gcloud = Google::Cloud.new project_id, credentials
        storage = gcloud.storage
        bucket = storage.bucket "cfdis"

        @venta = Venta.find(params[:id])

        negocio = current_user.negocio
        datos_fiscales_negocio = negocio.datos_fiscales_negocio
        sucursal = current_user.sucursal
        datos_fiscales_sucursal = sucursal.datos_fiscales_sucursal

        #1.-Obtención de certificado, llave y clave
        certificado_bucket = bucket.file datos_fiscales_negocio.path_cer
        url_certificado = certificado_bucket.signed_url expires: 600 # 10 minutos, no tiene por que demorar más.
        certificado = CFDI::Certificado.new url_certificado

        llave_bucket = bucket.file datos_fiscales_negocio.path_key
        url_llave = llave_bucket.signed_url expires: 600
        password_llave = datos_fiscales_negocio.password
        llave = CFDI::Key.new url_llave, password_llave
=begin       
          #Se debe de crear una nota de crédito cuando se necesite facturar una venta que ya haya sido incluida en una factura global.
          if @venta.factura.present?
            if @factura.tipo_factura == "fg"
              @factura = @venta.factura
              #2.- LLENADO DEL XML DIRECTAMENTE DE LA BASE DE DATOS
              #Para obtener el numero consecutivo a partir de la ultima NC o de lo contrario asignarle por primera vez un número
              consecutivo_nc_fg = 0
              if current_user.sucursal.nota_creditos.find_by(tipo_factura: "fg").last
                consecutivo_nc_fg = current_user.sucursal.nota_creditos.find_by(tipo_factura: "fg").last.consecutivo
                if consecutivo_nc_fg
                  consecutivo_nc_fg += 1
                end
              else
                consecutivo_nc_fg = 1 
              end

              serie_nc_fg = current_user.sucursal.clave + "NCFG"
              fecha_expedicion_nc_fg = Time.now
              #La informacion de la nota de crédito debe de ser la misma que la del comprobante de ingreso a la que se le realizará el descuento, devolucion...
              nota_credito = CFDI::Comprobante.new({
                serie: serie_nc_fg,
                folio: consecutivo_nc_fg,
                #fecha: fecha_expedicion_nc,
                #Deberá ser de tipo Egreso
                tipoDeComprobante: "E",
                #La moneda por default es MXN
                #Forma de pago, opciones de registro:
                  #La que se registró en el comprobante de tipo ingreso.
                  #Con la que se está efectuando el descuento, devolución o bonificación en su caso.
                formaPago: @factura.factura_forma_pago.cve_forma_pagoSAT,
                #condicionesDePago: 'Sera marcada como pagada en cuanto el receptor haya cubierto el pago.',
                metodoDePago: 'PUE', #Deberá ser PUE- Pago en una sola exhibición
                lugarExpedicion: current_user.sucursal.datos_fiscales_sucursal.codigo_postal
                #total: @cantidad_devuelta.to_f * @itemVenta.precio_venta
              })

              #La dirección fiscal ya no es requerida por el SAT, sin embargo se usaran para la representacion impresa de los CFDIs si esque los proporciona el cliente jaja.*
              #Son datos que ya existen en el sistema por haber realizado la factura y no tienen por que asignarse otro valor para las NC
              datos_fiscales_negocio = current_user.negocio.datos_fiscales_negocio
              direccion_negocio_nc_fg = CFDI::DatosComunes::Domicilio.new({
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
                direccion_sucursal_nc_fg= CFDI::DatosComunes::Domicilio.new({
                  calle: datos_fiscales_sucursal.calle,
                  noExterior: datos_fiscales_sucursal.numExt,
                  noInterior: datos_fiscales_sucursal.numInt,
                  colonia: datos_fiscales_sucursal.colonia,
                  localidad: datos_fiscales_sucursal.localidad,#current_user.negocio.datos_fiscales_negocio.,
                  referencia: datos_fiscales_sucursal.referencia,#current_user.negocio.datos_fiscalecurrent_user.sucursal.codigo_postals_negocio.,
                  municipio: datos_fiscales_sucursal.municipio,
                  estado: datos_fiscales_sucursal.estado,
                  codigoPostal: datos_fiscales_sucursal.codigo_postal,
                })
              else
                expedidoEn= CFDI::DatosComunes::Domicilio.new({})
              end

              nota_credito.emisor = CFDI::Emisor.new({
                rfc: datos_fiscales_negocio.rfc,
                nombre: datos_fiscales_negocio.nombreFiscal,
                regimenFiscal: datos_fiscales_negocio.regimen_fiscal.cve_regimen_fiscalSAT, #CATALOGO
                domicilioFiscal: direccion_negocio_nc_fg,
                expedidoEn: direccion_sucursal_nc_fg
              })

              #Se cargan los mismo datos del receptor, aquí solo se trata de devolución y no de una nota de crédito para enmendar un error.
              #Atributos del receptor
              rfc_receptor_nc_fg = @factura.cliente.datos_fiscales_cliente.rfc
              nombre_fiscal_receptor_nc_fg = @factura.cliente.datos_fiscales_cliente.nombreFiscal
              #Al tratarse de un CFDI de egresos, no será un comprobante de deducción para el receptor, ya que se está emitiendo para disminuir el importe de un CFDI relacionado.
              #Por lo tanto el uso sera: G02 - Devoluciones, descuentos o bonificaciones

              nota_credito.receptor = CFDI::Receptor.new({
                rfc: rfc_receptor_nc_fg,
                nombre: nombre_fiscal_receptor_nc_fg,
                UsoCFDI: "G02",#G02", #"Devoluciones, descuentos o bonificaciones" Aplica para persona fisica y moral
                domicilioFiscal: domicilioReceptor
              })

              #Cuando se realiza una nota de crédito por devolución, el comprobante de egreso(nota de crédito) debe de contener solo los productos devueltos.
              items_vta_fg << @venta.item_ventas
              cont=0
              items_vta_fg.each do |c|
                hash_conceptos_vta_fg = {ClaveProdServ: c.articulo.clave_prod_serv.clave, #Catálogo
                                NoIdentificacion: c.articulo.clave,
                                Cantidad: c.cantidad,
                                ClaveUnidad:c.articulo.unidad_medida.clave,#Catálogo
                                Unidad: c.articulo.unidad_medida.nombre, #Es opcional para precisar la unidad de medida propia de la operación del emisor, pero pues...
                                Descripcion: c.articulo.nombre
                                }

                importe_concepto = (c.precio_venta * @cantidad_devuelta.to_f)#Incluye impuestos(si esq), descuentos(si esq)...
                if c.articulo.impuesto.present? #Impuestos a la inversa
                  tasaOCuota = (c.articulo.impuesto.porcentaje / 100)#Se obtiene la tasa o cuota por ej. 16% => 0.160000
                  #Se calcula el precio bruto de cada concepto
                  base_gravable = (importe_concepto / (tasaOCuota + 1)) #Se obtiene el precio bruto por item de venta
                  importe_impuesto_concepto = (base_gravable * tasaOCuota)

                  valorUnitario = base_gravable / @cantidad_devuelta.to_f

                  if c.articulo.impuesto.tipo == "Federal"
                    if c.articulo.impuesto.nombre == "IVA"
                      clave_impuesto = "002"
                    elsif c.articulo.impuesto.nombre == "IEPS"
                      clave_impuesto =  "003"
                    end
                    nota_credito.impuestos.traslados << CFDI::Impuesto::Traslado.new(base: base_gravable,
                      tax: clave_impuesto, type_factor: "Tasa", rate: tasaOCuota, import: importe_impuesto_concepto.round(2), concepto_id: cont)
                  #end
                  #elsif c.articulo.impuesto.tipo == "Local"
                    #Para el complemento de impuestos locales.
                  end
                  hash_conceptos_vta_fg[:ValorUnitario] = valorUnitario
                  hash_conceptos_vta_fg[:Importe] = base_gravable
                else
                  hash_conceptos_vta_fg[:ValorUnitario] = importe_concepto = c.precio_venta
                  hash_conceptos_vta_fg[:Importe] = importe_concepto
                end
                nota_credito.conceptos << CFDI::Concepto.new(hash_conceptos_vta_fg)
                cont += 1
              end

              nota_credito.uuidsrelacionados << CFDI::Cfdirelacionado.new({
                uuid: @venta.factura.folio_fiscal #Aquí se relaciona el comprobante de ingreso por la que se realizará la nota de crŕedito
                })
              nota_credito.cfdisrelacionados = CFDI::CfdiRelacionados.new({
                tipoRelacion: "03" # Devolución de mercancías sobre facturas o traslados previos
              })

              #3.- SE AGREGA EL CERTIFICADO Y EL SELLO DIGITAL
              total_letras_nc_fg= nota_credito.total_to_words
              # Esto hace que se le agregue al comprobante el certificado y su número de serie (noCertificado)
              certificado.certifica nota_credito
              #Se agrega el sello digital del comprobante, esto implica actulizar la fecha y calcular la plantilla_email original
              xml_certificado_sellado_nc_fg = llave.sella nota_credito

              #4.- TIMBRADO DEL XML CON TIMBOX POR MEDIO DE WEB SERVICE
              #Se obtiene el xml timbrado
              # Convertir la plantilla_email del xml en base64
              xml_base64_nc_fg = Base64.strict_encode64(xml_certificado_sellado_nc_fg)
              # Parametros para conexion al Webservice (URL de Pruebas)
              wsdl_url = "https://staging.ws.timbox.com.mx/timbrado_cfdi33/wsdl"
              usuario = "AAA010101000"
              contrasena = "h6584D56fVdBbSmmnB"

              xml_timbox_nc_fg = servicio.timbrar_xml(usuario, contrasena, xml_base64_nc_fg, wsdl_url)

              #Guardo el xml recien timbradito de timbox, calientito
              nc_id = NotaCredito.last ? NotaCredito.last.id + 1 : 1
              archivo = File.open("public/#{nc_id}_nc_fg.xml", "w")
              archivo.write (xml_timbox_nc_fg)
              archivo.close

              #Esto lo esxtraigo por extraer porq... Tengo pendiente comproobar que  sea valido
              nota_credito.complemento = CFDI::Complemento.new(
                {
                  Version: xml_timbox_nc_fg.xpath('/cfdi:Comprobante/cfdi:Complemento//@Version'),
                  uuid:xml_timbox_nc_fg.xpath('/cfdi:Comprobante/cfdi:Complemento//@UUID'),
                  FechaTimbrado:xml_timbox_nc_fg.xpath('/cfdi:Comprobante/cfdi:Complemento//@FechaTimbrado'),
                  RfcProvCertif:xml_timbox_nc_fg.xpath('/cfdi:Comprobante/cfdi:Complemento//@RfcProvCertif'),
                  SelloCFD:xml_timbox_nc_fg.xpath('/cfdi:Comprobante/cfdi:Complemento//@SelloCFD'),
                  NoCertificadoSAT:xml_timbox_nc_fg.xpath('/cfdi:Comprobante/cfdi:Complemento//@NoCertificadoSAT')
                }
              )
              #se hace una copia del xml para modificarlo agregandole información extra para la representación impresa.
              xml_copia_nc_fg = xml_timbox_nc_fg

              #5.- SE AGREGAN NUEVOS DATOS PARA LA REPRESENTACIÓN IMPRESA(INFORMACIÓN(PDF) IMPORTANTE PARA LOS CONTRIBUYENTES, PERO QUE AL SAT NO LE IMPORTAN JAJA)
              codigoQR = nota_credito.qr_code xml_timbox_nc_fg
              cadOrigComplemento = nota_credito.complemento.cadena_TimbreFiscalDigital
              logo = current_user.negocio.logo
              #No hay nececidad de darle a escoger el uso del cfdi al usuario.
              uso_cfdi_descripcion = "Devoluciones, descuentos o bonificaciones"
              #cve_descripcion_uso_cfdi_fg = "G02 - Devoluciones, descuentos o bonificaciones"
              cve_nombre_forma_pago = "#{@factura.factura_forma_pago.cve_forma_pagoSAT } - #{@factura.factura_forma_pago.nombre_forma_pagoSAT}"
              #método de pago(clave y descripción)
              #"deberá de ser siempre.. PUE"
              cve_nombre_metodo_pago = "PUE - Pago en una sola exhibición"
              #Regimen fiscal
              cve_regimen_fiscalSAT = current_user.negocio.datos_fiscales_negocio.regimen_fiscal.cve_regimen_fiscalSAT
              nomb_regimen_fiscalSAT = current_user.negocio.datos_fiscales_negocio.regimen_fiscal.nomb_regimen_fiscalSAT
              cve_nomb_regimen_fiscalSAT = "#{cve_regimen_fiscalSAT} - #{nomb_regimen_fiscalSAT}"
              #Para el nombre del changarro feo jajaja
              nombre_negocio = current_user.negocio.nombre

              #Personalización de la plantilla de impresión de una factura de venta. :P
              plantilla_impresion_nc_fg = current_user.negocio.config_comprobantes.find_by(comprobante: "nc")
              tipo_fuente = plantilla_impresion_nc_fg.tipo_fuente
              tam_fuente = plantilla_impresion_nc_fg.tam_fuente
              color_fondo = plantilla_impresion_nc_fg.color_fondo
              color_banda = plantilla_impresion_nc_fg.color_banda
              color_titulos = plantilla_impresion_nc_fg.color_titulos

              #Se pasa un hash con la información extra en la representación impresa como: datos de contacto, dirección fiscal y descripcion de la clave de los catálogos del SAT.
              hash_info = {xml_copia: xml_copia, codigoQR: codigoQR, logo: logo, cadOrigComplemento: cadOrigComplemento, uso_cfdi_descripcion: uso_cfdi_descripcion, cve_nombre_forma_pago: cve_nombre_forma_pago, cve_nombre_metodo_pago: cve_nombre_metodo_pago, cve_nomb_regimen_fiscalSAT:cve_nomb_regimen_fiscalSAT, nombre_negocio: nombre_negocio,
                tipo_fuente: tipo_fuente, tam_fuente: tam_fuente, color_fondo:color_fondo, color_banda:color_banda, color_titulos:color_titulos,
                tel_negocio: current_user.negocio.telefono, email_negocio: current_user.negocio.email, pag_web_negocio: current_user.negocio.pag_web
              }

              unless @factura.cliente.telefono1.to_s.strip.empty?
                hash_info[:Telefono1Receptor] =  @factura.cliente.telefono1
              else
                hash_info[:Telefono1Receptor] =  @factura.cliente.telefono2 unless receptor_final.telefono2.to_s.strip.empty?
              end
              hash_info[:EmailReceptor]= @factura.cliente.email unless @factura.cliente.email.to_s.strip.empty?
              #Solo si tiene más de un establecimiento el negocio...
              if current_user.sucursal
                hash_info[:tel_sucursal] = current_user.sucursal.telefono
                hash_info[:email_sucursal] = current_user.sucursal.email
              end

              xml_rep_impresa = nota_credito.add_elements_to_xml(hash_info)
              template = Nokogiri::XSLT(File.read('/home/daniel/Vídeos/sysChurch/lib/XSLT.xsl'))

              html_document = template.transform(xml_rep_impresa)
              #File.open('/home/daniel/Documentos/timbox-ruby/CFDImpreso.html', 'w').write(html_document)
              pdf = WickedPdf.new.pdf_from_string(html_document)
              #Se guarda el pdf 
              save_path = Rails.root.join('public',"#{nc_id}_nc_fg.pdf")
              File.open(save_path, 'wb') do |file|
                  file << pdf
              end
              #6.- SE ALMACENAN EN GOOGLE CLOUD STORAGE
              gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
              storage = gcloud.storage
              bucket = storage.bucket "cfdis"
              #Se realizan las consultas para formar los directorios en cloud
              dir_negocio = current_user.negocio.nombre
              dir_cliente = @factura.cliente.nombre_completo
              #Se separan. Se obtiene el día, mes y año de la fecha de emisión del comprobante
              fecha_registroBD = DateTime.parse(xml_timbox.xpath('//@Fecha').to_s) 
              dir_dia = fecha_registroBD.strftime("%d")
              dir_mes = fecha_registroBD.strftime("%m")
              dir_anno = fecha_registroBD.strftime("%Y")

              fecha_file = fecha_registroBD.strftime("%Y-%m-%d")
              #Nomenclatura para el nombre del archivo: id + tipo_documento
              ruta_storage = "#{dir_negocio}/#{dir_sucursal}/#{dir_cliente}/#{dir_anno}/#{dir_mes}/#{dir_dia}/#{nc_id}_nc_fg"

              #Los comprobantes de almacenan en google cloud
              #file = bucket.create_file StringIO.new(pdf), "#{ruta_storage}_RepresentaciónImpresa.pdf"
              #file = bucket.create_file StringIO.new(xml_timbox.to_s), "#{ruta_storage}_CFDI.xml"
              file = bucket.create_file "public/#{nc_id}_nc_fg.pdf", "#{ruta_storage}.pdf"
              file = bucket.create_file "public/#{nc_id}_nc_fg.xml", "#{ruta_storage}.xml"
              
              if @factura.save
                 current_user.facturas<<@factura
                 current_user.negocio.facturas<<@factura
                 current_user.sucursal.facturas<<@factura
                 forma_pago = FacturaFormaPago.find(params[:forma_pago_id])
                 forma_pago.facturas << @factura

                 #Se factura a nombre del cliente que realizó la compra en el negocio.
                 cliente_id=@venta.cliente.id
                 Cliente.find(cliente_id).facturas << @factura
                 #@venta.factura = @factura
                 @factura.ventas <<  @venta
              end

               #7.- SE REGISTRA LA NUEVA NOTA DE CRÉDITO EN LA BASE DE DATOS
              folio_fiscal_xml = xml_timbox_nc_fg.xpath('/cfdi:Comprobante/cfdi:Complemento//@UUID')
              @nota_credito = NotaCredito.new( consecutivo: consecutivo_nc_fg, folio: serie_nc_fg + consecutivo_nc_fg.to_s, fecha_expedicion: fecha_file, estado_nc:"Activa", ruta_storage: ruta_storage, monto: @cantidad_devuelta.to_f * @itemVenta.precio_venta, folio_fiscal: folio_fiscal_xml)

              if @nota_credito.save 
                current_user.nota_creditos << @nota_credito
                @factura.cliente.nota_creditos << @nota_credito
                current_user.negocio.nota_creditos << @nota_credito
                current_user.sucursal.nota_creditos << @nota_credito
                 #Forma de pago, opciones de registro:
                    #La que se registró en el comprobante de tipo ingreso o con la que se está efectuando el descuento, devolución o bonificación en su caso.
                @factura.factura_forma_pago.nota_creditos << @nota_credito

                #Esto se hace debido a que se permite crear comprobantes con captura manual de datos(Sin depender de una venta del sistema)
                @factura_nota_credito = FacturaNotaCredito.new(estado_nc: "Activa", estado_fv: "Activa") #El monto esa pendiente
                @factura.factura_nota_creditos << @factura_nota_credito
                @nota_credito.factura_nota_creditos << @factura_nota_credito
                @factura_nota_credito.save

                #Se elimina la relación entre la venta y la factura global para asignar la factura del cliente final
                @venta.factura = null
              end     
              #8.- SE ENVIAN LOS COMPROBANTES(pdf y xml timbrado) AL CLIENTE POR CORREO ELECTRÓNICO. :p
              #Se asignan los valores del texto variable de la configuración de las plantillas de email de las notas de crédito para las facturas globales
              require 'plantilla_email/plantilla_email.rb'        

              destinatario_contador = params[:destinatario_contador]
              mensaje = current_user.negocio.plantillas_emails.find_by(comprobante: "nc_fg").msg_email
              asunto = current_user.negocio.plantillas_emails.find_by(comprobante: "nc_fg").asunto_email

              plantilla_email = PlantillaEmail::AsuntoMensaje.new
              plantilla_email.nombCliente = @factura.cliente.nombre_completo #if mensaje.include? "{{Nombre del cliente}}"
                
              plantilla_email.fecha = fecha_file
              plantilla_email.numero = consecutivo_nc_fg
              plantilla_email.folio = serie_nc_fg + consecutivo_nc_fg.to_s
              #plantilla_email.total = @cantidad_devuelta.to_f * @itemVenta.precio_venta

              plantilla_email.nombNegocio = current_user.negocio.nombre 
              plantilla_email.nombSucursal = current_user.sucursal.nombre
              plantilla_email.emailContacto = current_user.sucursal.email
              plantilla_email.telContacto = current_user.sucursal.telefono
              #Chance su página web posteriormente dspues, un poco mas tarde jaja

              @mensaje = plantilla_email.reemplazar_texto(mensaje)
              @asunto = plantilla_email.reemplazar_texto(asunto)
                
              comprobantes = {pdf_nc:"public/#{nc_id}_nc_fg.pdf", xml_nc:"public/#{nc_id}_nc_fg.xml"}

              FacturasEmail.factura_email(destinatario_contador, @mensaje, @asunto, comprobantes).deliver_now

            end #Fin de comprobación: ¿La venta está incluida en una factura global?
          end #Fin de comprobación: ¿La venta está facturada?
=end
  #========================================================================================================================
        #2.- Se arma el CFDI (.xml) a como el señor SAT lo pide. 
        #Para obtener el numero consecutivo a partir de la ultima factura o de lo contrario asignarle por primera vez un número
        consecutivo = 0
        consecutivo = sucursal.facturas.where(tipo_factura: "fv").last.consecutivo if sucursal.facturas.where(tipo_factura: "fv").last
        consecutivo += 1

        clave_sucursal = sucursal.clave
        folio_registroBD = clave_sucursal + "FV" + consecutivo.to_s
        serie = clave_sucursal + "FV"

        forma_pago = FacturaFormaPago.find(params[:forma_pago_id])
        cve_metodo_pagoSAT = params[:metodo_pago]
      
        factura = CFDI::Comprobante.new({
          serie: serie,
          folio: consecutivo,
          #Por defaulf el tipo de comprobante es de tipo "I" Ingreso
          #La moneda por default es MXN
          formaPago: forma_pago.cve_forma_pagoSAT, #De los catálogos del SAT
          #condicionesDePago: 'Sera marcada como pagada en cuanto el receptor haya cubierto el pago.',
          metodoDePago: cve_metodo_pagoSAT, #De los catálogos del SAT
          #Al ingresar el Código Postal en este campo se cumple con el requisitode señalar el domicilio y lugar de expedición del comprobante a que se refieren las fracciones I y III del Artículo 29-A del CFF.
          lugarExpedicion: datos_fiscales_sucursal.codigo_postal, #De los catálogos del SAT
          total: '%.2f' % @venta.montoVenta.round(2)
        })

        #Todo esto lo eliminaré

        #Estos datos no son requeridos por el SAT, sin embargo se usaran para la representacion impresa de los CFDIs.*
        #Se obtienen los datos del emisor
        hash_domicilioEmisor = {}
        if current_user.negocio.datos_fiscales_negocio
          domicilioEmisor = CFDI::DatosComunes::Domicilio.new({
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
        else
          domicilioEmisor = CFDI::DatosComunes::Domicilio.new({})
        end

        #Estos datos no son requeridos por el SAT, sin embargo se usaran para la representacion impresa de los CFDIs.*
        if current_user.sucursal
          expedidoEn= CFDI::DatosComunes::Domicilio.new({
            calle: datos_fiscales_sucursal.calle,
            noExterior: datos_fiscales_sucursal.numExt,
            noInterior: datos_fiscales_sucursal.numInt,
            colonia: datos_fiscales_sucursal.colonia,
            localidad: datos_fiscales_sucursal.localidad,
            codigoPostal: datos_fiscales_sucursal.codigo_postal,
            municipio: datos_fiscales_sucursal.municipio,
            estado: datos_fiscales_sucursal.estado,
            referencia: datos_fiscales_sucursal.referencia
          })
        else
          expedidoEn= CFDI::DatosComunes::Domicilio.new({})
        end

        factura.emisor = CFDI::Emisor.new({
          #Para timbox el rfc en el ambiente prueba tanto del recepor como del emisor es: 'AAA010101AAA'
          rfc: datos_fiscales_negocio.rfc, 
          nombre: datos_fiscales_negocio.nombreFiscal,
          regimenFiscal: datos_fiscales_negocio.regimen_fiscal.cve_regimen_fiscalSAT,
          domicilioFiscal: domicilioEmisor,
          expedidoEn: expedidoEn
        })

        #Datos del receptor
        #Estos datos tampoco son requeridos por el SAT, sin embargo se reflejarán en la representacion impresa de los CFDIs si se desea agregar concienzudamente*
        #Los datos de facturación del receptor son recibidos de la vista porque puede ser facturado a otro mono distino al que hizo la compra o haber sido hecha al público en general.
        domicilioReceptor = CFDI::DatosComunes::Domicilio.new({
          calle: params[:calle_receptor_vf],
          noExterior: params[:no_exterior_receptor_vf],
          noInterior:params[:no_interior_receptor_vf],
          colonia: params[:colonia_receptor_vf],
          localidad: params[:localidad_receptor_vf],
          municipio: params[:municipio_receptor_vf],
          estado: params[:estado_receptor_vf],
          codigoPostal: params[:cp_receptor_vf],
          pais: params[:pais_receptor_vf],
          referencia: params[:referencia_receptor_vf]
        })

        uso_cfdi = UsoCfdi.find(params[:uso_cfdi_id])
        factura.receptor = CFDI::Receptor.new({
          #Datos requeridos si o si son: el rfc, nombre fiscal y el uso del CFDI.
           rfc: params[:rfc_input],
           nombre: params[:nombre_fiscal_receptor_vf],
           UsoCFDI:uso_cfdi.clave, #De los catálogos del SAT
           domicilioFiscal: domicilioReceptor
          })

        @itemsVenta = @venta.item_ventas
        cont=0
        @itemsVenta.each do |c|
          hash_conceptos={ClaveProdServ: c.articulo.clave_prod_serv.clave, #De los catálogos del SAT
                          NoIdentificacion: c.articulo.clave,
                          Cantidad: c.cantidad,
                          ClaveUnidad:c.articulo.unidad_medida.clave, #De los catálogos del SAT
                          Unidad: c.articulo.unidad_medida.nombre, #Es opcional para precisar la unidad de medida propia de la operación del emisor, pero pues...
                          Descripcion: c.articulo.nombre
                          }

          importe_concepto = (c.precio_venta * c.cantidad)#Incluye impuestos(si esq), descuentos(si esq)...
          if c.articulo.impuesto.present? #Impuestos a la inversa
            tasaOCuota = (c.articulo.impuesto.porcentaje / 100)#Se obtiene la tasa o cuota por ej. 16% => 0.160000
            #Se calcula el precio bruto de cada concepto
            base_gravable = (importe_concepto / (tasaOCuota + 1)) #Se obtiene el precio bruto por item de venta
            importe_impuesto_concepto = (base_gravable * tasaOCuota)

            valorUnitario = base_gravable / c.cantidad

            if c.articulo.impuesto.tipo == "Federal"
              if c.articulo.impuesto.nombre == "IVA"
                clave_impuesto = "002"
              elsif c.articulo.impuesto.nombre == "IEPS"
                clave_impuesto =  "003"
              end
              factura.impuestos.traslados << CFDI::Impuesto::Traslado.new(base: base_gravable,
                tax: clave_impuesto, type_factor: "Tasa", rate: tasaOCuota, import: importe_impuesto_concepto.round(2), concepto_id: cont)
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

        #3.- Se agrega el no. del certificado y sello digitall
        @total_to_w= factura.total_to_words
        # Esto hace que se le agregue al comprobante el certificado y su número de serie (noCertificado)
        certificado.certifica factura
        #Se agrega el sello digital del comprobante, esto implica actulizar la fecha y calcular la plantilla_email original
        xml_certificado_sellado = llave.sella factura
        #p xml_certificado_sellado

        #4.- Se manda el xml a Timbox para su validación y timbrado
        xml_base64 = Base64.strict_encode64(xml_certificado_sellado) 
        xml_timbox= servicio.timbrar_xml(xml_base64)

        uuid_cfdi = xml_timbox.xpath('//@UUID') #En una nota de credito se debe ser más especifico porque hay mas de un atributo llamado UUID
        #Es la fecha de expedición, no la de timbrado
        fecha_expedion = DateTime.parse(xml_timbox.xpath('//@Fecha').to_s)  
        #Se crea una ruta en cloud con el nombre del negocio, el nombre de la sucursal... para almacenar el CFDI y el PDF
        dir_negocio = negocio.nombre
        dir_sucursal = sucursal.nombre
        dir_cliente = params[:nombre_fiscal_receptor_vf]
        dir_anno = fecha_expedion.year
        dir_mes = fecha_expedion.month
        dir_dia = fecha_expedion.day

        ruta_storage = "#{dir_negocio}/#{dir_sucursal}/#{dir_cliente}/#{dir_anno}/#{dir_mes}/#{dir_dia}/"
        #Se guarda el CFDI en la nube en la ruta indicada.
        file = bucket.create_file StringIO.new(xml_timbox.to_s), "#{ruta_storage}#{uuid_cfdi}.xml"

        #Y también se guarda en la base de datos
        @factura = Factura.new(folio: folio_registroBD, fecha_expedicion: fecha_expedion, consecutivo: consecutivo, estado_factura:"Activa", cve_metodo_pagoSAT: cve_metodo_pagoSAT, monto: '%.2f' % @venta.montoVenta.round(2), folio_fiscal: uuid_cfdi, ruta_storage: ruta_storage, tipo_factura: "fv")#, monto: @venta.montoVenta)
        
        if @factura.save
           current_user.facturas<<@factura
           current_user.negocio.facturas<<@factura
           current_user.sucursal.facturas<<@factura
           forma_pago.facturas << @factura
           Cliente.find(params[:receptor_id]).facturas << @factura
           @factura.ventas << @venta
        end

        #La cadena original del complemento de certificación digital del SAT es un requisito para las representaciones impresas
        #Se oye muy intimidador, pero solo es una simple contatenación de seis atributos del CFDI timbrado jaja 
        #Se eliminan los espacios de nombres del CFDI para poder manipular mejor sus atributos armar el PDF. No hay porq que alarmarse, el CFDI ya fue guardado en la nuebe intacto

        #xml_timbox.remove_namespaces!
        elem_TimbreFiscalDigital = xml_timbox.at_xpath('//tfd:TimbreFiscalDigital', {'tfd' => 'http://www.sat.gob.mx/TimbreFiscalDigital'})
        factura.complemento = CFDI::Complemento.new(
          {
            Version: elem_TimbreFiscalDigital.attr('Version'),
            uuid: elem_TimbreFiscalDigital.attr('UUID'),
            FechaTimbrado: elem_TimbreFiscalDigital.attr('FechaTimbrado'),
            RfcProvCertif: elem_TimbreFiscalDigital.attr('RfcProvCertif'),
            SelloCFD: elem_TimbreFiscalDigital.attr('SelloCFD'),
            NoCertificadoSAT: elem_TimbreFiscalDigital.attr('NoCertificadoSAT')
          }
        )

        #Información extra para las representaciones impresas 
        codigoQR=factura.qr_code xml_timbox
        cadOrigComplemento=factura.complemento.cadena_TimbreFiscalDigital
        logo=current_user.negocio.logo
        uso_cfdi_descripcion = uso_cfdi.descripcion
        cve_nombre_forma_pago = "#{forma_pago.cve_forma_pagoSAT } - #{forma_pago.nombre_forma_pagoSAT}"
        cve_nombre_metodo_pago =  cve_metodo_pagoSAT == "PUE" ? "PUE - Pago en una sola exhibición" : "PPD - Pago en parcialidades o diferido"
        #Para la clave y nombre del regimen fiscal
        cve_regimen_fiscalSAT = current_user.negocio.datos_fiscales_negocio.regimen_fiscal.cve_regimen_fiscalSAT
        nomb_regimen_fiscalSAT = current_user.negocio.datos_fiscales_negocio.regimen_fiscal.nomb_regimen_fiscalSAT
        cve_nomb_regimen_fiscalSAT = "#{cve_regimen_fiscalSAT} - #{nomb_regimen_fiscalSAT}"
        #Para el nombre del changarro feo jajaja
        nombre_negocio = current_user.negocio.nombre

        #Personalización de la plantilla de impresión de una factura de venta. :P
        plantilla_impresion = current_user.negocio.config_comprobantes.find_by(comprobante: "fv")
        tipo_fuente = plantilla_impresion.tipo_fuente
        tam_fuente = plantilla_impresion.tam_fuente
        color_fondo = plantilla_impresion.color_fondo
        color_banda = plantilla_impresion.color_banda
        color_titulos = plantilla_impresion.color_titulos

        #Se pasa un hash con la información extra en la representación impresa como: datos de contacto, dirección fiscal y descripcion de la clave de los catálogos del SAT.
        hash_info = {xml_copia: xml_timbox, codigoQR: codigoQR, logo: logo, cadOrigComplemento: cadOrigComplemento, uso_cfdi_descripcion: uso_cfdi_descripcion, cve_nombre_forma_pago: cve_nombre_forma_pago, cve_nombre_metodo_pago: cve_nombre_metodo_pago, cve_nomb_regimen_fiscalSAT:cve_nomb_regimen_fiscalSAT, nombre_negocio: nombre_negocio,
          tipo_fuente: tipo_fuente, tam_fuente: tam_fuente, color_fondo:color_fondo, color_banda:color_banda, color_titulos:color_titulos,
          tel_negocio: current_user.negocio.telefono, email_negocio: current_user.negocio.email, pag_web_negocio: current_user.negocio.pag_web
        }
        #Datos de contacto del receptor
        receptor_id = params[:receptor_id]
        receptor_final = Cliente.find(receptor_id)
        unless receptor_final.telefono1.to_s.strip.empty?
          hash_info[:Telefono1Receptor] =  receptor_final.telefono1
        else
          hash_info[:Telefono1Receptor] =  receptor_final.telefono2 unless receptor_final.telefono2.to_s.strip.empty?
        end
        hash_info[:EmailReceptor]= receptor_final.email unless receptor_final.email.to_s.strip.empty?
        #Solo si tiene más de un establecimiento el negocio...
        if current_user.sucursal
          hash_info[:tel_sucursal] = current_user.sucursal.telefono
          hash_info[:email_sucursal] = current_user.sucursal.email
        end


        info_negocio = {
          LogoNegocio: negocio.logo,
          NombreNegocio: negocio.nombre,
          TelefonoNegocio: negocio.telefono,
          EmailNegocio: negocio.email,
          PaginaWebNegocio: negocio.pag_web,
          CveNombreRegimenFiscalSAT: "#{datos_fiscales_negocio.regimen_fiscal.cve_regimen_fiscalSAT} - #{datos_fiscales_negocio.regimen_fiscal.nomb_regimen_fiscalSAT}",
          DireccionFiscalNegocio: {
            Calle: datos_fiscales_negocio.calle,
            NoExterior: datos_fiscales_negocio.numExterior,
            NoInterior: datos_fiscales_negocio.numInterior,
            Colonia: datos_fiscales_negocio.colonia,
            localidad: datos_fiscales_negocio.localidad,
            Municipio: datos_fiscales_negocio.municipio,
            Estado: datos_fiscales_negocio.estado,
            CodigoPostal: datos_fiscales_negocio.codigo_postal,
            Referencia: datos_fiscales_negocio.referencia
          }
        }

        info_sucursal = {
          TelefonoSucursal: sucursal.telefono,
          EmailSucursal: sucursal.email,
          DireccionFiscalSucursal: {
            Calle: datos_fiscales_sucursal.calle,
            NoExterior: datos_fiscales_sucursal.numExt,
            NoInterior: datos_fiscales_sucursal.numInt,
            Colonia: datos_fiscales_sucursal.colonia,
            Localidad: datos_fiscales_sucursal.localidad,
            Municipio: datos_fiscales_sucursal.municipio,
            Estado: datos_fiscales_sucursal.estado,
            CodigoPostal: datos_fiscales_sucursal.codigo_postal,
            Referencia: datos_fiscales_sucursal.referencia
          }
        }

        receptor_final = Cliente.find(params[:receptor_id])
        info_receptor = {
          CveNombreUsoCFDI: "uso_cfdi.clave - #{uso_cfdi.descripcion}",
          TelefonoReceptor: receptor_final.telefono1,
          EmailReceptor:  receptor_final.email,
          DireccionFiscalReceptor: {
            Calle: params[:calle_receptor_vf],
            NoExterior: params[:no_exterior_receptor_vf],
            NoInterior:params[:no_interior_receptor_vf],
            Colonia: params[:colonia_receptor_vf],
            Localidad: params[:localidad_receptor_vf],
            Municipio: params[:municipio_receptor_vf],
            Estado: params[:estado_receptor_vf],
            CodigoPostal: params[:cp_receptor_vf],
            Pais: params[:pais_receptor_vf],
            Referencia: params[:referencia_receptor_vf]
          }
        }
        
        #codigoQR=factura.qr_code xml_timbox
        info_comprobante = {
          CadOrigComplemento: factura.complemento.cadena_TimbreFiscalDigital, #Esto debería estar en mi clase PDF
          #CodigoQR: generar_codigo_QR(uuid, rfc_receptor, rfc_emisor, comprobante, total, sello),
          TotalLetras: factura.total_to_words,
          CveNombreFormaPago: "#{forma_pago.cve_forma_pagoSAT } - #{forma_pago.nombre_forma_pagoSAT}",
          CveNombreMetodoPago: cve_nombre_metodo_pago
        }   #Personalización de la plantilla de impresión de una factura de venta. :P
        plantilla_impresion = negocio.config_comprobantes.find_by(comprobante: "fv")
        info_plantilla_impresion = {
          TipoFuente: plantilla_impresion.tipo_fuente,
          TamFuente: plantilla_impresion.tam_fuente,
          ColorFondo: plantilla_impresion.color_fondo,
          ColorBanda: plantilla_impresion.color_banda,
          ColorTitulos: plantilla_impresion.color_titulos
        }

        info_adicional = {
          InformacionAdicional: { 
            DatosComprobante: info_comprobante,
            PlantillaImpresion: info_plantilla_impresion,
            DatosNegocio: info_negocio,
            DatosSucursal: info_sucursal,
            DatosReceptor: info_receptor
          }
        }

        xml_info_adicional = Nokogiri::XML(info_adicional.to_xml)
        xml1 = xml_timbox.children.first.add_child(xml_info_adicional.children.first.clone)

        a = File.open("/home/daniel/Vídeos/xml_COMBINADO", "w")
        a.write (xml1)
        a.close



        xml_rep_impresa = factura.add_elements_to_xml(hash_info)
        #Se genera el pdf 
        template = Nokogiri::XSLT(File.read('/home/daniel/Vídeos/sysChurch/lib/Plantilla de facturas de ventas.xsl'))
        html_document = template.transform(xml_rep_impresa)
        pdf = WickedPdf.new.pdf_from_string(html_document)
        #Se guarda el pdf en la nube en la misma ruta que el CFDI
        file = bucket.create_file StringIO.new(pdf), "#{ruta_storage}#{uuid_cfdi}.pdf"





        
        #Se envian los comprobantes al email del receptor si se ha proporcionado un mail
        unless params[:destinatario].empty?
          destinatario_final = params[:destinatario]
          #Se obtiene la plantilla de email (asunto y mensaje)
          mensaje = negocio.plantillas_emails.find_by(comprobante: "fv").msg_email
          asunto = negocio.plantillas_emails.find_by(comprobante: "fv").asunto_email
          #Se asignan los valores del texto variable de la configuración de las plantillas de email.
          require 'plantilla_email/plantilla_email.rb'
          plantilla_email = PlantillaEmail::AsuntoMensaje.new
          plantilla_email.nombCliente = params[:nombre_fiscal_receptor_vf]
          plantilla_email.uuid = uuid_cfdi
          plantilla_email.fecha = fecha_expedion
          plantilla_email.folio = consecutivo
          plantilla_email.serie = serie
          plantilla_email.total = @venta.montoVenta
          plantilla_email.nombNegocio = negocio.nombre
          plantilla_email.nombSucursal = sucursal.nombre 
          plantilla_email.emailContacto = sucursal.email
          plantilla_email.telContacto = sucursal.telefono 
          plantilla_email.paginaWeb = negocio.pag_web

          mensaje = plantilla_email.reemplazar_texto(mensaje)
          asunto = plantilla_email.reemplazar_texto(asunto)

          #Se genera un enlace para el .xml y se agrega al mensaje
          xml_bucket = bucket.file "#{ruta_storage}#{uuid_cfdi}.xml"
          url_xml = xml_bucket.signed_url expires: 2629800 
          link_xml = "<a href=\"#{url_xml}\">CFDI</a><br>"
          mensaje = mensaje << link_xml

          #Se genera un enlace para el .pdf y se agrega al mensaje
          pdf_bucket = bucket.file "#{ruta_storage}#{uuid_cfdi}.pdf"
          url_pdf = pdf_bucket.signed_url expires: 2629800 
          link_pdf = "<a href=\"#{url}\">Representación impresa del CFDI</a><br>"
          mensaje = mensaje << link_pdf
          #Se envia el email en el mismo momento
          FacturasEmail.factura_email(destinatario_final, mensaje, asunto).deliver_now
        end

        #Se muestra el pdf o se redirige a al index
        if "yes" == params[:imprimir]
          send_file( File.open( "public/#{uuid_cfdi}.pdf"), :disposition => "inline", :type => "application/pdf")
        else
          respond_to do |format|
            format.html { redirect_to facturas_index_path, success: "La venta con folio #{@venta.folio} fue facturada exitosamente" }
          end
        end
      end #fin de else que permiten facturar
    end #Fin post
  end #Fin del controlador
































































  #==============================================ACCIONES PARA LAS FACTURAS

  # GET /facturas/1
  # GET /facturas/1.json
  def mostrar_detalles
    @uuid = @factura.folio_fiscal
    @folio = @factura.consecutivo
    @serie = @factura.folio.delete(@folio.to_s)

    if @factura.tipo_factura == "fv"
      @nombreFiscal = @factura.cliente.datos_fiscales_cliente.nombreFiscal
      @rfc = @factura.cliente.datos_fiscales_cliente.rfc 
    else
      #Datos predefinidos por el gran SAT
      @nombreFiscal = "Público en general"
      @rfc = "XAXX010101000"
    end
    @forma_pago = "#{@factura.factura_forma_pago.cve_forma_pagoSAT} - #{@factura.factura_forma_pago.nombre_forma_pagoSAT}"
    #= ni hay ventas a parcialidades :V
    @cve_nombre_metodo_pagoSAT = @factura.cve_metodo_pagoSAT == "PUE" ? "PUE - Pago en una sola exhibición" : "PPD - Pago en parcialidades o diferido"
  end

  #Para cancelar una factura, aunque también se puede cancelar al mismo tiempo la venta asociada.
  #cancelaFacturaVenta
  def cancelar_factura
    #Sola las facturas de ventas son especiales como yo.
    if @factura.tipo_factura == "fv"
=begin
    Cancelación del CFDI sin aceptación del receptor:
      De acuerdo a la regla 2.7.1.39 de la Resolución Miscelánea Fiscal para el 2018, los contribuyentes podrán cancelar un CFDI sin que se requiera la aceptación por parte del receptor en los siguientes supuestos:

      Que amparen ingresos por un monto de hasta $5,000.00 MXN.
      Por concepto de nómina.
      Por concepto de egresos.
      Por concepto de traslado.
      #Por concepto de ingresos expedidos a contribuyentes del RIF.
      Emitidos a través de la herramienta electrónica de “Mis cuentas” en el aplicativo “Factura Fácil”.
      Que amparen retenciones e información de pagos.
      Expedidos en operaciones realizadas con el público en general de conformidad con la regla 2.7.1.24.
      Emitidos a residentes en el extranjero para efectos fiscales conforme a la regla 2.7.1.26.
      A través del adquirente y sector primario (reglas 2.4.3 y 2.7.4.1 de la RMF).
      Cuando la cancelación se realice dentro de los tres días siguientes a su expedición. *
      En ambiente de pruebas se considera 10 mins después de generado el CFDI.

    Cancelación del CFDI con aceptación del receptor:
      Los anteriores supuestos no son aplicables para la cancelación con aceptación.

      Para realizar la cancelación, el receptor sólo contará con 3 días hábiles* una vez recibida la solicitud de cancelación para que se autorice o no dicho movimiento, en caso que el receptor no responda a la solicitud en el lapso de tiempo antes mencionado, la autoridad fiscal dará por aceptada la solicitud automáticamente.

      *En ambiente de pruebas se considera 15 mins después de recibida la solicitud de cancelación.

    Cancelación del CFDI con documentos relacionados:
      Si el CFDI contiene documentos relacionados, el emisor sólo podrá cancelarlo siempre y cuando cancelen los CFDI relacionados y en el mismo momento el CFDI origen y tenga estatus de proceso de cancelación igual a: “Cancelable con o sin aceptación”. 
=end
      require 'timbrado'
      servicio = Timbox::Servicios.new

      username = "AAA010101000"
      password = "h6584D56fVdBbSmmnB"
      rfc_emisor  = @factura.negocio.datos_fiscales_negocio.rfc
      rfc_receptor = @factura.tipo_factura == "fg" ? "XAXX010101000" : @factura.cliente.datos_fiscales_cliente.rfc
      #Se supone que el método acepta muchos folios, pero para esta acción solo aplica para la factura seleccionada
=begin
      Se usa solo en ambiente de pruebas para simular un comprobante con cfdis relacionados con los siguientes UUIDs:
        Documento Hija, es el primer comprobante y este no tiene nodo de documentos relacionados.
          AAAA0101-AAAA-AA01-0101-AAAAAA010101
        Documento Padre, documento al que se le agrega como relacionado el documento Hija.
          BBBB0202-BBBB-BB02-0202-BBBBBB020202
        Documento Abuelo, tercer documento al que se le relaciona el folio del CFDI identificado como Padre
          CCCC0303-CCCC-CC03-0303-CCCCCC030303
=end
      uuid = "AAAA0101-AAAA-AA01-0101-AAAAAA010101" #@factura.folio_fiscal
=begin    
      folios =  %Q^<folio>
                    <uuid xsi:type="xsd:string">#{uuid}</uuid>
                    <rfc_receptor xsi:type="xsd:string">#{rfc_receptor}</rfc_receptor>
                    <total xsi:type="xsd:string">#{@factura.monto}</total>
                  </folio>^

      cert_pem = OpenSSL::X509::Certificate.new File.read './public/certificado.cer'
      llave_pem = OpenSSL::PKey::RSA.new File.read './public/llave.pem'
      llave_password = "12345678a"
=end      
      total = @factura.monto

      #El servicio de “consultar_estatus” se utiliza para la consulta del estatus del CFDI, este servicio pretende proveer una forma alternativa de consulta que requiera verificar el estado de un comprobante en bases de datos del SAT. Los parámetros que se requieren en la consulta se describen en la siguiente tabla.  
=begin      
        Cuando el emisor del CFDI requiera cancelarlo, tendrá que consultar el estado del comprobante, si es cancelable, le enviará al receptor del mismo una “Solicitud de Cancelación” ya sea a través del Portal del SAT o del Webservice del PAC, es decir, el contribuyente que requiera cancelar una factura deberá primero solicitar autorización a su cliente.
        La función de este servicio es consultar los estatus de los comprobantes contemplando los siguientes: 
        Esta tabla muestra los estados posibles que puede regresar la consulta de un comprobante.

        Los ESTATUS POSIBLES que puede regresar la consulta de un comprobante => Corresponde al estado del xml
          No Encontrado: El comprobante no fue encontrado
          Vigente: El comprobante fue encontrado y no ha sido cancelado
          Cancelado: El comprobante fue encontrado y ha sido cancelado con anterioridad

        Los TIPOS DE CANCELACIÓN que el comprobante puede tener
          Cancelable con Aceptación: El comprobante puede ser cancelado enviando una solicitud la cual puede ser aceptada o rechazada
          Cancelable sin Aceptación: El comprobante puede ser cancelado automáticamente
          No Cancelable: El comprobante no puede ser cancelado*
          *No significa que no se pueda cancelar, si no que serán aquellos que cuenten con al menos un documento relacionado con estatus “Vigente”, el emisor sólo podrá cancelarlo siempre y cuando los comprobantes relacionados se cancelen en el mismo momento que el comprobante origen y tenga estatus de “Cancelable con o sin aceptación”.
        
        Los STATUS DE CANCELACIÓN que se pueden obtener al hacer la consulta
          Cancelado sin aceptación: El comprobante fue cancelado exitosamente sin requerir aceptación
          Cancelado con aceptación:  El comprobante fue cancelado aceptando la solicitud de cancelación
          En proceso:  El comprobante recibió una solicitud de cancelación y se encuentra en espera de una respuesta o aun no es reflejada
          Solicitud Rechazada: El comprobante no se cancelo porque se rechazo la solicitud de cancelación
          Plazo Vencido: El comprobante fue cancelado ya que no se recibió respuesta del receptor en el tiempo límite.

        TIMBOX LOCO!!! Todo lo anterior asi está en su documentación, pero a la hora de probar el nodo "estatus_cancelación" puede tener los valores del "TIPOS DE CANCELACIÓN" y "ESTATUS DE CANCELACIÓN" 
=end
      xml_consultar_status = servicio.consultar_estatus(username, password, rfc_emisor, rfc_receptor, uuid, total)

      @codigo_estatus = Nokogiri::XML(xml_consultar_status.xpath('//codigo_estatus').to_s).content.upcase
      @es_cancelable = Nokogiri::XML(xml_consultar_status.xpath('//es_cancelable').to_s).content.upcase #No tiene sentido esto, pero bueno
      @estado = Nokogiri::XML(xml_consultar_status.xpath('//estado').to_s).content.upcase
      @estatus_cancelacion = Nokogiri::XML(xml_consultar_status.xpath('//estatus_cancelacion').to_s).content.upcase
      
      p "RESPUESTAS DE TIMBOX:"
      p "codigo_estatus - #{@codigo_estatus}"
      p "es_cancelable - #{@es_cancelable}"
      p "estado - #{@estado}"
      p "estatus_cancelacion - #{@estatus_cancelacion}"

      if @codigo_estatus == "S - Comprobante obtenido satisfactoriamente.".upcase #YEAH!
        if @estado == "Vigente".upcase #YEAH!
          if @es_cancelable == "Cancelable con Aceptación".upcase #YEAH!
            @mensaje_cancelacion_timbox = "Para poder cancelar el comprobante es necesario enviarle una solicitud al cliente la cual puede ser aceptada o rechazada hasta en un plazo máximo de 72 horas o de no responder, se podrá cancelar la factura por plazo vencido."
            @descripcion_submit = "Realizar la petición de aceptación/rechazo"
            
            if @estatus_cancelacion == "En proceso".upcase 
              @mensaje_cancelacion_timbox = " El comprobante recibió una solicitud de cancelación y se encuentra en espera de una respuesta o aun no es reflejada, por favor espere a que el receptor responda, hasta en un máximo de 72 hrs o de no ser así se podrá cancelar por plazo vencido."
            elsif @estatus_cancelacion == "Solicitud Rechazada".upcase # => YEAH!
              @mensaje_cancelacion_timbox = "El comprobante no se canceló porque el receptor rechazó la solicitud de cancelación"
              #@mensaje_cancelacion_timbox = "El comprobante no se canceló porque se rechazó la solicitud de cancelación"
            end

          elsif @es_cancelable == "Cancelable sin Aceptación".upcase #YEAH!
            @categorias_devolucion = current_user.negocio.cat_venta_canceladas
            @descripcion_submit = "Cancelar factura"
            plantilla_email("ac_fv")
          elsif @es_cancelable == "No Cancelable".upcase
            #El comprobante no puede ser cancelado
            @mensaje_cancelacion_timbox = "El comprobante no se puede cancelar a menos que se cancelen los CFDIs relacionados e inmediatamente el CFDI origen y tenga estatus de proceso de cancelación igual a: “Cancelable con o sin aceptación”."
            @descripcion_submit = "Cancelar los documentos relacionados"
          end
        elsif @estado == "Cancelado".upcase #YEAH!
          #Si ya está cancelado ya no se puede cancelar jeje suena lógico, pero ahora entiendo que si se pueden cumplir las siguientes condiciones debido a que el estado en la BD del comprobante no cambia hasta que se realice la peticion de las cancelaciones pendientes, y todos aquellos q fueron aceptados por el cliente o pasados despues de 72 hrs se cambian a cancelado en el sistema(OMILOS). 
          if @estatus_cancelacion == "Cancelado sin aceptación".upcase #YEAH!
            @mensaje_cancelacion_timbox = "El comprobante fue cancelado exitosamente sin requerir aceptación"
          elsif @estatus_cancelacion = "Cancelado con aceptación".upcase
            @mensaje_cancelacion_timbox = "El comprobante fue cancelado aceptando la solicitud de cancelación"
          elsif @estatus_cancelacion == "Plazo Vencido".upcase
            @mensaje_cancelacion_timbox = "El comprobante fue cancelado ya que no se recibió respuesta del receptor en el tiempo límite."
          end
        elsif @estado == "No Encontrado".upcase
          #mensaje_cancelacion_timbox = ""
          @mensaje_cancelacion_timbox = "El comprobante no fue encontrado"
        end
      #Este código de respuesta se presentará cuando el UUID del comprobante no se encuentre en la Base de Datos del SAT.
      elsif @codigo_estatus == "N - 602: Comprobante no encontrado.".upcase #YEAH!
        #:3 dudo pero da igual, sería un caso terrible jaja
        @mensaje_cancelacion_timbox = "El comprobante no fue encontrado y esto se debe a que el UUID del comprobante no existe en la Base de Datos del SAT, porfavor pongase en contacto con nosotros para que podamos ayudarle" if @estado == "No Encontrado".upcase
      elsif @codigo_estatus == "N 601 - La expresión impresa proporcionada no es válida".upcase
         @mensaje_cancelacion_timbox = "La expresión impresa proporcionada no es válida"
      end
    #Con esto me evito consultar el estatus del comprobante. Las facturas globales se pueden cancelar al momento.
    elsif @factura.tipo_factura == "fg"
      @descripcion_submit = "Cancelar factura"
      @categorias_devolucion = current_user.negocio.cat_venta_canceladas
      plantilla_email("ac_fg")
    end
  end

  def cancelaFacturaVenta2

=begin
    Código Estatus
    N 601 La expresión impresa proporcionada no es válida Este código de respuesta se presentará cuando la petición de validación no se haya respetado en el formato definido.
    N 602 Comprobante no encontrado Este código de respuesta se presentará cuando el UUID del comprobante no se encuentre en la Base de Datos del SAT.
    S Comprobante obtenido satisfactoriamente Este código se presentará cuando el UUID del comprobante se encuentre en la Base de Datos del SAT

    Estado
    No Encontrado El comprobante no fue encontrado
    Vigente El comprobante fue encontrado y no ha sido cancelado
    Cancelado El comprobante fue encontrado y ha sido cancelado con anterioridad

    Es Cancelable
    Cancelable con Aceptación El comprobante puede ser cancelado enviando una solicitud la cual puede ser aceptada o rechazada
    Cancelable sin Aceptación El comprobante puede ser cancelado automáticamente
    No Cancelable El comprobante no puede ser cancelado

    estatus_cancelacion
    Cancelado sin aceptación  El comprobante fue cancelado exitosamente sin requerir aceptación
    Cancelado con aceptación  El comprobante fue cancelado aceptando la solicitud de cancelación
    En proceso  El comprobante recibió una solicitud de cancelación y se encuentra en espera de una respuesta o aun no es reflejada
    Solicitud Rechazada El comprobante no se cancelo porque se rechazo la solicitud de cancelación
    Plazo Vencido El comprobante fue cancelado ya que no se recibió respuesta del receptor en el tiempo límite.
=end    

    require 'timbrado'

    servicio = Timbox::Servicios.new
    username = "AAA010101000"
    password = "h6584D56fVdBbSmmnB"

    #Solo se recibe como parametro el resultado de la consulta 'es_cancelable' por que se supone que el comprobante se obtubo satisfactoriamente y está vigente
    if params[:commit] == "Realizar la petición de aceptación/rechazo" # => "Cancelable con Aceptación".upcase
      #Para la otra debo de poner mayor atención, en este servicio se necesita el CSD  del reseptor y no del emisor.
      cert_pem_receptor = OpenSSL::X509::Certificate.new File.read './public/certificado.cer'
      llave_pem_receptor = OpenSSL::PKey::RSA.new File.read './public/llave.pem'
      llave_password = "12345678a" 
      rfc_receptor = @factura.cliente.datos_fiscales_cliente.rfc
      rfc_emisor  = @factura.negocio.datos_fiscales_negocio.rfc
      total = @factura.monto
      uuid = @factura.folio_fiscal

      respuesta = "R"
      #Se supone que el método acepta muchos folios, pero para esta acción solo aplica para la factura seleccionada
      respuestas =  %Q^<folios_respuestas>
                          <uuid>#{uuid}</uuid>
                          <rfc_emisor>#{rfc_emisor}</rfc_emisor>
                          <total>#{total}</total>
                          <respuesta>#{respuesta}</respuesta>
                        </folios_respuestas>^

      #El servicio de “procesar_respuesta” se utiliza para realizar la petición de aceptación/rechazo de la solicitud de cancelación que se encuentra en espera de dicha resolución por parte del receptor del documento al servicio del SAT.     
      hash_procesar_respuesta =  servicio.procesar_respuesta(username, password, rfc_receptor, respuestas, cert_pem_receptor, llave_pem_receptor, llave_password)
      folios_respuesta = hash_procesar_respuesta[:procesar_respuesta_response][:procesar_respuesta_result][:folios]
      xml_folios_respuesta = Nokogiri::XML(folios_respuesta.to_s)
      uuid = xml_folios_respuesta.xpath('//uuid').text
      codigo = xml_folios_respuesta.xpath('//codigo').text
      mensaje = xml_folios_respuesta.xpath('//mensaje').text

      p "uuid - #{uuid}"
      p "codigo - #{codigo}"
      p "mensaje - #{mensaje}"
=begin
      Erores de validación:
        CANC108 El CFDI ha sido cancelado previamente por plazo vencido, no puede ser aceptado.
        CANC109 El CFDI ha sido cancelado previamente, no puede ser aceptado.
        CANC110 El CFDI ha sido cancelado previamente por plazo vencido, no puede ser rechazado.
        CANC111 El CFDI ha sido cancelado previamente, no puede ser rechazado

      Pasos para replicar cada error
        CANC108 
          Generar un comprobante
          Esperar 10 minutos
          Realizar la solicitud de cancelacion como emisor
          Esperar 15 minutos
          Aceptar la solicitud de cancelacion como receptor
        CANC109 
          Generar un comprobante
          Esperar 10 minutos
          Realizar la solicitud de cancelacion como emisor
          Aceptar la solicitud de cancelacion como receptor
          Volver a aceptar la solicitud de cancelacion
        CANC110 
          Generar un comprobante
          Esperar 10 minutos
          Realizar la solicitud de cancelacion como emisor
          Esperar 15 minutos
          Rechazar la solicitud de cancelacion como receptor
        CANC111 
          Generar un comprobante
          Esperar 10 minutos
          Realizar la solicitud de cancelacion como emisor
          Rechazar la solicitud de cancelacion como receptor
          Volver a rechazar la solicitud de cancelacion
=end
      @erorr_procesar_respuesta = Timbox::Errores::ERRORES_PROCESADO_RESPUESTA[codigo.to_s]      
      redirect_to :back, notice: "Se ha relizado una solicitud de cancelación al receptor de la factura. Ahora debe de esperar a que responda o a que trascurran 72 hrs para poder cancelar por plazo vencido"
      #Eso fue todo, esto no garantiza que se lleve a cabo la cancelación del comprobante a no ser que el receptor ACEPTE o pasen 72 hrs sin respuesta del receptor. 
      #Posteriormente se debe de consumir otro servicio para consultar las peticiones de los comprobantes que se encuentran pendientes por la aceptación o rechazo por parte del Receptor, pero ese seguimiento se hace en alguna otra parte del sistema.
    elsif params[:commit] == "Cancelar factura"# => "Cancelable sin Aceptación".upcase #YEAH!

      cert_pem_emisor = OpenSSL::X509::Certificate.new File.read './public/certificado.cer'
      llave_pem_emisor = OpenSSL::PKey::RSA.new File.read './public/llave.pem'
      llave_password = "12345678a"
      rfc_emisor  = @factura.negocio.datos_fiscales_negocio.rfc

       
      folios =  %Q^<folio>
                    <uuid xsi:type="xsd:string">#{uuid}</uuid>
                    <rfc_receptor xsi:type="xsd:string">#{rfc_receptor}</rfc_receptor>
                    <total xsi:type="xsd:string">#{@factura.monto}</total>
                  </folio>^
          #Se procede a cancelar en el mismo momento. Se cancela como se solia hacer antes, es decir directamente sin tantos rollos
          xml_cancelado =  servicio.cancelar_CFDIs(username, password, rfc_emisor, folios, cert_pem_emisor, llave_pem_emisor, llave_password)
          #se extrae el acuse de cancelación del xml cancelado
          acuse = xml_cancelado.xpath("//acuse_cancelacion").text

          gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
          storage=gcloud.storage
          bucket = storage.bucket "cfdis"

          #Se realizan las consultas para formar los directorios en cloud
          dir_negocio = current_user.negocio.nombre
          dir_sucursal = current_user.sucursal.nombre
          dir_cliente = @factura.cliente.nombre_completo

          #Se separan obtiene el día, mes y año de la fecha de emisión del comprobante
          fecha_cancelacion =  DateTime.parse(Nokogiri::XML(acuse).xpath("//@Fecha").to_s) #Es el único atributo llamado Fecha en el acuse :P
          dir_dia = fecha_cancelacion.strftime("%d")
          dir_mes = fecha_cancelacion.strftime("%m")
          dir_anno = fecha_cancelacion.strftime("%Y")

          ac_id = AcuseCancelacion.present? ? AcuseCancelacion.last.id + 1 : 1

          ruta_storage = "#{dir_negocio}/#{dir_sucursal}/#{dir_cliente}/#{dir_anno}/#{dir_mes}/#{dir_dia}/#{ac_id}_ac_#{@factura.tipo_factura}"
          #Se guarda el Acuse en la nube
          file = bucket.create_file StringIO.new(acuse.to_s), "#{ruta_storage}.xml"

          acuse = Nokogiri::XML(acuse)
          a = File.open("public/#{ac_id}_ac_#{@factura.tipo_factura}", "w")
          a.write (acuse)
          a.close

          #Se guarda el Acuse en la nube
          file = bucket.create_file StringIO.new(acuse.to_s), "#{ruta_storage}.xml"
          
          #El consecutivo para formar el folio del acuse de cancelación
          if @factura.tipo_factura == "fv"
            #El consecutivo del acuse de cancelación de la factura de venta
            consecutivo = 0
            if current_user.sucursal.acuse_cancelacions.where(comprobante: "fv").last
              consecutivo = current_user.sucursal.acuse_cancelacions.where(comprobante: "fv").last.consecutivo
              if consecutivo
                consecutivo += 1
              end
            else
              consecutivo = 1 #Se asigna el número a la factura por default o de acuerdo a la configuración del usuario.
            end
            folio = current_user.sucursal.clave + "ACFV" + consecutivo.to_s
          elsif @factura.tipo_factura == "fg"
            #El consecutivo del acuse de cancelación de la factura global
            consecutivo = 0
            if current_user.sucursal.acuse_cancelacions.where(comprobante: "fg").last
              consecutivo = current_user.sucursal.acuse_cancelacions.where(comprobante: "fg").last.consecutivo
              if consecutivo
                consecutivo += 1
              end
            else
              consecutivo = 1 #Se asigna el número a la factura por default o de acuerdo a la configuración del usuario.
            end
            folio = current_user.sucursal.clave +  "ACFG" + consecutivo.to_s
          end

          @factura_cancelada = AcuseCancelacion.new(folio: folio, comprobante: @factura.tipo_factura, consecutivo: consecutivo, fecha_cancelacion: fecha_cancelacion, ruta_storage: ruta_storage)#, monto: @venta.montoVenta)

          if @factura_cancelada.save
            current_user.negocio.acuse_cancelacions << @factura_cancelada
            current_user.sucursal.acuse_cancelacions << @factura_cancelada 
            current_user.acuse_cancelacions << @factura_cancelada
            
            #No hay relaciones entre la tabla Acuses y los derefrentes comprobantes, en lugar de ello solo hago referencia 
            if AcuseCancelacion.present?
              acuse_cancelacion_id = AcuseCancelacion.last.consecutivo
              if acuse_cancelacion_id
                acuse_cancelacion_id += 1
              end
            else
              acuse_cancelacion_id = 1 #Se asigna el número a la factura por default o de acuerdo a la configuración del usuario.
            end

            @factura.ref_acuse_cancelacion =  acuse_cancelacion_id
            @factura.update( estado_factura: "Cancelada")      
          end

          plantilla_email("ac_#{@factura.tipo_factura}")


          destinatario = params[:destinatario]
          comprobantes = {xml_Ac: "public/#{ac_id}_ac_#{@factura.tipo_factura}"}

          FacturasEmail.factura_email(destinatario, @mensaje, @asunto, comprobantes).deliver_now

          ventas = @factura.ventas #Venta.find_by(factura: @factura.id)

          if params[:rbtn] == "rbtn_factura_venta"
            categoria = params[:cat_cancelacion]
            cat_venta_cancelada = CatVentaCancelada.find(categoria)
            #venta = params[:venta]
            observaciones = params[:observaciones]

            #@items = @venta.item_ventas
            #Si la factura esta compuesta por varias ventas de un mismo cliente, pero que no sea una factura global... se realiza la devolución de cada una de ellas
            ventas.each do |vta|
              if vta.update(:observaciones => observaciones, :status => "Cancelada")
                #Se obtiene el movimiento de caja de sucursal, de la venta que se quiere cancelar
                movimiento_caja = vta.movimiento_caja_sucursal

                #Si el pago de la venta se realizó en efectivo, entonces se añade el monto de la venta al saldo de la caja
                if movimiento_caja.tipo_pago.eql?("efectivo")
                  caja_sucursal = vta.caja_sucursal
                  saldo = caja_sucursal.saldo
                  saldoActualizado = saldo - vta.montoVenta
                  caja_sucursal.saldo = saldoActualizado
                  caja_sucursal.save
                end

                #Se elimina el movimiento de caja relacionado con la venta
                movimiento_caja.destroy

                #Por cada item de venta, se crea un registro de venta cancelada.
                vta.item_ventas.each do |itemVenta|
                  ventaCancelada = VentaCancelada.new(:articulo => itemVenta.articulo, :item_venta => itemVenta, :venta => vta, :cat_venta_cancelada=>cat_venta_cancelada, :user=>current_user, :observaciones=>observaciones, :negocio=>vta.negocio, :sucursal=>vta.sucursal, :cantidad_devuelta=>itemVenta.cantidad, :monto=>itemVenta.monto)
                  ventaCancelada.save
                  itemVenta.status = "Con devoluciones"
                  itemVenta.save
                end
              end
            end
          end
    redirect_to :back, notice: "La factura fué cancelada correctamente sin aceptación del receptor"
    elsif params[:commit] == "Cancelar los documentos relacionados"
      
      cert_pem_emisor = OpenSSL::X509::Certificate.new File.read './public/certificado.cer'
      llave_pem_emisor = OpenSSL::PKey::RSA.new File.read './public/llave.pem'
      llave_password = "12345678a"

      rfc_receptor = @factura.cliente.datos_fiscales_cliente.rfc
=begin
      Se usa solo en ambiente de pruebas para simular un comprobante con cfdis relacionados con los siguientes UUIDs:
        Documento Hija, es el primer comprobante y este no tiene nodo de documentos relacionados.
          AAAA0101-AAAA-AA01-0101-AAAAAA010101
        Documento Padre, documento al que se le agrega como relacionado el documento Hija.
          BBBB0202-BBBB-BB02-0202-BBBBBB020202
        Documento Abuelo, tercer documento al que se le relaciona el folio del CFDI identificado como Padre
          CCCC0303-CCCC-CC03-0303-CCCCCC030303
=end
      uuid = "AAAA0101-AAAA-AA01-0101-AAAAAA010101" # => Se debe de cambiar por el UUID real en producción @factura.folio_fiscal 

          #Se obtienen los docuemnetos relacionados por  medio del siguiente servicio antes de cancelar el documento origen
          hash_documentos_relacionados = servicio.consultar_documento_relacionado(username, password, rfc_receptor, uuid, cert_pem_emisor, llave_pem_emisor, llave_password)
          #Se obtienen todos los folios de los comprobantes
          p hash_documentos_relacionados
          #No tendría que hacer todo este rollo, por que las notas de credito no requieren aceptación del receptor, pero si se lanza el sistema sin que relice venttas en parcialidades hay riesgo de que eso... o  amm que alguién haga un comprobante en otro sistema      
          hash_documentos_relacionados = hash_documentos_relacionados[:consultar_documento_relacionado_response][:consultar_documento_relacionado_result]
          resultado_documentos_relacionados = hash_documentos_relacionados[:resultado]
          p "DOCUMENTOS RELACIONADOS"
          p resultado_documentos_relacionados
          #Obtener el código del mensaje, lo demás no me importa q diga.
  
          #2000  Existen cfdi relacionados al folio fiscal.  Este código de respuesta se presentará cuando la petición de consulta encuentre documentos relacionados al UUID consultado.
          #2001  No existen cfdi relacionados al folio fiscal. Este código de respuesta se presentará cuando el UUID consultado no contenga documentos relacionados a el.
          #2002  El folio fiscal no pertenece al receptor. Este código de respuesta se presentará cuando el RFC del receptor no corresponda al UUID consultado.
          #1101  No existen peticiones para el RFC Receptor. Este código se regresa cuando la consulta se realizó de manera exitosa, pero no se encontraron solicitudes de cancelación para el rfc receptor.
          ['Clave: 2000', 'Clave: 2001', 'Clave: 2002', 'Clave: 1101'].each { |cve| @clave = cve if resultado_documentos_relacionados.include? cve }
          #Solo si se encontraron documentos relacionados
          if 'Clave: 2000' == @clave 
            if hash_documentos_relacionados.key?(:relacionados_padres)
              relacionados_padres = hash_documentos_relacionados[:relacionados_padres]
              
              Nokogiri::XML(relacionados_padres.to_s).xpath('//uuid_padre').each do |doc_padre|
                uuid_documento_relacionado = doc_padre.xpath('//uuid').text
                rfc_emisor_documento_relacionado = doc_padre.xpath('//rfc-emisor').text
                rfc_receptor_documento_relacionado = doc_padre.xpath('//rfc-receptor').text
                
                #1.-Se consulta el estatus por cada documento padre
                #Entons... a consumir otro servicio para los detalles del comprobante
                total = @factura.monto #El total debe deser del comprobante 
                
                xml_consultar_status = servicio.consultar_estatus(username, password, rfc_emisor_documento_relacionado.to_s, rfc_receptor_documento_relacionado.to_s, uuid_documento_relacionado.to_s, total)
              
                codigo_estatus = Nokogiri::XML(xml_consultar_status.xpath('//codigo_estatus').to_s).content.upcase
                es_cancelable = Nokogiri::XML(xml_consultar_status.xpath('//es_cancelable').to_s).content.upcase #No tiene sentido esto, pero bueno
                estado = Nokogiri::XML(xml_consultar_status.xpath('//estado').to_s).content.upcase
                estatus_cancelacion = Nokogiri::XML(xml_consultar_status.xpath('//estatus_cancelacion').to_s).content.upcase
                p "DEL RELACIONADO (DOC PADRE)"
                p codigo_estatus
                p es_cancelable
                p estado
                p estatus_cancelacion

                #Para mostrar un mensaje para cualquier caso que pudiera suceder por cada 
                if codigo_estatus == "S - Comprobante obtenido satisfactoriamente.".upcase #YEAH!
                  if estado == "Vigente".upcase #YEAH!
                    if es_cancelable == "Cancelable con Aceptación".upcase #YEAH!
                      mensaje_cancelacion_timbox = "Para poder cancelar el comprobante es necesario enviarle una solicitud al cliente la cual puede ser aceptada o rechazada hasta en un plazo máximo de 72 horas o de no responder, se podrá cancelar la factura por plazo vencido."
                      if estatus_cancelacion == "En proceso".upcase 
                        mensaje_cancelacion_timbox = " El comprobante recibió una solicitud de cancelación y se encuentra en espera de una respuesta o aun no es reflejada, por favor espere a que el receptor responda, hasta en un máximo de 72 hrs o de no ser así se podrá cancelar por plazo vencido."
                      elsif estatus_cancelacion == "Solicitud Rechazada".upcase # => YEAH!
                        mensaje_cancelacion_timbox = "El comprobante no se canceló porque el receptor rechazó la solicitud de cancelación"
                        #@mensaje_cancelacion_timbox = "El comprobante no se canceló porque se rechazó la solicitud de cancelación"
                      end
                    elsif es_cancelable == "Cancelable sin Aceptación".upcase #YEAH!
                    elsif es_cancelable == "No Cancelable".upcase
                      #El comprobante no puede ser cancelado
                      mensaje_cancelacion_timbox = "El comprobante no se puede cancelar a menos que se cancelen los CFDIs relacionados e inmediatamente el CFDI origen y tenga estatus de proceso de cancelación igual a: “Cancelable con o sin aceptación”."
                    end
                  elsif estado == "Cancelado".upcase #YEAH!
                    #Si ya está cancelado ya no se puede cancelar jeje suena lógico, pero ahora entiendo que si se pueden cumplir las siguientes condiciones debido a que el estado en la BD del comprobante no cambia hasta que se realice la peticion de las cancelaciones pendientes, y todos aquellos q fueron aceptados por el cliente o pasados despues de 72 hrs se cambian a cancelado en el sistema(OMILOS). 
                    if estatus_cancelacion == "Cancelado sin aceptación".upcase #YEAH!
                      mensaje_cancelacion_timbox = "El comprobante fue cancelado exitosamente sin requerir aceptación"
                    elsif estatus_cancelacion = "Cancelado con aceptación".upcase
                      mensaje_cancelacion_timbox = "El comprobante fue cancelado aceptando la solicitud de cancelación"
                    elsif estatus_cancelacion == "Plazo Vencido".upcase
                      mensaje_cancelacion_timbox = "El comprobante fue cancelado ya que no se recibió respuesta del receptor en el tiempo límite."
                    end
                  elsif estado == "No Encontrado".upcase
                    #mensaje_cancelacion_timbox = ""
                    mensaje_cancelacion_timbox = "El comprobante no fue encontrado"
                  end
                #Este código de respuesta se presentará cuando el UUID del comprobante no se encuentre en la Base de Datos del SAT.
                elsif codigo_estatus == "N - 602: Comprobante no encontrado.".upcase #YEAH!
                  #:3 dudo pero da igual, sería un caso terrible jaja
                  mensaje_cancelacion_timbox = "El comprobante no fue encontrado y esto se debe a que el UUID del comprobante no existe en la Base de Datos del SAT, porfavor pongase en contacto con nosotros para que podamos ayudarle" if @estado == "No Encontrado".upcase
                elsif codigo_estatus == "N 601 - La expresión impresa proporcionada no es válida".upcase
                   mensaje_cancelacion_timbox = "La expresión impresa proporcionada no es válida"
                end
              end
              #2.-Se consulta el eststus del doc relacionado
              #3.-Se cancelan los doc relacionados
            end
      end          
    end
  end

  def visualizar_pdf
    # bucket_name = "Su nombre de depósito de Google Cloud Storage"
    # project_id = "cfdis-196902","public/CFDIs-0fd739cbe697.json"# project_id = "Su ID de proyecto de Google Cloud"
    project_id = "cfdis-196902"
    credentials = File.open("public/CFDIs-0fd739cbe697.json")
    gcloud = Google::Cloud.new project_id, credentials
    storage = gcloud.storage
    bucket = storage.bucket "cfdis"

    #Por supuesto que los comprobantes no estarán toda la vida ocupando espaci. Son "5 años" los que deben de conservarse... 
    begin
      file = bucket.file "#{@factura.ruta_storage}#{@factura.folio_fiscal}.pdf"
      url = file.signed_url expires: 600 #10 minutos es hasta mucho
      pdf_url = open(url) 
      #file_download_storage = bucket.file "#{storage_file_path}#{uuid}.pdf"
      #file_download_storage.download "public/#{uuid}.pdf"
    rescue
      respond_to do |format|
        if @factura.tipo_factura == "fv"
          format.html { redirect_to facturas_index_facturas_ventas_path(:tipo_factura => "fv")}
          flash[:danger] = "No se pudo recuperar la facura de venta, vuelva a intentarlo más tarde"
        elsif @factura.tipo_factura == "fg"
          format.html { redirect_to facturas_index_facturas_globales_path(:tipo_factura => "fg")}
          flash[:danger] = "No se pudo recuperar la facura global, vuelva a intentarlo más tarde"
        end
      end
    else
      if @factura.estado_factura == "Activa"
        file_name = @factura.tipo_factura == "fg" ? "Factura global.pdf" : "Factura de venta.pdf"
        send_data pdf_url.read, filename: file_name, type: "application/pdf", disposition: 'inline'#, stream: 'true', buffer_size: '4096'
        #send_file(pdf_IO, :disposition => "inline", :type => "application/pdf")
      else
          #Tengo que ponerle una marca de agua al pdf que diga CANCELADA. :3
      end
    end
  end

  def enviar_email_post
    #Se optienen los datos que se ingresen o en su caso los datos de la configuracion del mensaje de los correos.
    if request.post?
      destinatario_final = params[:destinatario]
      tipo_factura = @factura.tipo_factura

      asunto_email =  params[:asunto] 
      mensaje_email = params[:summernote]

      project_id = "cfdis-196902"
      credentials = File.open("public/CFDIs-0fd739cbe697.json")
      gcloud = Google::Cloud.new project_id, credentials
      storage = gcloud.storage
      bucket = storage.bucket "cfdis"

      #El método <signed> de cloud genera un error si <storage_file_path> no existe
      begin
      #Debería de hacer esto por cada archivo, pero... naaa
        if @factura.estado_factura == "Activa"
          uuid = @factura.folio_fiscal
          storage_file_path = @factura.ruta_storage
          #Si selecciona la casilla de pdf 
          if params[:xml_factura_activa] == "yes"
            file = bucket.file "#{storage_file_path}#{uuid}.xml"
            url = file.signed_url expires: 2629800 

            link = "<a href=\"#{url}\">CFDI</a><br>"
            mensaje_email = mensaje_email << link
          end
          if params[:pdf_factura_activa] == "yes"
            file = bucket.file "#{storage_file_path}#{uuid}.pdf"
            url = file.signed_url expires: 2629800 

            link = "<a href=\"#{url}\">Representación impresa del CFDI</a><br>"
            mensaje_email = mensaje_email << link
          end
        elsif @factura.estado_factura == "Cancelada"
          #Solo es posible si la factura de venta está cancelada
          #Pendiente
          if params[:xml_acuse_cancelacion] == "yes"
            acuse_cancelacion = AcuseCancelacion.find(@factura.ref_acuse_cancelacion)
            storage_file_path = acuse_cancelacion.ruta_storage
            #Ni que hacerle, los acuses no tienen uuid para identificarlos asi que husaré el del sistema.
            id = acuse_cancelacion.id
            file = bucket.file "#{storage_file_path}Acuse_#{id}.xml"
            url = file.signed_url expires: 2629800 
            link = "<a href=\"#{url}\">Acuse de cancelación</a><br>"
            mensaje_email = mensaje_email << link
          end
=begin
          if params[:pdf_factura_cancelada] == "yes"
            uuid = @factura.folio_fiscal
            storage_file_path = @factura.ruta_storage
            file = bucket.file "#{storage_file_path}#{uuid}.xml"
            url = file.signed_url expires: 2629800 

            link = "<a href=\"#{url}\">Representación impresa del CFDI cancelado</a><br>"
            mensaje_email = mensaje_email << link
          end
=end
        end
        #Se enviá al momento
        FacturasEmail.factura_email(destinatario_final, mensaje_email, asunto_email).deliver_now
      rescue
        #Si alguno de los comprobantes no se pudo obtener de la cloud, o al momento de enviar, o que... se 
        if @factura.tipo_factura == "fv"
          redirect_to facturas_index_facturas_ventas_path(:tipo_factura => "fv")
          flash[:danger] = "El comprobante no se pudo enviar por email, vuelva a intentarlo por favor"
        elsif @factura.tipo_factura == "fg"
          redirect_to facturas_index_facturas_globales_path(:tipo_factura => "fg")
          flash[:danger] = "El comprobante no se pudo enviar por email, vuelva a intentarlo por favor}"
        end
      else
        if @factura.tipo_factura == "fv"
          redirect_to facturas_index_facturas_ventas_path(:tipo_factura => "fv")
          flash[:success] = "El comprobante se ha enviado exitosamente a: #{destinatario_final}"
        elsif @factura.tipo_factura == "fg"
          redirect_to facturas_index_facturas_globales_path(:tipo_factura => "fg")
          flash[:success] = "El comprobante se ha enviado exitosamente a: #{destinatario_final}"
        end
      end
    end
  end

  def enviar_email 
      estado_factura = @factura.estado_factura
      tipo_factura = @factura.tipo_factura
      if tipo_factura == "fv"
        require 'plantilla_email/plantilla_email.rb'
        plantilla_email = PlantillaEmail::AsuntoMensaje.new

        if estado_factura == "Activa"
          #Se obtiene la plantilla de solo si es una factura de un cliete en especifico (factura de venta)
          mensaje = current_user.negocio.plantillas_emails.find_by(comprobante: tipo_factura).msg_email
          asunto = current_user.negocio.plantillas_emails.find_by(comprobante: tipo_factura).asunto_email

          plantilla_email.nombCliente = @factura.cliente.nombre_completo #Nombre que se usa en el sistema no el 
          plantilla_email.uuid = @factura.folio_fiscal
          plantilla_email.fecha = @factura.fecha_expedicion
          plantilla_email.folio= @factura.consecutivo
          plantilla_email.serie = @factura.folio.delete(@folio.to_s)
          plantilla_email.total= @factura.monto

          plantilla_email.nombNegocio = @factura.negocio.nombre 
          plantilla_email.nombSucursal = @factura.sucursal.nombre 
          plantilla_email.emailContacto = @factura.sucursal.email 
          plantilla_email.telContacto = @factura.sucursal.telefono 
          plantilla_email.paginaWeb = @factura.negocio.pag_web

        elsif estado_factura == "Cancelada" 
          mensaje = current_user.negocio.plantillas_emails.find_by(comprobante: "ac").msg_email
          asunto = current_user.negocio.plantillas_emails.find_by(comprobante: "ac").asunto_email
          
          acuse_cancelacion = AcuseCancelacion.find(@factura.ref_acuse_cancelacion)
          plantilla_email.fecha = acuse_cancelacion.fecha_cancelacion 

          #Es obvio que debe de ser el mismo cliente que aparece en la factura de venta
          plantilla_email.nombCliente = @factura.cliente.nombre_completo
          #Folio y serie*
          plantilla_email.nombNegocio = acuse_cancelacion.negocio.nombre
          plantilla_email.nombSucursal = acuse_cancelacion.sucursal.nombre
          plantilla_email.emailContacto = acuse_cancelacion.sucursal.email
          plantilla_email.telContacto = acuse_cancelacion.sucursal.telefono
          plantilla_email.paginaWeb = acuse_cancelacion.negocio.pag_web
        end
        @mensaje = plantilla_email.reemplazar_texto(mensaje)
        @asunto = plantilla_email.reemplazar_texto(asunto)
      end
        #Las facturas globales no se envian a ningún cliente en especifico, sin embargo estará la opción de enviar, claro solo usuarios con privilegios podrán hacerlo.
        #Por la misma razón, las FG no hacen uso de alguna plantilla
        #El mensaje queda a la libertad del usuario.
        #asunto_email =  params[:asunto_email] 
        #mensaje_email = params[:mensaje_email]
  end

  def descargar_cfdis
    # bucket_name = "Su nombre de depósito de Google Cloud Storage"
    # project_id = "cfdis-196902","public/CFDIs-0fd739cbe697.json"# project_id = "Su ID de proyecto de Google Cloud"
    project_id = "cfdis-196902"
    credentials = File.open("public/CFDIs-0fd739cbe697.json") #Esto debe de existir siempre si o si.
    gcloud = Google::Cloud.new project_id, credentials 
    storage = gcloud.storage
    bucket = storage.bucket "cfdis"

    uuid = @factura.folio_fiscal
    storage_file_path = @factura.ruta_storage
    begin
      #require 'open-uri'
      file = bucket.file "#{storage_file_path}#{uuid}.xml"
      url = file.signed_url expires: 600 #10 minutos es hasta mucho
      xml_url = open(url).read
    rescue
      respond_to do |format|
        if @factura.tipo_factura == "fv"
          flash[:danger] = "No se pudo descargar el CFDI, vuelva a intentarlo por favor"
          format.html { redirect_to facturas_index_facturas_ventas_path(:tipo_factura => "fv")}
        elsif @factura.tipo_factura == "fg"
          format.html { redirect_to facturas_index_facturas_globales_path(:tipo_factura => "fg")}
          flash[:danger] = "No se pudo descargar el CFDI, vuelva a intentarlo por favor"
        end
      end
    else
      send_data xml_url, filename: "CFDI.xml", disposition: 'attachment'
    end
  end

  def descargar_acuses
    # bucket_name = "Su nombre de depósito de Google Cloud Storage"
    # project_id = "cfdis-196902","public/CFDIs-0fd739cbe697.json"# project_id = "Su ID de proyecto de Google Cloud"
    project_id = "cfdis-196902"
    credentials = File.open("public/CFDIs-0fd739cbe697.json") #Esto debe de existir siempre si o si.
    gcloud = Google::Cloud.new project_id, credentials 
    storage = gcloud.storage
    bucket = storage.bucket "cfdis"

    begin
      acuse_cancelacion = AcuseCancelacion.find(@factura.ref_acuse_cancelacion)
      storage_file_path = acuse_cancelacion.ruta_storage
      #Ni que hacerle, los acuses no tienen uuid para identificarlos asi que husaré el del sistema.
      id = acuse_cancelacion.id

      file = bucket.file "#{storage_file_path}Acuse_#{id}.xml"
      url = file.signed_url expires: 600 #10 minutos es hasta mucho
      xml_url = open(url).read
    rescue
      respond_to do |format|
        if @factura.tipo_factura == "fv"
          format.html { redirect_to facturas_index_facturas_ventas_path(:tipo_factura => "fv")}
          flash[:danger] = "No se pudo descargar el acuse de cancelación, vuelva a intentarlo por favor"
        elsif @factura.tipo_factura == "fg"
          format.html { redirect_to facturas_index_facturas_globales_path(:tipo_factura => "fg")}
          flash[:danger] = "No se pudo descargar el acuse de cancelación, vuelva a intentarlo por favor"
        end
      end
    else
      send_data xml_url, filename: "Acuse de cancelación.xml", disposition: 'attachment'
    end
  end

  def consulta_por_fecha
    if request.post?
      @consulta = true
      @fechas=true
      @por_folio=false
      @avanzada = false
      @por_cliente= false
      @fechaInicial = (params[:fecha_inicial]).to_date
      @fechaFinal = (params[:fecha_final]).to_date
      @tipo_factura = params[:tipo_factura]
      if can? :create, Negocio
        @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal)
      else
        @facturas = current_user.sucursal.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal)
      end

      respond_to do |format|
        if @tipo_factura == "fv"
          format.html { render 'index_facturas_ventas'}
        elsif @tipo_factura == "fg"
          format.html { render 'index_facturas_globales'}
        end
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
      @tipo_factura = params[:tipo_factura]
      @folio_fact = params[:folio_fact]
      @facturas = Factura.find_by folio: @folio_fact
      if can? :create, Negocio
        @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, folio: @folio_fact)
      else
        @facturas = current_user.sucursal.facturas.where(tipo_factura: @tipo_factura, folio: @folio_fact)
        #@facturas = current_user.sucursal.facturas.where(folio: @folio_fact)
      end
      respond_to do |format|
        if @tipo_factura == "fv"
          format.html { render 'index_facturas_ventas'}
        elsif @tipo_factura == "fg"
          format.html { render 'index_facturas_globales'}
        end
      end
    end

  end
  
  #Las facturas globales no usan este filtro por que son echas al público en gral.
  def consulta_por_cliente
    @consulta = true
    @fechas = false
    @por_folio = false
    @avanzada = false
    @por_cliente= true

    if request.post?
      if can? :create, Negocio
        if params[:rbtn] == "rbtn_rfc"
          @rfc = params[:rfc]
          datos_fiscales_cliente = DatosFiscalesCliente.find_by(rfc: @rfc)
          cliente_id = datos_fiscales_cliente ? datos_fiscales_cliente.cliente_id : nil
          @facturas = current_user.negocio.facturas.where(tipo_factura: "fv", cliente_id: cliente_id)
        elsif params[:rbtn] == "rbtn_nombreFiscal"
          cliente_id = params[:cliente_id]
          unless cliente_id.empty?
            datos_fiscales_cliente = DatosFiscalesCliente.find(cliente_id)
            @nombreFiscal = datos_fiscales_cliente.nombreFiscal
            cliente = datos_fiscales_cliente.cliente_id
          else
            cliente =nil
            @nombreFiscal = ""
          end
          @facturas = current_user.negocio.facturas.where(tipo_factura: "fv", cliente_id: cliente)
        end
      else
        if params[:rbtn] == "rbtn_rfc"
          @rfc = params[:rfc]
          dfc = DatosFiscalesCliente.find_by(rfc: @rfc)
          cliente_id = dfc ? dfc.cliente_id : nil
          @facturas = current_user.sucursal.facturas.where(tipo_factura: "fv", cliente_id: cliente_id)
        elsif params[:rbtn] == "rbtn_nombreFiscal"
          cliente_id = params[:cliente_id]
          unless cliente_id.empty?
            datos_fiscales_cliente = DatosFiscalesCliente.find(cliente_id)
            @nombreFiscal = datos_fiscales_cliente.nombreFiscal
            cliente = datos_fiscales_cliente.cliente_id
          else
            cliente = nil
            @nombreFiscal = ""
          end
          @facturas = current_user.sucursal.facturas.where(tipo_factura: "fv", cliente_id: clientes_ids)
        end
      end
      respond_to do |format|
        format.html { render 'index_facturas_ventas'}
      end
    end
  end

  def consulta_avanzada
    @consulta = true
    @avanzada = true
    @fechas=false
    @por_folio=false

    if request.post?
      #Se obtienen los criterios de búsqueda

      @tipo_factura = params[:tipo_factura]

      @fechaInicial = (params[:fecha_inicial_avanzado]).to_date
      @fechaFinal = (params[:fecha_final_avanzado]).to_date

      if params[:opcion_busqueda_cliente] == "Buscar por R.F.C."
        @rfc = params[:rfc]
        datos_fiscales_cliente = DatosFiscalesCliente.find_by(rfc: @rfc)
        if datos_fiscales_cliente
          @criterio_cliente = true
          clientes_ids = datos_fiscales_cliente.cliente_id
        end
      elsif params[:opcion_busqueda_cliente] == "Buscar por nombre fiscal"
        cliente_id = params[:cliente_id]
        unless cliente_id.empty?
          datos_fiscales_cliente = DatosFiscalesCliente.find(cliente_id)
          @criterio_cliente = true
          @nombreFiscal = datos_fiscales_cliente.nombreFiscal
          clientes_ids = datos_fiscales_cliente.cliente_id 
        end
      end

      @condicion_monto_factura = params[:condicion_monto_factura]
      #Se convierte la descripción al operador equivalente
      unless @condicion_monto_factura.empty?
        operador_monto = case @condicion_monto_factura
           when "menor que" then "<"
           when "mayor que" then ">"
           when "menor o igual que" then "<="
           when "mayor o igual que" then ">="
           when "igual que" then "="
           when "diferente que" then "!=" #o también <> Distinto de
           when "rango desde" then ".." #o también <> Distinto de
        end
        @monto_factura = params[:monto_factura]
        @monto_factura2 = params[:monto_factura2]  
        if ((not(@monto_factura.empty?) && operador_monto != "..") || (not(@monto_factura.empty?) && not(@monto_factura2.empty?) && operador_monto == ".."))
          @criterio_monto = true
        end
      end

      @estado_factura = params[:estado_factura]

      @suc = params[:suc_elegida]
      unless @suc.empty?
        @sucursal = Sucursal.find(@suc)
      end

      if can? :create, Negocio
        #Se obtinen las facturas de ventas o globales dependiendo del parametro recibido del index
        #Si el usuario si eligió una sucursal
        unless @suc.empty? 
          #Si se eligió un cliente específico para esta consulta
          if @criterio_cliente 
            #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
            unless @estado_factura.eql?("Todas")  
              #Si se eligió monto de factura
              if @criterio_monto 
                if operador_monto == ".." #Cuando se trata de un rango
                  @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal, sucursal: @sucursal, cliente: clientes_ids, monto: @monto_factura..@monto_factura2) 
                else
                  @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal, sucursal: @sucursal, cliente: clientes_ids)
                  @facturas = @facturas.where("monto #{operador_monto} ?", @monto_factura)
                end
              else
                @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal, sucursal: @sucursal, cliente: clientes_ids, estado_factura: @estado_factura)
              end
            else
              @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal, sucursal: @sucursal, cliente: clientes_ids)
            end
          # Si no se eligió cliente, entonces no filtra las ventas por el cliente al que se expidió la factura.
          else
            #Filtra por estado de factura
            unless @estado_factura.eql?("Todas")
              #Filtra por monto: mayor que, menor que, igual a...
              if @criterio_monto
                if operador_monto == ".."
                  @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal, sucursal: @sucursal, estado_factura: @estado_factura, monto: @monto_factura..@monto_factura2)
                else
                  @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal, sucursal: @sucursal, estado_factura: @estado_factura)
                  @facturas = @facturas.where("monto #{operador_monto} ?", @monto_factura)
                end
              else
                @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal, sucursal: @sucursal, estado_factura: @estado_factura)
              end
              #Si el usuario no seleccionó estado de factura
            else
              @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal, sucursal: @sucursal)
            end
          end
        #Si el usuario no eligió ninguna sucursal específica, no filtra las ventas por sucursal
        else
          #valida si se eligió un cliente
          if @criterio_cliente#@cliente
            #Filtra por monto de la venta facurada.
            unless @estado_factura.eql?("Todas")
              if @criterio_monto
                if operador_monto == ".." #Cuando se trata de un rango
                  @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, estado_factura: @estado_factura, monto: @monto_factura..@monto_factura2)
                else
                  @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, estado_factura: @estado_factura)
                  @facturas = @facturas.where("monto #{operador_monto} ?", @monto_factura)
                end
              else
                @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, estado_factura: @estado_factura)
              end
            else
              @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids)
            end
          # Si no se eligió cliente, entonces no filtra las ventas por el cliente
          else
            unless @estado_factura.eql?("Todas")
              if @criterio_monto
                if operador_monto == ".." #Cuando se trata de un rango
                  @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura, monto: @monto_factura..@monto_factura2)
                else
                  @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura)
                  @facturas = @facturas.where("monto #{operador_monto} ?", @monto_factura) 
                end
              else
                @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura)
              end
            else
              @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal)
            end
          end
        end
      #Si el usuario no es un administrador o subadministrador
      else
        #valida si se eligió un cliente específico para esta consulta
        if @criterio_cliente
          #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
          unless @estado_factura.eql?("Todas")
            @facturas = current_user.sucursal.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, estado_factura: @estado_factura)
          else
            @facturas = current_user.sucursal.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids)
          end #Termina unless @estado_factura.eql?("Todas")
        # Si no se eligió cliente, entonces no filtra las ventas por el cliente
        else
          #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
          unless @estado_factura.eql?("Todas")
            @facturas = current_user.sucursal.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura)
          else
            @facturas =current_user.sucursal.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal)
          end #Termina unless @estado_factura.eql?("Todas")
        end 
      end

      respond_to do |format|
        if @tipo_factura == "fv"
          format.html { render 'index_facturas_ventas'}
        elsif @tipo_factura == "fg"
          format.html { render 'index_facturas_globales'}
        end
      end
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
    #========================================================================================================================
    #1.-CERTIFICADOS,  LLAVES Y CLAVES
    certificado = CFDI::Certificado.new '/home/daniel/Documentos/prueba/CSD01_AAA010101AAA.cer'
    # Esta se convierte de un archivo .key con:
    # openssl pkcs8 -inform DER -in someKey.key -passin pass:somePassword -out key.pem
    path_llave = "/home/daniel/Documentos/timbox-ruby/CSD01_AAA010101AAA.key.pem"
    password_llave = "12345678a"
    #openssl pkcs8 -inform DER -in /home/daniel/Documentos/prueba/CSD03_AAA010101AAA.key -passin pass:12345678a -out /home/daniel/Documentos/prueba/CSD03_AAA010101AAA.pem
    llave = CFDI::Key.new path_llave, password_llave

    #========================================================================================================================
    #2.- LLENADO DEL XML DIRECTAMENTE DE LA BASE DE DATOS
    #Para obtener el numero consecutivo a partir de la ultima factura o de lo contrario asignarle por primera vez un número
    consecutivo = 0
    if current_user.sucursal.facturas.where(tipo_factura: "fg").last
      consecutivo = current_user.sucursal.facturas.where(tipo_factura: "fg").last.consecutivo
      if consecutivo
        consecutivo += 1
      end
    else
       consecutivo = 1 #Se asigna el número a la factura por default o de acuerdo a la configuración del usuario.
    end

    claveSucursal = current_user.sucursal.clave
    folio_registroBD = claveSucursal + "FG" + consecutivo.to_s
    serie = claveSucursal + "FG"


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
      ventas = []
      #Se reciben los id de las ventas con las casillas marcadas en un arreglo de string y se convierten a enteros. Luego se buscan todas las ventas con los id del arreglo.
      params[:ventas].each {|id| ventas << (id.split('_')[0]).to_i }
      @ventas = Venta.where(id: ventas)

      #Se obtiene el nombre de la forma de pago de las ventas no facturadas (Que no es el nombre correcto pero bueno...)
      forma_pago_mayor_fg =  @ventas.max_by(&:montoVenta).venta_forma_pago.forma_pago.nombre
      #@ventas.each {|v|  if v.venta_forma_pago.forma_pago.nombre == forma_pago_mayor_fg}
      if forma_pago_mayor_fg == "efectivo"
        cve_nombre_forma_pagoSAT = "01 - Efectivo"
        cve_forma_pagoSAT = "01"
      elsif forma_pago_mayor_fg == "tarjeta credito"
        cve_nombre_forma_pagoSAT = "04 - Tarjeta de crédito"
        cve_forma_pagoSAT = "04"
      elsif forma_pago_mayor_fg == "tarjeta debito"
        cve_nombre_forma_pagoSAT = "28 - Tarjeta de débito"
        cve_forma_pagoSAT = "28"
      elsif forma_pago_mayor_fg == "oxxo" || forma_pago_mayor_fg == "paypal" || forma_pago_mayor_fg == "Deposito" || forma_pago_mayor_fg == "Trasferencia"
        cve_nombre_forma_pagoSAT = "03 - Transferencia electrónica de fondos"
        cve_forma_pagoSAT = "03"
      end

      #fecha_expedion = Time.now
      factura = CFDI::Comprobante.new({
        serie: serie,
        folio: consecutivo,
        #fecha: fecha_expedion,
        #Por defaulf el tipo de comprobante es de tipo "I" Ingreso
        #Moneda: MXN Peso Mexicano, USD Dólar Americano, Etc…
        #La moneda por default es MXN
        formaPago: cve_forma_pagoSAT,
        #El campo Condiciones de pago no debe de existir
        #Método de pago: SIEMPRE debe ser la clave “PUE” (Pago en una sola exhibición); en el caso de que se venda a parcialidades o diferido, se deberá proceder a emitir el CFDI con complemento de pagos, detallando los datos del cliente que los realiza; en pocas palabras, no esta permitido emitir un CFDI global con ventas a parcialidades o diferidas.
        metodoDePago: 'PUE',
        #El código postal de la matriz o sucursal
        lugarExpedicion: current_user.sucursal.datos_fiscales_sucursal.codigo_postal,
        total: '%.2f' % (@ventas.map(&:montoVenta).reduce(:+)).round(2)#96.56
        #Descuento:0 #DESCUENTO RAPPEL
      })

      #Estos datos no son requeridos por el SAT, sin embargo se usaran para la representacion impresa de los CFDIs.*
      #DATOS DEL EMISOR
      hash_domicilioEmisor = {}
      #Que locura, es una redundancia
      if current_user.negocio.datos_fiscales_negocio
        hash_domicilioEmisor[:calle] = current_user.negocio.datos_fiscales_negocio.calle ? current_user.negocio.datos_fiscales_negocio.calle : " "
        hash_domicilioEmisor[:noExterior] = current_user.negocio.datos_fiscales_negocio.numExterior ? current_user.negocio.datos_fiscales_negocio.numExterior : " "
        hash_domicilioEmisor[:noInterior] = current_user.negocio.datos_fiscales_negocio.numInterior ? current_user.negocio.datos_fiscales_negocio.numInterior : " "
        hash_domicilioEmisor[:colonia] = current_user.negocio.datos_fiscales_negocio.colonia ? current_user.negocio.datos_fiscales_negocio.colonia : " "
        hash_domicilioEmisor[:localidad] = current_user.negocio.datos_fiscales_negocio.localidad ? current_user.negocio.datos_fiscales_negocio.localidad : " "
        hash_domicilioEmisor[:referencia] = current_user.negocio.datos_fiscales_negocio.referencia ? current_user.negocio.datos_fiscales_negocio.referencia : " "
        hash_domicilioEmisor[:municipio] = current_user.negocio.datos_fiscales_negocio.municipio ? current_user.negocio.datos_fiscales_negocio.municipio : " "
        hash_domicilioEmisor[:estado] = current_user.negocio.datos_fiscales_negocio.estado ? current_user.negocio.datos_fiscales_negocio.estado : " "
        hash_domicilioEmisor[:codigoPostal] = current_user.negocio.datos_fiscales_negocio.codigo_postal ? current_user.negocio.datos_fiscales_negocio.codigo_postal : " "
      end
      domicilioEmisor = CFDI::DatosComunes::Domicilio.new(hash_domicilioEmisor)

      #III. Sí se tiene más de un local o establecimiento, se deberá señalar el domicilio del local o
      #establecimiento en el que se expidan las Facturas Electrónicas
      #Estos datos no son requeridos por el SAT, sin embargo se usaran para la representacion impresa de los CFDIs.*
      if current_user.sucursal #Solo si cuenta con más de un local
        expedidoEn= CFDI::DatosComunes::Domicilio.new({
          calle: current_user.sucursal.datos_fiscales_sucursal.calle,
          noExterior: current_user.sucursal.datos_fiscales_sucursal.numExt,
          noInterior: current_user.sucursal.datos_fiscales_sucursal.numInt,
          colonia: current_user.sucursal.datos_fiscales_sucursal.colonia,
          localidad: current_user.sucursal.datos_fiscales_sucursal.localidad,
          codigoPostal: current_user.sucursal.datos_fiscales_sucursal.codigo_postal,
          municipio: current_user.sucursal.datos_fiscales_sucursal.municipio,
          estado: current_user.sucursal.datos_fiscales_sucursal.estado,
          referencia: current_user.sucursal.datos_fiscales_sucursal.referencia,
        })
      else
        expedidoEn= CFDI::DatosComunes::Domicilio.new({})
      end

      factura.emisor = CFDI::Emisor.new({
        #rfc: 'AAA010101AAA',
        rfc: current_user.negocio.datos_fiscales_negocio.rfc,
        nombre: current_user.negocio.datos_fiscales_negocio.nombreFiscal,
        regimenFiscal: current_user.negocio.datos_fiscales_negocio.regimen_fiscal.cve_regimen_fiscalSAT, #CATALOGO
        domicilioFiscal: domicilioEmisor,
        expedidoEn: expedidoEn
      })

      #La dirección del receptor naaa, porq se trata de ventas al publico en general(clientes no registrados)

      #ATRIBUTOS EL RECEPTOR
      factura.receptor = CFDI::Receptor.new({
         #RFC receptor: Debe contener el RFC genérico (XAXX010101000) y el campo “Nombre” no debe existir.
         rfc: "XAXX010101000",
         #El Uso del CFDI es un campo obligatorio, se registra la clave P01 (por definir).
         UsoCFDI: "P01"#,
        })

      cont = 0 #Para marcar los impuestos que le pertenecen a una venta
      @ventas.each do |v|
        hash_conceptos={
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
          #ValorUnitario: v.montoVenta,
          #El importe siempre será la tabla del 1 jaja 1x1=1 1x2=2...
          #Descuento: 0 #Expresado en porcentaje
        }
        #Impuestos Trasladados (IVA o IEPS)
        #Impuestos trasladados: Deben indicar:
          #la base
          #el tipo de impuestos
          #si es tasa o cuota,
          #el valor de esta de la tasa o cuota
          #el impuesto que trasladan por cada comprobante simplificado.
        @itemsVenta = v.item_ventas
        valor_unitario_fg = 0.0
        @itemsVenta.each do |c|
          importe_concepto = (c.precio_venta * c.cantidad) #Incluye impuestos(si esq), descuentos(si esq)...
          if c.articulo.impuesto.present? #Impuestos a la inversa
            tasaOCuota = (c.articulo.impuesto.porcentaje / 100) #Se obtiene la tasa o cuota por ej. 16% => 0.160000
            #Se calcula el precio bruto de cada concepto
            base_gravable = (importe_concepto / (tasaOCuota + 1)) #Se obtiene el precio bruto por item de venta
            importe_impuesto_concepto = (base_gravable * tasaOCuota)

            valorUnitario = base_gravable / c.cantidad

            if c.articulo.impuesto.tipo == "Federal"
              if c.articulo.impuesto.nombre == "IVA"
                clave_impuesto = "002"
              elsif c.articulo.impuesto.nombre == "IEPS"
                clave_impuesto =  "003"
              end
              factura.impuestos.traslados << CFDI::Impuesto::Traslado.new(base: base_gravable,
                tax: clave_impuesto, type_factor: "Tasa", rate: tasaOCuota, import: importe_impuesto_concepto.round(2), concepto_id: cont)
            #end
            #elsif c.articulo.impuesto.tipo == "Local"
              #Para el complemento de impuestos locales.
            end
            valor_unitario_fg = valor_unitario_fg + base_gravable
          else
            valor_unitario_fg  = valor_unitario_fg + c.precioVenta
          end
        end
        hash_conceptos[:ValorUnitario] = valor_unitario_fg
        hash_conceptos[:Importe] = valor_unitario_fg.round(2) #Todo multiplicado por uno es lo mismo, eso lo aprendí en la primaria jaja.
        factura.conceptos << CFDI::Concepto.new(hash_conceptos)
        cont += 1
      end

#========================================================================================================================
      #3.- SE AGREGA EL CERTIFICADO Y EL SELLO DIGITAL
      @total_to_w= factura.total_to_words
      # Esto hace que se le agregue al comprobante el certificado y su número de serie (noCertificado)
      certificado.certifica factura
      #Se agrega el sello digital del comprobante, esto implica actulizar la fecha y calcular la plantilla_email oriiginal
      xml_certificado_sellado = llave.sella factura

#========================================================================================================================
      #4.- ALTERNATIVA DE CONEXIÓN PARA CONSUMIR EL WEBSERVICE DE TIMBRADO CON TIMBOX
      #Se convierte el xml en base64 para mandarselo a TIMBOX
      xml_base64 = Base64.strict_encode64(xml_certificado_sellado)
      # Parametros para conexion al Webservice (URL de Pruebas)
      wsdl_url = "https://staging.ws.timbox.com.mx/timbrado_cfdi33/wsdl"
      usuario = "AAA010101000"
      contrasena = "h6584D56fVdBbSmmnB"
      #Se obtiene el xml timbrado
      xml_timbox= timbrar_xml(usuario, contrasena, xml_base64, wsdl_url)
      #Guardo el xml recien timbradito de timbox, calientito
      fg_id = Factura.where(tipo_factura: "fg").last ? Factura.where(tipo_factura: "fg").last.id + 1 : 1
      archivo = File.open("public/#{fg_id}_fg.xml", "w")
      archivo.write (xml_timbox)
      archivo.close

      #Se forma la plantilla_email original del timbre fiscal digital de manera manual por que e mugroso xslt del SAT no Jala.
      factura.complemento = CFDI::Complemento.new(
        {
          Version: xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@Version'),
          uuid:xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@UUID'),
          FechaTimbrado:xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@FechaTimbrado'),
          RfcProvCertif:xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@RfcProvCertif'),
          SelloCFD:xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@SelloCFD'),
          NoCertificadoSAT:xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@NoCertificadoSAT')
        }
      )
      #se hace una copia del xml para modificarlo agregandole información extra para la representación impresa.
      xml_copia = xml_timbox

#========================================================================================================================
      #5.- SE AGREGAN NUEVOS DATOS PARA LA REPRESENTACIÓN IMPRESA(INFORMACIÓN(PDF) IMPORTANTE PARA LOS CONTRIBUYENTES, PERO QUE AL SAT NO LE IMPORTAN JAJA)
      codigoQR=factura.qr_code xml_timbox
      cadOrigComplemento = factura.complemento.cadena_TimbreFiscalDigital
      logo=current_user.negocio.logo
      uso_cfdi_descripcion = "Por definir"
      cve_nombre_metodo_pago =  "PUE - Pago en una sola exhibición"
      #Para la clave y nombre del regimen fiscal
      cve_regimen_fiscalSAT = current_user.negocio.datos_fiscales_negocio.regimen_fiscal.cve_regimen_fiscalSAT
      nomb_regimen_fiscalSAT = current_user.negocio.datos_fiscales_negocio.regimen_fiscal.nomb_regimen_fiscalSAT
      cve_nomb_regimen_fiscalSAT = "#{cve_regimen_fiscalSAT} - #{nomb_regimen_fiscalSAT}"
      #Para el nombre del changarro feo jajaja
      nombre_negocio = current_user.negocio.nombre

      #Personalización de la plantilla de impresión de una factura de venta. :P
      plantilla_impresion = current_user.negocio.config_comprobantes.find_by(comprobante: "f")
      tipo_fuente = plantilla_impresion.tipo_fuente
      tam_fuente = plantilla_impresion.tam_fuente
      color_fondo = plantilla_impresion.color_fondo
      color_banda = plantilla_impresion.color_banda
      color_titulos = plantilla_impresion.color_titulos

      #Se pasa un hash con la información extra en la representación impresa como: datos de contacto, dirección fiscal y descripcion de la clave de los catálogos del SAT.
      hash_info = {xml_copia: xml_copia, codigoQR: codigoQR, logo: logo, cadOrigComplemento: cadOrigComplemento, uso_cfdi_descripcion: uso_cfdi_descripcion, cve_nombre_forma_pago: cve_nombre_forma_pagoSAT, cve_nombre_metodo_pago: cve_nombre_metodo_pago, cve_nomb_regimen_fiscalSAT:cve_nomb_regimen_fiscalSAT, nombre_negocio: nombre_negocio,
        tipo_fuente: tipo_fuente, tam_fuente: tam_fuente, color_fondo:color_fondo, color_banda:color_banda, color_titulos:color_titulos,
        tel_negocio: current_user.negocio.telefono, email_negocio: current_user.negocio.email, pag_web_negocio: current_user.negocio.pag_web
      }
  
      #Solo si tiene más de un establecimiento el negocio...
      if current_user.sucursal
        hash_info[:tel_sucursal] = current_user.sucursal.telefono
        hash_info[:email_sucursal] = current_user.sucursal.email
      end

      xml_rep_impresa = factura.add_elements_to_xml(hash_info)
      #puts xml_rep_impresa
      template = Nokogiri::XSLT(File.read('/home/daniel/Vídeos/sysChurch/lib/XSLT.xsl'))
      html_document = template.transform(xml_rep_impresa)
      #File.open('/home/daniel/Documentos/timbox-ruby/CFDImpreso.html', 'w').write(html_document)
      pdf = WickedPdf.new.pdf_from_string(html_document)
      #Se guarda el pdf 
      nombre_pdf="#{fg_id}_fg.pdf"
      save_path = Rails.root.join('public',nombre_pdf)
      File.open(save_path, 'wb') do |file|
          file << pdf
      end

#========================================================================================================================
      #6.- SE ALMACENAN EN GOOGLE CLOUD STORAGE
      gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
      storage=gcloud.storage
      bucket = storage.bucket "cfdis"

      #Se realizan las consultas para formar los directorios en cloud
      dir_negocio = current_user.negocio.nombre
      dir_cliente = "Público en general"
      #Se separan obtiene el día, mes y año de la fecha de emisión del comprobante
      fecha_registroBD = DateTime.parse(xml_timbox.xpath('//@Fecha').to_s) 
      dir_dia = fecha_registroBD.strftime("%d")
      dir_mes = fecha_registroBD.strftime("%m")
      dir_anno = fecha_registroBD.strftime("%Y")
      fecha_file = fecha_registroBD.strftime("%Y-%m-%d")

      #Cosas a tener en cuenta antes de indicarle una ruta:
        #1.-Un negocio puede o no tener sucursales
      if current_user.sucursal
        dir_sucursal = current_user.sucursal.nombre
        ruta_storage = "#{dir_negocio}/#{dir_sucursal}/#{dir_cliente}/#{dir_anno}/#{dir_mes}/#{dir_dia}/#{fg_id}_fg"
      else
        ruta_storage = "#{dir_negocio}/#{dir_cliente}/#{dir_anno}/#{dir_mes}/#{dir_dia}/#{fg_id}_fg"
      end
      #Los comprobantes de almacenan en google cloud
      file = bucket.create_file "public/#{fg_id}_fg.pdf", "#{ruta_storage}.pdf"
      file = bucket.create_file "public/#{fg_id}_fg.xml", "#{ruta_storage}.xml"

      #7.- SE ENVIAN LOS COMPROBANTES(pdf y xml timbrado)
      

      #8.- SE REGISTRA LA NUEVA FACTURA GLOBAL EN LA BASE DE DATOS
      #Se crea un objeto del modelo Factura y se le asignan a los atributos los valores correspondientes para posteriormente guardarlo como un registo en la BD.
      folio_fiscal_xml = xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@UUID')
      @factura = Factura.new(folio: folio_registroBD, fecha_expedicion: fecha_file, consecutivo: consecutivo, estado_factura:"Activa", cve_metodo_pagoSAT: 'PUE', monto: '%.2f' % (@ventas.map(&:montoVenta).reduce(:+)).round(2), folio_fiscal: folio_fiscal_xml, ruta_storage: ruta_storage, tipo_factura: "fg")#, monto: @venta.montoVenta)
      
      if @factura.save
        current_user.facturas<<@factura
        current_user.negocio.facturas<<@factura
        current_user.sucursal.facturas<<@factura
        #FacturaFormaPago.find_by(cve_forma_pagoSAT: cve_forma_pagoSAT)
        forma_pago = FacturaFormaPago.find_by(cve_forma_pagoSAT: cve_forma_pagoSAT)
        forma_pago.facturas << @factura

        #A público en general
        current_user.negocio.clientes.find_by(nombre: "General").facturas << @factura
        #@venta.factura = @factura
        @ventas.each {|vta| @factura.ventas << vta} 

      end

      #Se comprueba que el archivo exista en la carpeta publica de la aplicación
      if File::exists?( "public/#{fg_id}_fg.pdf")
        file=File.open( "public/#{fg_id}_fg.pdf")
        send_file( file, :disposition => "inline", :type => "application/pdf")
        #File.delete("public/#{file_name}")
      else
        respond_to do |format|
          format.html { redirect_to action: "index_facturas_globales" }
          flash[:notice] = "No se encontró la factura, vuelva a intentarlo!"
          #format.html { redirect_to facturas_index_path, notice: 'No se encontró la factura, vuelva a intentarlo!' }
        end
      end
  end

  def generarFacturaGlobal

  end

  def mostrarVentas_FacturaGlobal
    @consulta = true

    @suc = params[:suc_elegida]

    unless @suc.empty?
      @sucursal = Sucursal.find(@suc)
    end

    if request.post?
      @fechaOne = DateTime.parse(params[:fecha_one]).to_date
      @fechaTwo = DateTime.parse(params[:fecha_two]).to_date

      if can? :create, Negocio
        #Si quieren generar facturas globales por sucursal
        @opcion_global = params[:opcion_global]
        unless @suc.empty?
          if params[:opcion_global] == "Facturar ventas por periodo"
            @ventas = current_user.negocio.ventas.where(fechaVenta: @fechaOne..@fechaTwo, sucursal: @sucursal)
          else
            @ventas = current_user.negocio.ventas.where(fechaVenta: @fechaOne, sucursal: @sucursal)
          end
          #Las ventas no deben de estar facturadas
          unless @ventas.empty?
            @ventas_sin_facturar=[]
            @ventas.each do |v|
              #Existen 3 statos de las ventas: Activa, Cancelada, y con devoluciones.
              if v.factura.blank?
                if v.status == "Activa"
                  @ventas_sin_facturar.push(v)
                  #Tambien se agragan las ventas con status 'Con devoluciones' siempre y cuando exista por lo menos un producto.
                elsif v.status == "Con devoluciones"
                  itemsVenta_Activos = v.item_ventas.where(status: "Activa").count
                  @ventas_sin_facturar.push(v) if itemsVenta_Activos >= 1
                end
                #Las ventas con status 'Cancelada' se mandan a volar jaja
              end
            end
          end
        else
          if params[:opcion_global] == "Facturar ventas por periodo"
            @ventas = current_user.negocio.ventas.where(fechaVenta: @fechaOne..@fechaTwo)
          else
            @ventas = current_user.negocio.ventas.where(fechaVenta: @fechaOne)
          end
          #Las ventas no deben de estar facturadas
          unless @ventas.empty?
            @ventas_sin_facturar=[]
            @ventas.each do |v|
              #Existen 3 statos de las ventas: Activa, Cancelada, y con devoluciones.
              if v.factura.blank?
                if v.status == "Activa"
                  @ventas_sin_facturar.push(v)
                  #Tambien se agragan las ventas con status 'Con devoluciones' siempre y cuando exista por lo menos un producto.
                elsif v.status == "Con devoluciones"
                  itemsVenta_Activos = v.item_ventas.where(status: "Activa").count
                  @ventas_sin_facturar.push(v) if itemsVenta_Activos >= 1
                end
                #Las ventas con status 'Cancelada' se mandan a volar jaja
              end
            end
          end
        end
      end
    end
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
=begin
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
=end

end
