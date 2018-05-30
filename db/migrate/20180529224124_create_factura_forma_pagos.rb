class CreateFacturaFormaPagos < ActiveRecord::Migration
  def change
    create_table :factura_forma_pagos do |t|
      t.string :cve_forma_pagoSAT
      t.string :nombre_forma_pagoSAT

      t.timestamps null: false
    end
  end
end
