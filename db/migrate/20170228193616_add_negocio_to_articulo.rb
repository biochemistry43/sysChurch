class AddNegocioToArticulo < ActiveRecord::Migration
  def change
    add_column :articulos, :negocio_id, :integer
    add_column :articulos, :sucursal_id, :integer
  end
end
