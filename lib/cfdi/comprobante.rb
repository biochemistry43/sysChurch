module CFDI
  class Comprobante # La clase principal para crear Comprobantes
    #Los datos del comprobante en el orden correcto.
    @@datosCadena =[:version,:serie,:folio, :fecha, :FormaPago, :noCertificado,:condicionesDePago, :subTotal, :Descuento, :moneda,:total, :tipoDeComprobante, :metodoDePago, :lugarExpedicion]
    @@data = @@datosCadena+[:emisor, :receptor, :conceptos, :sello, :certificado,:complemento, :uuidsrelacionados, :impuestos, :cfdisrelacionados]

    attr_accessor(*@@data) #sirve para generar metodos de acceso get y set de forma rapida.
    @addenda = nil
    @@options = {
      tasa: 0.16,
      defaults: {
        version: '3.3',
        moneda: 'MXN',
        subTotal: 0.00,
        #TipoCambio: 1,
        conceptos: [],
        uuidsrelacionados: [],
        impuestos: Impuesto.new,
        #cfdisrelacionados: [],
        #relacionados: CfdiRelacionado.new,
        tipoDeComprobante: 'I', #CATALOGO
        Descuento: 0.00
        #total:0.00
      }
    }

    # Configurar las opciones default de los comprobantes
    #
    # == Parameters:
    # options::
    #  Las opciones del comprobante: tasa (de impuestos), defaults: un Hash con la moneda (pesos), version (3.2), TipoCambio (1), y tipoDeComprobante (ingreso)
    #
    # @return [Hash]
    #
    def self.configure options
      @@options = Comprobante.rmerge @@options, options
      @@options
    end

    # Crear un comprobante nuevo
    # @return {CFDI::Comprobante}
    def initialize data={}, options={}
      #hack porque dup se caga con instance variables
      opts = Marshal::load(Marshal.dump(@@options))
      data = opts[:defaults].merge data
      @opciones = opts.merge options
      data.each do |k,v|
        method = "#{k}="
        next if !self.respond_to?(method)
        self.send method, v
      end
      #@impuestos ||= Impuestos.new
    end

    def addenda= addenda
      addenda = Addenda.new addenda unless addenda.is_a? Addenda
      @addenda = addenda
    end

    def serie=(serie)
      @serie=serie.squish
    end
    def folio=(folio)
      @folio=folio
    end

    #DESCUENTO COMERCIAL por cada concepto
    #def Descuento
    #  desc=0.00
    #  @conceptos.each do |d|
    #    desc += d.Descuento
    #  end
    #  @Descuento=desc
    #end
    #DESCUENTO RAPPEL
    #def Descuento= (des)
    #  @Descuento=des.to_f
    #end
    #DESCUENTO POR PAGO PUNTUAL
    #...
    def subTotal  # Regresa el subtotal de este comprobante, tomando el importe de cada concepto
      ret = 0
      @conceptos.each do |c|
        ret += c.Importe
      end
      ret # @return [Float] El subtotal del comprobante
    end

    # @return [Float] El subtotal multiplicado por la tasa


    #Sería mejor calcular estos datos antes y no aquí para no tener diferencias en la base de datos o hacer el mismo calculo dos veces.
    #def total
      #iva = 0.0
      #iva = (self.subTotal*@opciones[:tasa]) if @impuestos.count > 0
      #total_trans = format('%.2f', @impuestos.total_traslados if) @impuestos.count_impuestos > 0
      #self.subTotal + total_trans  #El orden es: subtotal - descuento + impuestos traslados -retenciones

    #end

    #Expresa el total en letras de forma estatica se usa la moneda nacional.
    def total_to_words
      decimal = format('%.2f', @total).split('.')
      "( #{@total.to_words.upcase} PESOS #{decimal[1]}/100 M.N. )"
    end

=begin
    def = value
      @impuestos = case @version
      when '3.2'
          return value if value.is_a? Impuestos
          raise 'v3.2 CFDI impuestos must be an array of hashes' unless value.is_a? Array

          traslados = value.map {|i|
            raise 'v3.2 CFDI impuestos must be an array of hashes' unless i.is_a? Hash

            tasa = i[:tasa] || @opciones[:tasa]

            {
              tasa: tasa,
              impuesto: i[:impuesto] || 'IVA',
              importe: tasa * self.subTotal
            }
          }

          Impuestos.new({ traslados: traslados })
        when '3.3' then value.is_a?(Impuestos) ? value : Impuestos.new(value)
      end
    end
