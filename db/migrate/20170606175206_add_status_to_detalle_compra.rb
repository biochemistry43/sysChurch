class AddStatusToDetalleCompra < ActiveRecord::Migration
  def change
    add_column :detalle_compras, :status, :string
  end
end
