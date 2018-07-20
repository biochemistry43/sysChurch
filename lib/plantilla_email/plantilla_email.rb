module PlantillaEmail 
	class AsuntoMensaje

		texto_variable = [:nombCliente, :fechaVta, :numVta, :folioVta, :fechaFact, :numFact, :folioFact, :totalFact, :fechaNC, :numNC, :folioNC, :totalNC, :nombNegocio, :nombSucursal, :emailContacto, :telContacto]
		attr_accessor(*texto_variable)
		
		def reemplazar_texto (cadena)

		      cadena = cadena.gsub(/(\{\{Nombre del cliente\}\})/, "#{@nombCliente}") if @nombCliente
		      cadena = cadena.gsub(/(\{\{Fecha de la venta\}\})/, "#{@fechaVta}") if @fechaVta
		      cadena = cadena.gsub(/(\{\{Número de venta\}\})/, "#{@numVta}") if @numVta
		      cadena = cadena.gsub(/(\{\{Folio de la venta\}\})/, "#{@folioVta}") if @folioVta
		      #Datos de la factura.
		      cadena = cadena.gsub(/(\{\{Fecha de la factura\}\})/, "#{@fechaFact}") if @fechaFact
		      cadena = cadena.gsub(/(\{\{Número de factura\}\})/, "#{@numFact}") if @numFact
		      cadena = cadena.gsub(/(\{\{Folio de la factura\}\})/, "#{@folioFact}") if @folioFact
		      cadena = cadena.gsub(/(\{\{Total de la factura\}\})/, "#{@totalFact}") if @totalFact

		      cadena = cadena.gsub(/(\{\{Fecha de la factura\}\})/, "#{@fechaNC}") if @fechaNC
		      cadena = cadena.gsub(/(\{\{Número de factura\}\})/, "#{@numNC}") if @numNC
		      cadena = cadena.gsub(/(\{\{Folio de la factura\}\})/, "#{@folioNC}") if @folioNC
		      cadena = cadena.gsub(/(\{\{Total de la factura\}\})/, "#{@totalNC}") if @totalNC

		      #Dirección y dtos de contacto del changarro
		      cadena = cadena.gsub(/(\{\{Nombre del negocio\}\})/, "#{@nombNegocio}") if @nombNegocio
		      cadena = cadena.gsub(/(\{\{Nombre de la sucursal\}\})/, "#{@nombSucursal}") if @nombSucursal
		      cadena = cadena.gsub(/(\{\{Email de contacto\}\})/, "#{@emailContacto}") if @emailContacto
		      cadena = cadena.gsub(/(\{\{Teléfono de contacto\}\})/, "#{@telContacto}") if @telContacto
		      return cadena
	    end
	end

end