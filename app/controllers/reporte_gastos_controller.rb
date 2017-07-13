class ReporteGastosController < ApplicationController
  
  def reporte_gastos

  	if request.get?
      @fecha = Date.today.strftime("%d/%m/%Y")
  	  
  	  @gastos_negocio_mes = current_user.negocio.gastos.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)
  	  @gastos_negocio_hoy = current_user.negocio.gastos.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)

      #Desglose de gastos del negocio      
      @compras_negocio_mes = current_user.negocio.compras.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto_compra)
      @compras_negocio_hoy = current_user.negocio.compras.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto_compra)
        

      #Los pagos realizados a proveedores por concepto de compras. No todas las compras registradas están necesariamente pagadas.
      #ni todos los pagos realizados a proveedores son por concepto de compras. Los registros cuyo campo compra_id esta nil, se descarta de esta sumatoria
      @pagos_compras_negocio_mes = current_user.negocio.pago_proveedores.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).where.not('compra_id'=>nil).sum(:monto)
      @pagos_compras_negocio_hoy = current_user.negocio.pago_proveedores.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).where.not('compra_id'=>nil).sum(:monto)

      #pagos pendientes a proveedores
      @pagos_pendientes_negocio_mes = current_user.negocio.pago_pendientes.where(fecha_vencimiento: Date.today.beginning_of_month..Date.today.end_of_month).sum(:saldo)
      @pagos_pendientes_negocio_hoy = current_user.negocio.pago_pendientes.where(fecha_vencimiento: Date.today.beginning_of_day..Date.today.end_of_day).sum(:saldo)

      #Gastos generales o administrativos que no son compras propiamente.
      @gastos_generales_negocio_mes = current_user.negocio.gasto_generals.where(created_at:Date.today.beginning_of_month.to_datetime..Date.today.end_of_day.to_datetime).sum(:monto)
      @gastos_generales_negocio_hoy = current_user.negocio.gasto_generals.where(created_at:Date.today.beginning_of_day.to_datetime..Date.today.end_of_day.to_datetime).sum(:monto)

      compras_canceladas_negocio_mes = current_user.negocio.compra_canceladas.where(created_at:Date.today.beginning_of_month.to_datetime..Date.today.end_of_day.to_datetime)
      compras_canceladas_negocio_hoy = current_user.negocio.compra_canceladas.where(created_at:Date.today.beginning_of_day.to_datetime..Date.today.end_of_day.to_datetime)

      @suma_compras_canceladas_negocio_mes = 0
      @suma_compras_canceladas_negocio_hoy = 0

      compras_canceladas_negocio_mes.each do |compra_cancelada|   

        @suma_compras_canceladas_negocio_mes += compra_cancelada.compra.monto_compra

      end

      compras_canceladas_negocio_hoy.each do |compra_cancelada|
  
        @suma_compras_canceladas_negocio_hoy += compra_cancelada.compra.monto_compra

      end

      ##################################################################################################################
      #reporte de gastos de la sucursal
      @gastos_sucursal_mes = current_user.sucursal.gastos.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)
  	  @gastos_sucursal_hoy = current_user.sucursal.gastos.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)
      
      #Desglose de gastos de la sucursal      
      @compras_sucursal_mes = current_user.sucursal.compras.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto_compra)
      @compras_sucursal_hoy = current_user.sucursal.compras.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto_compra)
        

      #Los pagos realizados a proveedores por concepto de compras. No todas las compras registradas están necesariamente pagadas.
      #ni todos los pagos realizados a proveedores son por concepto de compras. Los registros cuyo campo compra_id esta nil, se descarta de esta sumatoria
      @pagos_compras_sucursal_mes = current_user.sucursal.pago_proveedores.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).where.not('compra_id'=>nil).sum(:monto)
      @pagos_compras_sucursal_hoy= current_user.sucursal.pago_proveedores.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).where.not('compra_id'=>nil).sum(:monto)

      #pagos pendientes a proveedores
      @pagos_pendientes_sucursal_mes = current_user.sucursal.pago_pendientes.where(fecha_vencimiento: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_month).sum(:saldo)
      @pagos_pendientes_sucursal_hoy = current_user.sucursal.pago_pendientes.where(fecha_vencimiento: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:saldo)

      #Gastos generales o administrativos que no son compras propiamente.
      @gastos_generales_sucursal_mes = current_user.sucursal.gasto_generals.where(created_at:Date.today.beginning_of_month.to_datetime..Date.today.end_of_day.to_datetime).sum(:monto)
      @gastos_generales_sucursal_hoy = current_user.sucursal.gasto_generals.where(created_at:Date.today.beginning_of_day.to_datetime..Date.today.end_of_day.to_datetime).sum(:monto)

      compras_canceladas_sucursal_mes = current_user.sucursal.compra_canceladas.where(created_at:Date.today.beginning_of_month.to_datetime..Date.today.end_of_day.to_datetime)
      compras_canceladas_sucursal_hoy = current_user.sucursal.compra_canceladas.where(created_at:Date.today.beginning_of_day.to_datetime..Date.today.end_of_day.to_datetime)
    
      @suma_compras_canceladas_sucursal_mes = 0
      @suma_compras_canceladas_sucursal_hoy = 0

      compras_canceladas_sucursal_mes.each do |compra_cancelada|   

        @suma_compras_canceladas_sucursal_mes += compra_cancelada.compra.monto_compra

      end

      compras_canceladas_sucursal_hoy.each do |compra_cancelada|
  
        @suma_compras_canceladas_sucursal_hoy += compra_cancelada.compra.monto_compra

      end
   

      #Este código devuelve datos exclusivos para el rol de administrador. Lo que hace es almacenar la información
      #de cada sucursal y guardarla en el hash @sucursales
      @sucursales = Hash.new
      i = 0

      current_user.negocio.sucursals.each do |sucursal|
      	sucursalActual = Hash.new
      	sucursalActual[:nombre] = sucursal.nombre
      	sucursalActual[:gastos_del_mes] = sucursal.gastos.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)
      	sucursalActual[:gastos_del_dia] = sucursal.gastos.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)
        sucursalActual[:compras_del_mes] = sucursal.compras.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto_compra)
        sucursalActual[:compras_de_hoy] = sucursal.compras.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto_compra)
        sucursalActual[:pagos_compras_mes] = sucursal.pago_proveedores.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).where.not('compra_id'=>nil).sum(:monto)
        sucursalActual[:pagos_compras_hoy] = sucursal.pago_proveedores.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).where.not('compra_id'=>nil).sum(:monto)
        sucursalActual[:pagos_pendientes_mes] = sucursal.pago_pendientes.where(fecha_vencimiento: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_month).sum(:saldo)
        sucursalActual[:pagos_pendientes_hoy] = sucursal.pago_pendientes.where(fecha_vencimiento: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:saldo)
        sucursalActual[:gastos_generales_del_mes] = sucursal.gasto_generals.where(created_at:Date.today.beginning_of_month.to_datetime..Date.today.end_of_day.to_datetime).sum(:monto)
        sucursalActual[:gastos_generales_de_hoy] = sucursal.gasto_generals.where(created_at:Date.today.beginning_of_day.to_datetime..Date.today.end_of_day.to_datetime).sum(:monto)

        compras_canceladas_mes = sucursal.compra_canceladas.where(created_at:Date.today.beginning_of_month.to_datetime..Date.today.end_of_day.to_datetime)
        compras_canceladas_hoy = sucursal.compra_canceladas.where(created_at:Date.today.beginning_of_day.to_datetime..Date.today.end_of_day.to_datetime)
      
        @suma_compras_canceladas_mes = 0
        @suma_compras_canceladas_hoy = 0

        compras_canceladas_mes.each do |compra_cancelada|   

          @suma_compras_canceladas_mes += compra_cancelada.compra.monto_compra

        end

        compras_canceladas_hoy.each do |compra_cancelada|
    
          @suma_compras_canceladas_hoy += compra_cancelada.compra.monto_compra

        end  

        sucursalActual[:compras_canceladas_del_mes] = @suma_compras_canceladas_mes 
        sucursalActual[:compras_canceladas_de_hoy] =  @suma_compras_canceladas_hoy

        @sucursales["sucursal#{i}"] = sucursalActual
        i += 1
      end
  	end

  	if request.post?
      
      fecha_reporte = DateTime.parse(params[:fecha_reporte])
      @fecha = fecha_reporte.strftime("%d/%m/%Y")

      @gastos_negocio_mes = current_user.negocio.gastos.where(created_at: fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.to_datetime.end_of_month).sum(:monto)
      @gastos_negocio_hoy = current_user.negocio.gastos.where(created_at: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.to_datetime.end_of_day).sum(:monto)

      #Desglose de gastos del negocio      
      @compras_negocio_mes = current_user.negocio.compras.where(created_at: fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.to_datetime.end_of_month).sum(:monto_compra)
      @compras_negocio_hoy = current_user.negocio.compras.where(created_at: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.to_datetime.end_of_day).sum(:monto_compra)
        

      #Los pagos realizados a proveedores por concepto de compras. No todas las compras registradas están necesariamente pagadas.
      #ni todos los pagos realizados a proveedores son por concepto de compras. Los registros cuyo campo compra_id esta nil, se descarta de esta sumatoria
      @pagos_compras_negocio_mes = current_user.negocio.pago_proveedores.where(created_at: fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.to_datetime.end_of_month).where.not('compra_id'=>nil).sum(:monto)
      @pagos_compras_negocio_hoy = current_user.negocio.pago_proveedores.where(created_at: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.to_datetime.end_of_day).where.not('compra_id'=>nil).sum(:monto)

      #pagos pendientes a proveedores
      @pagos_pendientes_negocio_mes = current_user.negocio.pago_pendientes.where(fecha_vencimiento: fecha_reporte.beginning_of_month..fecha_reporte.end_of_month).sum(:saldo)
      @pagos_pendientes_negocio_hoy = current_user.negocio.pago_pendientes.where(fecha_vencimiento: fecha_reporte.beginning_of_day..fecha_reporte.end_of_day).sum(:saldo)

      #Gastos generales o administrativos que no son compras propiamente.
      @gastos_generales_negocio_mes = current_user.negocio.gasto_generals.where(created_at: fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.end_of_month.to_datetime).sum(:monto)
      @gastos_generales_negocio_hoy = current_user.negocio.gasto_generals.where(created_at: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.end_of_day.to_datetime).sum(:monto)

      compras_canceladas_negocio_mes = current_user.negocio.compra_canceladas.where(created_at: fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.end_of_month.to_datetime)
      compras_canceladas_negocio_hoy = current_user.negocio.compra_canceladas.where(created_at: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.end_of_day.to_datetime)

      @suma_compras_canceladas_negocio_mes = 0
      @suma_compras_canceladas_negocio_hoy = 0

      compras_canceladas_negocio_mes.each do |compra_cancelada|   

        @suma_compras_canceladas_negocio_mes += compra_cancelada.compra.monto_compra

      end

      compras_canceladas_negocio_hoy.each do |compra_cancelada|
  
        @suma_compras_canceladas_negocio_hoy += compra_cancelada.compra.monto_compra

      end

      ##################################################################################################################
      #reporte de gastos de la sucursal
      @gastos_sucursal_mes = current_user.sucursal.gastos.where(created_at: fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.to_datetime.end_of_month).sum(:monto)
      @gastos_sucursal_hoy = current_user.sucursal.gastos.where(created_at: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.to_datetime.end_of_day).sum(:monto)
      
      #Desglose de gastos de la sucursal      
      @compras_sucursal_mes = current_user.sucursal.compras.where(created_at: fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.to_datetime.end_of_month).sum(:monto_compra)
      @compras_sucursal_hoy = current_user.sucursal.compras.where(created_at: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.to_datetime.end_of_day).sum(:monto_compra)
        

      #Los pagos realizados a proveedores por concepto de compras. No todas las compras registradas están necesariamente pagadas.
      #ni todos los pagos realizados a proveedores son por concepto de compras. Los registros cuyo campo compra_id esta nil, se descarta de esta sumatoria
      @pagos_compras_sucursal_mes = current_user.sucursal.pago_proveedores.where(created_at: fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.to_datetime.end_of_month).where.not('compra_id'=>nil).sum(:monto)
      @pagos_compras_sucursal_hoy= current_user.sucursal.pago_proveedores.where(created_at: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.to_datetime.end_of_day).where.not('compra_id'=>nil).sum(:monto)

      #pagos pendientes a proveedores
      @pagos_pendientes_sucursal_mes = current_user.sucursal.pago_pendientes.where(fecha_vencimiento: fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.to_datetime.end_of_month).sum(:saldo)
      @pagos_pendientes_sucursal_hoy = current_user.sucursal.pago_pendientes.where(fecha_vencimiento: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.to_datetime.end_of_day).sum(:saldo)

      #Gastos generales o administrativos que no son compras propiamente.
      @gastos_generales_sucursal_mes = current_user.sucursal.gasto_generals.where(created_at: fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.end_of_month.to_datetime).sum(:monto)
      @gastos_generales_sucursal_hoy = current_user.sucursal.gasto_generals.where(created_at: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.end_of_day.to_datetime).sum(:monto)

      compras_canceladas_sucursal_mes = current_user.sucursal.compra_canceladas.where(created_at: fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.end_of_month.to_datetime)
      compras_canceladas_sucursal_hoy = current_user.sucursal.compra_canceladas.where(created_at: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.end_of_day.to_datetime)
    
      @suma_compras_canceladas_sucursal_mes = 0
      @suma_compras_canceladas_sucursal_hoy = 0

      compras_canceladas_sucursal_mes.each do |compra_cancelada|   

        @suma_compras_canceladas_sucursal_mes += compra_cancelada.compra.monto_compra

      end

      compras_canceladas_sucursal_hoy.each do |compra_cancelada|
  
        @suma_compras_canceladas_sucursal_hoy += compra_cancelada.compra.monto_compra

      end
   

      #Este código devuelve datos exclusivos para el rol de administrador. Lo que hace es almacenar la información
      #de cada sucursal y guardarla en el hash @sucursales
      @sucursales = Hash.new
      i = 0

      current_user.negocio.sucursals.each do |sucursal|
        sucursalActual = Hash.new
        sucursalActual[:nombre] = sucursal.nombre
        sucursalActual[:gastos_del_mes] = sucursal.gastos.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_month).sum(:monto)
        sucursalActual[:gastos_del_dia] = sucursal.gastos.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)
        sucursalActual[:compras_del_mes] = sucursal.compras.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_month).sum(:monto_compra)
        sucursalActual[:compras_de_hoy] = sucursal.compras.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto_compra)
        sucursalActual[:pagos_compras_mes] = sucursal.pago_proveedores.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_month).where.not('compra_id'=>nil).sum(:monto)
        sucursalActual[:pagos_compras_hoy] = sucursal.pago_proveedores.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).where.not('compra_id'=>nil).sum(:monto)
        sucursalActual[:pagos_pendientes_mes] = sucursal.pago_pendientes.where(fecha_vencimiento: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_month).sum(:saldo)
        sucursalActual[:pagos_pendientes_hoy] = sucursal.pago_pendientes.where(fecha_vencimiento: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:saldo)
        sucursalActual[:gastos_generales_del_mes] = sucursal.gasto_generals.where(created_at:Date.today.beginning_of_month.to_datetime..Date.today.end_of_month.to_datetime).sum(:monto)
        sucursalActual[:gastos_generales_de_hoy] = sucursal.gasto_generals.where(created_at:Date.today.beginning_of_day.to_datetime..Date.today.end_of_day.to_datetime).sum(:monto)

        compras_canceladas_mes = sucursal.compra_canceladas.where(created_at:Date.today.beginning_of_month.to_datetime..Date.today.end_of_month.to_datetime)
        compras_canceladas_hoy = sucursal.compra_canceladas.where(created_at:Date.today.beginning_of_day.to_datetime..Date.today.end_of_day.to_datetime)
      
        @suma_compras_canceladas_mes = 0
        @suma_compras_canceladas_hoy = 0

        compras_canceladas_mes.each do |compra_cancelada|   

          @suma_compras_canceladas_mes += compra_cancelada.compra.monto_compra

        end

        compras_canceladas_hoy.each do |compra_cancelada|
    
          @suma_compras_canceladas_hoy += compra_cancelada.compra.monto_compra

        end  

        sucursalActual[:compras_canceladas_del_mes] = @suma_compras_canceladas_mes 
        sucursalActual[:compras_canceladas_de_hoy] =  @suma_compras_canceladas_hoy

        @sucursales["sucursal#{i}"] = sucursalActual
        i += 1
      end
  	end

  end
end
