class AddFormaPagoToVenta < ActiveRecord::Migration
  def change
    add_column :ventas, :formaPago, :string
  end
end
