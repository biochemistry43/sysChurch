class FacturaFormaPago < ActiveRecord::Base
  	has_many :facturas
    def cve_nombre_forma_pagoSAT
        "#{cve_forma_pagoSAT} - #{nombre_forma_pagoSAT}"
  	end
end
