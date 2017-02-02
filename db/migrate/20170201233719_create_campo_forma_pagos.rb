class CreateCampoFormaPagos < ActiveRecord::Migration
  def change
    create_table :campo_forma_pagos do |t|
      t.integer :forma_pago_id

      t.timestamps null: false
    end
  end
end
