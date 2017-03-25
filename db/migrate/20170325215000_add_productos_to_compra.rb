class AddProductosToCompra < ActiveRecord::Migration
  def change
    add_column :compras, :articulos, :text
  end
end
