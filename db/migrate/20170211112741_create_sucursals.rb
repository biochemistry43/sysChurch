class CreateSucursals < ActiveRecord::Migration
  def change
    create_table :sucursals do |t|
      t.string :nombre
      t.string :representante
      t.string :direccion
      t.integer :negocio_id

      t.timestamps null: false
    end
  end
end
