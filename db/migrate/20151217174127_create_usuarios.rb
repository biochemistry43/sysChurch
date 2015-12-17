class CreateUsuarios < ActiveRecord::Migration
  def change
    create_table :usuarios do |t|
      t.string :nombreUsuario
      t.string :contrasena
      t.integer :persona_id
      t.integer :tipoUsuario_id

      t.timestamps null: false
    end
  end
end
