class AddPagoPendienteToPagoProveedor < ActiveRecord::Migration
  def change
    add_column :pago_proveedores, :pago_pendiente_id, :integer
  end
end
