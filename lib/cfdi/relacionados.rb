module CFDI
  #
  class CfdiRelacionados < ElementoComprobante
    attr_accessor :tipoRelacion
    def initialize
      @comp_relacionados = []
    end
    def count_relacionados
      @comp_relacionados.count #+ @detained.count
    end

    def relacionados=(data)
      if data.is_a? Array #En caso de que sea un arreglo
        data.map do |c|
          c = CfdiRelacionado.new(c) unless c.is_a? CfdiRelacionado
          @comp_relacionados << c
        end
      elsif data.is_a? Hash #O en el caso un hash
        @comp_relacionados << CfdiRelacionado.new(data)
      elsif data.is_a? CfdiRelacionado
        @comp_relacionados << data
      end
      @comp_relacionados
    end
  end

  class CfdiRelacionado
     attr_accessor  :uuid
  end
end
