class CreateCompras < ActiveRecord::Migration
  def change
    create_table :compras do |t|
      t.date :fecha
      t.string :tipo_pago
      t.string :plazo_pago
      t.string :folio_compra
      t.integer :proveedor_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
