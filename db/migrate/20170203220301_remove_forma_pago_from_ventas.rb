class RemoveFormaPagoFromVentas < ActiveRecord::Migration
  def change
    remove_column :ventas, :formaPago, :string
  end
end