=end
    # Asigna un emisor de tipo {CFDI::Entidad}
    # @param  emisor [Hash, CFDI::Entidad] Los datos de un emisor
    #
    # @return [CFDI::Entidad] Una entidad
    #Retorna un objeto de la clase Cfdirelacionado para poder acceder
    def uuidsrelacionados= data #Novato novato tenia que ser un método get, no método set!
      if data.is_a? Array #En caso de que sea un arreglo
        data.map do |ff|
          ff = Cfdirelacionado.new(ff) unless ff.is_a? Cfdirelacionado
          @uuidsrelacionados << ff
        end
      elsif data.is_a? Hash #O en el caso de quehtml_document sea un hash
        @uuidsrelacionados << Cfdirelacionado.new(data)
      elsif data.is_a? Cfdirelacionado
        @uuidsrelacionados << data
      end
      @uuidsrelacionados=data
      data
    end

    #Para indicar el tipo de RElación: Nota de Crédito(Factura de egreso)... bla bla bla
    def cfdisrelacionados= cfdisrelacionado
      cfdisrelacionado = CfdiRelacionados.new cfdisrelacionado unless cfdisrelacionado.is_a? CfdiRelacionados
      @cfdisrelacionados = cfdisrelacionado
      @cfdisrelacionados
    end
=begin
    def cfdisrelacionados= cfdisrelacionados
      if cfdisrelacionados.is_a? Array
        cfdisrelacionados.map! do |cfdi_r|
        cfdi_r = Cfdirelacionado.new cfdi_r unless cfdi_r.is_a? Cfdirelacionado
        end
      elsif cfdisrelacionados.is_a? Hash
        cfdisrelacionados << Cfdirelacionado.new(cfdi_r)
      elsif cfdisrelacionados.is_a?
        cfdisrelacionados << cfdisrelacionados
      end
      @cfdisrelacionados = cfdisrelacionados
      cfdisrelacionados
    end
