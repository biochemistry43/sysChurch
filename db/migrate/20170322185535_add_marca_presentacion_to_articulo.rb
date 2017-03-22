class AddMarcaPresentacionToArticulo < ActiveRecord::Migration
  def change
    add_column :articulos, :marca_producto_id, :integer
    add_column :articulos, :presentacion_producto_id, :integer
  end
end
