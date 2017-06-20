class CreateCajaChicas < ActiveRecord::Migration
  def change
    create_table :caja_chicas do |t|
      t.decimal :monto_movimiento
      t.decimal :saldo
      t.string :concepto
      t.integer :user_id
      t.integer :sucursal_id
      t.integer :negocio_id

      t.timestamps null: false
    end
  end
end
