class CreateNegocios < ActiveRecord::Migration
  def change
    create_table :negocios do |t|
      t.string :logo
      t.string :nombre
      t.string :representante
      t.string :direccion
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
