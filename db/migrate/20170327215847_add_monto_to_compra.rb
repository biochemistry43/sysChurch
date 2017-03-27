class AddMontoToCompra < ActiveRecord::Migration
  def change
    add_column :compras, :monto_compra, :decimal
  end
end
