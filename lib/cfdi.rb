# encoding: utf-8
#gem 'nokogiri', '1.5.11'

require 'bigdecimal'
require 'bigdecimal/util'

require_relative 'cfdi/version.rb'

require_relative 'cfdi/taxes.rb'
require_relative 'cfdi/comun.rb'
require_relative 'cfdi/addenda.rb'
require_relative 'cfdi/comprobante.rb'
require_relative 'cfdi/emisor_receptor.rb'
require_relative 'cfdi/concepto.rb'
require_relative 'cfdi/relacionados.rb'
require_relative 'cfdi/complemento.rb'
#require_relative 'xml.rb'
require_relative 'cfdi/certificado.rb'
require_relative 'cfdi/key.rb'



# Comprobantes fiscales digitales por los internets
#
# El sistema de generación y sellado de facturas es una patada en los genitales. Este gem pretende ser una bolsa de hielos. Igual va a doler, pero espero que al menos no quede moretón.
module CFDI

  #require 'nokogiri'
  require 'time'
  require 'base64'

  # Porque SAT, los métodos de pago con su clave
  #
  # @ return [Hash] La clave y su valor como texto
=begin
 METODOS_DE_PAGO = {
    '01' => 'Efectivo',
    '02' => 'Cheque nominativo',
    '03' => 'Transferencia electrónica de fondos',
    '04' => 'Tarjeta de crédito',
    '05' => 'Monedero electrónico',
    '06' => 'Dinero electrónico',
    '08' => 'Vales de despensa',
    '28' => 'Tarjeta de débito',
    '29' => 'Tarjeta de servicio',
    '99' => 'Otros',
  }

  # alias
  def self.metodos_de_pago
    METODOS_DE_PAGO
  end
=end


end