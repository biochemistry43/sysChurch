class CreateCajaSucursals < ActiveRecord::Migration
  def change
    create_table :caja_sucursals do |t|
      t.integer :numero_caja
      t.string :nombre
      t.integer :sucursal_id

      t.timestamps null: false
    end
  end
end
