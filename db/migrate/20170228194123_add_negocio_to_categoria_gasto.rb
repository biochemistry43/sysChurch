class AddNegocioToCategoriaGasto < ActiveRecord::Migration
  def change
    add_column :categoria_gastos, :negocio_id, :integer
  end
end
