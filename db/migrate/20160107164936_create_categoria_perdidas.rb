class CreateCategoriaPerdidas < ActiveRecord::Migration
  def change
    create_table :categoria_perdidas do |t|
      t.string :nombreCatPerdida
      t.string :descripcionCatPerdida
      t.integer :idCategoriaPadre

      t.timestamps null: false
    end
  end
end
