class CreatePagoDevolucions < ActiveRecord::Migration
  def change
    create_table :pago_devolucions do |t|
      t.decimal :monto
      t.integer :venta_cancelada_id
      t.integer :gasto_id
      t.integer :user_id
      t.integer :sucursal_id
      t.integer :negocio_id

      t.timestamps null: false
    end
  end
end
