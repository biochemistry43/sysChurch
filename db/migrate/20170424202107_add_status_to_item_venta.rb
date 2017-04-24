class AddStatusToItemVenta < ActiveRecord::Migration
  def change
    add_column :item_ventas, :status, :string
  end
end
