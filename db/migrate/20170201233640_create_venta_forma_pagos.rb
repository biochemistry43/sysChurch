class CreateVentaFormaPagos < ActiveRecord::Migration
  def change
    create_table :venta_forma_pagos do |t|
      t.integer :venta_id
      t.integer :forma_pago_id

      t.timestamps null: false
    end
  end
end
