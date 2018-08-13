class FacturasController < ApplicationController
  before_action :set_factura, only: [:show, :edit, :update, :destroy, :readpdf, :enviar_email,:enviar_email_post, :descargar_cfdis, :cancelar_cfdi, :cancelaFacturaVenta, :cancelaFacturaVenta2]
  #before_action :set_facturaDeVentas, only: [:show]
  #before_action :set_cajeros, only: [:index, :consulta_facturas, :consulta_avanzada, :consulta_por_folio, :consulta_por_cliente]
  before_action :set_sucursales, only: [:index, :index_facturas_globales, :consulta_facturas, :consulta_avanzada, :consulta_por_folio, :consulta_por_cliente, :generarFacturaGlobal, :mostrarVentas_FacturaGlobal]
  before_action :set_clientes, only: [:index, :consulta_facturas, :consulta_avanzada, :consulta_por_folio, :consulta_por_cliente]

  # GET /facturas
  # GET /facturas.json
  def index
    @consulta = false
    @avanzada = false

    if request.get?
      @tipo_factura = params[:tipo_factura]
      #el tipo_facura lo uso para discriminar las facturas de ventas entre las facturas globales
      if can? :create, Negocio
        @facturas = current_user.negocio.facturas.joins(:ventas).where(ventas: {tipo_factura: params[:tipo_factura]}, facturas: {created_at: Date.today.beginning_of_month..Date.today.end_of_month}).uniq.order(created_at: :desc)
        #@facturas = current_user.negocio.facturas.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
      else
        #@facturas = current_user.sucursal.facturas.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
        @facturas = current_user.sucursal.facturas.joins(:ventas).where( ventas: {tipo_factura: params[:tipo_factura]}, facturas: {created_at: Date.today.beginning_of_month..Date.today.end_of_month}).uniq.order(created_at: :desc)
      end
    end
  end

  def index_facturas_globales
    @consulta = false
    @avanzada = false

    if request.get?
      @tipo_factura = params[:tipo_factura]
      #el tipo_facura lo uso para discriminar las facturas de ventas entre las facturas globales
      if can? :create, Negocio
        @facturas = current_user.negocio.facturas.joins(:ventas).where(ventas: {tipo_factura: params[:tipo_factura]}, facturas: {created_at: Date.today.beginning_of_month..Date.today.end_of_month}).uniq.order(created_at: :desc)
        #@facturas = current_user.negocio.facturas.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
      else
        #@facturas = current_user.sucursal.facturas.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
        @facturas = current_user.sucursal.facturas.joins(:ventas).where( ventas: {tipo_factura: params[:tipo_factura]}, facturas: {created_at: Date.today.beginning_of_month..Date.today.end_of_month}).uniq.order(created_at: :desc)
      end
    end
  end

  # GET /facturas/1
  # GET /facturas/1.json
  def show
      @nombreFiscal =  @factura.cliente.datos_fiscales_cliente ?  @factura.cliente.datos_fiscales_cliente.nombreFiscal : "Púlico general"
      @rfc =  @factura.cliente.datos_fiscales_cliente ?  @factura.cliente.datos_fiscales_cliente.rfc : "XAXX010101000"
      cve_forma_pagoSAT = @factura.factura_forma_pago.cve_forma_pagoSAT
      nombre_forma_pagoSAT = @factura.factura_forma_pago.nombre_forma_pagoSAT
      @forma_pago = "#{cve_forma_pagoSAT} - #{nombre_forma_pagoSAT}"
      nombre_metodo_pagoSAT = @factura.cve_metodo_pagoSAT == "PUE" ? "Pago en una sola exhibición" : "Pago en parcialidades o diferido"
      @metodo_pago = "#{@factura.cve_metodo_pagoSAT} - #{nombre_metodo_pagoSAT}"
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

    if request.post?
      require 'cfdi'
      require 'timbrado'

      if params[:commit] == "Cancelar"
        @venta=nil #Se borran los datos por si el usuario le da "atras" en el navegador.
        redirect_to facturas_index_path
      else
        @venta = Venta.find(params[:id]) if params.key?(:id)
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
        if current_user.sucursal.facturas.last
          consecutivo = current_user.sucursal.facturas.last.consecutivo
          if consecutivo
            consecutivo += 1
          end
        else
          consecutivo = 1 #Se asigna el número a la factura por default o de acuerdo a la configuración del usuario.
        end

        claveSucursal = current_user.sucursal.clave
        folio_registroBD = claveSucursal + "FV" + consecutivo.to_s
        serie = claveSucursal + "FV"

        forma_pago_f = FacturaFormaPago.find(params[:forma_pago_id])
        metodo_pago_f = params[:metodo_pago] == "PUE - Pago en una sola exhibición" ? "PUE" : "PPD"
      
      factura = CFDI::Comprobante.new({
        serie: serie,
        folio: consecutivo,
        #Por defaulf el tipo de comprobante es de tipo "I" Ingreso
        #La moneda por default es MXN
        FormaPago: forma_pago_f.cve_forma_pagoSAT,#CATALOGO Es de tipo string
        condicionesDePago: 'Sera marcada como pagada en cuanto el receptor haya cubierto el pago.',
        metodoDePago: metodo_pago_f, #CATALOGO
        lugarExpedicion: current_user.sucursal.codigo_postal,#current_user.negocio.datos_fiscales_negocio.codigo_postal,#, #CATALOGO
        total: '%.2f' % @venta.montoVenta.round(2)
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

      uso_cfdi = UsoCfdi.find(params[:uso_cfdi_id])
      factura.receptor = CFDI::Receptor.new({
        #Datos requeridos si o si son: el rfc, nombre fiscal y el uso del CFDI.
         rfc: params[:rfc_input],
         nombre: params[:nombre_fiscal_receptor_vf],
         UsoCFDI:uso_cfdi.clave, #CATALOGO
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

#========================================================================================================================
      #3.- SE AGREGA EL CERTIFICADO Y EL SELLO DIGITAL
      @total_to_w= factura.total_to_words
      # Esto hace que se le agregue al comprobante el certificado y su número de serie (noCertificado)
      certificado.certifica factura
      #Se agrega el sello digital del comprobante, esto implica actulizar la fecha y calcular la cadena oriiginal
      xml_certificado_sellado = llave.sella factura
      p xml_certificado_sellado

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
      fv_id = Factura.last ? Factura.last.id + 1 : 1
      archivo = File.open("public/#{fv_id}_fv.xml", "w")
      archivo.write (xml_timbox)
      archivo.close

      #Se forma la cadena original del timbre fiscal digital de manera manual por que e mugroso xslt del SAT no Jala.
      factura.complemento=CFDI::Complemento.new(
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
      cadOrigComplemento=factura.complemento.cadena_TimbreFiscalDigital
      logo=current_user.negocio.logo
      uso_cfdi_descripcion = uso_cfdi.descripcion
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
      #Se guarda el pdf 
      nombre_pdf="#{fv_id}_fv.pdf"
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
      dir_cliente = params[:nombre_fiscal_receptor_vf]
      #Se separan obtiene el día, mes y año de la fecha de emisión del comprobante
      fecha_registroBD = DateTime.parse(xml_timbox.xpath('//@Fecha').to_s) 
      dir_dia = fecha_registroBD.strftime("%d")
      dir_mes = fecha_registroBD.strftime("%m")
      dir_anno = fecha_registroBD.strftime("%Y")

      fecha_file = fecha_registroBD.strftime("%Y-%m-%d")
      #Nomenclatura para el nombre del archivo: consecutivo + fecha + extención

      #Cosas a tener en cuenta antes de indicarle una ruta:
        #1.-Un negocio puede o no tener sucursales
      if current_user.sucursal
        dir_sucursal = current_user.sucursal.nombre
        ruta_storage = "#{dir_negocio}/#{dir_sucursal}/#{dir_cliente}/#{dir_anno}/#{dir_mes}/#{dir_dia}/#{fv_id}_fv"
      else
        ruta_storage = "#{dir_negocio}/#{dir_cliente}/#{dir_anno}/#{dir_mes}/#{dir_dia}/#{fv_id}_fv"
      end

      #Los comprobantes de almacenan en google cloud
      #file = bucket.create_file StringIO.new(pdf), "#{ruta_storage}_RepresentaciónImpresa.pdf"
      #file = bucket.create_file StringIO.new(xml_timbox.to_s), "#{ruta_storage}_CFDI.xml"
      file = bucket.create_file "public/#{fv_id}_fv.pdf", "#{ruta_storage}.pdf"
      file = bucket.create_file "public/#{fv_id}_fv.xml", "#{ruta_storage}.xml"

#========================================================================================================================

      #7.- SE REGISTRA LA NUEVA FACTURA EN LA BASE DE DATOS
      #Se crea un objeto del modelo Factura y se le asignan a los atributos los valores correspondientes para posteriormente guardarlo como un registo en la BD.
      folio_fiscal_xml = xml_timbox.xpath('//@UUID')
      @factura = Factura.new(folio: folio_registroBD, fecha_expedicion: fecha_file, consecutivo: consecutivo, estado_factura:"Activa", cve_metodo_pagoSAT: params[:metodo_pago], monto: '%.2f' % @venta.montoVenta.round(2), folio_fiscal: folio_fiscal_xml, ruta_storage: ruta_storage)#, monto: @venta.montoVenta)
      
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

         @venta.update(tipo_factura: "fv")
         @factura.ventas <<  @venta
      end

#=======================================================================================================================
        #8.- SE ENVIAN LOS COMPROBANTES(pdf y xml timbrado) AL CLIENTE POR CORREO ELECTRÓNICO. :p
        destinatario_final = params[:destinatario]
        #Se asignan los valores del texto variable de la configuración de las plantillas de email.
        plantilla_email("fv")
        comprobantes = {pdf:"public/#{fv_id}_fv.pdf", xml: "public/#{fv_id}_fv.xml"}
        #FacturasEmail.factura_email(@destinatario, @mensaje, @tema).deliver_now
        FacturasEmail.factura_email(destinatario_final, @mensaje, @asunto, comprobantes).deliver_now

#=======================================================================================================================
          #9.- SE MUESTRA EL PDF, SE REDIRIGE AL INDEX O ALGUNA EXCEPCIÓN
          if params[:commit] == "Facturar y crear nueva"
            if "yes" == params[:imprimir]
              send_file( File.open( "public/#{fv_id}_fv.pdf"), :disposition => "inline", :type => "application/pdf")
            else
              respond_to do |format|
              format.html { redirect_to action: "facturaDeVentas", notice: 'La factura fue registrada existoxamente!' }
              end
            end
          else
            if "yes" == params[:imprimir]
              send_file( File.open( "public/#{fv_id}_fv.pdf"), :disposition => "inline", :type => "application/pdf")
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
    #Solo se muestran los datos
    plantilla_email("ac_fv")
  end

  def cancelaFacturaVenta2
    require 'timbrado'
    #Primero se procede a cancelar y enviar el acuse de cancelación
    # Parametros para la conexión al Webservice  
    wsdl_url = "https://staging.ws.timbox.com.mx/timbrado_cfdi33/wsdl"
    usuario = "AAA010101000"
    contrasena = "h6584D56fVdBbSmmnB"
    # Parametros para la cancelación del CFDI
    uuid = ["113D811E-2B32-41F0-8585-FE68C07AB97D"]#@factura.folio_fiscal
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

    #Se realizan las consultas para formar los directorios en cloud
    dir_negocio = current_user.negocio.nombre
    dir_sucursal = current_user.sucursal.nombre
    dir_cliente = @factura.cliente.nombre_completo

    #Se separan obtiene el día, mes y año de la fecha de emisión del comprobante
    fecha_cancelacion =  DateTime.parse(Nokogiri::XML(acuse).xpath("//@Fecha").to_s) #Es el único atributo llamado Fecha en el acuse :P
    dir_dia = fecha_cancelacion.strftime("%d")
    dir_mes = fecha_cancelacion.strftime("%m")
    dir_anno = fecha_cancelacion.strftime("%Y")

    ac_fv_id = FacturaCancelada.last ? FacturaCancelada.last.id + 1 : 1

    ruta_storage = "#{dir_negocio}/#{dir_sucursal}/#{dir_cliente}/#{dir_anno}/#{dir_mes}/#{dir_dia}/#{ac_fv_id}_ac_fv"
    #Se guarda el Acuse en la nube
    file = bucket.create_file StringIO.new(acuse.to_s), "#{ruta_storage}.xml"

    acuse = Nokogiri::XML(acuse)
    a = File.open("public/#{ac_fv_id}_ac_fv", "w")
    a.write (acuse)
    a.close

    #Se guarda el Acuse en la nube
    file = bucket.create_file StringIO.new(acuse.to_s), "#{ruta_storage}.xml"
    #Se cambia el estado de la factura de Activa a Cancelada. Las facturas con acciones

    #Se registra la cancelación de la factura
    @factura_cancelada = FacturaCancelada.new(fecha_cancelacion: fecha_cancelacion, ruta_storage: ruta_storage)#, monto: @venta.montoVenta)

    if @factura_cancelada.save
      current_user.negocio.factura_canceladas << @factura_cancelada
      current_user.sucursal.factura_canceladas << @factura_cancelada 
      current_user.factura_canceladas << @factura_cancelada
      @factura.factura_cancelada = @factura_cancelada

      @factura.update( estado_factura: "Cancelada") 

      #Naaa mejor un filtro en las notas de crédito para que cancelen sus comprobantes relacionados...
=begin
      #En caso que la factura de venta tenga una o más notas de crédito relacionadas
      if @factura.factura_nota_creditos.present?
        #Se cambia el estado de la Factura de activa a Cancelada
        @factura.update(estado_factura: "Cancelada") 
 
        facturaVentaNotaCredito = @factura.factura_nota_creditos
        facturaVentaNotaCredito.each do | fv_nc|
          #Se comprueba que cada nota de credito de la factura no esté relacioonada con otro comprobante de ingreso para proceder a cancelarla
          
          notaCredito = NotaCredito.find(fv_nc.nota_credito.id)#.facturas_nota_creditos
            notaCreditoFacturaVenta = FacturaNotaCredito.where(nota_credito: notaCredito)
            
            #Quiere decir que la nota de credito fue realizada únicamente para la factura de venta que se cancelará, por lo q también se debe de cancelar la NC
            if notaCreditoFacturaVenta.length == 1 
              cancelar = true
            end 
        end
        #También se cambia el estado de las notas de crédito relacionadas, siempre y cuando éstas no esten asociadas a otros comprobantes de ingreso 
        notaCredito.update(estado_nc: "Cancelada")
              FacturaNotaCredito.find_by(factura: @factura, nota_credito: nc).update(estado_nc: "Cancelada")
      end
=end      
    end

    #En este caso se toman como para metros ya que la cancelación solo la prodrán realizar los uasurios con privilegios de administrador y sepa q
    #Se envia el acuse de cancelación al correo electrónico del fulano zutano perengano
    destinatario = params[:destinatario]
    asunto = params[:asunto]
    mensaje = params[:summernote]

    comprobantes = {xml_Ac: "public/#{ac_fv_id}_ac_fv"}

    FacturasEmail.factura_email(destinatario, mensaje, asunto, comprobantes).deliver_now

    ventas = @factura.ventas #Venta.find_by(factura: @factura.id)
    #respond_to do |format|
      #Por si quieren tambien afectar el inventario.
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
      ########
      end
     
    respond_to do |format| # Agregar mensajes después de las transacciones
      format.html { redirect_to facturas_index_path, notice: 'La factura ha sido cancelada exitosamente!' }
    end
  end


  def readpdf

    gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
    storage=gcloud.storage
    bucket = storage.bucket "cfdis"
    ruta_storage = @factura.ruta_storage
    #Se descarga el pdf de la nube y se guarda en el disco

    file_download_storage = bucket.file "#{ruta_storage}.pdf"
    file_download_storage.download "public/#{@factura.id}.pdf"


    #Se comprueba que el archivo exista en la carpeta publica de la aplicación
    if File::exists?( "public/#{@factura.id}.pdf")
      file=File.open( "public/#{@factura.id}.pdf")
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

      destinatario_final = params[:destinatario]
      if @factura.estado_factura == "Activa"
        plantilla_email("fv")
      elsif @factura.estado_factura == "Cancelada"
        plantilla_email("ac_fv")
      end

      ruta_storage = @factura.ruta_storage
      #Se crea un objeto de cloud para poder descargar los comprobantes
      gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
      storage=gcloud.storage
      bucket = storage.bucket "cfdis"

      comprobantes = {}
      if params[:pdf] == "yes"
        comprobantes[:pdf] = "public/#{@factura.id}_fv.pdf"
        file_download_storage_xml = bucket.file "#{ruta_storage}.pdf"
        file_download_storage_xml.download "public/#{@factura.id}_fv.pdf"
      end
      if params[:xml] == "yes"
        comprobantes[:xml] = "public/#{@factura.id}.xml"
        file_download_storage_xml = bucket.file "#{ruta_storage}.xml"
        file_download_storage_xml.download "public/#{@factura.id}_fv.xml"
      end
     
      #Solo es posible si la factura de venta está cancelada
      if params[:xml_Ac] == "yes"
        comprobantes[:xml_Ac] = "public/#{@factura.factura_cancelada.id}_ac_fv.xml"
        file_download_storage_xml = bucket.file "#{ruta_storage}.xml"
        file_download_storage_xml.download "public/#{@factura.factura_cancelada.id}_ac_fv.xml"
      end

      #FacturasEmail.factura_email(@destinatario, @mensaje, @tema).deliver_now
      FacturasEmail.factura_email(destinatario_final, @mensaje, @asunto, comprobantes).deliver_now

      respond_to do |format|
        format.html { redirect_to action: "index"}
        flash[:notice] = "Los comprobantes se han enviado a #{destinatario_final}!"
        #format.html { redirect_to facturas_index_path, notice: 'No se encontró la factura, vuelva a intentarlo!' }
      end

    end
  end

  def enviar_email 
    if @factura.estado_factura == "Activa"
      plantilla_email("fv")
    elsif @factura.estado_factura == "Cancelada"
      plantilla_email("ac_fv")
    end
  end

  def descargar_cfdis
    gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
    storage=gcloud.storage
    bucket = storage.bucket "cfdis"
    ruta_storage = @factura.ruta_storage

    file_download_storage_xml = bucket.file "#{ruta_storage}.xml"

    file_download_storage_xml.download "public/#{@factura.id}.xml"

    xml = File.open( "public/#{@factura.id}.xml")
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
      @tipo_factura = params[:tipo_factura]
      if can? :create, Negocio
        @facturas = current_user.negocio.facturas.joins(:ventas).where( ventas: {tipo_factura: @tipo_factura}, facturas: {fecha_expedicion: @fechaInicial..@fechaFinal}).uniq
      else
        @facturas = current_user.sucursal.facturas.joins(:ventas).where( ventas: {tipo_factura: @tipo_factura}, facturas: {fecha_expedicion: @fechaInicial..@fechaFinal}).uniq
      end

      respond_to do |format|
        if @tipo_factura == "fv"
          format.html { render 'index'}
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
        @facturas = current_user.negocio.facturas.joins(:ventas).where( ventas: {tipo_factura: @tipo_factura}, facturas: {folio: @folio_fact}).uniq
      else
        @facturas = current_user.sucursal.facturas.joins(:ventas).where( ventas: {tipo_factura: @tipo_factura}, facturas: {folio: @folio_fact}).uniq
        #@facturas = current_user.sucursal.facturas.where(folio: @folio_fact)
      end
      respond_to do |format|
        if @tipo_factura == "fv"
          format.html { render 'index'}
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
        #@facturas = current_user.negocio.facturas.where(cliente_id: current_user.negocio.clientes.where(id:(DatosFiscalesCliente.find_by rfc: @rfc).cliente_id))
        if params[:rbtn] == "rbtn_rfc"
          #Se puede presentar el caso en el que un negocio tenga clientes con el mismo RFC y/o nombres fiscales iguales como datos de facturción.
          #El resultado de la búsqueda serían todas las facturas de los diferentes clientes con el RFC igual. (incluyendo el XAXX010101000 pero solo para las realizads a un solo cliente)
          @rfc = params[:rfc]
          datos_fiscales_cliente = DatosFiscalesCliente.where rfc: @rfc
          clientes_ids = []
          datos_fiscales_cliente.each do |dfc|
            clientes_ids << dfc.cliente_id
          end
          #Se le pasa un arreglo con los ids para obtener las facturas de todos los clientes con el RFC =
          @facturas = current_user.negocio.facturas.joins(:ventas).where(ventas: {tipo_factura: "fv"}, facturas: {cliente_id: clientes_ids}).uniq
          #cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
        elsif params[:rbtn] == "rbtn_nombreFiscal"
          #En el caso de la búsqueda por nombre fiscal... el resutado serán todas las facturas de un único cliente.
          datos_fiscales_cliente = DatosFiscalesCliente.find params[:cliente_id]
          @nombreFiscal = datos_fiscales_cliente.nombreFiscal
          cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
          @facturas = current_user.negocio.facturas.joins(:ventas).where(ventas: {tipo_factura: "fv"}, facturas: {cliente_id: cliente}).uniq
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
          @facturas = current_user.sucursal.facturas.joins(:ventas).where(ventas: {tipo_factura: "fv"}, facturas: {cliente_id: clientes_ids}).uniq
          #@facturas = current_user.sucursal.facturas.where(cliente_id: clientes_ids)
          #cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
        elsif params[:rbtn] == "rbtn_nombreFiscal"
          #En el caso de la búsqueda por nombre fiscal... el resutado serán todas las facturas de un único cliente.
          datos_fiscales_cliente = DatosFiscalesCliente.find params[:cliente_id]
          @nombreFiscal = datos_fiscales_cliente.nombreFiscal
          cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente

          @facturas = current_user.sucursal.facturas.joins(:ventas).where(ventas: {tipo_factura: "fv"}, facturas: {cliente_id: clientes_ids}).uniq
          #@facturas = current_user.sucursal.facturas.where(cliente_id: cliente)
        end

      end
      respond_to do |format|
        format.html { render 'index'}
      end
    end
  end

  def consulta_avanzada
    @consulta = true
    @avanzada = true
    @fechas=false
    @por_folio=false

    if request.post?
      @tipo_factura = params[:tipo_factura]

      @fechaInicial = DateTime.parse(params[:fecha_inicial_avanzado]).to_date
      @fechaFinal = DateTime.parse(params[:fecha_final_avanzado]).to_date

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
        #Se obtinen las facturas de ventas o globales dependiendo del parametro recibido del index
        @facturas = current_user.negocio.facturas.joins(:ventas).where(ventas: {tipo_factura: @tipo_factura}).uniq

        unless @suc.empty?
          #valida si se eligió un cliente específico para esta consulta
          if @rfc || @nombreFiscal#@cliente
            #Filtra por monto de la venta facurada.
            if operador_monto
              @monto_factura = params[:monto_factura]
              unless operador_monto == ".." #Cuando se trata de un rango
                #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where("montoVenta #{operador_monto} ?", @monto_factura)) if @monto_factura
                @facturas = @facturas.where("monto #{operador_monto} ?", @monto_factura) if @monto_factura
              else
                @monto_factura2 = params[:monto_factura2]
                #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where(montoVenta: @monto_factura..@monto_factura2)) if @monto_factura && @monto_factura2
                @facturas = @facturas.where(monto: @monto_factura..@monto_factura2) if @monto_factura && @monto_factura2
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
                @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, estado_factura: @estado_factura, sucursal: @sucursal)
              else
                @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, sucursal: @sucursal)
              end
            end
          # Si no se eligió cliente, entonces no filtra las ventas por el cliente al que se expidió la factura.
          else
            #Filtra por monto de la venta facurada.
            if operador_monto
              @monto_factura = params[:monto_factura]
              unless operador_monto == ".." #Cuando se trata de un rango
                #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where("montoVenta #{operador_monto} ?", @monto_factura)) if @monto_factura
                @facturas = @facturas.where("monto #{operador_monto} ?", @monto_factura) if @monto_factura
              else
                @monto_factura2 = params[:monto_factura2]
                #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where(montoVenta: @monto_factura..@monto_factura2)) if @monto_factura && @monto_factura2
                @facturas = @facturas.where(monto: @monto_factura..@monto_factura2) if @monto_factura && @monto_factura2
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
                @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura, sucursal: @sucursal)
              else
                @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, sucursal: @sucursal)
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
                @facturas = @facturas.where("monto #{operador_monto} ?", @monto_factura) if @monto_factura
              else
                @monto_factura2 = params[:monto_factura2]
                #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where(montoVenta: @monto_factura..@monto_factura2)) if @monto_factura && @monto_factura2
                @facturas = @facturas.where(monto: @monto_factura..@monto_factura2) if @monto_factura && @monto_factura2
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
                @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, estado_factura: @estado_factura)
              else
                @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids)
              end
            end
          # Si no se eligió cliente, entonces no filtra las ventas por el cliente
          else
            if operador_monto
              @monto_factura = params[:monto_factura]
              unless operador_monto == ".." #Cuando se trata de un rango
                #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where("montoVenta #{operador_monto} ?", @monto_factura)) if @monto_factura
                @facturas = @facturas.where("monto #{operador_monto} ?", @monto_factura) if @monto_factura
              else
                @monto_factura2 = params[:monto_factura2]
                #@facturas = current_user.negocio.facturas.where(venta_id: current_user.negocio.ventas.where(montoVenta: @monto_factura..@monto_factura2)) if @monto_factura && @monto_factura2
                @facturas = @facturas.where(facturas: {monto: @monto_factura..@monto_factura2}) if @monto_factura && @monto_factura2
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
                @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura)
              else
                @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal)
              end
            end
          end
        end
      #Si el usuario no es un administrador o subadministrador
      else
        @facturas = current_user.sucursal.facturas.joins(:ventas).where(ventas: {tipo_factura: @tipo_factura}).uniq
        #valida si se eligió un cliente específico para esta consulta
        if @rfc || @nombreFiscal#@cliente
          #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
          unless @estado_factura.eql?("Todas")
            @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, estado_factura: @estado_factura)
          else
            @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids)
          end #Termina unless @estado_factura.eql?("Todas")
        # Si no se eligió cliente, entonces no filtra las ventas por el cliente
        else
          #Si el estado_factura elegido es todas, entonces no filtra las ventas por el estado_factura
          unless @estado_factura.eql?("Todas")
            @facturas = @facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_factura: @estado_factura)
          else
            @facturas =@facturas.where(fecha_expedicion: @fechaInicial..@fechaFinal)
          end #Termina unless @estado_factura.eql?("Todas")
        end 
      end

      respond_to do |format|
        if @tipo_factura == "fv"
          format.html { render 'index'}
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
    if current_user.sucursal.facturas.joins(:ventas).where(ventas: {tipo_factura: "fg"}).last
      consecutivo = current_user.sucursal.facturas.joins(:ventas).where(ventas: {tipo_factura: "fg"}).last.consecutivo
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

      #fecha_expedicion_f = Time.now
      factura = CFDI::Comprobante.new({
        serie: serie,
        folio: consecutivo,
        #fecha: fecha_expedicion_f,
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
      #Se agrega el sello digital del comprobante, esto implica actulizar la fecha y calcular la cadena oriiginal
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
      fg_id = Factura.joins(:ventas).where(ventas: {tipo_factura: "fg"}).last ? Factura.joins(:ventas).where(ventas: {tipo_factura: "fg"}).last.id + 1 : 1
      archivo = File.open("public/#{fg_id}_fg.xml", "w")
      archivo.write (xml_timbox)
      archivo.close

      #Se forma la cadena original del timbre fiscal digital de manera manual por que e mugroso xslt del SAT no Jala.
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
      tipo_fuente = current_user.negocio.config_comprobantes.find_by(comprobante: "fg").tipo_fuente
      tam_fuente = current_user.negocio.config_comprobantes.find_by(comprobante: "fg").tam_fuente
      color_fondo = current_user.negocio.config_comprobantes.find_by(comprobante: "fg").color_fondo
      color_banda = current_user.negocio.config_comprobantes.find_by(comprobante: "fg").color_banda
      color_titulos = current_user.negocio.config_comprobantes.find_by(comprobante: "fg").color_titulos

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
      #Las facturas globales no tiene sentido enviarlas por email por que son a público en general.

      #8.- SE REGISTRA LA NUEVA FACTURA GLOBAL EN LA BASE DE DATOS
      #Se crea un objeto del modelo Factura y se le asignan a los atributos los valores correspondientes para posteriormente guardarlo como un registo en la BD.
      folio_fiscal_xml = xml_timbox.xpath('//@UUID')
      @factura = Factura.new(folio: folio_registroBD, fecha_expedicion: fecha_file, consecutivo: consecutivo, estado_factura:"Activa", cve_metodo_pagoSAT: 'PUE', monto: '%.2f' % (@ventas.map(&:montoVenta).reduce(:+)).round(2), folio_fiscal: folio_fiscal_xml, ruta_storage: ruta_storage)#, monto: @venta.montoVenta)
      
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
        @ventas.each do |vta| 
          vta.update(tipo_factura: "fg")
          @factura.ventas << vta
        end
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
    #Esta función sirve para optener la plantilla de email de los comprobantes, según sus estatus
    #Solo funciona para facturas de ventas y para el envío de los acuses de cancelación de las mismas.
    def plantilla_email (opc)
      require 'plantilla_email/plantilla_email.rb'
      #Las 4 opciones posibles son:
        #fv => factura de venta
        #ac_fv => acuse de cancelación de factura de venta (Las facturas globales quedan excluidas)
        #ac_nc => acuse de cancelación de nota de crédito
        #nc => nota de crédito
    
      mensaje = current_user.negocio.plantillas_emails.find_by(comprobante: opc).msg_email
      asunto = current_user.negocio.plantillas_emails.find_by(comprobante: opc).asunto_email

      cadena = PlantillaEmail::AsuntoMensaje.new
      if opc == "fv"
        cadena.nombCliente = @factura.cliente.nombre_completo 

        cadena.fechaFact = @factura.fecha_expedicion
        cadena.numFact = @factura.consecutivo
        cadena.folioFact = @factura.folio 
        cadena.totalFact = @factura.monto
        cadena.nombNegocio = @factura.negocio.nombre 
        cadena.nombSucursal = @factura.sucursal.nombre 
        cadena.emailContacto = @factura.sucursal.email 
        cadena.telContacto = @factura.sucursal.telefono 

        @mensaje = cadena.reemplazar_texto(mensaje)
        @asunto = cadena.reemplazar_texto(asunto)
      else
        #El cliente debe de ser el mismo
        cadena.nombCliente = @factura.cliente.nombre_completo 

        cadena.fechaCancelacion = @factura.factura_cancelada.fecha_cancelacion
        #cadena.folioAcuseCancelacion = @factura.factura_cancelada.folio

        cadena.fechaFact = @factura.fecha_expedicion
        cadena.numFact = @factura.consecutivo
        cadena.folioFact = @factura.folio 
        cadena.totalFact = @factura.monto

        cadena.nombNegocio = @factura.factura_cancelada.negocio.nombre
        cadena.nombSucursal = @factura.factura_cancelada.sucursal.nombre
        cadena.emailContacto = @factura.factura_cancelada.sucursal.email
        cadena.telContacto = @factura.factura_cancelada.sucursal.telefono

        @mensaje = cadena.reemplazar_texto(mensaje)
        @asunto = cadena.reemplazar_texto(asunto)
      end

    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def factura_params
      params.require(:factura).permit(:uso_cfdi_id)
      #params.require(:factura).permit(:folio, :fecha_expedicion, :estado_factura,:venta_id, :user_id, :negocio_id, :sucursal_id, :cliente_id,:forma_pago_id, :folio_fiscal, :consecutivo)
    end
end
