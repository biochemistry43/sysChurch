class CreateGastos < ActiveRecord::Migration
  def change
    create_table :gastos do |t|
      t.decimal :monto
      t.string :concepto
      t.string :tipo
      t.integer :categoria_gasto_id
      t.integer :caja_chica_id
      t.integer :caja_venta_id
      t.integer :user_id
      t.integer :sucursal_id
      t.integer :negocio_id

      t.timestamps null: false
    end
  end
end
