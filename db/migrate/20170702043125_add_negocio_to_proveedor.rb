class AddNegocioToProveedor < ActiveRecord::Migration
  def change
    add_column :proveedores, :negocio_id, :integer
  end
end
