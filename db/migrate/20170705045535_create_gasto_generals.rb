class CreateGastoGenerals < ActiveRecord::Migration
  def change
    create_table :gasto_generals do |t|
      t.string :folio_gasto
      t.string :ticket_gasto
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
