class AddCajaSucursalToCajaVenta < ActiveRecord::Migration
  def change
    add_column :caja_ventas, :caja_sucursal_id, :integer
  end
end
