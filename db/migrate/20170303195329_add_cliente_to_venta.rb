class AddClienteToVenta < ActiveRecord::Migration
  def change
    add_column :ventas, :cliente_id, :integer
  end
end
