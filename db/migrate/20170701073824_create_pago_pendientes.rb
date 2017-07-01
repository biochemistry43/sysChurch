class CreatePagoPendientes < ActiveRecord::Migration
  def change
    create_table :pago_pendientes do |t|
      t.date :fecha_vencimiento
      t.decimal :saldo
      t.integer :compra_id
      t.integer :proveedor_id
      t.integer :sucursal_id
      t.integer :negocio_id

      t.timestamps null: false
    end
  end
end
