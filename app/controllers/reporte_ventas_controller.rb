class ReporteVentasController < ApplicationController
  def reporte_ventas
    @ventas = current_user.negocio.ventas.where(fechaVenta: @fechaInicial..@fechaFinal)
  	if request.get?

      @fecha = Date.today.strftime("%d/%m/%Y")
  	  
  	  @ventas_negocio_mes = current_user.negocio.ventas.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).sum(:montoVenta)
  	  @ventas_negocio_hoy = current_user.negocio.ventas.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:montoVenta)
  	  
  	  @devoluciones_negocio_mes = current_user.negocio.venta_canceladas.where(created_at:  Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)
  	  @devoluciones_negocio_hoy = current_user.negocio.venta_canceladas.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)
      
      @remanente_negocio_mes = @ventas_negocio_mes - @devoluciones_negocio_mes
      @remanente_negocio_hoy = @ventas_negocio_hoy - @devoluciones_negocio_hoy

      #reporte de ventas de la sucursal
      @ventas_sucursal_mes = current_user.sucursal.ventas.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).sum(:montoVenta)
  	  @ventas_sucursal_hoy = current_user.sucursal.ventas.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:montoVenta)
  	  
  	  @devoluciones_sucursal_mes = current_user.sucursal.venta_canceladas.where(created_at:  Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)
  	  @devoluciones_sucursal_hoy = current_user.sucursal.venta_canceladas.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)
      
      @remanente_sucursal_mes = @ventas_sucursal_mes - @devoluciones_sucursal_mes
      @remanente_sucursal_hoy = @ventas_sucursal_hoy - @devoluciones_sucursal_hoy


      @sucursales = Hash.new
      i = 0
      current_user.negocio.sucursals.each do |sucursal|
      	sucursalActual = Hash.new
      	sucursalActual[:nombre] = sucursal.nombre
      	sucursalActual[:venta_del_mes] = sucursal.ventas.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).sum(:montoVenta)
      	sucursalActual[:venta_del_dia] = sucursal.ventas.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:montoVenta)
      	sucursalActual[:devoluciones_del_mes] = sucursal.venta_canceladas.where(created_at:  Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)
      	sucursalActual[:devoluciones_del_dia] = sucursal.venta_canceladas.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)

        venta_del_mes = sucursal.ventas.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).sum(:montoVenta)
      	venta_del_dia = sucursal.ventas.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:montoVenta)
      	devoluciones_del_mes = sucursal.venta_canceladas.where(created_at:  Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)
      	devoluciones_del_dia = sucursal.venta_canceladas.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)

        venta_remanente_mes = venta_del_mes.to_f - devoluciones_del_mes.to_f
        venta_remanente_dia = venta_del_dia.to_f - devoluciones_del_dia.to_f

      	sucursalActual[:remanente_del_mes] = venta_remanente_mes
      	sucursalActual[:remanente_del_dia] = venta_remanente_dia

        @sucursales["sucursal#{i}"] = sucursalActual
        i += 1
      end
  	end

  	if request.post?

      fecha_reporte = DateTime.parse(params[:fecha_reporte])
      @fecha = fecha_reporte.strftime("%d/%m/%Y")
      
      @ventas_negocio_mes = current_user.negocio.ventas.where(created_at: fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.to_datetime.end_of_month).sum(:montoVenta)
      @ventas_negocio_hoy = current_user.negocio.ventas.where(created_at: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.to_datetime.end_of_day).sum(:montoVenta)
      
      @devoluciones_negocio_mes = current_user.negocio.venta_canceladas.where(created_at:  fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.to_datetime.end_of_month).sum(:monto)
      @devoluciones_negocio_hoy = current_user.negocio.venta_canceladas.where(created_at: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.to_datetime.end_of_day).sum(:monto)
      
      @remanente_negocio_mes = @ventas_negocio_mes - @devoluciones_negocio_mes
      @remanente_negocio_hoy = @ventas_negocio_hoy - @devoluciones_negocio_hoy

      #reporte de ventas de la sucursal
      @ventas_sucursal_mes = current_user.sucursal.ventas.where(created_at: fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.to_datetime.end_of_month).sum(:montoVenta)
      @ventas_sucursal_hoy = current_user.sucursal.ventas.where(created_at: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.to_datetime.end_of_day).sum(:montoVenta)
      
      @devoluciones_sucursal_mes = current_user.sucursal.venta_canceladas.where(created_at:  fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.to_datetime.end_of_month).sum(:monto)
      @devoluciones_sucursal_hoy = current_user.sucursal.venta_canceladas.where(created_at: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.to_datetime.end_of_day).sum(:monto)
      
      @remanente_sucursal_mes = @ventas_sucursal_mes - @devoluciones_sucursal_mes
      @remanente_sucursal_hoy = @ventas_sucursal_hoy - @devoluciones_sucursal_hoy


      @sucursales = Hash.new
      i = 0
      current_user.negocio.sucursals.each do |sucursal|
        sucursalActual = Hash.new
        sucursalActual[:nombre] = sucursal.nombre
        sucursalActual[:venta_del_mes] = sucursal.ventas.where(created_at: fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.to_datetime.end_of_month).sum(:montoVenta)
        sucursalActual[:venta_del_dia] = sucursal.ventas.where(created_at: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.to_datetime.end_of_day).sum(:montoVenta)
        sucursalActual[:devoluciones_del_mes] = sucursal.venta_canceladas.where(created_at:  fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.to_datetime.end_of_month).sum(:monto)
        sucursalActual[:devoluciones_del_dia] = sucursal.venta_canceladas.where(created_at: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.to_datetime.end_of_day).sum(:monto)

        venta_del_mes = sucursal.ventas.where(created_at: fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.to_datetime.end_of_month).sum(:montoVenta)
        venta_del_dia = sucursal.ventas.where(created_at: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.to_datetime.end_of_day).sum(:montoVenta)
        devoluciones_del_mes = sucursal.venta_canceladas.where(created_at:  fecha_reporte.beginning_of_month.to_datetime..fecha_reporte.to_datetime.end_of_month).sum(:monto)
        devoluciones_del_dia = sucursal.venta_canceladas.where(created_at: fecha_reporte.beginning_of_day.to_datetime..fecha_reporte.to_datetime.end_of_day).sum(:monto)

        venta_remanente_mes = venta_del_mes.to_f - devoluciones_del_mes.to_f
        venta_remanente_dia = venta_del_dia.to_f - devoluciones_del_dia.to_f

        sucursalActual[:remanente_del_mes] = venta_remanente_mes
        sucursalActual[:remanente_del_dia] = venta_remanente_dia

        @sucursales["sucursal#{i}"] = sucursalActual
        i += 1
      end

  	end

  end
end
