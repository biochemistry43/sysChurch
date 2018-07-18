class FacturasController < ApplicationController
  before_action :set_factura, only: [:show, :edit, :update, :destroy, :readpdf, :enviar_email,:enviar_email_post, :descargar_cfdis, :cancelar_cfdi, :cancelaFacturaVenta, :cancelaFacturaVenta2]
  #before_action :set_facturaDeVentas, only: [:show]
  #before_action :set_cajeros, only: [:index, :consulta_facturas, :consulta_avanzada, :consulta_por_folio, :consulta_por_cliente]
  before_action :set_sucursales, only: [:index, :consulta_facturas, :consulta_avanzada, :consulta_por_folio, :consulta_por_cliente, :generarFacturaGlobal, :mostrarVentas_FacturaGlobal ]
  before_action :set_clientes, only: [:index, :consulta_facturas, :consulta_avanzada, :consulta_por_folio, :consulta_por_cliente]

  #sirve para buscar la venta y mostrar los resultados antes de facturar.
  def buscarVentaFacturar
    @consulta = false
    if request.post?
      #si existe una venta con el folio solicitado, despliega una sección con los detalles en la vista
      @venta = current_user.negocio.ventas.find_by :folio=>params[:folio]
      #@@venta = @venta
      @consulta = true #determina si se realizó una consulta
      #La venta debe de ser del mismo negocio o mostrará que no hay ventas registradas con X folio de venta
      if @venta #&& current_user.negocio.id == @venta.negocio.id
        unless @venta.status.eql?("Cancelada") #Quiere decir que puede estar Activa o con devoluciones
          #p "VENTA ACTIVA O CON DEVOLUCIONES"
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
          end # Fin de devoluciones

          #Solo si el monto de la suma de todas las devoluciones es inferior al monto de la venta
          unless @monto_devolucion == @venta.montoVenta
            #p "EL MONTO ES EL MISMO DE LA VENTA ORIGINAL"
            @ventaConDevolucionTotal = false
            #@devoluciones = false
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
            #Es una venta que no ha sido facturada ninguna vez.
            if (@ventaFacturaActiva == false && @ventaFacturada ) || @ventaFacturada == false
              #p "SIN FACTURA"
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
              #Temporalmente...
              if current_user.sucursal.clave.present?
                claveSucursal = current_user.sucursal.clave
                @serie = claveSucursal + "F"
              else
                folio_default="F"
                @serie = folio_default
              end
              #RECEPTOR
              @email_receptor = @venta.cliente.email #Dirección para el envío de los comprobantes
              #Datos requeridos por el SAT por eso son de ley para la factura, pero cuando se trata de facturar una venta echa al publico en genera resulta que no existen datos fiscales.
              @rfc_receptor_f = @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.rfc : ""
              @nombre_fiscal_receptor_f=@venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.nombreFiscal : ""

              @calle_receptor_f = @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.calle : ""
              @noInterior_receptor_f = @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.numInterior : ""
              @noExterior_receptor_f = @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.numExterior : ""
              @colonia_receptor_f = @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.colonia : ""
              @localidad_receptor_f = @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.localidad : ""
              @municipio_receptor_f = @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.municipio : ""
              @estado_receptor_f = @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.estado : ""
              @referencia_receptor_f =  @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.referencia : " "
              @cp_receptor_f = @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.codigo_postal : ""
              @pais_receptor_f = @venta.cliente.datos_fiscales_cliente ? @venta.cliente.datos_fiscales_cliente.pais : ""
              @uso_cfdi_receptor_f=UsoCfdi.all

              #COMPROBANTE
              #@c_unidadMedida_f=current_user.negocio.unidad_medidas.cla
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
            end
            #::::::::::::::::
          else
            #p "LA VENTA FUE COMPLETAMENTE DEVUELTA"
            @ventaConDevolucionTotal = true
          end
        else
          #p "VENTA CANCELADA"
          @ventaCancelada = true
        end
      else #Fin de la comprobación de existencia del folio de la venta del negocio
        @folioVenta = params[:folio]
      end
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

      #Datos del receptor
      #Estos datos no son requeridos por el SAT, sin embargo se usaran para la representacion impresa de los CFDIs.*
      #Los datos de facturación del receptor son recibidos como paramatros porque puede ser facturado a otro fulano distino al que hizo la compra o haber sido hecha al público en general.

      domicilioReceptor = CFDI::DatosComunes::Domicilio.new({
        calle: params[:calle_receptor_vf],
        noExterior: params[:no_Exterior_vf],
        noInterior:params[:no_Interior_vf],
        colonia: params[:colonia_receptor_vf],
        localidad: params[:localidad_receptor_vf],
        municipio: params[:municipio_receptor_vf],
        estado: params[:estado_receptor_vf],
        codigoPostal: params[:cp_receptor_vf],
        pais: params[:pais_receptor_f],
        referencia: params[:referencia_receptor_vf]
        })

      @usoCfdi = UsoCfdi.find(params[:uso_cfdi_id])
      factura.receptor = CFDI::Receptor.new({
        #Datos requeridos si o si son: el rfc, nombre fiscal y el uso del CFDI.
         rfc: params[:rfc_input],
         nombre: params[:nombre_fiscal_receptor_vf],
         UsoCFDI:@usoCfdi.clave, #CATALOGO
         domicilioFiscal: domicilioReceptor
        })
      #<< para que puedan ser agragados los conceptos que se deseen.
      @itemsVenta = @venta.item_ventas
      cont=0
      @itemsVenta.each do |c|
        hash_conceptos={ClaveProdServ: c.articulo.clave_prod_serv.clave, #Catálogo
                        NoIdentificacion: c.articulo.clave,
                        Cantidad: c.cantidad,
                        ClaveUnidad:c.articulo.unidad_medida.clave,#Catálogo
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
      uso_cfdi_descripcion = @usoCfdi.descripcion
      cve_nombre_forma_pago = "#{forma_pago_f.cve_forma_pagoSAT } - #{forma_pago_f.nombre_forma_pagoSAT}"
      cve_nombre_metodo_pago =  params[:metodo_pago] == "PUE" ? "PUE - Pago en una sola exhibición" : "PPD - Pago en parcialidades o diferido"
      #Para la clave y nombre del regimen fiscal
      cve_regimen_fiscalSAT = current_user.negocio.datos_fiscales_negocio.regimen_fiscal.cve_regimen_fiscalSAT
      nomb_regimen_fiscalSAT = current_user.negocio.datos_fiscales_negocio.regimen_fiscal.nomb_regimen_fiscalSAT
      cve_nomb_regimen_fiscalSAT = "#{cve_regimen_fiscalSAT} - #{nomb_regimen_fiscalSAT}"
      #Para el nombre del changarro feo jajaja
      nombre_negocio = current_user.negocio.nombre

      #Personalización de la plantilla de impresión de una factura de venta. :P
      tipo_fuente = current_user.negocio.config_comprobantes.find_by(comprobante: "fv").tipo_fuente
      tam_fuente = current_user.negocio.config_comprobantes.find_by(comprobante: "fv").tam_fuente
      color_fondo = current_user.negocio.config_comprobantes.find_by(comprobante: "fv").color_fondo
      color_banda = current_user.negocio.config_comprobantes.find_by(comprobante: "fv").color_banda
      color_titulos = current_user.negocio.config_comprobantes.find_by(comprobante: "fv").color_titulos

      #Se pasa un hash con la información extra en la representación impresa como: datos de contacto, dirección fiscal y descripcion de la clave de los catálogos del SAT.
      hash_info = {xml_copia: xml_copia, codigoQR: codigoQR, logo: logo, cadOrigComplemento: cadOrigComplemento, uso_cfdi_descripcion: uso_cfdi_descripcion, cve_nombre_forma_pago: cve_nombre_forma_pago, cve_nombre_metodo_pago: cve_nombre_metodo_pago, cve_nomb_regimen_fiscalSAT:cve_nomb_regimen_fiscalSAT, nombre_negocio: nombre_negocio,
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


      xml_rep_impresa = factura.add_elements_to_xml(hash_info)
      #puts xml_rep_impresa
      template = Nokogiri::XSLT(File.read('/home/daniel/Vídeos/sysChurch/lib/XSLT.xsl'))
      html_document = template.transform(xml_rep_impresa)
      #File.open('/home/daniel/Documentos/timbox-ruby/CFDImpreso.html', 'w').write(html_document)
      pdf = WickedPdf.new.pdf_from_string(html_document)

      #6.- SE ALMACENAN EN GOOGLE CLOUD STORAGE
      #Directorios
      dir_negocio = current_user.negocio.nombre
      dir_cliente = params[:nombre_fiscal_receptor_vf]

      #Se separan obtiene el día, mes y año de la fecha de emisión del comprobante
      fecha_registroBD=Date.parse(fecha_expedicion_f.to_s)
      dir_dia = fecha_registroBD.strftime("%d")
      dir_mes = fecha_registroBD.strftime("%m")
      dir_anno = fecha_registroBD.strftime("%Y")

      fecha_file= fecha_registroBD.strftime("%Y-%m-%d")
      #Nomenclatura para el nombre del archivo: consecutivo + fecha + extención
      file_name="#{consecutivo}_#{fecha_file}"

        #Cosas a tener en cuenta antes de indicarle una ruta:
          #1.-Un negocio puede o no tener sucursales
        if current_user.sucursal
          dir_sucursal = current_user.sucursal.nombre
          ruta_storage = "#{dir_negocio}/#{dir_sucursal}/#{dir_anno}/#{dir_mes}/#{dir_dia}/#{dir_cliente}/#{file_name}"
        else
          ruta_storage = "#{dir_negocio}/#{dir_anno}/#{dir_mes}/#{dir_dia}/#{dir_cliente}/#{file_name}"
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

        #7.- SE SALVA EN LA BASE DE DATOS
          #Se crea un objeto del modelo Factura y se le asignan a los atributos los valores correspondientes para posteriormente guardarlo como un registo en la BD.
          folio_fiscal_xml = xml_timbrado.xpath('//@UUID')
          @factura = Factura.new(folio: folio_registroBD, fecha_expedicion: fecha_file, consecutivo: consecutivo, estado_factura:"Activa", cve_metodo_pagoSAT: params[:metodo_pago])#, monto: @venta.montoVenta)

          @factura.folio_fiscal = folio_fiscal_xml
          @factura.ruta_storage =  ruta_storage

          if @factura.save
          current_user.facturas<<@factura
          current_user.negocio.facturas<<@factura
          current_user.sucursal.facturas<<@factura
          forma_pago = FacturaFormaPago.find(params[:forma_pago_id])
          forma_pago.facturas << @factura

          #Se factura a nombre del cliente que realizó la compra en el negocio.
          cliente_id=@venta.cliente.id
          Cliente.find(cliente_id).facturas << @factura

          @venta.factura = @factura
          #@factura.ventas <<  @venta

          end

        #8.- SE ENVIAN LOS COMPROBANTES(pdf y xml timbrado) AL CLIENTE POR CORREO ELECTRÓNICO. :p
        #Se asignan los valores del texto variable de la configuración de las plantillas de email.
        txtVariable_nombCliente = @factura.cliente.nombre_completo # =>nombreCliente

        txtVariable_fechaVenta =  @venta.fechaVenta # => fechaVenta
        txtVariable_consecutivoVenta = @venta.consecutivo # => númeroVenta
        #txtVariable_montoVenta = @venta.montoVenta # => totalVenta
        txtVariable_folioVenta = @venta.folio # => folioVenta
        #texto variable para las facturas
        txtVariable_fechaFactura = @factura.fecha_expedicion
        txtVariable_numeroFactura = @factura.consecutivo
        txtVariable_folioFactura = @factura.folio

        #Datos de la dirección de la empresa
        txtVariable_negocio= @factura.negocio.nombre # => Nombre de la empresa, negocio, changarro o ...
        #En cuanto a los datos de la sucursal
        txtVariable_sucursal = @factura.sucursal.nombre
        txtVariable_email = @factura.sucursal.email
        txtVariable_telefono = @factura.sucursal.telefono

        txtVariable_nombNegocio = current_user.negocio.datos_fiscales_negocio.nombreFiscal # => nombreNegocio
        #txtVariable_emailNegocio = current_user.negocio.datos_fiscales_negocio.email # => nombre
        mensaje = current_user.negocio.plantillas_emails.find_by(comprobante: "fv").msg_email
        #msg = "Hola sr. {{nombreCliente}} le hago llegar por este medio la factura de su compra del día {{fechaVenta}}"
        mensaje_email = mensaje.gsub(/(\{\{Nombre del cliente\}\})/, "#{txtVariable_nombCliente}")
        mensaje_email = mensaje_email.gsub(/(\{\{Fecha de la venta\}\})/, "#{txtVariable_fechaVenta}")
        mensaje_email = mensaje_email.gsub(/(\{\{Número de venta\}\})/, "#{txtVariable_consecutivoVenta}")
        mensaje_email = mensaje_email.gsub(/(\{\{Folio de la venta\}\})/, "#{txtVariable_folioVenta}")
        #Datos de la factura.
        mensaje_email = mensaje_email.gsub(/(\{\{Fecha de la factura\}\})/, "#{txtVariable_fechaFactura}")
        mensaje_email = mensaje_email.gsub(/(\{\{Número de factura\}\})/, "#{txtVariable_numeroFactura}")
        mensaje_email = mensaje_email.gsub(/(\{\{Folio de la factura\}\})/, "#{txtVariable_folioFactura}")
        #Dirección y dtos de contacto del changarro
        mensaje_email = mensaje_email.gsub(/(\{\{Nombre del negocio\}\})/, "#{txtVariable_negocio}")
        mensaje_email = mensaje_email.gsub(/(\{\{Nombre de la sucursal\}\})/, "#{txtVariable_sucursal}")
        mensaje_email = mensaje_email.gsub(/(\{\{Email de contacto\}\})/, "#{txtVariable_email}")
        mensaje_email = mensaje_email.gsub(/(\{\{Teléfono de contacto\}\})/, "#{txtVariable_telefono}")

        destinatario = params[:destinatario]
        tema = current_user.negocio.plantillas_emails.find_by(comprobante: "fv").asunto_email
        #También se debe de reemplazar el text variable.
        #file_name = "#{consecutivo}_#{fecha_file}"
        comprobantes = {}
        #Aquí  no se da a elegir si desea enviar pdf o xml porque, porque, porque no jajaja
        comprobantes[:pdf] = "public/#{file_name}_RepresentaciónImpresa.pdf"
        comprobantes[:xml] = "public/#{file_name}_CFDI.xml"

        #FacturasEmail.factura_email(@destinatario, @mensaje, @tema).deliver_now
        FacturasEmail.factura_email(destinatario, mensaje_email, tema, comprobantes).deliver_now

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

  #Para cancelar una factura, aunque también se puede cancelar al mismo tiempo la venta asociada.
  def cancelaFacturaVenta
    @categorias_devolucion = current_user.negocio.cat_venta_canceladas
  end

  def cancelaFacturaVenta2
    #Primero se procede a cancelar y enviar el acuse de cancelación
    # Parametros para la conexión al Webservice
    wsdl_url = "https://staging.ws.timbox.com.mx/timbrado_cfdi33/wsdl"
    usuario = "AAA010101000"
    contrasena = "h6584D56fVdBbSmmnB"

    # Parametros para la cancelación del CFDI
    uuid = @factura.folio_fiscal
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
    ruta_storage = @factura.ruta_storage
    fecha_expedicion=@factura.fecha_expedicion
    consecutivo =@factura.consecutivo
    file_name = "#{consecutivo}_#{fecha_expedicion}"
    #Se guarda el Acuse en la nube
    file = bucket.create_file StringIO.new(acuse.to_s), "#{ruta_storage}_AcuseDeCancelación.xml"
    #Se cambia el estado de la factura de Activa a Cancelada. Las facturas con acciones
    @factura.update( estado_factura: "Cancelada") #Pasa de activa a cancelada
    acuse = Nokogiri::XML(acuse)
    a = File.open("public/#{file_name}_AcuseDeCancelación", "w")
    a.write (acuse)
    a.close

    #Se envia el acuse de cancelación al correo electrónico del fulano zutano perengano
    destinatario = params[:destinatario]
    #Aquí el mensaje de la configuración...
    mensaje = "HOLA cara de bola"
    tema = "Acuse de cancelación"
    comprobantes = {xml_Ac: "public/#{file_name}_AcuseDeCancelación"}

    FacturasEmail.factura_email(destinatario, mensaje, tema, comprobantes).deliver_now

    @venta = Venta.find_by(factura: @factura.id)
    #respond_to do |format|
      #Por si quieren tambien afectar el inventario.
      if params[:rbtn] == "rbtn_factura_venta"
        categoria = params[:cat_cancelacion]
        cat_venta_cancelada = CatVentaCancelada.find(categoria)
        #venta = params[:venta]
        observaciones = params[:observaciones]
        @items = @venta.item_ventas
        #Changos que hacen estas cosas aquí? jajaja
        require 'timbrado'
        require 'nokogiri'
        require 'byebug'

        if @venta.update(:observaciones => observaciones, :status => "Cancelada")
          #Se obtiene el movimiento de caja de sucursal, de la venta que se quiere cancelar
          movimiento_caja = @venta.movimiento_caja_sucursal

          #Si el pago de la venta se realizó en efectivo, entonces se añade el monto de la venta al saldo de la caja
          if movimiento_caja.tipo_pago.eql?("efectivo")
            caja_sucursal = @venta.caja_sucursal
            saldo = caja_sucursal.saldo
            saldoActualizado = saldo - @venta.montoVenta
            caja_sucursal.saldo = saldoActualizado
            caja_sucursal.save
          end

          #Se elimina el movimiento de caja relacionado con la venta
          movimiento_caja.destroy

          #Por cada item de venta, se crea un registro de venta cancelada.
          @venta.item_ventas.each do |itemVenta|
            ventaCancelada = VentaCancelada.new(:articulo => itemVenta.articulo, :item_venta => itemVenta, :venta => @venta, :cat_venta_cancelada=>cat_venta_cancelada, :user=>current_user, :observaciones=>observaciones, :negocio=>@venta.negocio, :sucursal=>@venta.sucursal, :cantidad_devuelta=>itemVenta.cantidad, :monto=>itemVenta.monto)
            ventaCancelada.save
            itemVenta.status = "Con devoluciones"
            itemVenta.save
          end
        end
        #format.json { head :no_content}
        #format.js
      #else
        #Agregar extenciones...y transacciones.
        #format.html { redirect_to facturas_index_path, notice: 'No se pudo cancelar la venta de la factura, intente cancelarla desde el módulo de ventas..' }
      #end
    end
    respond_to do |format| # Agregar mensajes después de las transacciones
      format.html { redirect_to facturas_index_path, notice: 'La factura ha sido cancelada exitosamente!' }
    end
  end
=begin
  #NOTAS DE CRÉDITO pendientes(por ahora solo se expiden notas de crédito por devoluciones de mercancia)
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
        regimenFiscal: current_user.negocio.datos_fiscales_negocio.regimen_fiscal.cve_regimen_fiscalSAT, #CATALOGO
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


        if c.articulo.impuesto.present? && c.articulo.impuesto.tipo == "Federal"
          if c.articulo.impuesto.nombre == "IVA"
            clave_impuesto = "002"
          elsif c.articulo.impuesto.nombre == "IEPS"
            clave_impuesto =  "003"
          end
          factura.impuestos.traslados << CFDI::Impuesto::Traslado.new(base: c.precio_venta * c.cantidad,
            tax: clave_impuesto, type_factor: "Tasa", rate: format('%.6f',(c.articulo.impuesto.porcentaje/100)).to_f, concepto_id: cont )
        end

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

=end

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
      venta = @factura.venta#s.first
      txtVariable_nombCliente = @factura.cliente.nombre_completo # =>No se toma de la venta por que se puede facturar a nombre de otro cuate
      #texti variable para las ventas
      txtVariable_fechaVenta =  venta.fechaVenta # => fechaVenta
      txtVariable_consecutivoVenta = venta.consecutivo # => númeroVenta
      #txtVariable_montoVenta = venta.montoVenta # => totalVenta
      txtVariable_folioVenta = venta.folio # => folioVenta

      #texto variable para las facturas
      txtVariable_fechaFactura = @factura.fecha_expedicion # => folioVenta
      txtVariable_numeroFactura = @factura.consecutivo # => folioVenta
      txtVariable_folioFactura = @factura.folio# => folioVenta

      #Datos de la dirección de la empresa
      txtVariable_negocio= @factura.negocio.nombre # => Nombre de la empresa, negocio, changarro o ...
      #En cuanto a los datos de la sucursal
      txtVariable_sucursal = @factura.sucursal.nombre
      txtVariable_email = @factura.sucursal.email
      txtVariable_telefono = @factura.sucursal.telefono


      txtVariable_nombNegocio = current_user.negocio.datos_fiscales_negocio.nombreFiscal # => nombreNegocio
      #txtVariable_emailNegocio = current_user.negocio.datos_fiscales_negocio.email # => nombre
      if @factura.estado_factura == "Activa"
         asunto = current_user.negocio.plantillas_emails.find_by(comprobante: "fv").asunto_email
         mensaje = current_user.negocio.plantillas_emails.find_by(comprobante: "fv").msg_email
      elsif @factura.estado_factura == "Cancelada"
         mensaje = current_user.negocio.plantillas_emails.find_by(comprobante: "ac_fv").msg_email
         asunto = current_user.negocio.plantillas_emails.find_by(comprobante: "ac_fv").asunto_email
      end
      #msg = "Hola sr. {{nombreCliente}} le hago llegar por este medio la factura de su compra del día {{fechaVenta}}"
      #msg = "Hola sr. {{nombreCliente}} le hago llegar por este medio la factura de su compra del día {{fechaVenta}}"
      mensaje_email = mensaje.gsub(/(\{\{Nombre del cliente\}\})/, "#{txtVariable_nombCliente}")
      mensaje_email = mensaje_email.gsub(/(\{\{Fecha de la venta\}\})/, "#{txtVariable_fechaVenta}")
      mensaje_email = mensaje_email.gsub(/(\{\{Número de venta\}\})/, "#{txtVariable_consecutivoVenta}")
      mensaje_email = mensaje_email.gsub(/(\{\{Folio de la venta\}\})/, "#{txtVariable_folioVenta}")
      #Datos de la factura.
      mensaje_email = mensaje_email.gsub(/(\{\{Fecha de la factura\}\})/, "#{txtVariable_fechaFactura}")
      mensaje_email = mensaje_email.gsub(/(\{\{Número de factura\}\})/, "#{txtVariable_numeroFactura}")
      mensaje_email = mensaje_email.gsub(/(\{\{Folio de la factura\}\})/, "#{txtVariable_folioFactura}")
      #Dirección y dtos de contacto del changarro
      mensaje_email = mensaje_email.gsub(/(\{\{Nombre del negocio\}\})/, "#{txtVariable_negocio}")
      mensaje_email = mensaje_email.gsub(/(\{\{Nombre de la sucursal\}\})/, "#{txtVariable_sucursal}")
      mensaje_email = mensaje_email.gsub(/(\{\{Email de contacto\}\})/, "#{txtVariable_email}")
      mensaje_email = mensaje_email.gsub(/(\{\{Teléfono de contacto\}\})/, "#{txtVariable_telefono}")

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
      #Solo es posible si la factura de venta está cancelada
      if params[:xml_Ac] == "yes"
        comprobantes[:xml_Ac] = "public/#{file_name}_AcuseDeCancelación.xml"
        file_download_storage_xml = bucket.file "#{ruta_storage}_AcuseDeCancelación.xml"
        file_download_storage_xml.download "public/#{file_name}_AcuseDeCancelación.xml"
      end

      #FacturasEmail.factura_email(@destinatario, @mensaje, @tema).deliver_now
      FacturasEmail.factura_email(destinatario, mensaje_email, asunto, comprobantes).deliver_now

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
    if @factura.estado_factura == "Activa"
       @tema = current_user.negocio.plantillas_emails.find_by(comprobante: "fv").asunto_email
       mensaje = current_user.negocio.plantillas_emails.find_by(comprobante: "fv").msg_email
    elsif @factura.estado_factura == "Cancelada"
       mensaje = current_user.negocio.plantillas_emails.find_by(comprobante: "ac_fv").msg_email
       @tema = current_user.negocio.plantillas_emails.find_by(comprobante: "ac_fv").asunto_email
    end

    #@tema.html_safe
    venta = @factura.venta#s.first
    txtVariable_nombCliente = @factura.cliente.nombre_completo # =>No se toma de la venta por que se puede facturar a nombre de otro cuate
    #texti variable para las ventas
    txtVariable_fechaVenta =  venta.fechaVenta # => fechaVenta
    txtVariable_consecutivoVenta = venta.consecutivo # => númeroVenta
    #txtVariable_montoVenta = venta.montoVenta # => totalVenta
    txtVariable_folioVenta = venta.folio # => folioVenta

    #texto variable para las facturas
    txtVariable_fechaFactura = @factura.fecha_expedicion # => folioVenta
    txtVariable_numeroFactura = @factura.consecutivo # => folioVenta
    txtVariable_folioFactura = @factura.folio# => folioVenta

    #Datos de la dirección de la empresa
    txtVariable_negocio= @factura.negocio.nombre # => Nombre de la empresa, negocio, changarro o ...
    #En cuanto a los datos de la sucursal
    txtVariable_sucursal = @factura.sucursal.nombre
    txtVariable_email = @factura.sucursal.email
    txtVariable_telefono = @factura.sucursal.telefono

    txtVariable_nombNegocio = current_user.negocio.datos_fiscales_negocio.nombreFiscal # => nombreNegocio
    #txtVariable_emailNegocio = current_user.negocio.datos_fiscales_negocio.email # => nombre
    #msg = "Hola sr. {{nombreCliente}} le hago llegar por este medio la factura de su compra del día {{fechaVenta}}"
    mensaje_email = mensaje.gsub(/(\{\{Nombre del cliente\}\})/, "#{txtVariable_nombCliente}")
    mensaje_email = mensaje_email.gsub(/(\{\{Fecha de la venta\}\})/, "#{txtVariable_fechaVenta}")
    mensaje_email = mensaje_email.gsub(/(\{\{Número de venta\}\})/, "#{txtVariable_consecutivoVenta}")
    mensaje_email = mensaje_email.gsub(/(\{\{Folio de la venta\}\})/, "#{txtVariable_folioVenta}")
    #Datos de la factura.
    mensaje_email = mensaje_email.gsub(/(\{\{Fecha de la factura\}\})/, "#{txtVariable_fechaFactura}")
    mensaje_email = mensaje_email.gsub(/(\{\{Número de factura\}\})/, "#{txtVariable_numeroFactura}")
    mensaje_email = mensaje_email.gsub(/(\{\{Folio de la factura\}\})/, "#{txtVariable_folioFactura}")
    #Dirección y dtos de contacto del changarro
    mensaje_email = mensaje_email.gsub(/(\{\{Nombre del negocio\}\})/, "#{txtVariable_negocio}")
    mensaje_email = mensaje_email.gsub(/(\{\{Nombre de la sucursal\}\})/, "#{txtVariable_sucursal}")
    mensaje_email = mensaje_email.gsub(/(\{\{Email de contacto\}\})/, "#{txtVariable_email}")
    mensaje_email = mensaje_email.gsub(/(\{\{Teléfono de contacto\}\})/, "#{txtVariable_telefono}")

    @mensaje= mensaje_email

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
    @por_cliente= false
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
    @por_cliente= false

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
                #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where("montoVenta #{operador_monto} ?", @monto_factura)) if @monto_factura
                @facturas = current_user.negocio.facturas.where("monto #{operador_monto} ?", @monto_factura) if @monto_factura
              else
                @monto_factura2 = params[:monto_factura2]
                #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where(montoVenta: @monto_factura..@monto_factura2)) if @monto_factura && @monto_factura2
                @facturas = current_user.negocio.facturas.where(monto: @monto_factura..@monto_factura2) if @monto_factura && @monto_factura2
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
                #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where("montoVenta #{operador_monto} ?", @monto_factura)) if @monto_factura
                @facturas = current_user.negocio.facturas.where("monto #{operador_monto} ?", @monto_factura) if @monto_factura
              else
                @monto_factura2 = params[:monto_factura2]
                #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where(montoVenta: @monto_factura..@monto_factura2)) if @monto_factura && @monto_factura2
                @facturas = current_user.negocio.facturas.where(monto: @monto_factura..@monto_factura2) if @monto_factura && @monto_factura2
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
                #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where("montoVenta #{operador_monto} ?", @monto_factura)) if @monto_factura
                @facturas = current_user.negocio.facturas.where("monto #{operador_monto} ?", @monto_factura) if @monto_factura
              else
                @monto_factura2 = params[:monto_factura2]
                #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where(montoVenta: @monto_factura..@monto_factura2)) if @monto_factura && @monto_factura2
                @facturas = current_user.negocio.facturas.where(monto: @monto_factura..@monto_factura2) if @monto_factura && @monto_factura2
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
                #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where("montoVenta #{operador_monto} ?", @monto_factura)) if @monto_factura
                @facturas = current_user.negocio.facturas.where("monto #{operador_monto} ?", @monto_factura) if @monto_factura
              else
                @monto_factura2 = params[:monto_factura2]
                #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where(montoVenta: @monto_factura..@monto_factura2)) if @monto_factura && @monto_factura2
                @facturas = current_user.negocio.facturas.where(monto: @monto_factura..@monto_factura2) if @monto_factura && @monto_factura2
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
    #ventas = @factura.ventas
    #if ventas.length == 1 #Cuando se trate de una sola venta facturada
      #venta = ventas.first
      venta = @factura.venta
      @items  = venta.item_ventas
      #@montoFactura = venta.montoVenta
      @nombreFiscal =  @factura.cliente.datos_fiscales_cliente ?  @factura.cliente.datos_fiscales_cliente.nombreFiscal : "Púlico general"
      @rfc =  @factura.cliente.datos_fiscales_cliente ?  @factura.cliente.datos_fiscales_cliente.rfc : "XAXX010101000"
      cve_forma_pagoSAT = @factura.factura_forma_pago.cve_forma_pagoSAT
      nombre_forma_pagoSAT = @factura.factura_forma_pago.nombre_forma_pagoSAT
      @forma_pago = "#{cve_forma_pagoSAT} - #{nombre_forma_pagoSAT}"
      nombre_metodo_pagoSAT = @factura.cve_metodo_pagoSAT == "PUE" ? "Pago en una sola exhibición" : "Pago en parcialidades o diferido"
      @metodo_pago = "#{@factura.cve_metodo_pagoSAT} - #{nombre_metodo_pagoSAT}"
    #elsif ventas.length > 1 #Si es una factura global contiene varias ventas

    #end

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



      #LLENADO DEL XML DIRECTAMENTE DE LA BASE DE DATOS
      fecha_expedicion_f = Time.now
      factura = CFDI::Comprobante.new({
        serie: serie,
        folio: consecutivo,
        fecha: fecha_expedicion_f,
        #Por defaulf el tipo de comprobante es de tipo "I" Ingreso
        #Moneda: MXN Peso Mexicano, USD Dólar Americano, Etc…
        #La moneda por default es MXN
        FormaPago: cve_forma_pagoSAT,
        #El campo Condiciones de pago no debe de existir
        #Método de pago: SIEMPRE debe ser la clave “PUE” (Pago en una sola exhibición); en el caso de que se venda a parcialidades o diferido, se deberá proceder a emitir el CFDI con complemento de pagos, detallando los datos del cliente que los realiza; en pocas palabras, no esta permitido emitir un CFDI global con ventas a parcialidades o diferidas.
        metodoDePago: 'PUE',
        #El código postal de la matriz o sucursal
        lugarExpedicion: current_user.sucursal.codigo_postal,#current_user.negocio.datos_fiscales_negocio.codigo_postal,#, #CATALOGO
        total: '%.2f' % (@ventas.map(&:montoVenta).reduce(:+)).round(2)#96.56
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
        regimenFiscal: current_user.negocio.datos_fiscales_negocio.regimen_fiscal.cve_regimen_fiscalSAT, #CATALOGO
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
      #Para la clave y el nombre del regimen fiscal del contribuyente
      cve_regimen_fiscalSAT = current_user.negocio.datos_fiscales_negocio.regimen_fiscal.cve_regimen_fiscalSAT
      nomb_regimen_fiscalSAT = current_user.negocio.datos_fiscales_negocio.regimen_fiscal.nomb_regimen_fiscalSAT
      cve_nomb_regimen_fiscalSAT = "#{cve_regimen_fiscalSAT} - #{nomb_regimen_fiscalSAT}"
      #Para el nombre del changarro feo
      nombre_negocio = current_user.negocio.nombre
      #Se pasa un hash con la información extra en la representación impresa como: datos de contacto, dirección fiscal y descripcion de la clave de los catálogos del SAT.
      hash_info = {xml_copia: xml_copia, codigoQR: codigoQR, logo: logo, cadOrigComplemento: cadOrigComplemento, uso_cfdi_descripcion: "Por definir",
                  cve_nombre_metodo_pago:"PUE - Pago en una sola exhibición", cve_nombre_forma_pago: cve_nombre_forma_pagoSAT, cve_nomb_regimen_fiscalSAT: cve_nomb_regimen_fiscalSAT, nombre_negocio: nombre_negocio}
      #hash_info[:Telefono1Receptor]= @@venta.cliente.telefono1 if @@venta.cliente.telefono1
      #hash_info[:EmailReceptor]= @@venta.cliente.email if @@venta.cliente.email


      xml_rep_impresa = factura.add_elements_to_xml(hash_info)
      #puts xml_rep_impresa
      template = Nokogiri::XSLT(File.read('/home/daniel/Vídeos/sysChurch/lib/XSLT.xsl'))
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
      dir_dia = fecha_registroBD.strftime("%d")
      dir_mes = fecha_registroBD.strftime("%m")
      dir_anno = fecha_registroBD.strftime("%Y")

      fecha_file= fecha_registroBD.strftime("%Y-%m-%d")
      #Nomenclatura para el nombre del archivo: consecutivo + fecha + extención
      file_name="#{consecutivo}_#{fecha_file}"

        #Cosas a tener en cuenta antes de indicarle una ruta:
          #1.-Un negocio puede o no tener sucursales
        if current_user.sucursal
          dir_sucursal = current_user.sucursal.nombre
          ruta_storage = "#{dir_negocio}/#{dir_sucursal}/#{dir_anno}/#{dir_mes}/#{dir_dia}/#{dir_cliente}/#{file_name}"
        else
          ruta_storage = "#{dir_negocio}/#{dir_anno}/#{dir_mes}/#{dir_dia}/#{dir_cliente}/#{file_name}"
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

        #7.- SE ENVIAN LOS COMPROBANTES(pdf y xml timbrado)
        #Las facturas globales no tiene sentido enviarlas por email por que son a público en general.

        #8.- SE SALVA EN LA BASE DE DATOS
          #Se crea un objeto del modelo Factura y se le asignan a los atributos los valores correspondientes para posteriormente guardarlo como un registo en la BD.
          folio_fiscal_xml = xml_timbrado.xpath('//@UUID')
          @factura = Factura.new(folio: folio_registroBD, fecha_expedicion: fecha_file, consecutivo: consecutivo, estado_factura:"Activa", cve_metodo_pagoSAT: "PUE")
=begin
          @factura.folio_fiscal = folio_fiscal_xml
          @factura.ruta_storage =  ruta_storage

          if @factura.save
          current_user.facturas<<@factura
          current_user.negocio.facturas<<@factura
          current_user.sucursal.facturas<<@factura
          #Se relaciona con su forma de pago
          forma_pago = FacturaFormaPago.find_by(cve_forma_pagoSAT: cve_forma_pagoSAT) #Recibir como parametro si hay dos operaciones con montos iguales pero diferente forma de pago
          forma_pago.facturas << @factura

          #Se factura a nombre del cliente que realizó la compra en el negocio.
          #cliente_id=@@venta.cliente.id
          #Cliente.find(cliente_id).facturas << @factura

          #venta_id=@@venta.id
          #Venta.find(venta_id).factura = @factura #relación uno a uno
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
end
