class AddNegocioToCatArticulo < ActiveRecord::Migration
  def change
    add_column :cat_articulos, :negocio_id, :integer
  end
end
