class CreateCompraCanceladas < ActiveRecord::Migration
  def change
    create_table :compra_canceladas do |t|
      t.integer :compra_id
      t.integer :cat_compra_cancelada_id
      t.integer :user_id
      t.string :observaciones

      t.timestamps null: false
    end
  end
end
