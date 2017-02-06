class PuntoVentaController < ApplicationController
    #after_filter { flash.discard if request.xhr? }

	def index9
	end

	def realizarVenta
	  literal = params[:dataVenta]
	  hash = literal
	  hash = JSON.parse(hash.gsub('\"', '"'))
	  caja = ""
      loquesea = ""
      formaPago = ""
      numTDebito = ""
      numTCredito = ""
      plazoCredito = ""
      refOxxo = ""
      refPaypal = ""
    
	  #primer nivel del json
	  hash.each do |item|
	    if item.respond_to?(:key?)
	  	  if item.has_key?("caja")
		    caja = item["caja"]
		  end
	    end
	        	
	    if item.is_a?(Array)
	      if item[0].has_key?("formaPago")
	              	
	        hashPago = item[0]
	        formaPago = hashPago["formaPago"]
	       
		    if formaPago == "debito"
		      numTDebito = hashPago["ntDebito"]
		    end

		    if formaPago == "credito"
		      numTDebito = hashPago["ntCredito"]
		      plazoCredito = hashPago["plazoTCredito"]
		    end

		    if formaPago == "oxxo"
		      refOxxo = hashPago["refOxxo"]
		    end

		    if formaPago == "paypal"
		      refOxxo = hashPago["refPaypal"]
		    end
	      
	      end
	      
	      if item[0].has_key?("importe")
            
            #hash que contiene los items de venta
            montoVenta = 0
	        
	        item.each do |itemVenta|
			  
			  montoVenta += itemVenta["importe"].to_f

			end

			@venta = Venta.new
			@venta.fechaVenta = Time.now
			@venta.montoVenta = montoVenta
			@venta.caja = 1
			@venta.user = current_user
			itemSaved = true

			if @venta.save
			  #Aquí se recorre cada item de venta
			  item.each do |itemVenta|
                
			    itemV = ItemVenta.new

                itemV.venta = @venta
                itemV.articulo = Articulo.find_by clave: itemVenta["codigo"]
                itemV.cantidad = itemVenta["cantidad"]
				
				if itemV.save
				  itemSaved = itemSaved && true
				else
				  itemSaved = itemSaved && false
				end

			  end
						
			  if itemSaved
			    flash[:notice] = "La venta se guardó exitosamente!"
			    redirect_to punto_venta_index_path
			  else
			    flash[:notice] = "Error al intentar guardar la venta"
			    redirect_to punto_venta_index_path
			  end
			#Si la venta no se guardó correctamente
			else
			  flash[:notice] = "Error al intentar guardar la venta"
			  redirect_to punto_venta_index_path
			end
		  end
	    end
	  end
	end
end