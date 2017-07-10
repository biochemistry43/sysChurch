class ReporteGastosController < ApplicationController
  
  def reporte_gastos

  	if request.get?
  	  
  	  @gastos_negocio_mes = current_user.negocio.gastos.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)
  	  @gastos_negocio_hoy = current_user.negocio.gastos.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)

      #reporte de gastos de la sucursal
      @gastos_sucursal_mes = current_user.sucursal.gastos.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)
  	  @gastos_sucursal_hoy = current_user.sucursal.gastos.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)

      @sucursales = Hash.new
      i = 0
      current_user.negocio.sucursals.each do |sucursal|
      	sucursalActual = Hash.new
      	sucursalActual[:nombre] = sucursal.nombre
      	sucursalActual[:gastos_del_mes] = sucursal.gastos.where(created_at: Date.today.beginning_of_month.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)
      	sucursalActual[:gastos_del_dia] = sucursal.gastos.where(created_at: Date.today.beginning_of_day.to_datetime..Date.today.to_datetime.end_of_day).sum(:monto)

        @sucursales["sucursal#{i}"] = sucursalActual
        i += 1
      end
  	end

  	if request.post?
  	end

  end
end
