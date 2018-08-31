module CFDI
  # Crea un CFDI::Comprobante desde un string XML
  # @ param  data [String, IO] El XML a parsear, según acepte Nokogiri
  #
  # @ return [CFDI::Comprobante] El comprobante parseado
  #Va a ser necesario agregar las direcciones fiscales del emisor y resceptor despues de crear el objeto del CFDI, porque el xml(orignal sin alteraciones) q se pasará como parametro no contine esos datos por la nueva versión. 
  def self.from_xml(string_xml)
    xml = Nokogiri::XML(string_xml);
    xml.remove_namespaces!
    cfdi = Comprobante.new
    
    #|Mismo nombre de atributo de la clase CFDI (métodos accesores) - Mismo nombre de atributos del XML según el ANEXO 20 del SAT (Se carácterizan por iniciar en mayúsculas) - Comentarios o pendientes|
    comprobante = xml.at_xpath('//Comprobante') # => si

    #====================NODO COMPROBANTE====================
    cfdi.version = comprobante.attr('Version') # => yes - si
    cfdi.serie = comprobante.attr('Serie') if comprobante.attr('Serie') # => yes - si
    cfdi.folio = comprobante.attr('Folio') if comprobante.attr('Folio')# => yes - si
    cfdi.fecha = Time.parse(comprobante.attr('Fecha')) # => yes - si 
    cfdi.sello = comprobante.attr('Sello') # => yes - si - CONDICIONADO? SOLO PARA FACTURAS EN BORRADOR(PENDIENTES DE TIMBRAR)
    cfdi.formaPago = comprobante.attr('FormaDePago') if comprobante.attr('FormaDePago')# => yes - si
    cfdi.noCertificado = comprobante.attr('NoCertificado') # => yes - si - CONDICIONADO? SOLO PARA FACTURAS EN BORRADOR(PENDIENTES DE TIMBRAR) 
    cfdi.certificado = comprobante.attr('Certificado') # => yes - si - CONDICIONADO? SOLO PARA FACTURAS EN BORRADOR(PENDIENTES DE TIMBRAR) 
    cfdi.condicionesDePago = comprobante.attr('CondicionesDePago') if comprobante.attr('CondicionesDePago') # => yes - si
    cfdi.subTotal = comprobante.attr('SubTotal') # => yes - si 
    cfdi.descuento = comprobante.attr('Descuento') if comprobante.attr('Descuento')# => yes - si
    cfdi.moneda = comprobante.attr('Moneda') #....................... => yes - si
    cfdi.tipoCambio = comprobante.attr('tipoCambio') if comprobante.attr('Moneda') != 'MXN'# => Es opcional o amm... solo requerido cuando la moneda sea diferente a 'MXN'
    cfdi.total = comprobante.attr('Total') # => yes - si
    cfdi.tipoDeComprobante = comprobante.attr('TipoDeComprobante') # => yes - si 
    cfdi.metodoDePago = comprobante.attr('MetodoDePago') if comprobante.attr('MetodoDePago')# => yes - si
    cfdi.lugarExpedicion = comprobante.attr('LugarExpedicion') # => yes - si
    #cfdi.confirmacion = comprobante.attr('Confirmacion') # => Es requerido cuando se agrega un cambio o total fuera del establecido. El codigo lo agrega el PAC.

    #====================NODO EMISOR====================
    emisor = xml.at_xpath('//Emisor') # => si
    emisor = {
      rfc: emisor.attr('Rfc'), # => yes - si
      nombre: emisor.attr('Nombre'), # => yes - si
      regimenFiscal: emisor.attr('RegimenFiscal') # => yes - si     
    }
    cfdi.emisor = emisor

    #====================NODO RECEPTOR====================
    receptor = xml.at_xpath('//Receptor') # => si
    receptor = {
      rfc: receptor.attr('Rfc'), # => yes - si
      nombre: receptor.attr('Nombre'), # => yes - si
      #residenciaFiscal: comprobante.attr('Descuento') # => Cuando se trate de un extranjero se deve de registrar la clave del pais de residencia
      #numRegIdTrib: receptor.attr('NumRegIdTrib') # => Requerido cuando se incluya el complemento de comercio exterior. Es el número de registro de identidad fiscal del receptor(extranjero)
      UsoCFDI: receptor.attr('UsoCFDI')
    }
    cfdi.receptor = receptor

    #====================NODO CONCEPTOS====================
    cfdi.conceptos = []
    #puts "conceptos: #{cfdi.conceptos.length}"
    xml.xpath('//Concepto').each_with_index do |concepto, index|
      hash = {
        ClaveProdServ: concepto.attr('ClaveProdServ'), # => yes - si
        NoIdentificacion: concepto.attr('NoIdentificacion'), # => yes - si
        #Cantidad: concepto.attr('Cantidad'), # => yes - si 
        ClaveUnidad: concepto.attr('ClaveUnidad'), # => yes - si
        Unidad: concepto.attr('Unidad'), # => yes - si
        Descripcion: concepto.attr('Descripcion'), # => yes - si
        #ValorUnitario: concepto.attr('ValorUnitario'), # => yes - si
        #Importe: concepto.attr('Importe'), # => yes - si
        #Descuento: concepto.attr('Descuento') # => yes - si       
      }
      
      #Guardo el index del concepto en un atributo del impuesto para poder relaionarlo... no se me ocurrió otra cosa.
      impuestos_conceptos = concepto.at_xpath('//Impuestos')

      #if impuestos_conceptos.empty? para los traslados y retenciones

      traslados_conceptos = impuestos_conceptos.xpath('//Traslados')
      unless traslados_conceptos.empty?
        #cfdi.impuestos.totalImpuestosTrasladados = impuestos_node.attr('TotalImpuestosTrasladados') #... => Modifiqué la gema para que el total de impuestos se calcule.
        traslados = []
        traslado_concepto = traslados_conceptos.xpath('//Traslado')
        traslado = Impuesto::Traslado.new
        #traslado.base =  traslado_concepto.attr('Base') # => yes -  si - No solo lo convierto a flotante, sino q conservo los ceros no significativos truncando y sin redondear por  luego por 0.000001 se pone chocosito
        traslado.tax = traslado_concepto.attr('Impuesto') # => yes - si
        traslado.type_factor = traslado_concepto.attr('TipoFactor') # => yes - si
        #traslado.rate = traslado_concepto.attr('TasaOCuota') # => yes - si
        #traslado.import = traslado_concepto.attr('Importe')  # => yes - si
        traslado.concepto_id = index # => Lo uso solo como referencia 
        traslados << traslado
        cfdi.impuestos.traslados = traslados
      end
      #Ey ejele el producto o servicio también puede tener un nodo retenciones 
      cfdi.conceptos << Concepto.new(hash)
    end

    #====================NODO IMPUESTOS====================
    #Llega la hora de hacer un resumen de todos los impuestos, resumen para los traslados y también para las retenciones
    impuestos_resumen = xml.at_xpath('//Impuestos')
    #cfdi.impuestos.totalImpuestosTrasladados = impuestos_resumen.attr('TotalImpuestosTrasladados') #... => Modifiqué la gema para que el total de impuestos se calcule, pero ahora q lo veo...
    #cfdi.impuestos.totalImpuestosRetenidos = impuestos_resumen.attr('TotalImpuestosRetenidos')
    traslados_resumen = impuestos_resumen.xpath('//Traslados')
    unless traslados_resumen.empty?
      traslados = []

      traslados_resumen.xpath('//Traslado').each do |traslado_resumen|
        traslado = Impuesto::Traslado.new
        traslado.tax = traslado_resumen.attr('Impuesto') 
        #traslado.type_factor = traslado_resumen.attr('TipoFactor')
        #traslado.rate = traslado_resumen.attr('TasaOCuota')
        #traslado.import = traslado_resumen.attr('Importe')
        traslados << traslado
      end
      cfdi.impuestos.traslados = traslados
    end

    #Las retenciones no por ahora jaja suficiente tengo con los traslados
