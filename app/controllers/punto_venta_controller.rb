class PuntoVentaController < ApplicationController
    #after_filter { flash.discard if request.xhr? }
   # before_filter :authenticate_user!

	def index
      @formas_pago = FormaPago.all
	end

	def obtenerCamposFormaPago
      
      if request.post?
        formaP = params[:formaPago]
        formaElegida = formaP.to_s.sub('-', ' ')
        forma = FormaPago.find_by_nombre(formaElegida)
        campos = forma.campo_forma_pagos
        render :json => campos
      end

    end 

	def realizarVenta
	  literal = params[:dataVenta]
	  hash = literal
	  hash = JSON.parse(hash.gsub('\"', '"'))
	  caja = ""
      loquesea = ""
      formaPago = ""
      formaPagoBD = ""
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
	        
	        formaPagoBD = "efectivo" if formaPago == "efectivo"

		    if formaPago == "debito"
		      formaPagoBD = "tarjeta debito"
		      numTDebito = hashPago["ntDebito"]
		    end

		    if formaPago == "credito"
		      formaPagoBD = "tarjeta credito"
		      numTCredito = hashPago["ntCredito"]
		      plazoCredito = hashPago["plazoTCredito"]
		    end

		    if formaPago == "oxxo"
		      formaPagoBD = "oxxo"
		      refOxxo = hashPago["refOxxo"]
		    end

		    if formaPago == "paypal"
		      formaPagoBD = "paypal"
		      refPaypal = hashPago["refPaypal"]
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
			@venta.caja = caja
			current_user.ventas << @venta
			#@venta.user = current_user
			itemSaved = true
			ventaFPCSaved = true
              
            formaP = FormaPago.find_by nombre: formaPagoBD

			#Se guarda la forma de pago y sus datos de compra
			#primero se liga la forma de pago con la venta
			ventaFP =VentaFormaPago.new
			@venta.venta_forma_pago = ventaFP
			formaP.venta_forma_pagos << ventaFP

			#Luego se rellenan los campos en base a los datos
     		formaP.campo_forma_pagos.each do |campo|
			 	  
			  ventaFPC = VentaFormaPagoCampo.new

			  if formaP.nombre == "tarjeta credito"
                ventaFPC.ValorCampo = numTCredito if campo.nombrecampo == "numero tarjeta"
                ventaFPC.ValorCampo = plazoCredito if campo.nombrecampo == "plazo credito"
              end

              if formaP.nombre == "tarjeta debito"
                ventaFPC.ValorCampo = numTDebito if campo.nombrecampo == "numero tarjeta"
              end

              if formaP.nombre == "oxxo"
                ventaFPC.ValorCampo = refOxxo if campo.nombrecampo == "referencia oxxo"
              end

              if formaP.nombre == "paypal"
                ventaFPC.ValorCampo = refPaypal if campo.nombrecampo == "referencia paypal"
              end

              #Se relacionan las formas de pago con los datos de capura.
              ventaFP.venta_forma_pago_campos << ventaFPC 
              campo.venta_forma_pago_campos << ventaFPC

			end

			#Aquí se recorre cada item de venta
			item.each do |itemVenta|
                
			  itemV = ItemVenta.new

	          
	          itemV.articulo = Articulo.find_by clave: itemVenta["codigo"]
	          itemV.cantidad = itemVenta["cantidad"]
              @venta.item_ventas << itemV
			end

            if @venta.save && ventaFP.save
              if itemSaved
			    flash[:notice] = "La venta se guardó exitosamente!"
			    redirect_to punto_venta_index_path
			  else
			    flash[:notice] = "Error al intentar guardar la venta"
			    redirect_to punto_venta_index_path
			  end
			else
			  flash[:notice] = "Error al intentar guardar la venta"
			  redirect_to punto_venta_index_path
			end

		  end
	    end
	  end
	end
end