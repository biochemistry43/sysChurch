class CreatePerfils < ActiveRecord::Migration
  def change
    create_table :perfils do |t|
      t.string :nombre
      t.string :ape_materno
      t.string :ape_paterno
      t.string :dir_calle
      t.string :dir_numero_ext
      t.string :dir_numero_int
      t.string :dir_colonia
      t.string :dir_municipio
      t.string :dir_delegacion
      t.string :dir_estado
      t.string :dir_cp
      t.string :foto
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