=begin
    retenciones_node = impuestos_node.xpath('//Retenciones')
    unless retenciones_node.empty?
      cfdi.impuestos.totalImpuestosRetenidos = impuestos_node.attr('totalImpuestosRetenidos')
      retenciones = []
      retenciones_node.xpath('//Retencion').each do |retencion_node|
        retencion = Impuestos::Retencion.new
        retencion.impuesto = retencion_node.attr('impuesto') if retencion_node.attr('impuesto')
        retencion.tasa = retencion_node.attr('tasa').to_f if retencion_node.attr('tasa')
        retencion.importe = retencion_node.attr('importe').to_f if retencion_node.attr('importe')
        retenciones << retencion
      end
      cfdi.impuestos.retenciones = retenciones
    end
=end

    #====================NODO COMPLEMENTO====================
    #Si el xml ya cuenta con el timbre q le asigna el PAC entoonces tal vez lo unico que necesiten generar una representtaciones impresas. eso sería geniial
    #Para el fin que lo quiero se deberá de actualizar el sello fecha y bla bla... pero para los comprobantes de captura manual si q será de gran utilidad.
    timbre = xml.at_xpath('//TimbreFiscalDigital')
    if timbre
      cfdi.complemento = {
        Version: timbre.attr('Version'), #........................... => yes - si
        uuid: timbre.attr('UUID'), #................................. => yes - si
        FechaTimbrado: timbre.attr('FechaTimbrado'), #............... => yes - si
        RfcProvCertif: timbre.attr('RfcProvCertif'), #............... => yes - si 
        SelloCFD: timbre.attr('SelloCFD'), #......................... => yes - si
        NoCertificadoSAT: timbre.attr('NoCertificadoSAT'), #......... => yes - si
        #SelloSAT: timbre.attr('SelloSAT') #.......................... => yes - si
      }
    end

    cfdi
    #Lo que resta es agregarle la información extra(dirección fiscal de la matriz, sucursal, receptor y sha la la sha la la)
  end
end
