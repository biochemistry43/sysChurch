class AddColumnsToArticulo < ActiveRecord::Migration
  def change
    add_column :articulos, :precioCompra, :decimal
    add_column :articulos, :precioVenta, :decimal
  end
end
