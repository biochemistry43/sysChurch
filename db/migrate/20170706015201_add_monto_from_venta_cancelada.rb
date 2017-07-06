class AddMontoFromVentaCancelada < ActiveRecord::Migration
  def change
    add_column :venta_canceladas, :monto, :decimal
  end
end
