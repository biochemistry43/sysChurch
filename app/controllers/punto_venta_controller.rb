class PuntoVentaController < ApplicationController
    after_filter { flash.discard if request.xhr? }

	def index
	end

	def realizarVenta
		literal = params[:data]
		hash = literal
		hash = JSON.parse(hash) if hash.is_a?(String)
		render :text => hash
		if false
	        montoVenta = 0
			hash.each do |indice, itemVenta|
			  itemVenta.each do |clave, valor|
	             if clave == "importe"
	             	montoVenta += valor.to_f
	             end
			  end
			end


	        @venta = Venta.new
	        @venta.fechaVenta = Time.now
	        @venta.montoVenta = montoVenta
	        @venta.caja = 1
	        @venta.user = current_user
	        itemSaved = true

		    if @venta.save
		      	#en el primer nivel del hash están los indice de cada item de venta
		       	hash.each do |indice, itemVenta|

		        itemV = ItemVenta.new
		       	  #en el segundo nivel de hash están los items particulares de la venta
				  itemVenta.each do |clave, valor|
			           
			       	itemV.venta = @venta
			       	if clave == "codigo"
		                itemV.articulo = Articulo.find_by clave: valor
			       	end
			       	if clave == "cantidad"
		                itemV.cantidad = valor
			       	end
			        	
				  end
				  if itemV.save
				  	itemSaved = itemSaved && true
				  else
				  	itemSaved = itemSaved && false
				  end

				end
				if itemSaved
				   render :text => "Venta realizada correctamente"
	            else
	               render :text => "Fallo al intentar realizar la venta"
	            end
		    else
		       	render :text => "Fallo al intentar realizar la venta"
		    end
		end
	end
end