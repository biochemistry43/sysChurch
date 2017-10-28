=begin
module Saluda
	module Salud
	class Salu
		def sal()
			"hola danielito"
		end
	end
	end
end
=end
require_relative 'cfdi.rb'
#include FacturasHelper

	#@fact=Factura.all
	#@hola=Salud::Salu.new.sal()

	#certificado = CFDI::Certificado.new './Cert_Sellos/CSDAAA010101AAA/CSD01_AAA010101AAA.cer'
	# la llave en formato pem, porque no encontré como usar OpenSSL con llaves tipo PKCS8
	# Esta se convierte de un archivo .key con:
	# openssl pkcs8 -inform DER -in someKey.key -passin pass:somePassword -out key.pem
	#llave = CFDI::Key.new './Cert_Sellos/CSDAAA010101AAA/CSD01_AAA010101AAA.pem', '12345678a'
	#DATOS DE PRUEBA. AQUI SE REALIZARAN LAS CONSULTAS PARA OBTENER LOS DATOS DEL CLIENTE Y EMISOR .
	#Y SE PASARAN LOS DATOS DE LAS VENTAS A FACTURAS A TRAVES DE LOS FORMULARIOS.


	factura = CFDI::Comprobante.new({
		serie: '   FA_V',
			folio: 1,
		fecha: Time.now,
		formaDePago: '01',#CATALOGO
		condicionesDePago: '  Sera marcada como pagada en cuanto el receptor haya cubierto el pago.',
		metodoDePago: 'PUE', #CATALOGO
		lugarExpedicion: '93600'#, #CATALOGO
		#Descuento:30 #DESCUENTO RAPPEL
	})


	#puts factura.

	# Esto es un domicilio casi completo

	#domicilioEmisor = CFDI::Domicilio.new({
	 # calle: 'Calle X',
	 # noExterior: '42',
	 # noInterior: '314',
	 # colonia: 'Centro',
	 # localidad: 'No se que sea esto, pero va',
	 # referencia: 'Sin Referencia',
	 # municipio: 'Martinez de la Torre',
	 # estado: 'Veracruz',
	 # pais: 'Mexico',
	 # codigoPostal: '93600'
	#})

	# y esto es una persona fiscal
	factura.emisor = CFDI::Emisor.new({
		rfc: "   XAXX010101000   ",
		nombre: 'Empresa X   ',
		#domicilioFiscal: domicilioEmisor,
		#expedidoEn: domicilioEmisor,
		regimenFiscal: '601  ' #CATALOGO
	})

	#domicilioReceptor = CFDI::Domicilio.new({
	 # referencia: 'Sin Referencia',
	 # estado: 'Martinez de la Torre',
	 # pais: 'Mexico'
	#})

	factura.receptor = CFDI::Receptor.new({
		rfc: '    XAXX010101000',
		 nombre: 'Juan Perez Miranda.',
		 UsoCFDI:'G01' #CATALOGO
		#, domicilioFiscal: domicilioReceptor
		})

	#<< para que puedan ser agragados los conceptos que se deseen.
	factura.conceptos << CFDI::Concepto.new({
		ClaveProdSer: '50431800', #CATALOGO
		noIdentificacion: 'SKUFRI25',
		cantidad: 2,
		ClaveUnidad: '53',#CATALOGO
		unidad: 'Kilos',
		descripcion: 'Frijol',
		valorUnitario: 25.00, #el importe se calcula solo
		Descuento: 50 #Expresado en porcentaje
	})

	factura.conceptos << CFDI::Concepto.new({
		ClaveProdSer: '50431800', #CATALOGO
		noIdentificacion: 'SKUFRI25',
		cantidad: 1,
		ClaveUnidad: '53',#CATALOGO
		unidad: 'Kilos',
		descripcion: 'Lentejas',
		valorUnitario: 25.00, #el importe se calcula solo
		Descuento: 50
	})

		puts factura.Descuento


	#factura.impuestos << CFDI::Impuestos.new{impuestos: 'IVA'}

	#ob=CFDI::Impuestos::Traslado.new({impuesto: 'IVA', tasa: 0.17})
	factura.impuestos = {impuestos: 'IVA'}

  #puts CFDI::ElementoComprobante.data

	puts a= 1.00091.to_d
	puts b= 9999994.1233
	puts a+b


  puts factura.cadena_original
