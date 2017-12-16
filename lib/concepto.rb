module CFDI

  # Un concepto del comprobante
  class Concepto < ElementoComprobante

    # @private
    @cadenaOriginal = [:totalDescuento,:ClaveProdSer, :NoIdentificacion, :Cantidad, :ClaveUnidad, :Unidad, :Descripcion,  :ValorUnitario, :Importe, :Descuento]
    # @private
    attr_accessor *@cadenaOriginal
=begin
    def initialize (d=0.00)
      self.Descuento= d
    end
=end
    # @private
    def cadena_original #aquí se establece el orden de la cadena original! que engañado eh vivido jaja
      return [
        @ClaveProdSer,
        @NoIdentificacion,
        @Cantidad.to_f,
        @ClaveUnidad,
        @Unidad,
        @Descripcion,
        self.ValorUnitario,
        self.Importe,
        @Descuento
      ]
    end

    def Descuento= (porcentaje)# 50 %
      @Descuento=((@ValorUnitario*@Cantidad)/100)*porcentaje
      @Descuento
    end
    # Asigna la descripción de un concepto
    # @param descricion [String] La descripción del concepto
    #
    # @return [String] La descripción como string sin espacios extraños
    def Descripcion= descripcion
      @Descripcion = descripcion.squish
      @Descripcion
    end

    # Asigna el valor unitario de este concepto
    # @param  dineros [String, Float, #to_f] Cualquier cosa que responda a #to_f
    #
    # @return [Float] El valor unitario como Float
    def ValorUnitario= dineros
      @ValorUnitario = dineros.to_f
      @ValorUnitario
    end
    # El importe de este concepto
    #
    # @return [Float] El valor unitario multiplicado por la Cantidad
    def Importe
      return @ValorUnitario*@Cantidad
    end


    # Asigna la Cantidad de (tipo) de este concepto
    # @param  qty [Integer, String, #to_i] La Cantidad, que ahuevo queremos en int, porque no, no podemos vender 1.5 Kilos de verga...
    #
    # @return [Integer] La Cantidad
    def Cantidad= qty
      @Cantidad = qty.to_f
      @Cantidad
    end

  end

end
