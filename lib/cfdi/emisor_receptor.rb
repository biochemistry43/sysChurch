module CFDI
  class DatosComunes < ElementoComprobante
    @@cadenaComun=[:rfc, :nombre]
    attr_accessor(*@cadenaComun)
    def rfc=(rfc)
      @rfc=rfc.squish
    end
    def nombre=(nombre)
      @nombre=nombre.squish
    end
  end
  class Receptor < DatosComunes
     #UsoCFDI=[:UsoCFDI]
     @cadenaOriginal = @@cadenaComun+[:UsoCFDI]#  + [:UsoCFDI]
     attr_accessor(@cadenaOriginal[2])
     def UsoCFDI=(usoCFDI)
       @UsoCFDI=usoCFDI.squish
     end
    def cadena_original
      return [
        @rfc,
        @nombre,
        @UsoCFDI
      ].flatten
    end
    def rr_QR
      rfc=  @rfc
    end
    def ns
      return ({
        Nombre: @nombre,
        Rfc: @rfc,
        UsoCFDI: @UsoCFDI
      })
    end
  end
  class Emisor < DatosComunes
    @cadenaOriginal =@@cadenaComun +[:regimenFiscal]#  + [:UsoCFDI]
    attr_reader(@cadenaOriginal[2])
    def regimenFiscal= (regimenFiscal)
      @regimenFiscal=regimenFiscal.squish
    end
    def cadena_original
      return [
        @rfc,
        @nombre,

        @regimenFiscal
      ].flatten
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
