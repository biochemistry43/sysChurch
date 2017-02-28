class AddSucursalToVenta < ActiveRecord::Migration
  def change
    add_column :ventas, :sucursal_id, :integer
  end
end
