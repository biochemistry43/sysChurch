class CreateCajaVentas < ActiveRecord::Migration
  def change
    create_table :caja_ventas do |t|
      t.decimal :entrada
      t.decimal :salida
      t.decimal :saldo
      t.integer :venta_id
      t.integer :user_id
      t.integer :sucursal_id
      t.integer :negocio_id

      t.timestamps null: false
    end
  end
end
