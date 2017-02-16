class CreateClientes < ActiveRecord::Migration
  def change
    create_table :clientes do |t|
      t.string :nombre
      t.string :direccionCalle
      t.string :direccionNumeroExt
      t.string :direccionNumeroInt
      t.string :direccionColonia
      t.string :direccionMunicipio
      t.string :direccionDelegacion
      t.string :direccionEstado
      t.string :direccionCp
      t.string :foto
      t.string :telefono1
      t.string :telefono2
      t.string :email
      t.integer :negocio_id

      t.timestamps null: false
    end
  end
end
