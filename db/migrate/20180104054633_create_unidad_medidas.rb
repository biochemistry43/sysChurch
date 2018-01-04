class CreateUnidadMedidas < ActiveRecord::Migration
  def change
    create_table :unidad_medidas do |t|
      t.string :clave
      t.string :nombre
      t.text :descripcion
      t.string :simbolo

      t.timestamps null: false
    end
  end
end
