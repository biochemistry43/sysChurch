class CreateTelefonoPersonas < ActiveRecord::Migration
  def change
    create_table :telefono_personas do |t|
      t.string :telefono
      t.string :persona_id

      t.timestamps null: false
    end
  end
end
