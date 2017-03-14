class AddCatArticuloToCatArticulo < ActiveRecord::Migration
  def change
    add_column :cat_articulos, :cat_articulo_id, :integer
  end
end
