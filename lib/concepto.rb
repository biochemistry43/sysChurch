module CFDI

  # Un concepto del comprobante
  class Concepto < ElementoComprobante

    # @private
    @cadenaOriginal = [:totalDescuento,:ClaveProdSer, :noIdentificacion, :cantidad, :ClaveUnidad, :unidad, :descripcion,  :valorUnitario, :importe, :Descuento]
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
        @noIdentificacion,
        @cantidad.to_f,
        @ClaveUnidad,
        @unidad,
        @descripcion,
        self.valorUnitario,
        self.importe,
        @Descuento
      ]
    end

    def Descuento= (porcentaje)# 50 %
      @Descuento=((@valorUnitario*@cantidad)/100)*porcentaje
      @Descuento
    end
    # Asigna la descripción de un concepto
    # @param descricion [String] La descripción del concepto
    #
    # @return [String] La descripción como string sin espacios extraños
    def descripcion= descripcion
      @descripcion = descripcion.squish
      @descripcion
    end

    # Asigna el valor unitario de este concepto
    # @param  dineros [String, Float, #to_f] Cualquier cosa que responda a #to_f
    #
    # @return [Float] El valor unitario como Float
    def valorUnitario= dineros
      @valorUnitario = dineros.to_f
      @valorUnitario
    end
    # El importe de este concepto
    #
    # @return [Float] El valor unitario multiplicado por la cantidad
    def importe
      return @valorUnitario*@cantidad
    end


    # Asigna la cantidad de (tipo) de este concepto
    # @param  qty [Integer, String, #to_i] La cantidad, que ahuevo queremos en int, porque no, no podemos vender 1.5 Kilos de verga...
    #
    # @return [Integer] La cantidad
    def cantidad= qty
      @cantidad = qty.to_f
      @cantidad
    end

  end

end
