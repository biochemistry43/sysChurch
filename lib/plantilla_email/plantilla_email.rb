module PlantillaEmail 
	class AsuntoMensaje
		#La fecha puede ser usada para fecha de expedición o cancelación
		texto_variable = [:nombCliente, :uuid, :fecha, :serie, :folio, :total, :nombNegocio, :nombSucursal, :emailContacto, :telContacto, :paginaWeb]
		attr_accessor(*texto_variable)
		
		def reemplazar_texto (cadena)
		      cadena = cadena.gsub(/(\{\{Nombre del cliente\}\})/, "#{@nombCliente}") if @nombCliente
		      cadena = cadena.gsub(/(\{\{Fecha\}\})/, "#{@fecha}") if @fecha
		      cadena = cadena.gsub(/(\{\{Número\}\})/, "#{@numero}") if @numero
		      cadena = cadena.gsub(/(\{\{Folio\}\})/, "#{@folio}") if @folio
		      cadena = cadena.gsub(/(\{\{Total\}\})/, "#{@total}") if @total
		    
		      #Dirección y datos de contacto del changarro
		      cadena = cadena.gsub(/(\{\{Nombre del negocio\}\})/, "#{@nombNegocio}") if @nombNegocio
		      cadena = cadena.gsub(/(\{\{Nombre de la sucursal\}\})/, "#{@nombSucursal}") if @nombSucursal
		      cadena = cadena.gsub(/(\{\{Email de contacto\}\})/, "#{@emailContacto}") if @emailContacto
		      cadena = cadena.gsub(/(\{\{Teléfono de contacto\}\})/, "#{@telContacto}") if @telContacto
		      return cadena
	    end
	end

end