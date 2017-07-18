class PuntoVentaController < ApplicationController
   #load_and_authorize_resource
    #after_filter { flash.discard if request.xhr? }
   # before_filter :authenticate_user!

	def index
    if current_user.caja_sucursal
    @formas_pago = FormaPago.all
    @cajas = current_user.sucursal.caja_sucursals
    @cajaAsignada = CajaSucursal.where("user_id = ?", current_user.id).take
    @pos = true
    if params[:venta]
      @venta = Venta.find(params[:venta])
      @itemsVenta = @venta.item_ventas
      @nombreNegocio = current_user.negocio.nombre
      @nombreFiscalNegocio = current_user.negocio.datos_fiscales_negocio ? current_user.negocio.datos_fiscales_negocio.nombreFiscal : " "
      @rfcNegocio = current_user.negocio.datos_fiscales_negocio ? current_user.negocio.datos_fiscales_negocio.rfc : " "
      @direccionFiscalNegocio = ""
      @direccionSucursal = ""
      @sucursal = current_user.sucursal.nombre
      @folio = @venta.folio
       
      if current_user.negocio.datos_fiscales_negocio
        dirFiscal = current_user.negocio.datos_fiscales_negocio
        calle = dirFiscal.calle
        numExterior = dirFiscal.numExterior
        numInterior = "-"+dirFiscal.numInterior ? dirFiscal.numInterior : " "
        colonia = dirFiscal.colonia ? dirFiscal.colonia : " "
        cp = dirFiscal.codigo_postal ? dirFiscal.codigo_postal : " "
        municipio = dirFiscal.municipio ? dirFiscal.municipio : " "
        delegacion = dirFiscal.delegacion ? dirFiscal.delegacion : " "
        estado = dirFiscal.estado ? dirFiscal.estado : " "

        @direccionFiscalNegocio << calle << " " << numExterior << numInterior << " " << colonia << " " << cp  << " " << municipio << " " << delegacion << " " << estado
      end

      if current_user.sucursal
        sucursal = current_user.sucursal
        calleSuc = sucursal.calle ? sucursal.calle : " "
        numExteriorSuc = sucursal.numExterior ? sucursal.numExterior : " "
        numInteriorSuc = sucursal.numInterior ? sucursal.numInterior : " "
        coloniaSuc = sucursal.colonia ? sucursal.colonia : " "
        cpSuc = sucursal.codigo_postal ? sucursal.codigo_postal : " "
        municipioSuc = sucursal.municipio ? sucursal.municipio : " "
        delegacionSuc = sucursal.delegacion ? sucursal.delegacion : " "
        estadoSuc = sucursal.estado ? sucursal.estado : " "
        @direccionSucursal << calleSuc << " " << numExteriorSuc << " " << numInteriorSuc << " " << coloniaSuc << " " << cpSuc  << " " << municipioSuc << " " << delegacionSuc << " " << estadoSuc
      end

      @cliente = ""
      if @venta.cliente
     
        @cliente = @venta.cliente.nombre_completo

	    else
	      @cliente = "General"
	    end
        
      nomCajero = @venta.user.perfil ? @venta.user.perfil.nombre : "" 
  	  apePatCajero = @venta.user.perfil ? @venta.user.perfil.ape_paterno: ""
	    apeMatCajero = @venta.user.perfil ? @venta.user.perfil.ape_materno: ""
      @cajero = nomCajero << " "
      @cajero << apePatCajero 
      @cajero << " "
      @cajero << apeMatCajero

      @formaPago = @venta.venta_forma_pago.forma_pago.nombre
      
      if @venta.venta_forma_pago.venta_forma_pago_campos
        @camposFormaPago = @venta.venta_forma_pago.venta_forma_pago_campos
      end
    end
    else
      flash[:notice] = "No ha asignado una caja de venta a este usuario, no puede acceder al módulo de punto de venta. Verifique con el administrador del sistema."
      redirect_to root_path
    end
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

          #busca la última venta agregada en la sucursal y obtiene su consecutivo. Si no encuentra
          #ninguna venta, entonces asigna el número 1.
          consecutivo = 0

          if current_user.sucursal.ventas.last
            consecutivo = current_user.sucursal.ventas.last.consecutivo

            if consecutivo
              consecutivo += 1
            end
          else
            consecutivo = 1
          end

          #Se crea un objeto Venta de base de datos y se añade la fecha actual
          #el monto total de la venta, la caja, la sucursal y el cliente
          @venta = Venta.new
          @venta.fechaVenta = Time.now
          @venta.montoVenta = montoVenta
          
          unless cliente.eql?("")
            Cliente.find(cliente).ventas << @venta
          else
            Cliente.where(nombre: "General", negocio: current_user.negocio).take.ventas << @venta
          end

          current_user.ventas << @venta
          current_user.sucursal.ventas << @venta
          current_user.negocio.ventas << @venta
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
            itemV.precio_venta = itemV.articulo.precioVenta
            itemV.cantidad = itemVenta["cantidad"]
            monto_item = itemV.cantidad * itemV.precio_venta
            itemV.monto = monto_item
            @venta.item_ventas << itemV
            itemV.articulo.existencia = itemV.articulo.existencia - itemV.cantidad

            itemV.articulo.save

          end

          #Para cerrar la venta, primero evalúa mediante la variable booleana
          #ventaFPCSaved, que todos los campos de la forma de pago fueron
          #guardados correctamente en la base de datos
          if ventaFPCSaved 

            @venta.status = "Activa"

            claveSucursal = current_user.sucursal.clave
            @venta.consecutivo = consecutivo
            folio = claveSucursal + "V"
            folio << consecutivo.to_s
            @venta.folio = folio

            #En caso de que el tipo de pago haya sido efectivo, se hace un registro de movimiento
            #en la caja de venta elegida por el usuario.

            if nombreFormaPago.eql?("efectivo")
              movimiento_caja_suc = MovimientoCajaSucursal.new(:entrada=>@venta.montoVenta, :tipo_pago=>"efectivo")

              #Se obtiene el registro de la caja de venta elegida o asignada.
              cajaBD = CajaSucursal.find(caja)

              current_user.movimiento_caja_sucursals << movimiento_caja_suc
              current_user.sucursal.movimiento_caja_sucursals << movimiento_caja_suc
              current_user.negocio.movimiento_caja_sucursals << movimiento_caja_suc
              @venta.movimiento_caja_sucursal = movimiento_caja_suc
              cajaBD.movimiento_caja_sucursals << movimiento_caja_suc
              cajaBD.ventas << @venta

              movimiento_caja_suc.save

              saldoActualCaja = cajaBD.saldo

              saldoActualizado = saldoActualCaja + @venta.montoVenta
              cajaBD.saldo = saldoActualizado
              cajaBD.save
              
            #Si el tipo de pago no es efectivo, se registra el movimiento en la caja con el nombre de tipo de pago
            #pero no se añade al saldo de la caja de venta
            else 

              movimiento_caja_suc = MovimientoCajaSucursal.new(:entrada=>@venta.montoVenta, :tipo_pago=>nombreFormaPago)

              #Se obtiene el registro de la caja de venta elegida o asignada.
              cajaBD = CajaSucursal.find(caja)

              current_user.movimiento_caja_sucursals << movimiento_caja_suc
              current_user.sucursal.movimiento_caja_sucursals << movimiento_caja_suc
              current_user.negocio.movimiento_caja_sucursals << movimiento_caja_suc
              @venta.movimiento_caja_sucursal = movimiento_caja_suc
              cajaBD.movimiento_caja_sucursals << movimiento_caja_suc
              cajaBD.ventas << @venta

              movimiento_caja_suc.save
            end

            #Si los campos fueron guardados correctamente, procede a guardar la venta
            if @venta.save && recordVentaFormaPago.save
              if itemSaved
              flash[:notice] = "La venta se guardó exitosamente!"
              redirect_to action: "index", venta: @venta
			        #redirect_to punto_venta_index_path(:venta=> @venta)
			        else
                flash[:notice] = "Error al intentar guardar la venta"
                redirect_to punto_venta_index_path
              end
			      #Si la venta no fue gfoliouardada correctamente  
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