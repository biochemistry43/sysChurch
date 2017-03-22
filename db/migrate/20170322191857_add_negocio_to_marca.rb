class AddNegocioToMarca < ActiveRecord::Migration
  def change
    add_column :marca_productos, :negocio_id, :integer
  end
end