=end
    def emisor= emisor
      emisor = Emisor.new emisor unless emisor.is_a? Emisor
      @emisor = emisor;
    end

    # Asigna un receptor
    # @param  receptor [Hash, CFDI::Entidad] Los datos de un receptor
    #
    # @return [CFDI::Entidad] Una entidad
    def receptor= receptor
      receptor = Rceptor.new receptor unless receptor.is_a? Receptor
      @receptor = receptor;
      #receptor
    end

    # Agrega uno o varios conceptos
    # @param  conceptos [Array, Hash, CFDI::Concepto] Uno o varios conceptos
    # En caso de darle un Hash o un {CFDI::Concepto}, agrega este a los conceptos, de otro modo, sobreescribe los conceptos pre-existentes
    # @return [Array] Los conceptos de este comprobante
    def conceptos= conceptos
      if conceptos.is_a? Array
        conceptos.map! do |concepto|
          concepto = Concepto.new concepto unless concepto.is_a? Concepto
        end
      elsif conceptos.is_a? Hash
        conceptos << Concepto.new(concepto)
      elsif conceptos.is_a? Concepto
        conceptos << conceptos
      end

      @conceptos = conceptos
      conceptos
    end



    # Asigna un complemento al comprobante
    # @param  complemento [Hash, CFDI::Complemento] El complemento a agregar
    # @return [CFDI::Complemento]
    def complemento= complemento
      complemento = Complemento.new complemento unless complemento.is_a? Complemento
      @complemento = complemento
      complemento
    end


    # Asigna una fecha al comprobante
    # @param  fecha [Time, String] La fecha y hora (YYYY-MM-DDTHH:mm:SS) de la emisión
    # @return [String] la fecha en formato '%FT%R:%S'
    def fecha= fecha
      fecha = fecha.strftime('%FT%R:%S') unless fecha.is_a? String
      @fecha = fecha
    end

    # El comprobante como XML
    # @return [String] El comprobante namespaceado en versión 3.3

    def comprobante_to_xml
      ns = {
        'xmlns:cfdi' => "http://www.sat.gob.mx/cfd/3",
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xsi:schemaLocation' => "http://www.sat.gob.mx/cfd/3 http://www.sat.gob.mx/sitio_internet/cfd/3/cfdv#{@version.gsub(/\D/, '')}.xsd",
        Version: @version,
        Serie: @serie,
        Folio: @folio,
        Fecha: @fecha,
        FormaPago: @FormaPago,
        CondicionesDePago: @condicionesDePago,
        SubTotal: sprintf('%.2f', self.subTotal),
        Moneda: @moneda,
        Total: sprintf('%.2f', @total),
        #Total: sprintf('%.2f', self.total),
        TipoDeComprobante: @tipoDeComprobante,
        MetodoPago: @metodoDePago,

        LugarExpedicion: @lugarExpedicion,
      }
      #ns[:serie] = @serie if @serie
      #ns[:TipoCambio] = @TipoCambio if @TipoCambio
      #ns[:NumCtaPago] = @NumCtaPago if @NumCtaPago && @NumCtaPago!=''

      if (@addenda)
        # Si tenemos addenda, entonces creamos el campo "xmlns:ElNombre" y agregamos sus definiciones al SchemaLocation
        ns["xmlns:#{@addenda.nombre}"] = @addenda.namespace
        ns['xsi:schemaLocation'] += ' '+[@addenda.namespace, @addenda.xsd].join(' ')
      end

      if @noCertificado
        ns[:NoCertificado] = @noCertificado
        ns[:Certificado] = @certificado
      end

      #if @sello
      #  ns[:Sello] = @sello
      #end

      #VAMO A HACER TRAMPITA
      #if @sello
        ns[:Sello] = ""
      #end

      @builder = Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
        xml.Comprobante(ns) do
          ins = xml.doc.root.add_namespace_definition('cfdi', 'http://www.sat.gob.mx/cfd/3')
          xml.doc.root.namespace = ins

          #Si el tipo de comprobante es "E", se agregará el nodo CfdiRelaionados en el que se indicará el tipo de relación
          #en otras palabras, si es una nota de crédito o débito...y además se agregará el elemento Cfdirelacionado para
          #indicar cuales son los folios fiscales que incluiran en el nuevo comprobante.
          if ns[:TipoDeComprobante]=="E"
          xml.CfdiRelacionados(TipoRelacion: @cfdisrelacionados.tipoRelacion){
            if @uuidsrelacionados.cout > 0
              cont=0
              @uuidsrelacionados.each do |ff|
              xml.CfdiRelacionado(
                 UUID: @uuidsrelacionados[cont].uuid
                )
                cont=cont+1
              end
            end
          }
          end
          xml.Emisor(@emisor.ns)  {
          }
          xml.Receptor(@receptor.ns) {
          }
          arrayTrasladados=[]
          #Variable para comprobar que existe almenos un concepto con impuestos aplicables(IVA o IEPS)
          impuestos_aplicables = false
          cant_trasladados_federales = 0
          xml.Conceptos {
            c_it=0
            @conceptos.each do |concepto|
              # select porque luego se pone roñoso el xml si incluyo noIdentificacion y es empty
              cc = concepto.to_h.select {|k,v| v!=nil && v != ''}
              cc = cc.map {|k,v|
                v = sprintf('%.2f', v) if v.is_a? Float
                [k,v]
              }.to_h
              xml.Concepto(cc) {
                #Ahora los impuestos por cada concepto
                if @impuestos.count_impuestos > 0#en caso que haya algun impuesto
                  if @impuestos.traslados.count > 0
                    imp_vacio = @impuestos.traslados[c_it].tax
                    unless imp_vacio == "Ninguno"
                      #Se llena un arreglo con los impuestos de los conceptos sin importar que se repitan y además
                      #Y se excluyen aquellos "disque impuestos" de los conceptos que no tienen ningun impuesto relacionado.
                      arrayTrasladados << [@impuestos.traslados[c_it].tax,
                                           @impuestos.traslados[c_it].type_factor,
                                           @impuestos.traslados[c_it].rate,
                                           @impuestos.traslados[c_it].import]
                      cant_trasladados_federales += 1 #aumenta siempre y cuando el impuesto sea valido
                      impuestos_aplicables = true
                      xml.Impuestos {
                          xml.Traslados {
                              xml.Traslado(
                                  Base: @impuestos.traslados[c_it].base,
                                  Impuesto: @impuestos.traslados[c_it].tax,
                                  TipoFactor: @impuestos.traslados[c_it].type_factor,
                                  TasaOCuota:  @impuestos.traslados[c_it].rate,
                                  Importe: @impuestos.traslados[c_it].import)
                          }
                        #Agregar el nodo Impuestos por si se mas adelante se ocupan las retenciones
                        #if @impuestos.detained.count > 0
                        #  xml.Retenciones do
                        #    @impuestos.detained.each do |det|
                        #      xml.Retencion(impuesto: det.tax, tasa: format('%.2f', det.rate),
                        #                    importe: format('%.2f', det.import))
                        #    end
                        #  end
                        #end
                      }
                    end
                  end
                end

                #xml.ComplementoConcepto
              }
              c_it=c_it+1
            end
          }
          #Cuando todos los conceptos no tengan ningun mugroso impuesto, no tiene por que mostrar el resumen total de los impuestos. suena lógico jaja
          if impuestos_aplicables
            tax_options = {}
            total_trans = format('%.2f', @impuestos.total_traslados)
            #total_detained = format('%.2f', @impuestos.total_detained)
            tax_options[:TotalImpuestosTrasladados] = total_trans if
              total_trans.to_i > 0
            #tax_options[:totalImpuestosRetenidos] = total_detained if
              #total_detained.to_i > 0
            #cant_it = @impuestos.traslados.count
            xml.Impuestos(tax_options) do
              if @impuestos.traslados.count > 0
                xml.Traslados{
                #if @impuestos.count_impuestos > 0
                resumen_traslados=[] #Para guardar todos los diferentes impuestos trasladados.

                #Se obtienen los valores del primer impuesto traslado y se almacenan.
                impuesto_it = arrayTrasladados[0][0] #Impuesto => tax
                tipoFactor_it = arrayTrasladados[0][1] #TipoFactor => type_factor
                tasaOCuota_it = arrayTrasladados[0][2] #TasaOCuota => rate
                importe_it = arrayTrasladados[0][3] #Importe => import
                resumen_traslados << [impuesto_it, tipoFactor_it, tasaOCuota_it, importe_it]

                #Si solo hay uno, pues para que hacerle al cuento. Se agrega un solo hijo "Traslado" al elemento padre "Traslados"
                if arrayTrasladados.length == 1
                  xml.Traslado(
                  Impuesto: impuesto_it,
                  TipoFactor:tipoFactor_it ,
                  TasaOCuota: tasaOCuota_it,
                  Importe: format('%.2f',importe_it)
                  )
                else
                  detectaCambio = false
                  indice = 0 #El indice del arreglo resumen_traslados[][] aumenta cuando se deja de comparar un impuesto y se pasa a otro
                  it = 0 #Es un apuntador (No siempre incremente de uno en uno)
                  while it < arrayTrasladados.length #Itera todos los impuestos de los conceptos(Excluidos los impuestos vacios)
                    indice_cambio = 0

                    bandera_cambio = true #Solo aplica para el primer cambio y omite el rest(si es que existen)
                    #Para comparar los atributos de  impuesto seleccionado a impuesto.
                    val = 0
                    while val < arrayTrasladados.length
                      #Se identifican los valores iguales
                      if arrayTrasladados[it][0] == arrayTrasladados[val][0] && arrayTrasladados[it][2] == arrayTrasladados[val][2]
                        #Se suman los importes de los impuestos iguales
                        #El indice 3 pertenece a los importes de los impuestos
                        if it != val #En tal caso que fueran = sería el mismo impuesto que se quiere comparar por lo que no se toma en cuenta para sumar sus importes
                          resumen_traslados[indice][3] = resumen_traslados[indice][3] + arrayTrasladados[val][3]
                        end
                        #En este caso se trata del mismo, es igual por que es el mismo jaja.
                        if val == arrayTrasladados.length - 1 && detectaCambio == true && it == val
                          #El último impuesto diferente y huerfanito se agrega al arreglo.
                          resumen_traslados << [arrayTrasladados[val][0],
                                                arrayTrasladados[val][1],
                                                arrayTrasladados[val][2],
                                                arrayTrasladados[val][3]]
                        end

                      else #Se debe de identificar el impuesto diferente más proximo y guardarlo hasta la nueva iteración
                        #Detecta el primer cambio y de aquí partimos señores!
                        detectaCambio = true
                        if bandera_cambio
                          if val > it
                            ite = 0
                            #Se comprueba que no se haya tomado en cuenta el mismo impuesto antes.
                            while ite < resumen_traslados.length
                              if resumen_traslados[ite][0] != arrayTrasladados[val][0] && resumen_traslados[ite][2] != arrayTrasladados[val][2]
                                #indice_cambio = val if indice_cambio > it
                                bandera_cambio = false #Esto asegura que sea el indice proximo y no el proximo del proximo
                                indice_cambio = val
                              end
                              ite += 1
                            end
                          end
                        end
                      end
                      val += 1
                    end #Fin de bucle anidado

                    #Se agrega un elemento Traslado por cada impuesto estrictamente diferente
                    xml.Traslado(
                    Impuesto: resumen_traslados[indice][0],
                    TipoFactor:resumen_traslados[indice][1],
                    TasaOCuota: resumen_traslados[indice][2],
                    Importe: format('%.2f',resumen_traslados[indice][3]) #Esto es el importe por cada impuesto diferente
                    )

                    if detectaCambio
                      if it == arrayTrasladados.length - 1
                        it = arrayTrasladados.length
                      else
                        it = indice_cambio
                      end
                      indice += 1 #Solo si hay cambio seguirá entrando
                    else #Si no se detecto cambio quiere decir que todos los impuestos traslados son identicos
                      it = arrayTrasladados.length #Solo un novato entra en un ciclo infinito jaja cual -1 ni que nada
                    end
                  end
                end
                }
                #if @impuestos.detained.count > 0
                #  xml.Retenciones do
                #    @impuestos.detained.each do |det|
                #      xml.Retencion(impuesto: det.tax, tasa: format('%.2f', det.rate),
                #                    importe: format('%.2f', det.import))
                #    end
                #  end
                #end
              end
            end
          end



