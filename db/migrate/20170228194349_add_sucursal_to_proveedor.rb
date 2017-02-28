class AddSucursalToProveedor < ActiveRecord::Migration
  def change
    add_column :proveedores, :sucursal_id, :integer
  end
end
