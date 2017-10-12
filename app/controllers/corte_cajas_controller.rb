class CorteCajasController < ApplicationController
  
  def show
    if request.get?

      if current_user.caja_sucursal
      
	      #Obtengo todas las formas de pago para desglosar las ventas según la forma de pago
	      formas_de_pago = FormaPago.all

	      #este arreglo permitirá el almacenamiento de todas las ventas del día de la caja del usuario actual
	      @ventas_del_dia = []

	      @desglose_ventas = {}

	      #Primero obtengo todas las ventas que se hayan hecho el día de hoy y hasta el momento actual
	      ventas = current_user.ventas.where(created_at: Date.today.beginning_of_day..DateTime.now)

	      #Obtengo la caja de sucursal a la que está asignado el usuario
	      caja = current_user.caja_sucursal

	      #Se recorre cada venta con el fin de llenar el arreglo ventas_del_dia. Si la venta encontrada en la consulta pertenece
	      #a la caja asignada al usuario actual, entonces añade dicha venta al arreglo ventas_del_dia
	      ventas.each do |venta|
	        #if venta.caja_sucursal == caja
	          @ventas_del_dia << venta
	        #end
	      end

	      #Se obtienen los registros de formas de pago por cada venta del día de hoy
	      formas_pago = VentaFormaPago.where(created_at: Date.today.beginning_of_day..DateTime.now)

	      ventas_encontradas = []

	      #Aquí se llena el hash desglose_ventas, en primer lugar con las claves. Dichas claves corresponden
	      #a las formas de pago de las ventas del día de hoy
	      formas_pago.each do |forma_pago|
		    @desglose_ventas[forma_pago.forma_pago.nombre] = nil
		  end

	      #Recorremos ahora el hash desglose_ventas que hasta este momento contiene las claves con las formas de pago
	      #del día de hoy.
		  @desglose_ventas.each do |forma_pago, valor|
		  	#Ventas del dia contiene los objetos Venta que fueron creados en este día.
		  	#ventas_del_dia se recorre y analiza para verificar si su forma de pago coincide con la forma de pago analizada.
	        @ventas_del_dia.each do |venta_del_dia|
	          if venta_del_dia.venta_forma_pago.forma_pago.nombre == forma_pago
	          	#Si la forma de pago coincide con la analizada, entonces se añade la venta al arreglo ventas_encontradas
	          	ventas_encontradas << venta_del_dia
	          end

	          #Ahora se añade el arreglo ventas encontradas al hash desglose_ventas en la forma de pago analizada,
	          #de tal manera que el hash queda así por ejemplo:
	          #{"efectivo"=>[Objeto_Venta, Objeto_Venta]} donde cada Objeto_Venta representa a los objetos venta que cumplieron
	          #con el criterio de pertenecer a la forma de pago analizada (efectivo en el ejemplo)
	          @desglose_ventas[forma_pago] = ventas_encontradas
	        end

	        #esta variable almacena la suma de la sumatoria total de ventas en el rango de tiempo determinado
	        @sumatoria_ventas = Venta.where(created_at: Date.today.beginning_of_day..DateTime.now).sum(:montoVenta)

	        if @sumatoria_ventas == nil
	          @sumatoria_ventas = 0
	        end

		  end #fin de @desglose_ventas.each...

	      #Ahora se procede al análisis de los gastos salidos de la caja analizada. Los gastos pueden ser devoluciones
	      #o pagos.
	      #Primero obtenemos todos los gastos que se realizaron el día de hoy (o más bien hasta ahora)
	      gastos_hoy = current_user.negocio.where(created_at: Date.today.beginning_of_day..DateTime.now)
		  
		  #Este arreglo contendrá los objetos Gasto que cumplan con el criterio de pertenecer a la caja de sucursal analizada
	      gastos_caja = []

	      #Recorremos todos los gastos de hoy para discriminar los que pertenecen a la caja de sucursal analizada
	      gastos_hoy.each do |gasto_hoy|
	        
	        if gasto_hoy.caja_sucursal
	          #se añade el gasto encontrado al arreglo gastos_caja, si es que la caja de donde salió el gasto
	          #coincide con la caja analizada
	          if gasto_hoy.caja_sucursal == current_user.caja_sucursal
	            gastos_caja << gasto_hoy
	          end

	        end

	      end #fin de gastos_hoy.each...

	      #El arreglo pagos_devoluciones almacenará los pagos realizados por concepto de devolución en este caja analizada
	      @pagos_devoluciones = []

	      #El arreglo pagos_proveedores alamacenará los pagos realizados por concepto de compras a proveedores
	      @pagos_proveedores = []

	      #El arreglo pagos_gastos almacenará los pagos realizados por concepto de gastos generales
	      @pagos_gastos = []

	      #recorre todos los gastos realizados en la caja y discrimina por cada tipo diferente y llena los arreglos
	      gastos_caja.each do |gasto_caja|
	        
	        if gasto_caja.tipo == "Gasto general"
	          @pagos_gastos << gasto_caja
	        elsif gasto_caja.tipo == "compra"
	          @pagos_proveedores << gasto_caja
	        elsif gasto_caja.tipo == "devolucion"
	          @pagos_devoluciones << gasto_caja
	        end

	      end #Fin de gastos_caja.each...
	  else #else if current_user.caja_sucursal
	  	flash[:notice] = "El usuario no tiene asignada ninguna caja"
        redirect_to action: "index", controller: "ventas"
        
	  end

    end #fin de request.get?

  end #fin del método show

end #fin de la clase CorteCajasController