=begin
          impuestos_options = {} #un hash
          impuestos_options = {totalImpuestosTrasladados: sprintf('%.2f', self.subTotal*@opciones[:tasa])} if @impuestos.count > 0
          xml.Impuestos(impuestos_options) {
            if @impuestos.traslados.count > 0
              xml.Traslados {
                @impuestos.traslados.each do |traslado|
                  xml.Traslado({
                    impuesto: traslado.impuesto,
                    tasa:(@opciones[:tasa]*100).to_i,
                    importe: sprintf('%.2f', self.subTotal*@opciones[:tasa])})
                end
              }
            end
            if @impuestos.retenciones.count > 0
              xml.Retenciones {
                @impuestos.retenciones.each do |retencion|
                  xml.Retencion({
                    impuesto: retencion.impuesto,
                    tasa:(@opciones[:tasa]*100).to_i,
                    importe: sprintf('%.2f', self.subTotal*@opciones[:tasa])})
                end
              }
            end
          }
=end
          xml.Complemento {
            if @complemento
              nsTFD = {
                'xsi:schemaLocation' => 'http://www.sat.gob.mx/TimbreFiscalDigital http://www.sat.gob.mx/TimbreFiscalDigital/TimbreFiscalDigital.xsd',
                'xmlns:tfd' => 'http://www.sat.gob.mx/TimbreFiscalDigital',
                'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance'
              }
              xml['tfd'].TimbreFiscalDigital(@complemento.to_h.merge nsTFD) {
              }

            end
          }

          if (@addenda)
            xml.Addenda {
              @addenda.data.each do |k,v|
                if v.is_a? Hash
                  xml[@addenda.nombre].send(k, v)
                elsif v.is_a? Array
                  xml[@addenda.nombre].send(Regimenk, v)
                else
                  xml[@addenda.nombre].send(k, v)
                end
              end
            }
          end

        end
      end
      @builder.to_xml
    end


    # Un hash con todos los datos del comprobante, listo para Hash.to_json
    #
    # @return [Hash] El comprobante como Hash
    def to_h
      hash = {}
      @@data.each do |key|
        data = deep_to_h send(key)
        hash[key] = data
      end

      return hash
    end


    # La cadena original del CFDI
    #
    # @return [String] Separada por pipes, because fuck you that's why
    def cadena_original
      params = []
      @@datosCadena.each {|key| params.push send(key) } #Los atributos a nivel factura
      params += @emisor.cadena_original  #los datos del emisor
      params += @receptor.cadena_original # seguido de los del receptor

      cont=0
      @conceptos.each do |concepto| # Cada concepto con su respectivo impuesto
      params += concepto.cadena_original
      if @impuestos.traslados.any?
        params += @impuestos.traslados_cadena_original[cont]
      end
      cont =cont+1
