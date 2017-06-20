class CreateGastoCorrientes < ActiveRecord::Migration
  def change
    create_table :gasto_corrientes do |t|
      t.decimal :monto
      t.string :concepto
      t.integer :gasto_id
      t.integer :user_id
      t.integer :sucursal_id
      t.integer :negocio_id

      t.timestamps null: false
    end
  end
end
