class CreatePersonas < ActiveRecord::Migration
  def change
    create_table :personas do |t|
      t.string :nombre
      t.string :telefono1
      t.string :telefono2
      t.string :email
      t.string :direccion
      t.string :cargo

      t.timestamps null: false
    end
  end
end
