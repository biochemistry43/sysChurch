class AddStatusToCompra < ActiveRecord::Migration
  def change
    add_column :compras, :status, :string
  end
end