=begin
        AQUÍ SE DEBE DE PONER:
          Retenciónnombre
            *sus atributos
          Aduanera
            ...
          CuentaPredial
            ...
=end
      end
      if @impuestos.traslados.any?
        #Se supone que el único impuesto en las facturas electronicas el el IVA trasladado
        #Si estoy en lo correcto, entonces los valores pueden ser estaticos.
        tax='002'
        type_factor='Tasa'
        rate=0.160000
        import=@impuestos.total_traslados
        params += [tax,type_factor,rate,import,@impuestos.total_traslados]
      end
=begin
      if @impuestos.count > 0
        @impuestos.traslados.each do |traslado|
          # tasa = traslado.tasa ? traslado.tasa.to_i : (@opciones[:tasa]*100).to_i
          tasa = (@opciones[:tasa]*100).to_i
          total = self.subTotal*@opciones[:tasa]
          params += [traslado.impuesto, tasa, total, total]
        end
      end
=end
      params.select! { |i| i != nil && i != '' }
      params.map! do |elem|
        if elem.is_a? Float
          elem = sprintf('%.2f', elem)
        else
          elem = elem.to_s
        end
        elem
      end

      return "||#{params.join '|'}||"
    end


    # Revisa que el timbre de un comprobante sea válido
    # @param [String] El certificado del PAC
    #
    # @return [Boolean] El resultado de la validación
    def timbre_valido? cert=nil
      return false unless complemento && complemento.selloSAT

      unless cert
        require 'open-uri'
        comps = complemento.noCertificadoSAT.scan(/(\d{6})(\d{6})(\d{2})(\d{2})(\d{2})?/)
        base_url = 'ftp://ftp2.sat.gob.mx/Certificados/FEA'
        url = "#{base_url}/#{comps.join('/')}/#{cert}.cer"
        begin
          cert = open(url).read
        rescue Exception => e
          raise "No pude descargar el certificado <#{url}>: #{e}"
        end
      end

      cert = OpenSSL::X509::Certificate.new cert
      selloBytes = Base64::decode64(complemento.selloSAT)
      cert.public_key.verify(OpenSSL::Digest::SHA1.new, selloBytes, complemento.cadena)
    end


    # @private
    def self.rmerge defaults, other_hash
      result = defaults.merge(other_hash) do |key, oldval, newval|
        oldval = oldval.to_hash if oldval.respond_to?(:to_hash)
        newval = newval.to_hash if newval.respond_to?(:to_hash)
        oldval.class.to_s == 'Hash' && newval.class.to_s == 'Hash' ? Comprobante.rmerge(oldval, newval) : newval
      end
      result
    end

