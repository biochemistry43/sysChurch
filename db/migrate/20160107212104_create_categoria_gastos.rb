class CreateCategoriaGastos < ActiveRecord::Migration
  def change
    create_table :categoria_gastos do |t|
      t.string :nombreCategoria
      t.string :descripcionCategoria
      t.integer :idCategoriaPadre

      t.timestamps null: false
    end
  end
end
