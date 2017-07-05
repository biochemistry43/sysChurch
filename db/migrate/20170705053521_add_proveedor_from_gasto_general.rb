class AddProveedorFromGastoGeneral < ActiveRecord::Migration
  def change
    add_column :gasto_generals, :proveedor_id, :integer
  end
end
