class AddStatusPagoToPagoProveedor < ActiveRecord::Migration
  def change
    add_column :pago_proveedores, :statusPago, :string
  end
end
