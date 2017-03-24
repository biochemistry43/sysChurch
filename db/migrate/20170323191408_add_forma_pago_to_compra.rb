class AddFormaPagoToCompra < ActiveRecord::Migration
  def change
    add_column :compras, :forma_pago, :string
  end
end
