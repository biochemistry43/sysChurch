class CreateCampoFormaPagoItems < ActiveRecord::Migration
  def change
    create_table :campo_forma_pago_items do |t|
      t.integer :campo_forma_pago_id
      t.string :valor_item

      t.timestamps null: false
    end
  end
end
