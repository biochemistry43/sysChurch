class AddGastoToCompra < ActiveRecord::Migration
  def change
    add_column :compras, :gasto_id, :integer
  end
end