=begin
    # return string with total in words.
    # Example: ( UN MIL CIENTO SESENTA PESOS 29/100 M.N. )
    def total_to_words
      decimal = format('%.2f', @total).split('.')
      "( #{@total.to_words.upcase} PESOS #{decimal[1]}/100 M.N. )"
    end

=end

  # Función para formar el Código de Barra Bidimencional
  def qr_code document
    #La URL del acceso al servicio que pueda mostrar los datos del
    #comprobante
    #https://verificacfdi.facturaelectronica.sat.gob.mx/default.aspx
    cbb = "https://verificacfdi.facturaelectronica.sat.gob.mx/default.aspx?"
    #UUID del comprobante, precedido por el texto “&id=”
    cbb += "&id=#{@complemento.uuid}"   #Investigar si es ? o &
    #RFC del Emisor, a 12/13 posiciones, precedido por el texto ”&re=”
    cbb += "&re==#{@emisor.re_QR}"
    #RFC del Receptor, a 12/13 posiciones, precedido por el texto
    #“&rr=”, para el comprobante de retenciones se usa el dato que
    #esté registrado en el RFC del receptor o el NumRegIdTrib (son
    #excluyentes).
    cbb += "&rr=#{@receptor.rr_QR}"
    #Total del comprobante máximo a 25 posiciones (18 para los
    #enteros, 1 para carácter “.”, 6 para los decimales), se deben
    #omitir los ceros no significativos, precedido por el texto “&tt=”
    cbb += "&tt=#{format('%6f', @total).rjust(25).squish}" #Ya no quieren los mugrosos ceros no significativos
    #t += "&tt=#{format('%6f', @total).rjust(25, '0')}"

    #Ocho últimos caracteres del sello digital del emisor del
    #comprobante, precedido por el texto “&fe=”
    sello=document.xpath('//@Sello')
    s=sello.to_s()
    last8=s.split('').last(8).join
    puts cbb += "&fe=#{last8}"

    img = RQRCode::QRCode.new(cbb).to_img
    #No debe de ser menor a 2.75 cm
    #1.75 cm == 103.937008 px
    #3.175 cm == 120 px
    img.resize(120, 120).save("/home/daniel/Documentos/timbox-ruby/code_qr_CFDI.png")#No quedará de otra mas que guardar la imagen.
  end

  #Esta función es para generar un nuevo xml con datos adicionales para poder formar la representación impresa del CFDI debido
  #a que se usa una hoja de transformacón y el xml timbrado no contiene algunos datos para su correspondiente representación.
  def add_elements_to_xml xml_copia, codigoQR, cadOrigComplemento , logo, uso_cfdi_descripcion
    ns={
      CodigoQR: "/home/daniel/Documentos/timbox-ruby/code_qr_CFDI.png", #la misma ruta donde se guarda el CBB
      CadOrigComplemento: cadOrigComplemento,
      Logo:logo, #Sha la la sha la la
      TotalLetras: total_to_words(),
      NombRegimenFiscal:"E",
      NombFormaPago:"F",
      NombMetodoPago:"G",
      UsoCfdiDescripcion:uso_cfdi_descripcion
      }
    builder = Nokogiri::XML::Builder.new(encoding: 'utf-8')  do |xml| #La linea <?xml version="1.0" encoding="utf-8"?> se duplicará con la combinación
      xml.RepresentacionImpresa(ns){
        xml.DomicilioEmisor(@emisor.domicilioFiscal.to_h.reject {|k,v| v == nil}) #
        xml.ExpedidoEn(@emisor.expedidoEn.to_h.reject {|k,v| v == nil || v == ''})
        xml.DomicilioReceptor(@receptor.domicilioFiscal.to_h.reject {|k,v| v == nil || v == ''})
      }
    end
    xml_info_extra=builder.to_xml
    #Se combinan el xml previamente timbrado con el xml que contiene los datos adicionales para la representación impresa.
    #El resultado es un xml
    #xml1 = Nokogiri::XML(xml_copia)
    xml1 = xml_copia
    xml2 = Nokogiri::XML(xml_info_extra)
    xml1.children.first.add_child(xml2.children.first.clone)

    a = File.open("/home/daniel/Documentos/timbox-ruby/xml_COMBINADO", "w")
    a.write (xml1)
    a.close

    xml1
  end

  #Función para representar el total en letras
  def total_to_words
    decimal = format('%.2f', @total).split('.')
    total_en_letras="#{@total.to_words.upcase} PESOS #{decimal[1]}/100 M.N."
  end

  #Funcion para guardar los xml
  def guardar_xml(xml,ruta,nombre)
    archivo = File.open("#{ruta}/#{nombre}", "w")
    archivo.write (xml)
    archivo.close
  end


  private

  def deep_to_h value
    if value.is_a? ElementoComprobante
      original = value.to_h
      value = {}
      original.each do |k,v|
        value[k] = deep_to_h v
      end
    elsif value.is_a?(Array)
      value = value.map do |v|
        deep_to_h v
      end
    end
    value
  end

  end
end
