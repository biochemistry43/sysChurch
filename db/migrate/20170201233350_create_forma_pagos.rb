class CreateFormaPagos < ActiveRecord::Migration
  def change
    create_table :forma_pagos do |t|
      t.string :nombre
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
