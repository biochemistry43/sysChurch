class CreateClaveProdServs < ActiveRecord::Migration
  def change
    create_table :clave_prod_servs do |t|
      t.integer :clave
      t.string :nombre

      t.timestamps null: false
    end
  end
end
