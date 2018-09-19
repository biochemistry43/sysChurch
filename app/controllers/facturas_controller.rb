class FacturasController < ApplicationController
  before_action :set_factura, only: [:show, :edit, :update, :destroy, :readpdf, :enviar_email,:enviar_email_post, :descargar_cfdis, :cancelaFacturaVenta, :cancelaFacturaVenta2]
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
      #el tipo_facura lo uso para discriminar las facturas de ventas entre las facturas globales
      if can? :create, Negocio
        
        @facturas = current_user.negocio.facturas.where(tipo_factura: params[:tipo_factura], created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
        #@facturas = current_user.negocio.facturas.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
      else
        #@facturas = current_user.sucursal.facturas.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
        @facturas = current_user.sucursal.facturas.where(tipo_factura: params[:tipo_factura], created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
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
        @facturas = current_user.negocio.facturas.where(tipo_factura: params[:tipo_factura], created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
        #@facturas = current_user.negocio.facturas.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
      else
        #@facturas = current_user.sucursal.facturas.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
        @facturas = current_user.sucursal.facturas.where(tipo_factura: params[:tipo_factura], created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
      end
    end
  end

  # GET /facturas/1
  # GET /facturas/1.json
  def show
    
      @nombreFiscal =  @factura.cliente.datos_fiscales_cliente ?  @factura.cliente.datos_fiscales_cliente.nombreFiscal : "Público general"
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
    #if request.post?
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
    #end
  end

  def facturarVenta

    if request.post?
      require 'cfdi'
      require 'timbrado'
      servicio = Timbox::Servicios.new

      if params[:commit] == "Cancelar"
        @venta=nil #Se borran los datos por si el usuario le da "atras" en el navegador.
        redirect_to facturas_index_path
      else
        @venta = Venta.find(params[:id]) if params.key?(:id)
#========================================================================================================================
        #1.-CERTIFICADOS,  LLAVES Y CLAVES
        if File::exists?( 'public/certificado.cer') && File::exists?( 'public/llave.pem')
          certificado = CFDI::Certificado.new 'public/certificado.cer'
          # Esta se convierte de un archivo .key con:
          # openssl pkcs8 -inform DER -in someKey.key -passin pass:somePassword -out key.pem
          path_llave = 'public/llave.pem'
          password_llave = "12345678a"
          #openssl pkcs8 -inform DER -in /home/daniel/Documentos/prueba/CSD03_AAA010101AAA.key -passin pass:12345678a -out /home/daniel/Documentos/prueba/CSD03_AAA010101AAA.pem
          llave = CFDI::Key.new path_llave, password_llave
#------------------------------------------------------------------------------------------------------------------------
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
            #Se agrega el sello digital del comprobante, esto implica actulizar la fecha y calcular la cadena original
            xml_certificado_sellado_nc_fg = llave.sella nota_credito

            #4.- TIMBRADO DEL XML CON TIMBOX POR MEDIO DE WEB SERVICE
            #Se obtiene el xml timbrado
            # Convertir la cadena del xml en base64
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
=begin
          #8.- SE ENVIAN LOS COMPROBANTES(pdf y xml timbrado) AL CLIENTE POR CORREO ELECTRÓNICO. :p
          #Se asignan los valores del texto variable de la configuración de las plantillas de email de las notas de crédito para las facturas globales
          require 'plantilla_email/plantilla_email.rb'        

          destinatario_contador = params[:destinatario_contador]
          mensaje = current_user.negocio.plantillas_emails.find_by(comprobante: "nc_fg").msg_email
          asunto = current_user.negocio.plantillas_emails.find_by(comprobante: "nc_fg").asunto_email

          cadena = PlantillaEmail::AsuntoMensaje.new
          cadena.nombCliente = @factura.cliente.nombre_completo #if mensaje.include? "{{Nombre del cliente}}"
            
          cadena.fecha = fecha_file
          cadena.numero = consecutivo_nc_fg
          cadena.folio = serie_nc_fg + consecutivo_nc_fg.to_s
          #cadena.total = @cantidad_devuelta.to_f * @itemVenta.precio_venta

          cadena.nombNegocio = current_user.negocio.nombre 
          cadena.nombSucursal = current_user.sucursal.nombre
          cadena.emailContacto = current_user.sucursal.email
          cadena.telContacto = current_user.sucursal.telefono
          #Chance su página web posteriormente dspues, un poco mas tarde jaja

          @mensaje = cadena.reemplazar_texto(mensaje)
          @asunto = cadena.reemplazar_texto(asunto)
            
          comprobantes = {pdf_nc:"public/#{nc_id}_nc_fg.pdf", xml_nc:"public/#{nc_id}_nc_fg.xml"}

          FacturasEmail.factura_email(destinatario_contador, @mensaje, @asunto, comprobantes).deliver_now
=end
          end
          end #Hasta quí se acaba la generación de la nota de credito 
  #========================================================================================================================
          #2.- LLENADO DEL XML DIRECTAMENTE DE LA BASE DE DATOS
          #Para obtener el numero consecutivo a partir de la ultima factura o de lo contrario asignarle por primera vez un número
          consecutivo = 0
          if current_user.sucursal.facturas.where(tipo_factura: "fv").last
            consecutivo = current_user.sucursal.facturas.where(tipo_factura: "fv").last.consecutivo
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
          formaPago: forma_pago_f.cve_forma_pagoSAT,#CATALOGO Es de tipo string
          #condicionesDePago: 'Sera marcada como pagada en cuanto el receptor haya cubierto el pago.',
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
        #p xml_certificado_sellado

#========================================================================================================================
        #4.- ALTERNATIVA DE CONEXIÓN PARA CONSUMIR EL WEBSERVICE DE TIMBRADO CON TIMBOX
        #Se convierte el xml en base64 para mandarselo a TIMBOX
        xml_base64 = Base64.strict_encode64(xml_certificado_sellado)
        # Parametros para conexion al Webservice (URL de Pruebas)
        wsdl_url = "https://staging.ws.timbox.com.mx/timbrado_cfdi33/wsdl"
        usuario = "AAA010101000"
        contrasena = "h6584D56fVdBbSmmnB"
        #Se obtiene el xml timbrado
        xml_timbox= servicio.timbrar_xml(usuario, contrasena, xml_base64, wsdl_url)
        #Guardo el xml recien timbradito de timbox, calientito
        uuid_cfdi = xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@UUID')
        archivo = File.open("public/#{uuid_cfdi}.xml", "w")
        archivo.write (xml_timbox)
        archivo.close

        #Se forma la cadena original del timbre fiscal digital de manera manual por que e mugroso xslt del SAT no Jala.
        
        factura.complemento=CFDI::Complemento.new(
          {
            Version: xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@Version'),
            uuid: uuid_cfdi,
            FechaTimbrado:xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@FechaTimbrado'),
            RfcProvCertif:xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@RfcProvCertif'),
            SelloCFD:xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@SelloCFD'),
            NoCertificadoSAT:xml_timbox.xpath('/cfdi:Comprobante/cfdi:Complemento//@NoCertificadoSAT')
          }
        )
        #se hace una copia del xml para modificarlo agregandole información extra para la representación impresa.
        xml_copia = xml_timbox
 
#========================================================================================================================
        #7.- SE REGISTRA LA NUEVA FACTURA EN LA BASE DE DATOS
        #Se crea un objeto del modelo Factura y se le asignan a los atributos los valores correspondientes para posteriormente guardarlo como un registo en la BD.
        fecha_registroBD = DateTime.parse(xml_timbox.xpath('//@Fecha').to_s) 
        fecha_expedicion_f = fecha_registroBD.strftime("%Y-%m-%d")


        #Se realizan las consultas para formar los directorios en cloud y se guarda la ruta en la BD para poder acceder a los archivos posteriormente.
        dir_negocio = current_user.negocio.nombre
        dir_cliente = params[:nombre_fiscal_receptor_vf]
        #Se separan obtiene el día, mes y año de la fecha de emisión del comprobante
        dir_dia = fecha_registroBD.strftime("%d")
        dir_mes = fecha_registroBD.strftime("%m")
        dir_anno = fecha_registroBD.strftime("%Y")
        #Nomenclatura para el nombre del archivo: consecutivo + fecha + extenció
        dir_sucursal = current_user.sucursal.nombre
        ruta_storage = "#{dir_negocio}/#{dir_sucursal}/#{dir_cliente}/#{dir_anno}/#{dir_mes}/#{dir_dia}/"

        @factura = Factura.new(folio: folio_registroBD, fecha_expedicion: fecha_expedicion_f, consecutivo: consecutivo, estado_factura:"Activa", cve_metodo_pagoSAT: params[:metodo_pago], monto: '%.2f' % @venta.montoVenta.round(2), folio_fiscal: uuid_cfdi, ruta_storage: ruta_storage, tipo_factura: "fv")#, monto: @venta.montoVenta)
        
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
        plantilla_impresion = current_user.negocio.config_comprobantes.find_by(comprobante: "fv")
        tipo_fuente = plantilla_impresion.tipo_fuente
        tam_fuente = plantilla_impresion.tam_fuente
        color_fondo = plantilla_impresion.color_fondo
        color_banda = plantilla_impresion.color_banda
        color_titulos = plantilla_impresion.color_titulos

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
        template = Nokogiri::XSLT(File.read('/home/daniel/Vídeos/sysChurch/lib/Plantilla de facturas de ventas.xsl'))
        html_document = template.transform(xml_rep_impresa)
        #File.open('/home/daniel/Documentos/timbox-ruby/CFDImpreso.html', 'w').write(html_document)
        pdf = WickedPdf.new.pdf_from_string(html_document)
        #Se guarda el pdf 
        nombre_pdf = "#{uuid_cfdi}.pdf"
        save_path = Rails.root.join('public',nombre_pdf)
        File.open(save_path, 'wb') do |file|
            file << pdf
        end

  #========================================================================================================================
        #6.- SE ALMACENAN EN GOOGLE CLOUD STORAGE
        gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
        storage=gcloud.storage
        bucket = storage.bucket "cfdis"

        #Los comprobantes de almacenan en google cloud
        #file = bucket.create_file StringIO.new(pdf), "#{ruta_storage}_RepresentaciónImpresa.pdf"
        #file = bucket.create_file StringIO.new(xml_timbox.to_s), "#{ruta_storage}_CFDI.xml"
        file = bucket.create_file "public/#{uuid_cfdi}.pdf", "#{ruta_storage}#{uuid_cfdi}.pdf"
        file = bucket.create_file "public/#{uuid_cfdi}.xml", "#{ruta_storage}#{uuid_cfdi}.xml"

  #=======================================================================================================================
          #8.- SE ENVIAN LOS COMPROBANTES(pdf y xml timbrado) AL CLIENTE POR CORREO ELECTRÓNICO. :p
          destinatario_final = params[:destinatario]
          #Se asignan los valores del texto variable de la configuración de las plantillas de email.
          plantilla_email("fv")
          comprobantes = {pdf:"public/#{uuid_cfdi}.pdf", xml: "public/#{uuid_cfdi}.xml"}
          #FacturasEmail.factura_email(@destinatario, @mensaje, @tema).deliver_now
          FacturasEmail.factura_email(destinatario_final, @mensaje, @asunto, comprobantes).deliver_now

  #=======================================================================================================================
          #9.- SE MUESTRA EL PDF, SE REDIRIGE AL INDEX O ALGUNA EXCEPCIÓN
          if "yes" == params[:imprimir]
            send_file( File.open( "public/#{uuid_cfdi}.pdf"), :disposition => "inline", :type => "application/pdf")
          else
            respond_to do |format|
              format.html { redirect_to facturas_index_path, notice: 'La factura fue registrada existoxamente!' }
            end
          end
        else
          redirect_to :back, notice: "Los Certificados de Sello Digital no se encontraron, por favor intente facturar nuevamente."
        end
      end #fin de else que permiten facturar
    end #Fin del méodo post
  end #Fin del controlador

  #Para cancelar una factura, aunque también se puede cancelar al mismo tiempo la venta asociada.
  def cancelaFacturaVenta
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















  def readpdf

    gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
    storage=gcloud.storage
    bucket = storage.bucket "cfdis"
    ruta_storage = @factura.ruta_storage
    uuid = @factura.folio_fiscal
    #Se descarga el pdf de la nube y se guarda en el disco

    file_download_storage = bucket.file "#{ruta_storage}#{uuid}.pdf"
    file_download_storage.download "public/#{uuid}.pdf"


    #Se comprueba que el archivo exista en la carpeta publica de la aplicación
    if File::exists?( "public/#{uuid}.pdf")
      file=File.open( "public/#{uuid}.pdf")
      send_file( file, :disposition => "inline", :type => "application/pdf")
    else
      respond_to do |format|
        format.html { redirect_to action: "index" }
        flash[:notice] = "No se pudo mostrar la factura, vuelva a intentarlo por favor!"
        #format.html { redirect_to facturas_index_path, notice: 'No se encontró la factura, vuelva a intentarlo!' }
      end
    end
  end

  def enviar_email_post
    #Se optienen los datos que se ingresen o en su caso los datos de la configuracion del mensaje de los correos.
    if request.post?

      destinatario_final = params[:destinatario]

      ruta_storage = @factura.ruta_storage
      uuid = @factura.folio_fiscal
      #Se crea un objeto de cloud para poder descargar los comprobantes
      gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
      storage=gcloud.storage
      bucket = storage.bucket "cfdis"

      comprobantes = {}
      tipo_factura = @factura.tipo_factura
      if params[:pdf] == "yes"
        comprobantes[:pdf] = "public/#{uuid}.pdf"

        file_download_storage_xml = bucket.file "#{ruta_storage}#{uuid}.pdf"
        file_download_storage_xml.download "public/#{uuid}.pdf"

      end
      if params[:xml] == "yes"
        comprobantes[:xml] = "public/#{uuid}.xml"
        file_download_storage_xml = bucket.file "#{ruta_storage}#{uuid}.xml"
        file_download_storage_xml.download "public/#{uuid}.xml"
      end
     
      #Solo es posible si la factura de venta está cancelada
      if params[:xml_Ac] == "yes"
        comprobantes[:xml_Ac] = "public/#{uuid}(cancelado).xml"
        file_download_storage_xml = bucket.file "#{ruta_storage}#{uuid}(cancelado).xml"
        file_download_storage_xml.download "public/#{uuid}(cancelado).xml"
      end

      if @factura.tipo_factura == "fv"
        if @factura.estado_factura == "Activa"
          plantilla_email("fv")
        elsif @factura.estado_factura == "Cancelada"
          plantilla_email("ac_fv")
        end
      elsif @factura.tipo_factura == "fg"
        if @factura.estado_factura == "Activa"
          plantilla_email("fg")
        elsif @factura.estado_factura == "Cancelada"
          plantilla_email("ac_fg")
        end
      end

      FacturasEmail.factura_email(destinatario_final, @mensaje, @asunto, comprobantes).deliver_now

      #respond_to do |format|
        #format.html { redirect_to action: "index"}
        #flash[:notice] = "Los comprobantes se han enviado a #{destinatario_final}!"
        #format.html { redirect_to facturas_index_path, notice: 'No se encontró la factura, vuelva a intentarlo!' }
      #end
      
      redirect_to :back, notice: "Los comprobantes se han enviado a #{destinatario_final}!"


    end
  end

  def enviar_email 
    if @factura.tipo_factura == "fv"
      if @factura.estado_factura == "Activa"
        plantilla_email("fv")
      elsif @factura.estado_factura == "Cancelada"
        plantilla_email("ac_fv")
      end
    elsif @factura.tipo_factura == "fg"
      if @factura.estado_factura == "Activa"
        plantilla_email("fg")
      elsif @factura.estado_factura == "Cancelada"
        plantilla_email("ac_fg")
      end
    end
  end

  def descargar_cfdis

    require 'timbrado'
    gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
    storage=gcloud.storage
    uuid = @factura.folio_fiscal
    bucket = storage.bucket "cfdis"

    #Si cambio de parecer, quitaré las condiciones del estado de facturas
    if @factura.estado_factura == "Activa"
      ruta_storage = @factura.ruta_storage
      file_download_storage_xml = bucket.file "#{ruta_storage}#{uuid}.xml"
      file_download_storage_xml.download "public/#{uuid}.xml"

      if File.exist?("public/#{uuid}.xml")
        xml = File.open("public/#{uuid}.xml")
        send_file(
          xml,
          filename: "CFDI.xml",
          type: "application/xml"
        )
      else
        respond_to do |format|
          format.html { redirect_to action: "index" }
          flash[:notice] = "No se pudo descargar el CFDI, por favor vuelva a intentar nuevamente"
          #format.html { redirect_to facturas_index_path, notice: 'No se encontró la factura, vuelva a intentarlo!' }
        end
      end
    elsif @factura.estado_factura == "Cancelada"
      acuse_cancelacion = AcuseCancelacion.find(@factura.ref_acuse_cancelacion)
      file_download_storage_xml = bucket.file "#{ruta_storage}#{uuid}(cancelado).xml"
      file_download_storage_xml.download "public/#{uuid}(cancelado).xml"

      if File.exist?("public/#{uuid}(cancelado).xml")
        xml = File.open("public/#{uuid}(cancelado).xml")
        send_file(
          xml,
          filename: "Acuse de cancelación.xml",
          type: "application/xml"
        )
      else
        respond_to do |format|
          format.html { redirect_to action: "index" }
          flash[:notice] = "No se pudo descargar el acuse de cancelación de la factura, por favor vuelva a intentar nuevamente"
          #format.html { redirect_to facturas_index_path, notice: 'No se encontró la factura, vuelva a intentarlo!' }
        end
      end
=begin      
      

      username = "AAA010101000" # Usuario del webservice    Sí
      password = "h6584D56fVdBbSmmnB" # Contraseña del webservice   Sí
      #Parametros de búsqueda opcionales
      uuid = @factura.folio_fiscal
      uuids =  %Q^<uuids xsi:type="urn:uuid">
                  <!--Zero or more repetitions:-->
                    <uuid>#{uuid}</uuid>
                  </uuids>^
      #<fecha_timbrado_inicio xsi:type="xsd:string">#{fecha_timbrado_inicio}</fecha_timbrado_inicio>
      #<fecha_timbrado_fin xsi:type="xsd:string">#{fecha_timbrado_fin}</fecha_timbrado_fin>
      hash_acuse_timbox = buscar_acuses_recepcion(username, password, uuids)
      #En plural porq e puede regresar hasta 500 acuses, pero jaja da igual esta acción solo es para obtener un solo acuse.
      #Si hubo un error con alguno de los parámetros o en el servicio de buscar acuses, se le notificará por medio de un mensaje de error, de lo contrario recibirá la estructura “buscar_acuse_recepcion_result” compuesta de lo siguiente:         
      if hash_acuse_timbox[:buscar_acuse_recepcion_response][:buscar_acuse_recepcion_result]
        #Parámetros de la respuesta
          #acuses El acuse de recepción que regresa el SAT.
          #uuids_erroneos  Información de los uuid’s que no son válidos o no cumplen con la expresión regular.
          #uuids_no_encontrados  Información de los uuid’s que no fueron encontrados en BD.
        acuses = hash_acuse_timbox[:buscar_acuse_recepcion_response][:buscar_acuse_recepcion_result][:acuses]
        uuids_erroneos = hash_acuse_timbox[:buscar_acuse_recepcion_response][:buscar_acuse_recepcion_result][:uuids_erroneos]
        uuids_no_encontrados = hash_acuse_timbox[:buscar_acuse_recepcion_response][:buscar_acuse_recepcion_result][:uuids_no_encontrados] 
        #El contenido del nodo <acuses> es una cadena q incluye elementos hijos y que al convertirla conserva las etiquetas xml:
        #<acuse> </acuse>
        acuse = acuses.slice!(7..-9)
        acuse = Nokogiri::XML(acuse)

        archivo = File.open("public/#{uuid}.xml", "w")
        archivo.write (acuse)
        archivo.close
 
        else
          #Desirle lo siento queridisimo usuriatooo jaja
        end
      end
=end         
    end
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
        @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal)
      else
        @facturas = current_user.sucursal.facturas.where(tipo_factura: @tipo_factura, fecha_expedicion: @fechaInicial..@fechaFinal)
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
        @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura, folio: @folio_fact)
      else
        @facturas = current_user.sucursal.facturas.where(tipo_factura: @tipo_factura, folio: @folio_fact)
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
          @facturas = current_user.negocio.facturas.where(tipo_factura: "fv", cliente_id: clientes_ids)
          #cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
        elsif params[:rbtn] == "rbtn_nombreFiscal"
          #En el caso de la búsqueda por nombre fiscal... el resutado serán todas las facturas de un único cliente.
          datos_fiscales_cliente = DatosFiscalesCliente.find params[:cliente_id]
          @nombreFiscal = datos_fiscales_cliente.nombreFiscal
          cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
          @facturas = current_user.negocio.facturas.where(tipo_factura: "fv", cliente_id: cliente)
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
          @facturas = current_user.sucursal.facturas.where(tipo_factura: "fv", cliente_id: clientes_ids)
          #@facturas = current_user.sucursal.facturas.where(cliente_id: clientes_ids)
          #cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
        elsif params[:rbtn] == "rbtn_nombreFiscal"
          #En el caso de la búsqueda por nombre fiscal... el resutado serán todas las facturas de un único cliente.
          datos_fiscales_cliente = DatosFiscalesCliente.find params[:cliente_id]
          @nombreFiscal = datos_fiscales_cliente.nombreFiscal
          cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente

          @facturas = current_user.sucursal.facturas.where(tipo_factura: "fv", cliente_id: clientes_ids)
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
        @facturas = current_user.negocio.facturas.where(tipo_factura: @tipo_factura)

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
        @facturas = current_user.sucursal.facturas.where(tipo_factura: @tipo_factura)
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

      #fecha_expedicion_f = Time.now
      factura = CFDI::Comprobante.new({
        serie: serie,
        folio: consecutivo,
        #fecha: fecha_expedicion_f,
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
      fg_id = Factura.where(tipo_factura: "fg").last ? Factura.where(tipo_factura: "fg").last.id + 1 : 1
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

      if opc == "fv" || opc == "fg"
        cadena.nombCliente = @factura.cliente.nombre_completo 

        cadena.fecha = @factura.fecha_expedicion
        cadena.numero = @factura.consecutivo
        cadena.folio= @factura.folio 
        cadena.total= @factura.monto
        cadena.nombNegocio = @factura.negocio.nombre 
        cadena.nombSucursal = @factura.sucursal.nombre 
        cadena.emailContacto = @factura.sucursal.email 
        cadena.telContacto = @factura.sucursal.telefono 

        @mensaje = cadena.reemplazar_texto(mensaje)
        @asunto = cadena.reemplazar_texto(asunto)

      #Solo por que estos dos tipos de comprobantes estan dentro de la misma tabla de la BD
      elsif opc == "ac_fv" || opc == "ac_fg"
        #El cliente debe de ser el mismo
        cadena.nombCliente = @factura.cliente.nombre_completo 

        #cadena.fecha = fecha_cancelacion 
        #cadena.numero = @factura.consecutivo
        #cadena.folio = folio
        #cadena.total = fecha_cancelacion

        cadena.nombNegocio = current_user.negocio.nombre
        cadena.nombSucursal = current_user.sucursal.nombre
        cadena.emailContacto = current_user.sucursal.email
        cadena.telContacto = current_user.sucursal.telefono

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
