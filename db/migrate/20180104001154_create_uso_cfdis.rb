class CreateUsoCfdis < ActiveRecord::Migration
  def change
    create_table :uso_cfdis do |t|
      t.string :clave
      t.text :descripcion

      t.timestamps null: false
    end
  end
end
