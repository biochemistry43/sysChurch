class AddStatusToVenta < ActiveRecord::Migration
  def change
    add_column :ventas, :status, :string
    add_column :ventas, :observaciones, :text
  end
end
