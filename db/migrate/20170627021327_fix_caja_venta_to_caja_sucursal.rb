class FixCajaVentaToCajaSucursal < ActiveRecord::Migration
  def change
  	rename_column :gastos, :caja_venta_id, :caja_sucursal_id
  end
end
