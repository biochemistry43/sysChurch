module CFDI
  
  class Receptor < ElementoComprobante

     @cadenaOriginal = [:rfc, :nombre, :UsoCFDI]
     @data = @cadenaOriginal
    attr_accessor *@cadenaOriginal
    

    def cadena_original
      return [
        @rfc,
        @nombre,
        @UsoCFDI
      ].flatten
    end

    def ns
      return ({
        nombre: @nombre,
        rfc: @rfc
      })
    end
    
  end

  class Emisor < ElementoComprobante
   @cadenaOriginal = [:rfc, :nombre,  
      :regimenFiscal]
    @data = @cadenaOriginal

    attr_accessor *@cadenaOriginal
    def cadena_original
     
      return [
        @rfc,
        @nombre,

        @regimenFiscal
      ].flatten
    end
    def ns
      return ({
        nombre: @nombre,
        rfc: @rfc
      })
    end
    
  end  
end