class DropNumeroCajaMovimientoCajaSucursal < ActiveRecord::Migration
  def change
  	remove_column :movimientos_caja_sucursal, :numero_caja, :integer
  end
end
