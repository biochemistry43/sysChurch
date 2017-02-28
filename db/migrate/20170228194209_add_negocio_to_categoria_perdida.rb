class AddNegocioToCategoriaPerdida < ActiveRecord::Migration
  def change
    add_column :categoria_perdidas, :negocio_id, :integer
  end
end
