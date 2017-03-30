class AddNomSucursalToArticulo < ActiveRecord::Migration
  def change
    add_column :articulos, :sucursal, :string
  end
end
