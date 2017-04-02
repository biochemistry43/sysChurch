class AddNegocioSucursalToCompra < ActiveRecord::Migration
  def change
  	add_column :compras, :sucursal_id, :integer
  	add_column :compras, :negocio_id, :integer
  end
end
