class RenameManyColumns < ActiveRecord::Migration
  def change
  	rename_column :categoria_gastos, :nombreCategoria, :nombre_categoria
  end
end
