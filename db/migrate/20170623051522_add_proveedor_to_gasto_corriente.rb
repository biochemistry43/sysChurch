class AddProveedorToGastoCorriente < ActiveRecord::Migration
  def change
    add_column :gasto_corrientes, :proveedor_id, :integer
  end
end
