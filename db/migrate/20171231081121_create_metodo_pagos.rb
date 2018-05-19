class CreateMetodoPagos < ActiveRecord::Migration
  def change
    create_table :metodo_pagos do |t|
      t.string :clave
      t.string :descripcion

      t.timestamps null: false
    end
  end
end
