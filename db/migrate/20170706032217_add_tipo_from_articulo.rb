class AddTipoFromArticulo < ActiveRecord::Migration
  def change
    add_column :articulos, :tipo, :string
  end
end
