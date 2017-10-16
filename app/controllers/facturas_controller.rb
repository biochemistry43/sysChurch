class FacturasController < ApplicationController
	#require 'foo.rb'
	#include Saluda
	require 'cfdi'
	#include FacturasHelper
	def index 
		@fact=Factura.all
		#@hola=Salud::Salu.new.sal()
		
		certificado = CFDI::Certificado.new './Cert_Sellos/aaa010101aaa_FIEL/aaa010101aaa_FIEL.cer'
		# la llave en formato pem, porque no encontré como usar OpenSSL con llaves tipo PKCS8
		# Esta se convierte de un archivo .key con:
		# openssl pkcs8 -inform DER -in someKey.key -passin pass:somePassword -out key.pem
		llave = CFDI::Key.new './Cert_Sellos/aaa010101aaa_FIEL/Claveprivada_FIEL_AAA010101AAA_20170515_120909.pem', '12345678a'
				
		factura = CFDI::Comprobante.new({
		    folio: 1,
			serie: 'F',
			fecha: Time.now,
			formaDePago: 'PAGO EN UNA SOLA EXHIBICION',
			condicionesDePago: 'Sera marcada como pagada en cuanto el receptor haya cubierto el pago.',
			metodoDePago: 'Transferencia Bancaria',
			lugarExpedicion: 'Martinez de la Torre'
		})

		# Esto es un domicilio casi completo
		domicilioEmisor = CFDI::Domicilio.new({
		  calle: 'Calle Feliz',
		  noExterior: '42',
		  noInterior: '314',
		  colonia: 'Centro',
		  localidad: 'No se que sea esto, pero va',
		  referencia: 'Sin Referencia',
		  municipio: 'Martinez de la Torre',
		  estado: 'Veracruz',
		  pais: 'Mexico',
		  codigoPostal: '31415'
		})

		# y esto es una persona fiscal
		factura.emisor = CFDI::Entidad.new({
		  rfc: 'XAXX010101000',
		  nombre: 'Empresa X',
		  domicilioFiscal: domicilioEmisor,
		  expedidoEn: domicilioEmisor,
		  regimenFiscal: 'Pruebas Fiscales'
		})

		# misma mierda
		domicilioReceptor = CFDI::Domicilio.new({
		  referencia: 'Sin Referencia',
		  estado: 'Nutopía',
		  pais: 'Nutopía'
		})
		factura.receptor = CFDI::Entidad.new({rfc: 'XAXX010101000', nombre: 'El SAT apesta S. de R.L.', domicilioFiscal: domicilioReceptor})


		# Así agregamos conceptos, en este caso, 2 Kg de Verga
		factura.conceptos << CFDI::Concepto.new({
		  cantidad: 2,
		  unidad: 'Kilos',
		  noIdentificacion: 'KDV',
		  descripcion: 'Verga',
		  valorUnitario: 5500.00 #el importe se calcula solo
		})

		# Todavía no agarro bien el pedo sobre como salen los impuestos, pull request?
		#factura.impuestos << {impuestos: 'IVA'}


		factura.addenda= {
		  nombre: 'poo',
		  namespace: 'http://surrealista.mx/xsd/poo',
		  xsd: 'http://surrealista.mx/xsd/poo/poo.xsd',
		  data: {
		    caca: 'popo',
		    pipi: 'pedos'
		  }
		}
		certificado.certifica factura
		# Para mandarla a un PAC, necesitamos sellarla, y esto lo hace agregando el sello
		# La cadena original que generamos sólo tiene los datos que u
		llave.sella factura

		# Esto genera la factura como xml
		@hola= factura.to_xml
	end	
	def show
	end
end

