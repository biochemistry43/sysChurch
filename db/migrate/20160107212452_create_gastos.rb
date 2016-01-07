class CreateGastos < ActiveRecord::Migration
  def change
    create_table :gastos do |t|
      t.float :montoGasto
      t.date :fechaGasto
      t.string :descripcionGasto
      t.string :lugarCompraGasto
      t.integer :persona_id
      t.integer :categoria_gasto_id

      t.timestamps null: false
    end
  end
end
