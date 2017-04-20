class PuntoVentaController < ApplicationController
   #load_and_authorize_resource
    #after_filter { flash.discard if request.xhr? }
   # before_filter :authenticate_user!

	def index
      @formas_pago = FormaPago.all
      @pos = true
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

    #Este método se encarga de realizar la inserción de todos los datos
    #correspondientes a una venta.
	def realizarVenta
	  literal = params[:dataVenta]
	  hash = literal
	  hash = JSON.parse(hash.gsub('\"', '"'))
	  
	  caja = ""
	  cliente = ""
      formaPagoBD = ""
      nombreFormaPago = ""
      hashPago = {}
      
      #params contiene objetos hash y arreglos, por tanto es necesario
      #verificar si corresponde a uno u otro tipo de dato
	  #primer nivel...
	  hash.each do |item|
        #Si el item analizado responde al método key?, entonces es un hash
	    if item.respond_to?(:key?)
	      #Si el hash tiene la llave "caja", entonces asigno su valor a la
	      #variable caja
	  	  if item.has_key?("caja")
		    caja = item["caja"]
		  end

		  if item.has_key?("id_cliente")
            cliente = item["id_cliente"]
		  end
	    end
	        	
	    if item.is_a?(Array)
	      #Si el item evaluado en el array tiene la llave "formaPago",
	      #entonces implica que este es el hash con los datos de 
	      #forma de pago.
	      if item[0].has_key?("formaPago")
	        
	        #Guarda el hash con los datos de la forma de pago
	        #en la variable hashPago
	        hashPago = item[0]

	        #la variable formaPago recupera la forma de pago elegida.
	        nombreFormaPago = hashPago["formaPago"]

	      end
	      
	      if item[0].has_key?("importe")
            
            
            montoVenta = 0
	        
	        #recorre cada item de venta. Después extrae y suma el valor
	        #de los importes individuales para obtener el importe total.

	        item.each do |itemVenta|
			  #La variable montoVenta guarda la sumatoria del importe total  
			  montoVenta += itemVenta["importe"].to_f

			end

            #Se crea un objeto Venta de base de datos y se añade la fecha actual
            #el monto total de la venta, la caja, la sucursal y el cliente
			@venta = Venta.new
			@venta.fechaVenta = Time.now
			@venta.montoVenta = montoVenta
			@venta.caja = caja
			unless cliente.eql?("")
              Cliente.find(cliente).ventas << @venta
            else
              Cliente.find_by  nombre: "general"
			end

			
			current_user.ventas << @venta
			current_user.sucursal.ventas << @venta
			current_user.negocio.ventas << @venta
			#@venta.user = current_user
			itemSaved = true
			ventaFPCSaved = true
              
            formaPagoBD = FormaPago.find_by nombre: nombreFormaPago

			#Se guarda la forma de pago y sus datos de compra
			#primero se liga forma de pago de la venta con la Forma de Pago
			#elegida por el usuario
			recordVentaFormaPago =VentaFormaPago.new
			
            
            #Se liga la forma de pago con la venta, a través del objeto
            #recordVentaFormaPago (Forma de pago de la venta)
			@venta.venta_forma_pago = recordVentaFormaPago

			#Una forma de pago, esta relacionada con una venta
			#por medio de la tabla venta_forma_pagos. En consecuencia,
			#el objeto recordVentaFormaPago se asigna a la forma de pago elegida.
			formaPagoBD.venta_forma_pagos << recordVentaFormaPago

			#Recorre los campos encontrados en la base de datos para esta
			#forma de pago.
     		formaPagoBD.campo_forma_pagos.each do |campo|
			  
			  #por cada campo encontrado, crea un objeto VentaFormaPagoCampo
			  #este objeto relacionará el campo de la forma de pago con la
			  #información efectivamente capturada en la venta.
			  #En otras palabras, este es el objeto que finalmente guardará
			  #individualmente, los datos de la forma de pago de una venta
			  #concreta.
			  ventaFormaPagoCampo = VentaFormaPagoCampo.new
              
              # Primero se relaciona la forma de pago elegida en la venta,
              # con los campos capturados.
              # recordVentaFormaPago contiene la forma de pago en particular que fue elegida
              # en la venta y ventaFormaPagoCampo contendrá el dato de un campo
              # específico de la forma de pago elegida en la venta.
              recordVentaFormaPago.venta_forma_pago_campos << ventaFormaPagoCampo

              #También se relaciona el objeto ventaFormaPagoCampo (que tiene
              #el dato de un campo específico de la forma de pago elegida en
              #la venta) con cada uno de los campos encontrados para la forma
              #de pago elegida en la venta.
              campo.venta_forma_pago_campos << ventaFormaPagoCampo


              #hashPago contiene la información capturada de la forma de pago
              #elegida.
              hashPago.each do |llave, valor|

                if llave.eql? campo.nombrecampo.to_s
                  ventaFormaPagoCampo.ValorCampo = valor
                  
                  #Se evalua que los valores de los campos de la forma de pago
                  #elegida hayan sido guardados adecuadamente.
                  if ventaFormaPagoCampo.save
                    ventaFPCSaved && true
                  else
                  	ventaFPCSaved && false
                  end

                end

              end

			end #Termina recorrido de los campos encontrados para la forma de pago elegida

			#Aquí se recorre cada item de venta
			item.each do |itemVenta|
                
			  itemV = ItemVenta.new

	          
	          itemV.articulo = Articulo.find_by clave: itemVenta["codigo"]
	          itemV.cantidad = itemVenta["cantidad"]
              @venta.item_ventas << itemV
              itemV.articulo.existencia = itemV.articulo.existencia - itemV.cantidad
			end
            
            #Para cerrar la venta, primero evalúa mediante la variable booleana
            #ventaFPCSaved, que todos los campos de la forma de pago fueron
            #guardados correctamente en la base de datos
            if ventaFPCSaved 

              @venta.status = "activo"

              #Si los campos fueron guardados correctamente, procede a guardar la venta
              if @venta.save && recordVentaFormaPago.save
	            if itemSaved
			      flash[:notice] = "La venta se guardó exitosamente!"
			      redirect_to punto_venta_index_path
			    else
			      flash[:notice] = "Error al intentar guardar la venta"
			      redirect_to punto_venta_index_path
			    end
			  #Si la venta no fue guardada correctamente  
			  else
			    flash[:notice] = "Error al intentar guardar la venta"
			    redirect_to punto_venta_index_path
			  end
			#Si los campos de la forma de pago no fueron guardados correctamente.
            else
              flash[:notice] = "Error al intentar guardar la venta"
			  redirect_to punto_venta_index_path
            end #Termina guardado de la venta

		  end #Termina la evaluación de la llave importe

	    end #Termina la evaluación de si es array

	  end #Termina el recorrido de los datos recibidos.

	end #Termina el método realizar venta

end #Termina la clase PuntoVentaController