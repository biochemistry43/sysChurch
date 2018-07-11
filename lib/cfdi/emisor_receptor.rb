module CFDI
  #El cliente y el emisor tienen en comun que tienen una direccion fiscal
  class DatosComunes < ElementoComprobante

    @atributosDomicilio= [:domicilioFiscal, :expedidoEn]
    attr_accessor *@atributosDomicilio
    @@cadenaComun=[:rfc, :nombre]
    attr_accessor(*@cadenaComun)

    def rfc=(rfc)
      @rfc=rfc.squish
    end
    def nombre=(nombre)
      @nombre=nombre.squish
    end
    # @ return [CFDI::Domicilio] idem
    def domicilioFiscal= domicilio
      domicilio = Domicilio.new domicilio unless domicilio.is_a? Domicilio
      @domicilioFiscal = domicilio
      @domicilioFiscal
    end

    # Designa dónde se expidió el comprobante, sólo para Entidades de tipo "Emisor"
    # @ param  domicilio [CFDI::Domicilio, Hash] El domicilio de expedición de este emisor
    # @ return [CFDI::Domicilio] idem
    def expedidoEn= domicilio
      return if !domicilio
      domicilio = Domicilio.new domicilio unless domicilio.is_a? Domicilio
      @expedidoEn = domicilio
    end

    class Domicilio < ElementoComprobante
      @cadenaOriginal = [:calle, :noExterior, :noInterior, :colonia, :localidad, :referencia, :municipio, :estado, :codigoPostal, :pais]
      attr_accessor *@cadenaOriginal
    end
  end

  class Receptor < DatosComunes
     #UsoCFDI=[:UsoCFDI]
     @cadenaOriginal = @@cadenaComun+[:UsoCFDI]#  + [:UsoCFDI]
     attr_accessor(@cadenaOriginal[2])
     def UsoCFDI=(usoCFDI)
       @UsoCFDI=usoCFDI.squish
     end

    def rr_QR
      rfc=  @rfc
    end
    def ns
      datos_receptor = {
        Rfc: @rfc,
        UsoCFDI: @UsoCFDI
      }
      datos_receptor[:Nombre] = @nombre if @nombre
      return (datos_receptor)
    end
  end

  class Emisor < DatosComunes
    @cadenaOriginal =@@cadenaComun +[:regimenFiscal]#  + [:UsoCFDI]
    attr_reader(@cadenaOriginal[2])
    def regimenFiscal= (regimenFiscal)
      @regimenFiscal=regimenFiscal.squish
    end
    def re_QR
      rfc=  @rfc
    end
    def ns
      return ({
        Nombre: @nombre,
        Rfc: @rfc,
        RegimenFiscal:@regimenFiscal
      })
    end
  end
end


=begin
module CFDI
  #El cliente y el emisor tienen en comun que tienen una direccion fiscal
  class DatosComunes < ElementoComprobante

    @atributosDomicilio= [:domicilioFiscal, :expedidoEn]
    attr_accessor *@atributosDomicilio
    @@cadenaComun=[:rfc, :nombre]
    attr_accessor(*@cadenaComun)

    def rfc=(rfc)
      @rfc=rfc.squish
    end
    def nombre=(nombre)
      @nombre=nombre.squish
    end
    # @ return [CFDI::Domicilio] idem
    def domicilioFiscal= domicilio
      domicilio = Domicilio.new domicilio unless domicilio.is_a? Domicilio
      @domicilioFiscal = domicilio
      @domicilioFiscal
    end

    # Designa dónde se expidió el comprobante, sólo para Entidades de tipo "Emisor"
    # @ param  domicilio [CFDI::Domicilio, Hash] El domicilio de expedición de este emisor
    # @ return [CFDI::Domicilio] idem
    def expedidoEn= domicilio
      return if !domicilio
      domicilio = Domicilio.new domicilio unless domicilio.is_a? Domicilio
      @expedidoEn = domicilio
    end

    class Domicilio < ElementoComprobante
      @cadenaOriginal = [:calle, :noExterior, :noInterior, :colonia, :localidad, :referencia, :municipio, :estado, :pais, :codigoPostal]
      attr_accessor *@cadenaOriginal
    end
  end

  class Receptor < DatosComunes
     #UsoCFDI=[:UsoCFDI]
     @cadenaOriginal = @@cadenaComun+[:UsoCFDI]#  + [:UsoCFDI]
     attr_accessor(@cadenaOriginal[2])
     def UsoCFDI=(usoCFDI)
       @UsoCFDI=usoCFDI.squish
     end

    def rr_QR
      rfc=  @rfc
    end
    def ns
      datos_emisor = {
        Rfc: @rfc,
        UsoCFDI: @UsoCFDI
      }
      datos_emisor[:Nombre] = @nombre if @nombre
      return (datos_emisor)
    end
  end

  class Emisor < DatosComunes
    @cadenaOriginal =@@cadenaComun +[:regimenFiscal]#  + [:UsoCFDI]
    attr_reader(@cadenaOriginal[2])
    def regimenFiscal= (regimenFiscal)
      @regimenFiscal=regimenFiscal.squish
    end
    def re_QR
      rfc=  @rfc
    end
    def ns
      return ({
        Nombre: @nombre,
        Rfc: @rfc,
        RegimenFiscal:@regimenFiscal
      })
    end
  end
end

=end
