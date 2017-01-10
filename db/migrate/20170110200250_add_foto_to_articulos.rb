class AddFotoToArticulos < ActiveRecord::Migration
  def change
    add_column :articulos, :fotoProducto, :string
  end
end
