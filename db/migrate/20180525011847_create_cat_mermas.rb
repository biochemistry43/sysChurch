class CreateCatMermas < ActiveRecord::Migration
  def change
    create_table :cat_mermas do |t|
      t.string :categoria
      t.string :descripcion

      t.timestamps null: false
    end
  end
end
