class RenameCajaIdToCajaSucursalIdInVenta < ActiveRecord::Migration
  def change
  	rename_column :ventas, :caja_id, :caja_sucursal_id
  end
end
