module CFDI

   class Cfdirelacionado < ElementoComprobante#Vamos a complacer al SAT de como se tiene que hacer  jajaja

     #attr_accessor :folios_relacionados
     #Estos son los UUIDs(Folios fiscales de los CFDIs) relacionados que se aplicarán en la
     #nota de crédito o también conocida como Factura de Egreso.

       attr_accessor  :uuid

       def uuid=(uuid)
         @uuid=uuid
       end

  end #Clase Padre CfdiRelacionado

  class CfdiRelacionados# < Cfdirelacionado
    attr_accessor :uuids, :tipoRelacion

    def initialize data={}  #No se que changos pero salió jajaja
      #puts self.class
      data.each do |k,v|
        method = "#{k}=".to_sym
        next if !self.respond_to? method
        self.send method, v
      end
    end

  end

end
