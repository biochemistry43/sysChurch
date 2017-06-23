class AddNumCajaToCajaVenta < ActiveRecord::Migration
  def change
    add_column :caja_ventas, :numero_caja, :integer
  end
end
