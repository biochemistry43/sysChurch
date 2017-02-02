class CreateVentaFormaPagoCampos < ActiveRecord::Migration
  def change
    create_table :venta_forma_pago_campos do |t|
      t.integer :venta_forma_pago_id
      t.integer :campo_forma_pago_id
      t.string :ValorCampo

      t.timestamps null: false
    end
  end
end
